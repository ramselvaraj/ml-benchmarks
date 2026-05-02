// attention_int8.cpp — fused INT8 × INT8 attention kernel (W8A8), FlashAttention-style
// online softmax. Targets AMD Alveo U280 (xcu280) via Vitis HLS 2023.2+.
//
// Structure (from attention_top.h, in order of outer → inner loop):
//     for each query head h_q
//       for each query block qb (of BQ rows)
//         load Q_tile[BQ][D] from HBM
//         init online softmax state m, l, O_tile
//         for each kv block kb (of BK rows), causal-gated on kb <= qb+BQ
//           load K_tile[BK][D], V_tile[BK][D] from HBM
//           scores = Q_tile @ K_tile^T  (INT8 × INT8 → INT32)
//           dequantize + causal-mask + online softmax update of (m, l, O_tile)
//           accumulate O_tile += P @ V  (P quantized per-row back to INT8)
//         normalize O_tile /= l, cast to FP16, write back to HBM
//
// Every numerical cast is documented. See ARCHITECTURE.md §4.

#include "attention_top.h"
#include <hls_math.h>
#include <hls_half.h>

// -----------------------------------------------------------------------------
// Small helpers
// -----------------------------------------------------------------------------

// Approximate expf via a 64-entry LUT + linear interpolation. HLS's built-in
// hls::expf is accurate but maps to a much larger area. For softmax we only
// need ~3-4 decimal digits of precision because the denominator averages
// out most error. The LUT spans exp(x) for x ∈ [-10, 0]; arguments outside
// this range are clamped (fine for causal-masked softmax after max-subtraction).
static float fast_expf(float x) {
    #pragma HLS INLINE
    if (x < -10.0f) return 0.0f;
    if (x > 0.0f)   x = 0.0f;       // softmax inputs are always <= 0 after max-sub
    // Clamp x ∈ [-10, 0] onto 64 LUT entries
    const float step = 10.0f / 64.0f;
    int idx = (int)((-x) / step);   // 0 .. 63
    if (idx > 63) idx = 63;
    static const float lut[65] = {
        1.000000f, 0.855951f, 0.732611f, 0.627058f, 0.536782f, 0.459410f,
        0.393181f, 0.336504f, 0.288073f, 0.246597f, 0.211100f, 0.180715f,
        0.154701f, 0.132428f, 0.113361f, 0.097041f, 0.083083f, 0.071136f,
        0.060910f, 0.052149f, 0.044648f, 0.038228f, 0.032726f, 0.028016f,
        0.023986f, 0.020535f, 0.017580f, 0.015050f, 0.012884f, 0.011029f,
        0.009441f, 0.008082f, 0.006920f, 0.005924f, 0.005072f, 0.004342f,
        0.003717f, 0.003183f, 0.002725f, 0.002333f, 0.001997f, 0.001710f,
        0.001464f, 0.001253f, 0.001073f, 0.000918f, 0.000786f, 0.000673f,
        0.000576f, 0.000493f, 0.000422f, 0.000361f, 0.000309f, 0.000265f,
        0.000227f, 0.000194f, 0.000166f, 0.000142f, 0.000122f, 0.000104f,
        0.000089f, 0.000076f, 0.000065f, 0.000056f, 0.000048f
    };
    // Linear interpolation between lut[idx] and lut[idx+1]
    float frac = ((-x) / step) - (float)idx;
    return lut[idx] * (1.0f - frac) + lut[idx + 1] * frac;
}


// -----------------------------------------------------------------------------
// Top-level kernel
// -----------------------------------------------------------------------------

