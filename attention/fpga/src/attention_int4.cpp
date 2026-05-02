// attention_int4.cpp — W4A4 variant of attention_int8.cpp.
//
// Structural differences from the INT8 kernel:
//   - q_t / k_t / v_t are ap_int<4>  (stored packed 2-per-byte in HBM)
//   - unpack routines read uint8 from HBM and split into two ap_int<4>
//   - DSP packing factor doubles: target 4 INT4 MACs per DSP48E2 (WP487)
//   - everything else (softmax, causal mask, dataflow) is identical
//
// For brevity, the body of this file is a minimal translation of the INT8
// kernel with type renames and an unpack-on-load helper. Once the INT8 kernel
// is verified and the friend is comfortable with it, port this in parallel.
//
// The structural reason W4A4 on FPGA matters: unlike the GPU INT4 path which
// is actually W4A8 (real INT8 compute, INT4 storage), the FPGA does
// genuine INT4 × INT4 → INT32 MMA. The accumulator still fits in INT32 because
// 128 (head_dim) × 7 × 7 ≤ 6272 << 2³¹.

#include "attention_top.h"
#include <hls_math.h>
#include <hls_half.h>

// INT4 types override the INT8 defaults from attention_top.h.
using i4_t = ap_int<4>;
using u8_t = ap_uint<8>;

// -----------------------------------------------------------------------------
// Unpack helper: one uint8 from HBM → two signed INT4 values.
// Layout: low nibble (bits 0..3) is the first element, high nibble is the
// second. This matches scripts/quantize_weights.py's "low_nibble_first"
// packing, which the dump_testvectors.py script also follows.
// -----------------------------------------------------------------------------

static inline void unpack_two_int4(u8_t byte, i4_t &lo, i4_t &hi) {
    #pragma HLS INLINE
    ap_uint<4> lo_u = byte.range(3, 0);
    ap_uint<4> hi_u = byte.range(7, 4);
    // Sign-extend 4-bit two's-complement to ap_int<4>
    lo = (ap_int<4>)lo_u;
    hi = (ap_int<4>)hi_u;
}

// -----------------------------------------------------------------------------
// Reuse the fast_expf LUT from attention_int8.cpp — define it 'static inline'
// there, or copy the 64-entry table here. For brevity this file assumes a
// linker-visible definition; easiest path is to move fast_expf into a
// shared header (e.g. src/fast_expf.h) and include from both kernels.
// -----------------------------------------------------------------------------

extern float fast_expf(float x);    // defined once in attention_int8.cpp

// -----------------------------------------------------------------------------
// Top-level W4A4 kernel. Shape-equivalent to the INT8 kernel; the user-facing
// argument difference is that the input pointers are uint8 (2× narrower than
// the INT8 version because two INT4 values are packed per byte).
// -----------------------------------------------------------------------------

