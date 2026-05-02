// tb_attention_int8.cpp — C / RTL cosim testbench for attention_int8_kernel.
//
// Reads Q.bin, K.bin, V.bin, meta.json, output_reference.bin (all written by
// scripts/dump_testvectors.py), calls the HLS kernel, and compares the
// kernel's FP16 output to the reference (dequantized to FP16) within
// atol = 5e-2.
//
// Exit code 0 = PASS, non-zero = FAIL. Vitis HLS uses the exit code to mark
// cosim success/failure.

#include "../src/attention_top.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <cmath>
#include <hls_half.h>

// -----------------------------------------------------------------------------
// Binary file helpers
// -----------------------------------------------------------------------------

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
        std::fprintf(stderr, "ERROR: %s: wanted %zu elements, got %zu\n",
                     path, nelem, got);
        return -1;
    }
    return 0;
}

// Read two scalars from meta.json (naive parse — the only keys we need).
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
    std::sscanf(q, "\"q_scale\"%*[^0-9.-]%f", &q_scale);
    std::sscanf(v, "\"v_scale\"%*[^0-9.-]%f", &v_scale);
    return 0;
}

// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------

int main(int argc, char **argv) {
    const char *dir = "testvectors/int8";
    if (argc > 1) dir = argv[1];

    char path_q[512], path_k[512], path_v[512], path_ref[512], path_meta[512];
    std::snprintf(path_q,    sizeof(path_q),    "%s/Q.bin",                dir);
    std::snprintf(path_k,    sizeof(path_k),    "%s/K.bin",                dir);
    std::snprintf(path_v,    sizeof(path_v),    "%s/V.bin",                dir);
    std::snprintf(path_ref,  sizeof(path_ref),  "%s/output_reference.bin", dir);
    std::snprintf(path_meta, sizeof(path_meta), "%s/meta.json",            dir);

    // Allocate host buffers matching the kernel's declared shapes.
    const size_t N_Q   = (size_t)NUM_Q_HEADS  * SEQ_LEN * HEAD_DIM;
    const size_t N_KV  = (size_t)NUM_KV_HEADS * SEQ_LEN * HEAD_DIM;
    const size_t N_OUT = (size_t)NUM_Q_HEADS  * SEQ_LEN * HEAD_DIM;

    q_t     *Q_host   = new q_t[N_Q];
    k_t     *K_host   = new k_t[N_KV];
    v_t     *V_host   = new v_t[N_KV];
    out_t   *O_host   = new out_t[N_OUT];
    half    *O_ref_h  = new half[N_OUT];   // reference comes in as FP16

    if (read_bin(path_q, Q_host, N_Q) ||
        read_bin(path_k, K_host, N_KV) ||
        read_bin(path_v, V_host, N_KV) ||
        read_bin(path_ref, (uint16_t*)O_ref_h, N_OUT)) {
        return 2;
    }

    float q_scale = 0.0f, v_scale = 0.0f;
    if (read_scales(path_meta, q_scale, v_scale)) {
        std::fprintf(stderr, "ERROR: could not parse q_scale/v_scale from %s\n", path_meta);
        return 3;
    }
    std::printf("[tb] testvec dir = %s\n", dir);
    std::printf("[tb] q_scale = %g, v_scale = %g\n", q_scale, v_scale);
    std::printf("[tb] SEQ_LEN = %d, H_q = %d, H_kv = %d, D = %d, BQ = %d, BK = %d\n",
                SEQ_LEN, NUM_Q_HEADS, NUM_KV_HEADS, HEAD_DIM, BQ, BK);

    // --- Call the kernel (C-sim: direct function call;
    // cosim: Vitis wraps this in RTL) -----------------------------------------
    attention_int8_kernel(Q_host, K_host, V_host, O_host, q_scale, v_scale);

    // --- Compare output to reference within tolerance ------------------------
    const float atol = 5.0e-2f;     // generous — INT8 quant noise plus FP16 cast
    size_t n_fail = 0;
    float  max_abs_diff = 0.0f;
    for (size_t i = 0; i < N_OUT; ++i) {
        half     hv = *reinterpret_cast<half*>(&O_host[i]);
        float    got = (float)hv;
        float    ref = (float)O_ref_h[i];
        float    d   = std::fabs(got - ref);
        if (d > max_abs_diff) max_abs_diff = d;
        if (d > atol) ++n_fail;
    }

    std::printf("[tb] max abs diff = %.4e  (atol = %.4e)\n", max_abs_diff, atol);
    std::printf("[tb] mismatches > atol: %zu / %zu (%.3f%%)\n",
                n_fail, N_OUT, 100.0 * (double)n_fail / (double)N_OUT);

    delete[] Q_host; delete[] K_host; delete[] V_host; delete[] O_host; delete[] O_ref_h;

    if (max_abs_diff > atol) {
        std::printf("TEST FAIL\n");
        return 1;
    }
    std::printf("TEST PASS\n");
    return 0;
}
