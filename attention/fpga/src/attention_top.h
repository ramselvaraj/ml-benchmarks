// attention_top.h — parameters and type aliases for the HLS attention kernel.
//
// Change these once, re-run synth. Keep in mind that any dimension that
// appears as an array size must be a compile-time constant for HLS to
// synthesize BRAMs / URAMs correctly; fully dynamic dimensions produce
// very inefficient hardware.

#ifndef ATTENTION_TOP_H_
#define ATTENTION_TOP_H_

#include <ap_int.h>
#include <hls_stream.h>
#include <hls_vector.h>

// -----------------------------------------------------------------------------
// Problem geometry — set these to match the attention shape being measured.
// Current defaults: Llama-2-7B MHA (32 heads, 32 KV heads, D=128) at S=1024.
// For StarCoder MQA:  set NUM_KV_HEADS = 1.
// For Mistral GQA:    set NUM_KV_HEADS = 8.
// -----------------------------------------------------------------------------

constexpr int SEQ_LEN       = 1024;     // Fixed at synth time. Runtime-variable
                                        // seq_len would hurt Fmax; for sweep
                                        // data, re-synthesize at each S.
constexpr int HEAD_DIM      = 128;      // All our models use D=128.
constexpr int NUM_Q_HEADS   = 32;       // H_q
constexpr int NUM_KV_HEADS  = 32;       // H_kv  (MHA=32, GQA=8, MQA=1)
constexpr int BATCH         = 1;        // Prefill batch-1, as in our CPU/GPU runs.

// -----------------------------------------------------------------------------
// Tile sizes — change these to tune BRAM pressure vs Fmax.
// -----------------------------------------------------------------------------

constexpr int BQ = 64;      // Query rows per tile.
constexpr int BK = 64;      // Key/Value rows per tile.

static_assert(SEQ_LEN % BQ == 0, "SEQ_LEN must be divisible by BQ");
static_assert(SEQ_LEN % BK == 0, "SEQ_LEN must be divisible by BK");
static_assert(NUM_Q_HEADS % NUM_KV_HEADS == 0, "H_q must be divisible by H_kv for GQA/MQA");

constexpr int Q_PER_KV = NUM_Q_HEADS / NUM_KV_HEADS;   // 1 for MHA, 4 for GQA, 32 for MQA

// -----------------------------------------------------------------------------
// Dtype aliases.
// INT8 variant uses ap_int<8>.  INT4 variant (separate file) uses ap_int<4>.
// -----------------------------------------------------------------------------

using q_t        = ap_int<8>;     // quantized activation / weight
using k_t        = ap_int<8>;
using v_t        = ap_int<8>;
using acc_t      = ap_int<32>;    // integer accumulator for the MAC
using out_t      = ap_uint<16>;   // raw bits holding an IEEE FP16 value
using score_t    = float;         // FP32 softmax state (numerically safe)

// -----------------------------------------------------------------------------
// AXI burst / wide-word aliases.
// On U280, AXI4 master ports are 512-bit (64 byte); pack 64 INT8 per beat.
// -----------------------------------------------------------------------------

using axi_word_int8 = hls::vector<q_t,  64>;    // 512 bits / 8 bits per elem
using axi_word_fp16 = hls::vector<out_t, 32>;   // 512 bits / 16 bits per elem

// -----------------------------------------------------------------------------
// Top-level kernel prototype (defined in attention_int8.cpp).
//
// All tensor pointers are HBM-resident; scalars come via AXI-Lite.
// -----------------------------------------------------------------------------

extern "C" void attention_int8_kernel(
    const q_t * Q_in,          // [NUM_Q_HEADS, SEQ_LEN, HEAD_DIM], INT8
    const k_t * K_in,          // [NUM_KV_HEADS, SEQ_LEN, HEAD_DIM], INT8
    const v_t * V_in,          // [NUM_KV_HEADS, SEQ_LEN, HEAD_DIM], INT8
    out_t     * O_out,         // [NUM_Q_HEADS, SEQ_LEN, HEAD_DIM], FP16 bit-packed
    float       q_scale,       // combined Q·K rescale = sQ * sK / sqrt(D)
    float       v_scale        // rescale for V dequantization
);

#endif  // ATTENTION_TOP_H_
