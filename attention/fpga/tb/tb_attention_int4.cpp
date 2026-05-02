// tb_attention_int4.cpp — testbench for the W4A4 kernel.
// Structure identical to tb_attention_int8.cpp; differences:
//   - Reads packed-INT4 input bytes (testvectors/int4/)
//   - Calls attention_int4_kernel(...)
//   - Same FP16 output comparison against the Python reference.
// (Kept as a separate file so Vitis HLS can set_top to the right symbol.)

#include "../src/attention_top.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <cmath>
#include <hls_half.h>

using u8_t = ap_uint<8>;

extern "C" void attention_int4_kernel(
    const u8_t * Q_in_packed,
    const u8_t * K_in_packed,
    const u8_t * V_in_packed,
    out_t      * O_out,
    float        q_scale,
    float        v_scale);

template <typename T>
static int read_bin(const char *path, T *buf, size_t nelem) {
    FILE *f = std::fopen(path, "rb");
    if (!f) { std::fprintf(stderr, "ERROR: cannot open %s\n", path); return -1; }
    size_t got = std::fread(buf, sizeof(T), nelem, f);
    std::fclose(f);
    return (got == nelem) ? 0 : -1;
}

static int read_scales(const char *path, float &q_scale, float &v_scale) {
    FILE *f = std::fopen(path, "r");
    if (!f) return -1;
    char buf[4096]; size_t n = std::fread(buf, 1, sizeof(buf) - 1, f);
    buf[n] = '\0'; std::fclose(f);
    const char *q = std::strstr(buf, "\"q_scale\"");
    const char *v = std::strstr(buf, "\"v_scale\"");
    if (!q || !v) return -1;
    std::sscanf(q, "\"q_scale\"%*[^0-9.-]%f", &q_scale);
    std::sscanf(v, "\"v_scale\"%*[^0-9.-]%f", &v_scale);
    return 0;
}

int main(int argc, char **argv) {
    const char *dir = (argc > 1) ? argv[1] : "testvectors/int4";

    char path_q[512], path_k[512], path_v[512], path_ref[512], path_meta[512];
    std::snprintf(path_q,    sizeof(path_q),    "%s/Q.bin", dir);
    std::snprintf(path_k,    sizeof(path_k),    "%s/K.bin", dir);
    std::snprintf(path_v,    sizeof(path_v),    "%s/V.bin", dir);
    std::snprintf(path_ref,  sizeof(path_ref),  "%s/output_reference.bin", dir);
    std::snprintf(path_meta, sizeof(path_meta), "%s/meta.json", dir);

    // Packed INT4: two elements per byte ⇒ half as many bytes as the
    // logical element count.
    const size_t N_Q_LOG  = (size_t)NUM_Q_HEADS  * SEQ_LEN * HEAD_DIM;
    const size_t N_KV_LOG = (size_t)NUM_KV_HEADS * SEQ_LEN * HEAD_DIM;
    const size_t N_OUT    = N_Q_LOG;
    const size_t N_Q_PACK  = N_Q_LOG  / 2;
    const size_t N_KV_PACK = N_KV_LOG / 2;

    u8_t   *Q_host   = new u8_t[N_Q_PACK];
    u8_t   *K_host   = new u8_t[N_KV_PACK];
    u8_t   *V_host   = new u8_t[N_KV_PACK];
    out_t  *O_host   = new out_t[N_OUT];
    half   *O_ref_h  = new half[N_OUT];

    if (read_bin(path_q, (uint8_t*)Q_host, N_Q_PACK) ||
        read_bin(path_k, (uint8_t*)K_host, N_KV_PACK) ||
        read_bin(path_v, (uint8_t*)V_host, N_KV_PACK) ||
        read_bin(path_ref, (uint16_t*)O_ref_h, N_OUT)) return 2;

    float q_scale = 0.f, v_scale = 0.f;
    if (read_scales(path_meta, q_scale, v_scale)) return 3;
    std::printf("[tb int4] q_scale=%g v_scale=%g\n", q_scale, v_scale);

    attention_int4_kernel(Q_host, K_host, V_host, O_host, q_scale, v_scale);

    const float atol = 8.0e-2f;  // INT4 has coarser quant — looser tolerance
    float max_abs_diff = 0.f;
    size_t n_fail = 0;
    for (size_t i = 0; i < N_OUT; ++i) {
        half  hv   = *reinterpret_cast<half*>(&O_host[i]);
        float got  = (float)hv;
        float ref  = (float)O_ref_h[i];
        float d    = std::fabs(got - ref);
        if (d > max_abs_diff) max_abs_diff = d;
        if (d > atol) ++n_fail;
    }
    std::printf("[tb int4] max abs diff=%.4e (atol=%.4e)  mismatch=%zu/%zu\n",
                max_abs_diff, atol, n_fail, N_OUT);

    delete[] Q_host; delete[] K_host; delete[] V_host; delete[] O_host; delete[] O_ref_h;
    if (max_abs_diff > atol) { std::printf("TEST FAIL\n"); return 1; }
    std::printf("TEST PASS\n");
    return 0;
}