extern "C" void attention_int4_kernel(
    const u8_t * Q_in_packed,   // [H_q,  S, D/2] packed INT4
    const u8_t * K_in_packed,   // [H_kv, S, D/2] packed INT4
    const u8_t * V_in_packed,   // [H_kv, S, D/2] packed INT4
    out_t      * O_out,         // [H_q,  S, D]   FP16 bit-packed
    float        q_scale,
    float        v_scale)
{
    #pragma HLS INTERFACE m_axi port=Q_in_packed offset=slave bundle=gmem_q \
            depth=(NUM_Q_HEADS*SEQ_LEN*HEAD_DIM/2)
    #pragma HLS INTERFACE m_axi port=K_in_packed offset=slave bundle=gmem_k \
            depth=(NUM_KV_HEADS*SEQ_LEN*HEAD_DIM/2)
    #pragma HLS INTERFACE m_axi port=V_in_packed offset=slave bundle=gmem_v \
            depth=(NUM_KV_HEADS*SEQ_LEN*HEAD_DIM/2)
    #pragma HLS INTERFACE m_axi port=O_out offset=slave bundle=gmem_o \
            depth=(NUM_Q_HEADS*SEQ_LEN*HEAD_DIM)
    #pragma HLS INTERFACE s_axilite port=q_scale bundle=control
    #pragma HLS INTERFACE s_axilite port=v_scale bundle=control
    #pragma HLS INTERFACE s_axilite port=return  bundle=control

    for (int h_q = 0; h_q < NUM_Q_HEADS; ++h_q) {
        const int h_kv = h_q / Q_PER_KV;

        const u8_t *Qh = Q_in_packed + h_q  * SEQ_LEN * (HEAD_DIM / 2);
        const u8_t *Kh = K_in_packed + h_kv * SEQ_LEN * (HEAD_DIM / 2);
        const u8_t *Vh = V_in_packed + h_kv * SEQ_LEN * (HEAD_DIM / 2);
        out_t      *Oh = O_out        + h_q  * SEQ_LEN *  HEAD_DIM;

        for (int qb = 0; qb < SEQ_LEN; qb += BQ) {

            // Unpack Q into on-chip BRAM once per Q block.
            i4_t Q_tile[BQ][HEAD_DIM];
            #pragma HLS ARRAY_PARTITION variable=Q_tile dim=2 cyclic factor=16

            load_q_unpack: for (int i = 0; i < BQ; ++i) {
                for (int d = 0; d < HEAD_DIM; d += 2) {
                    #pragma HLS PIPELINE II=1
                    u8_t byte = Qh[(qb + i) * (HEAD_DIM / 2) + (d / 2)];
                    i4_t lo, hi;
                    unpack_two_int4(byte, lo, hi);
                    Q_tile[i][d]     = lo;
                    Q_tile[i][d + 1] = hi;
                }
            }

            float O_tile[BQ][HEAD_DIM];
            float m_state[BQ];
            float l_state[BQ];
            #pragma HLS ARRAY_PARTITION variable=O_tile dim=2 cyclic factor=16
            #pragma HLS ARRAY_PARTITION variable=m_state complete
            #pragma HLS ARRAY_PARTITION variable=l_state complete

            init_state: for (int i = 0; i < BQ; ++i) {
                #pragma HLS PIPELINE II=1
                m_state[i] = -1.0e30f;
                l_state[i] = 0.0f;
                for (int d = 0; d < HEAD_DIM; ++d) {
                    #pragma HLS UNROLL
                    O_tile[i][d] = 0.0f;
                }
            }

            for (int kb = 0; kb < SEQ_LEN; kb += BK) {
                if (kb > qb + BQ - 1) break;    // causal skip

                i4_t K_tile[BK][HEAD_DIM];
                i4_t V_tile[BK][HEAD_DIM];
                #pragma HLS ARRAY_PARTITION variable=K_tile dim=2 cyclic factor=16
                #pragma HLS ARRAY_PARTITION variable=V_tile dim=2 cyclic factor=16

                load_kv_unpack: for (int j = 0; j < BK; ++j) {
                    for (int d = 0; d < HEAD_DIM; d += 2) {
                        #pragma HLS PIPELINE II=1
                        u8_t kb_byte = Kh[(kb + j) * (HEAD_DIM / 2) + (d / 2)];
                        u8_t vb_byte = Vh[(kb + j) * (HEAD_DIM / 2) + (d / 2)];
                        i4_t k_lo, k_hi, v_lo, v_hi;
                        unpack_two_int4(kb_byte, k_lo, k_hi);
                        unpack_two_int4(vb_byte, v_lo, v_hi);
                        K_tile[j][d]     = k_lo;  K_tile[j][d + 1] = k_hi;
                        V_tile[j][d]     = v_lo;  V_tile[j][d + 1] = v_hi;
                    }
                }

                // --- Scores: INT4 × INT4 → INT32 ---
                float scores[BQ][BK];
                float row_max[BQ];
                #pragma HLS ARRAY_PARTITION variable=scores dim=2 cyclic factor=16
                #pragma HLS ARRAY_PARTITION variable=row_max complete

                compute_scores: for (int i = 0; i < BQ; ++i) {
                    float rmax = -1.0e30f;
                    for (int j = 0; j < BK; ++j) {
                        #pragma HLS PIPELINE II=1
                        acc_t acc = 0;
                        for (int d = 0; d < HEAD_DIM; ++d) {
                            #pragma HLS UNROLL
                            // INT4 × INT4 → INT32. Extend both to 32-bit before
                            // multiply so HLS allocates a wide enough DSP path.
                            acc += (acc_t)Q_tile[i][d] * (acc_t)K_tile[j][d];
                        }
                        float s = (float)acc * q_scale;
                        if ((kb + j) > (qb + i)) s = -1.0e30f;
                        scores[i][j] = s;
                        if (s > rmax) rmax = s;
                    }
                    row_max[i] = rmax;
                }

                // --- Online softmax update + PV accumulate (identical to INT8) ---
                for (int i = 0; i < BQ; ++i) {
                    #pragma HLS PIPELINE II=1
                    const float m_new       = (row_max[i] > m_state[i]) ? row_max[i] : m_state[i];
                    const float rescale_old = fast_expf(m_state[i] - m_new);

                    float l_new = 0.0f;
                    float P_row[BK];
                    for (int j = 0; j < BK; ++j) {
                        #pragma HLS UNROLL factor=8
                        float p = fast_expf(scores[i][j] - m_new);
                        P_row[j] = p;
                        l_new += p;
                    }
                    l_state[i] = l_state[i] * rescale_old + l_new;

                    for (int d = 0; d < HEAD_DIM; ++d) {
                        #pragma HLS UNROLL factor=16
                        float pv = 0.0f;
                        for (int j = 0; j < BK; ++j) {
                            pv += P_row[j] * ((float)V_tile[j][d] * v_scale);
                        }
                        O_tile[i][d] = O_tile[i][d] * rescale_old + pv;
                    }
                    m_state[i] = m_new;
                }
            } // kb

            write_out: for (int i = 0; i < BQ; ++i) {
                const float inv_l = (l_state[i] > 0.0f) ? (1.0f / l_state[i]) : 0.0f;
                for (int d = 0; d < HEAD_DIM; ++d) {
                    #pragma HLS PIPELINE II=1
                    float v_raw = O_tile[i][d] * inv_l;
                    half  h     = (half)v_raw;
                    out_t bits  = *reinterpret_cast<const out_t*>(&h);
                    Oh[(qb + i) * HEAD_DIM + d] = bits;
                }
            }
        } // qb
    } // h_q
}
