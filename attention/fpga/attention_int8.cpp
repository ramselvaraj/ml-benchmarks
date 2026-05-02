// attention_int8.cpp — fused INT8 × INT8 attention kernel (W8A8).
//
// SIMPLE CLEANUP based on v3.
//
// What changed vs v3:
//   1. REMOVED `#pragma HLS ARRAY_PARTITION variable=V_tile cyclic factor=4 dim=1`
//      That pragma is what made HLS promote V_tile to ROM and burn 512 BRAMs.
//      Without it, V_tile stays as RAM and BRAM usage drops back to single digits.
//   2. REMOVED `#pragma HLS BIND_STORAGE variable=lut type=rom_np impl=lutram`
//      This was being silently rejected ("Unsupported scalar variable"), so it
//      was doing nothing anyway. Cleaner to drop it.
//   3. KEPT the ALLOCATION pragmas (instances=fmul limit=64, fadd limit=32).
//      These genuinely reduced PV-loop DSP from 510 to 442 in v3 — keep them.
//   4. KEPT the V_tile cyclic factor=8 dim=2 partition (matches d-axis access).
//
// Expected vs v3:
//   - BRAM: 70%  → ~5%
//   - LUT:  59%  → similar (~60%)
//   - DSP:  78%  → similar
//   - Latency: 743M cycles → similar
//   - Softmax II=2 still — that's not fixable without restructuring.
//
// Compile time should be similar to v3 (~80s). No DATAFLOW, no struct streams.

#include "attention_top.h"
#include <hls_math.h>
#include <hls_half.h>


static float fast_expf(float x) {
    #pragma HLS INLINE
    if (x < -10.0f) return 0.0f;
    if (x > 0.0f)   x = 0.0f;
    const float step = 10.0f / 64.0f;
    int idx = (int)((-x) / step);
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
    #pragma HLS ARRAY_PARTITION variable=lut complete

    float frac = ((-x) / step) - (float)idx;
    return lut[idx] * (1.0f - frac) + lut[idx + 1] * frac;
}


