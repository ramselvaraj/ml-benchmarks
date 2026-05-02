// tb_attention_int8.cpp — C-sim and cosim driver for attention_int8_kernel.
//
// Reads Q.bin, K.bin, V.bin, output_reference.bin, meta.json from the
// directory passed as argv[1] (defaults to "testvectors/int8").
//
// Calls the kernel and compares its FP16 output to the reference within
// atol = 5e-2. Returns 0 on PASS (cosim sees this as success).

#include "attention_top.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <cmath>
#include <hls_half.h>


// ---------------------------------------------------------------------------
// Binary file helpers
// ---------------------------------------------------------------------------
template <typename T>
static int read_bin(const char *path, T *buf, size_t nelem) {
    FILE *f = std::fopen(path, "rb");
    if (!f) {
        std::fprintf(stderr, "ERROR: cannot open %s\n", path);
        return -1;
    }
    size_t got = std::fread(buf, sizeof(T), nelem, f);
    std::fclose(f);
    if (got != nelem) {
        std::fprintf(stderr, "ERROR: %s: wanted %zu elems of size %zu, got %zu\n",
                     path, nelem, sizeof(T), got);
        return -1;
    }
    return 0;
}

// Naive parse of two scalars from meta.json. Looks for "q_scale" and "v_scale".
static int read_scales(const char *path, float &q_scale, float &v_scale) {
    FILE *f = std::fopen(path, "r");
    if (!f) {
        std::fprintf(stderr, "ERROR: cannot open %s\n", path);
        return -1;
    }
    char buf[4096];
    size_t n = std::fread(buf, 1, sizeof(buf) - 1, f);
    buf[n] = '\0';
    std::fclose(f);
    const char *q = std::strstr(buf, "\"q_scale\"");
    const char *v = std::strstr(buf, "\"v_scale\"");
    if (!q || !v) return -1;
    if (std::sscanf(q, "\"q_scale\"%*[^0-9.eE+-]%f", &q_scale) != 1) return -1;
    if (std::sscanf(v, "\"v_scale\"%*[^0-9.eE+-]%f", &v_scale) != 1) return -1;
    return 0;
}


// ---------------------------------------------------------------------------
// Forward declaration of the kernel — the testbench links against the
// kernel object built by Vitis HLS. Signature must match attention_int8.cpp.
// ---------------------------------------------------------------------------
extern "C" void attention_int8_kernel(
    const q_t *Q_in,
    const k_t *K_in,
    const v_t *V_in,
    out_t     *O_out,
    float      q_scale,
    float      v_scale);


int main(int argc, char **argv) {
    const char *dir = (argc > 1) ? argv[1] : "testvectors/int8";

    // NUM_KV_HEADS isn't a constant in attention_top.h (the kernel uses
    // Q_PER_KV instead), so derive it here.
    constexpr int NUM_KV_HEADS = NUM_Q_HEADS / Q_PER_KV;

    char path_q[512], path_k[512], path_v[512], path_ref[512], path_meta[512];
    std::snprintf(path_q,    sizeof(path_q),    "%s/Q.bin",                dir);
    std::snprintf(path_k,    sizeof(path_k),    "%s/K.bin",                dir);
    std::snprintf(path_v,    sizeof(path_v),    "%s/V.bin",                dir);
    std::snprintf(path_ref,  sizeof(path_ref),  "%s/output_reference.bin", dir);
    std::snprintf(path_meta, sizeof(path_meta), "%s/meta.json",            dir);

    const size_t N_Q   = (size_t)NUM_Q_HEADS  * SEQ_LEN * HEAD_DIM;
    const size_t N_KV  = (size_t)NUM_KV_HEADS * SEQ_LEN * HEAD_DIM;
    const size_t N_OUT = (size_t)NUM_Q_HEADS  * SEQ_LEN * HEAD_DIM;

    q_t   *Q_host  = new q_t  [N_Q];
    k_t   *K_host  = new k_t  [N_KV];
    v_t   *V_host  = new v_t  [N_KV];
    out_t *O_host  = new out_t[N_OUT];
    uint16_t *O_ref = new uint16_t[N_OUT];   // reference: raw FP16 bits

    if (read_bin(path_q,   Q_host, N_Q)   ||
        read_bin(path_k,   K_host, N_KV)  ||
        read_bin(path_v,   V_host, N_KV)  ||
        read_bin(path_ref, O_ref,  N_OUT)) {
        return 2;
    }

    float q_scale = 0.0f, v_scale = 0.0f;
    if (read_scales(path_meta, q_scale, v_scale)) {
        std::fprintf(stderr, "ERROR: cannot parse q_scale/v_scale from %s\n", path_meta);
        return 3;
    }
    std::printf("[tb] dir            = %s\n", dir);
    std::printf("[tb] q_scale        = %.6g\n", q_scale);
    std::printf("[tb] v_scale        = %.6g\n", v_scale);
    std::printf("[tb] NUM_Q_HEADS    = %d\n", NUM_Q_HEADS);
    std::printf("[tb] NUM_KV_HEADS   = %d (= NUM_Q_HEADS / Q_PER_KV)\n", NUM_KV_HEADS);
    std::printf("[tb] SEQ_LEN        = %d\n", SEQ_LEN);
    std::printf("[tb] HEAD_DIM       = %d\n", HEAD_DIM);
    std::printf("[tb] BQ x BK        = %d x %d\n", BQ, BK);
    std::printf("[tb] N_Q elems      = %zu\n", N_Q);

    // ---- Run the kernel (csim: direct call; cosim: Vitis wraps in RTL) ----
    attention_int8_kernel(Q_host, K_host, V_host, O_host, q_scale, v_scale);

    // ---- Compare ----
    const float atol = 5.0e-2f;
    size_t n_fail = 0;
    float  max_abs_diff = 0.0f;
    for (size_t i = 0; i < N_OUT; ++i) {
        // Kernel stores FP16 bit pattern in ap_uint<16>; reference is the
        // same. Compare both via half->float conversion.
        uint16_t got_bits = (uint16_t)O_host[i];
        uint16_t ref_bits = O_ref[i];
        half got_h, ref_h;
        std::memcpy(&got_h, &got_bits, sizeof(uint16_t));
        std::memcpy(&ref_h, &ref_bits, sizeof(uint16_t));
        float got = (float)got_h;
        float ref = (float)ref_h;
        float d   = std::fabs(got - ref);
        if (d > max_abs_diff) max_abs_diff = d;
        if (d > atol) ++n_fail;
    }

    std::printf("[tb] max abs diff   = %.4e  (atol = %.4e)\n", max_abs_diff, atol);
    std::printf("[tb] mismatches     = %zu / %zu  (%.3f%%)\n",
                n_fail, N_OUT, 100.0 * (double)n_fail / (double)N_OUT);

    delete[] Q_host; delete[] K_host; delete[] V_host;
    delete[] O_host; delete[] O_ref;

    if (max_abs_diff > atol) {
        std::printf("TEST FAIL\n");
        return 1;
    }
    std::printf("TEST PASS\n");
    return 0;
}
