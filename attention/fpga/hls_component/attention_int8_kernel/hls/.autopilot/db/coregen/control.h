// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read/COR)
//        bit 7  - auto_restart (Read/Write)
//        bit 9  - interrupt (Read)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0 - enable ap_done interrupt (Read/Write)
//        bit 1 - enable ap_ready interrupt (Read/Write)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0 - ap_done (Read/TOW)
//        bit 1 - ap_ready (Read/TOW)
//        others - reserved
// 0x10 : Data signal of Q_in
//        bit 31~0 - Q_in[31:0] (Read/Write)
// 0x14 : Data signal of Q_in
//        bit 31~0 - Q_in[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of K_in
//        bit 31~0 - K_in[31:0] (Read/Write)
// 0x20 : Data signal of K_in
//        bit 31~0 - K_in[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of V_in
//        bit 31~0 - V_in[31:0] (Read/Write)
// 0x2c : Data signal of V_in
//        bit 31~0 - V_in[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of O_out
//        bit 31~0 - O_out[31:0] (Read/Write)
// 0x38 : Data signal of O_out
//        bit 31~0 - O_out[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of q_scale
//        bit 31~0 - q_scale[31:0] (Read/Write)
// 0x44 : reserved
// 0x48 : Data signal of v_scale
//        bit 31~0 - v_scale[31:0] (Read/Write)
// 0x4c : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define CONTROL_ADDR_AP_CTRL      0x00
#define CONTROL_ADDR_GIE          0x04
#define CONTROL_ADDR_IER          0x08
#define CONTROL_ADDR_ISR          0x0c
#define CONTROL_ADDR_Q_IN_DATA    0x10
#define CONTROL_BITS_Q_IN_DATA    64
#define CONTROL_ADDR_K_IN_DATA    0x1c
#define CONTROL_BITS_K_IN_DATA    64
#define CONTROL_ADDR_V_IN_DATA    0x28
#define CONTROL_BITS_V_IN_DATA    64
#define CONTROL_ADDR_O_OUT_DATA   0x34
#define CONTROL_BITS_O_OUT_DATA   64
#define CONTROL_ADDR_Q_SCALE_DATA 0x40
#define CONTROL_BITS_Q_SCALE_DATA 32
#define CONTROL_ADDR_V_SCALE_DATA 0x48
#define CONTROL_BITS_V_SCALE_DATA 32