extern "C" void attention_int8_kernel(
    const q_t * Q_in,
    const k_t * K_in,
    const v_t * V_in,
    out_t     * O_out,
    float       q_scale,
    float       v_scale)
{
    #pragma HLS INTERFACE m_axi     port=Q_in    offset=slave bundle=gmem0 depth=NUM_Q_HEADS*SEQ_LEN*HEAD_DIM
    #pragma HLS INTERFACE m_axi     port=K_in    offset=slave bundle=gmem1 depth=NUM_KV_HEADS*SEQ_LEN*HEAD_DIM
    #pragma HLS INTERFACE m_axi     port=V_in    offset=slave bundle=gmem2 depth=NUM_KV_HEADS*SEQ_LEN*HEAD_DIM
    #pragma HLS INTERFACE m_axi     port=O_out   offset=slave bundle=gmem3 depth=NUM_Q_HEADS*SEQ_LEN*HEAD_DIM
    #pragma HLS INTERFACE s_axilite port=Q_in    bundle=control
    #pragma HLS INTERFACE s_axilite port=K_in    bundle=control
    #pragma HLS INTERFACE s_axilite port=V_in    bundle=control
    #pragma HLS INTERFACE s_axilite port=O_out   bundle=control
    #pragma HLS INTERFACE s_axilite port=q_scale bundle=control
    #pragma HLS INTERFACE s_axilite port=v_scale bundle=control
    #pragma HLS INTERFACE s_axilite port=return  bundle=control

    // ALLOCATION pragmas reduced PV-loop DSP from 510 to 442 in v3 — keep.
    #pragma HLS ALLOCATION operation instances=fmul limit=64
    #pragma HLS ALLOCATION operation instances=fadd limit=32

    for (int h_q = 0; h_q < NUM_Q_HEADS; ++h_q) {
        const int h_kv = h_q / Q_PER_KV;

        const q_t *Qh = Q_in  + h_q  * SEQ_LEN * HEAD_DIM;
        const k_t *Kh = K_in  + h_kv * SEQ_LEN * HEAD_DIM;
        const v_t *Vh = V_in  + h_kv * SEQ_LEN * HEAD_DIM;
        out_t     *Oh = O_out + h_q  * SEQ_LEN * HEAD_DIM;

        for (int qb = 0; qb < SEQ_LEN; qb += BQ) {

            q_t   Q_tile[BQ][HEAD_DIM];
            float O_tile[BQ][HEAD_DIM];
            float m_state[BQ];
            float l_state[BQ];

            #pragma HLS ARRAY_PARTITION variable=Q_tile  complete dim=2
            #pragma HLS ARRAY_PARTITION variable=O_tile  cyclic factor=8 dim=2
            #pragma HLS ARRAY_PARTITION variable=m_state complete
            #pragma HLS ARRAY_PARTITION variable=l_state complete

            for (int i = 0; i < BQ; ++i) {
                for (int d = 0; d < HEAD_DIM; ++d) {
                    #pragma HLS PIPELINE II=1
                    Q_tile[i][d] = Qh[(qb + i) * HEAD_DIM + d];
                }
            }

            for (int i = 0; i < BQ; ++i) {
                #pragma HLS PIPELINE II=1
                m_state[i] = -1.0e30f;
                l_state[i] = 0.0f;
                for (int d = 0; d < HEAD_DIM; ++d) {
                    #pragma HLS UNROLL factor=8
                    O_tile[i][d] = 0.0f;
                }
            }

            for (int kb = 0; kb < SEQ_LEN; kb += BK) {
                if (kb > qb + BQ - 1) break;

                k_t K_tile[BK][HEAD_DIM];
                v_t V_tile[BK][HEAD_DIM];

                #pragma HLS ARRAY_PARTITION variable=K_tile complete dim=2
                // Only one V_tile partition: cyclic factor=8 on dim=2 to match
                // the d-axis unroll. The dim=1 cyclic from v3 caused HLS to
                // promote V_tile to ROM and explode BRAM usage. Removed.
                #pragma HLS ARRAY_PARTITION variable=V_tile cyclic factor=8 dim=2

                for (int j = 0; j < BK; ++j) {
                    for (int d = 0; d < HEAD_DIM; ++d) {
                        #pragma HLS PIPELINE II=1
                        K_tile[j][d] = Kh[(kb + j) * HEAD_DIM + d];
                        V_tile[j][d] = Vh[(kb + j) * HEAD_DIM + d];
                    }
                }

                float scores[BQ][BK];
                float row_max[BQ];

                #pragma HLS ARRAY_PARTITION variable=scores  cyclic factor=8 dim=2
                #pragma HLS ARRAY_PARTITION variable=row_max complete

                for (int i = 0; i < BQ; ++i) {
                    float rmax = -1.0e30f;
                    for (int j = 0; j < BK; ++j) {
                        #pragma HLS PIPELINE II=1
                        acc_t acc = 0;
                        for (int d = 0; d < HEAD_DIM; ++d) {
                            #pragma HLS UNROLL
                            acc += (acc_t)Q_tile[i][d] * (acc_t)K_tile[j][d];
                        }
                        float s = (float)acc * q_scale;
                        if ((kb + j) > (qb + i)) s = -1.0e30f;
                        scores[i][j] = s;
                        if (s > rmax) rmax = s;
                    }
                    row_max[i] = rmax;
                }

                for (int i = 0; i < BQ; ++i) {
                    const float m_new       = (row_max[i] > m_state[i]) ? row_max[i] : m_state[i];
                    const float rescale_old = fast_expf(m_state[i] - m_new);

                    float P_row[BK];
                    #pragma HLS ARRAY_PARTITION variable=P_row complete

                    for (int j = 0; j < BK; ++j) {
                        #pragma HLS PIPELINE II=1
                        P_row[j] = fast_expf(scores[i][j] - m_new);
                    }

                    float l_new = 0.0f;
                    for (int j = 0; j < BK; ++j) {
                        #pragma HLS UNROLL
                        l_new += P_row[j];
                    }
                    l_state[i] = l_state[i] * rescale_old + l_new;

                    for (int d = 0; d < HEAD_DIM; ++d) {
                        #pragma HLS PIPELINE II=1
                        float pv = 0.0f;
                        for (int j = 0; j < BK; ++j) {
                            #pragma HLS UNROLL factor=8
                            pv += P_row[j] * ((float)V_tile[j][d] * v_scale);
                        }
                        O_tile[i][d] = O_tile[i][d] * rescale_old + pv;
                    }
                    m_state[i] = m_new;
                }
            }

            for (int i = 0; i < BQ; ++i) {
                const float inv_l = (l_state[i] > 0.0f) ? (1.0f / l_state[i]) : 0.0f;
                for (int d = 0; d < HEAD_DIM; ++d) {
                    #pragma HLS PIPELINE II=1
                    float   v    = O_tile[i][d] * inv_l;
                    half    h    = (half)v;
                    out_t   bits = *reinterpret_cast<const out_t*>(&h);
                    Oh[(qb + i) * HEAD_DIM + d] = bits;
                }
            }
        }
    }
}