extern "C" void attention_int8_kernel(
    const q_t * Q_in,
    const k_t * K_in,
    const v_t * V_in,
    out_t     * O_out,
    float       q_scale,
    float       v_scale)
{
    // Separate AXI master bundles → HBM pseudo-channel parallelism.
    #pragma HLS INTERFACE m_axi port=Q_in  offset=slave bundle=gmem_q \
            depth=(NUM_Q_HEADS*SEQ_LEN*HEAD_DIM)  max_read_burst_length=64
    #pragma HLS INTERFACE m_axi port=K_in  offset=slave bundle=gmem_k \
            depth=(NUM_KV_HEADS*SEQ_LEN*HEAD_DIM) max_read_burst_length=64
    #pragma HLS INTERFACE m_axi port=V_in  offset=slave bundle=gmem_v \
            depth=(NUM_KV_HEADS*SEQ_LEN*HEAD_DIM) max_read_burst_length=64
    #pragma HLS INTERFACE m_axi port=O_out offset=slave bundle=gmem_o \
            depth=(NUM_Q_HEADS*SEQ_LEN*HEAD_DIM)  max_write_burst_length=64
    #pragma HLS INTERFACE s_axilite port=q_scale bundle=control
    #pragma HLS INTERFACE s_axilite port=v_scale bundle=control
    #pragma HLS INTERFACE s_axilite port=return  bundle=control

    // -------------------------------------------------------------------------
    // Iterate over query heads (outer serialization — one head at a time).
    // -------------------------------------------------------------------------

    for (int h_q = 0; h_q < NUM_Q_HEADS; ++h_q) {
        const int h_kv = h_q / Q_PER_KV;    // GQA/MQA grouping

        // Pointers into each head's slab
        const q_t *Qh = Q_in  + h_q  * SEQ_LEN * HEAD_DIM;
        const k_t *Kh = K_in  + h_kv * SEQ_LEN * HEAD_DIM;
        const v_t *Vh = V_in  + h_kv * SEQ_LEN * HEAD_DIM;
        out_t     *Oh = O_out + h_q  * SEQ_LEN * HEAD_DIM;

        // ---------------------------------------------------------------------
        // For each query block of BQ rows.
        // ---------------------------------------------------------------------

        for (int qb = 0; qb < SEQ_LEN; qb += BQ) {

            // On-chip buffers. cyclic partition on D allows parallel MAC.
            q_t Q_tile[BQ][HEAD_DIM];
            #pragma HLS ARRAY_PARTITION variable=Q_tile dim=2 cyclic factor=16

            float O_tile[BQ][HEAD_DIM];
            #pragma HLS ARRAY_PARTITION variable=O_tile dim=2 cyclic factor=16

            float m_state[BQ];
            float l_state[BQ];
            #pragma HLS ARRAY_PARTITION variable=m_state complete
            #pragma HLS ARRAY_PARTITION variable=l_state complete

            // --- Load Q_tile ---
            load_q: for (int i = 0; i < BQ; ++i) {
                for (int d = 0; d < HEAD_DIM; ++d) {
                    #pragma HLS PIPELINE II=1
                    Q_tile[i][d] = Qh[(qb + i) * HEAD_DIM + d];
                }
            }

            // --- Init online softmax state ---
            init_state: for (int i = 0; i < BQ; ++i) {
                #pragma HLS PIPELINE II=1
                m_state[i] = -1.0e30f;
                l_state[i] = 0.0f;
                for (int d = 0; d < HEAD_DIM; ++d) {
                    #pragma HLS UNROLL
                    O_tile[i][d] = 0.0f;
                }
            }

            // -----------------------------------------------------------------
            // Stream K, V blocks. Causal gate: skip blocks entirely to the
            // right of this Q block.
            // -----------------------------------------------------------------

            for (int kb = 0; kb < SEQ_LEN; kb += BK) {

                // If the entire KV block is in the "future" of every query
                // in this Q block, skip it (causal mask).
                if (kb > qb + BQ - 1) break;

                k_t K_tile[BK][HEAD_DIM];
                v_t V_tile[BK][HEAD_DIM];
                #pragma HLS ARRAY_PARTITION variable=K_tile dim=2 cyclic factor=16
                #pragma HLS ARRAY_PARTITION variable=V_tile dim=2 cyclic factor=16

                // --- Load K and V tiles (parallel — separate AXI bundles) ---
                load_kv: for (int j = 0; j < BK; ++j) {
                    for (int d = 0; d < HEAD_DIM; ++d) {
                        #pragma HLS PIPELINE II=1
                        K_tile[j][d] = Kh[(kb + j) * HEAD_DIM + d];
                        V_tile[j][d] = Vh[(kb + j) * HEAD_DIM + d];
                    }
                }

                // --- Compute scores = Q_tile @ K_tile^T (INT8 × INT8 → INT32)
                //     then dequantize, mask, and find per-row max.
                // -----------------------------------------------------------

                float scores[BQ][BK];
                float row_max[BQ];
                #pragma HLS ARRAY_PARTITION variable=scores dim=2 cyclic factor=16
                #pragma HLS ARRAY_PARTITION variable=row_max complete

                compute_scores: for (int i = 0; i < BQ; ++i) {
                    float rmax = -1.0e30f;
                    for (int j = 0; j < BK; ++j) {
                        #pragma HLS PIPELINE II=1

                        // Integer MAC — this is where DSP48E2 usage concentrates.
                        acc_t acc = 0;
                        for (int d = 0; d < HEAD_DIM; ++d) {
                            #pragma HLS UNROLL
                            acc += (acc_t)Q_tile[i][d] * (acc_t)K_tile[j][d];
                        }
                        float s = (float)acc * q_scale;

                        // Causal mask: j (column in KV block) corresponds to
                        // absolute KV index (kb + j); i corresponds to (qb + i).
                        if ((kb + j) > (qb + i)) s = -1.0e30f;

                        scores[i][j] = s;
                        if (s > rmax) rmax = s;
                    }
                    row_max[i] = rmax;
                }

                // --- Online softmax update per query row ------------------

                for (int i = 0; i < BQ; ++i) {
                    #pragma HLS PIPELINE II=1

                    // New m: max of previous m and this block's row_max.
                    const float m_new = (row_max[i] > m_state[i])
                                        ? row_max[i] : m_state[i];

                    // Rescale factor for old accumulators.
                    const float rescale_old = fast_expf(m_state[i] - m_new);

                    // Exponentiate scores and accumulate into l_new (denom).
                    float l_new = 0.0f;
                    float P_row[BK];
                    for (int j = 0; j < BK; ++j) {
                        #pragma HLS UNROLL factor=8
                        float p = fast_expf(scores[i][j] - m_new);
                        P_row[j] = p;
                        l_new += p;
                    }

                    // Combined denominator
                    l_state[i] = l_state[i] * rescale_old + l_new;

                    // --- O_tile += P_row @ V_tile, plus rescale of prior O --
                    //
                    // We stay in FP for this small matmul (BQ*BK*D ≈ 500K
                    // FP-mults is cheap compared to the INT8 block above).
                    // A proper W8A8 impl would re-quantize P_row to INT8 per
                    // row and do INT8 × INT8 on the DSPs — worth doing as an
                    // optimization once the FP version is correct.

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

            // -----------------------------------------------------------------
            // Normalize and write back (cast FP32 → FP16 via hls::half).
            // -----------------------------------------------------------------

            write_out: for (int i = 0; i < BQ; ++i) {
                const float inv_l = (l_state[i] > 0.0f) ? (1.0f / l_state[i]) : 0.0f;
                for (int d = 0; d < HEAD_DIM; ++d) {
                    #pragma HLS PIPELINE II=1
                    float   v    = O_tile[i][d] * inv_l;
                    half    h    = (half)v;
                    out_t   bits = *reinterpret_cast<const out_t*>(&h);
                    Oh[(qb + i) * HEAD_DIM + d] = bits;
                }
            }
        } // qb
    } // h_q
}
