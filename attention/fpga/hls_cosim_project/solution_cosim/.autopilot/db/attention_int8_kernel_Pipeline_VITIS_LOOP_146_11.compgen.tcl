# This script segment is generated automatically by AutoPilot

set name attention_int8_kernel_sitofp_32s_32_6_no_dsp_1
if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $name BINDTYPE {op} TYPE {sitofp} IMPL {auto} LATENCY 5 ALLOW_PRAGMA 1
}


set name attention_int8_kernel_mul_8s_8s_16_1_1
if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $name BINDTYPE {op} TYPE {mul} IMPL {auto} LATENCY 0 ALLOW_PRAGMA 1
}


set id 202
set name attention_int8_kernel_mac_muladd_8s_8s_16s_17_4_1
set corename simcore_mac
set op mac
set stage_num 4
set clk_width 1
set clk_signed 0
set reset_width 1
set reset_signed 0
set in0_width 8
set in0_signed 1
set in1_width 8
set in1_signed 1
set in2_width 16
set in2_signed 1
set ce_width 1
set ce_signed 0
set out_width 17
set arg_lists {i0 {8 1 +} i1 {8 1 +} m {16 1 +} i2 {16 1 +} p {17 1 +} c_reg {1} rnd {0} acc {0} }
set TrueReset 0
if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $name BINDTYPE {op} TYPE {all} IMPL {dsp48} LATENCY 3 ALLOW_PRAGMA 1
}


set op mac
set corename DSP48
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_dsp48] == "::AESL_LIB_VIRTEX::xil_gen_dsp48"} {
eval "::AESL_LIB_VIRTEX::xil_gen_dsp48 { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    true_reset ${TrueReset} \
    stage_num ${stage_num} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    in2_width ${in2_width} \
    in2_signed ${in2_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
    arg_lists {${arg_lists}} \
}"
} else {
puts "@W \[IMPL-101\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_dsp48, check your platform lib"
}
}


# clear list
if {${::AESL::PGuard_autoexp_gen}} {
    cg_default_interface_gen_dc_begin
    cg_default_interface_gen_bundle_begin
    AESL_LIB_XILADAPTER::native_axis_begin
}

# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 237 \
    name K_tile_V \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V \
    op interface \
    ports { K_tile_V_address0 { O 7 vector } K_tile_V_ce0 { O 1 bit } K_tile_V_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 239 \
    name K_tile_V_1 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_1 \
    op interface \
    ports { K_tile_V_1_address0 { O 7 vector } K_tile_V_1_ce0 { O 1 bit } K_tile_V_1_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_1'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 241 \
    name K_tile_V_2 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_2 \
    op interface \
    ports { K_tile_V_2_address0 { O 7 vector } K_tile_V_2_ce0 { O 1 bit } K_tile_V_2_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_2'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 243 \
    name K_tile_V_3 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_3 \
    op interface \
    ports { K_tile_V_3_address0 { O 7 vector } K_tile_V_3_ce0 { O 1 bit } K_tile_V_3_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_3'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 245 \
    name K_tile_V_4 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_4 \
    op interface \
    ports { K_tile_V_4_address0 { O 7 vector } K_tile_V_4_ce0 { O 1 bit } K_tile_V_4_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_4'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 247 \
    name K_tile_V_5 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_5 \
    op interface \
    ports { K_tile_V_5_address0 { O 7 vector } K_tile_V_5_ce0 { O 1 bit } K_tile_V_5_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_5'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 249 \
    name K_tile_V_6 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_6 \
    op interface \
    ports { K_tile_V_6_address0 { O 7 vector } K_tile_V_6_ce0 { O 1 bit } K_tile_V_6_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_6'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 251 \
    name K_tile_V_7 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_7 \
    op interface \
    ports { K_tile_V_7_address0 { O 7 vector } K_tile_V_7_ce0 { O 1 bit } K_tile_V_7_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_7'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 253 \
    name K_tile_V_8 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_8 \
    op interface \
    ports { K_tile_V_8_address0 { O 7 vector } K_tile_V_8_ce0 { O 1 bit } K_tile_V_8_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_8'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 255 \
    name K_tile_V_9 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_9 \
    op interface \
    ports { K_tile_V_9_address0 { O 7 vector } K_tile_V_9_ce0 { O 1 bit } K_tile_V_9_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_9'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 257 \
    name K_tile_V_10 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_10 \
    op interface \
    ports { K_tile_V_10_address0 { O 7 vector } K_tile_V_10_ce0 { O 1 bit } K_tile_V_10_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_10'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 259 \
    name K_tile_V_11 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_11 \
    op interface \
    ports { K_tile_V_11_address0 { O 7 vector } K_tile_V_11_ce0 { O 1 bit } K_tile_V_11_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_11'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 261 \
    name K_tile_V_12 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_12 \
    op interface \
    ports { K_tile_V_12_address0 { O 7 vector } K_tile_V_12_ce0 { O 1 bit } K_tile_V_12_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_12'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 263 \
    name K_tile_V_13 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_13 \
    op interface \
    ports { K_tile_V_13_address0 { O 7 vector } K_tile_V_13_ce0 { O 1 bit } K_tile_V_13_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_13'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 265 \
    name K_tile_V_14 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_14 \
    op interface \
    ports { K_tile_V_14_address0 { O 7 vector } K_tile_V_14_ce0 { O 1 bit } K_tile_V_14_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_14'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 267 \
    name K_tile_V_15 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_15 \
    op interface \
    ports { K_tile_V_15_address0 { O 7 vector } K_tile_V_15_ce0 { O 1 bit } K_tile_V_15_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_15'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 269 \
    name K_tile_V_16 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_16 \
    op interface \
    ports { K_tile_V_16_address0 { O 7 vector } K_tile_V_16_ce0 { O 1 bit } K_tile_V_16_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_16'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 271 \
    name K_tile_V_17 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_17 \
    op interface \
    ports { K_tile_V_17_address0 { O 7 vector } K_tile_V_17_ce0 { O 1 bit } K_tile_V_17_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_17'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 273 \
    name K_tile_V_18 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_18 \
    op interface \
    ports { K_tile_V_18_address0 { O 7 vector } K_tile_V_18_ce0 { O 1 bit } K_tile_V_18_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_18'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 275 \
    name K_tile_V_19 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_19 \
    op interface \
    ports { K_tile_V_19_address0 { O 7 vector } K_tile_V_19_ce0 { O 1 bit } K_tile_V_19_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_19'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 277 \
    name K_tile_V_20 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_20 \
    op interface \
    ports { K_tile_V_20_address0 { O 7 vector } K_tile_V_20_ce0 { O 1 bit } K_tile_V_20_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_20'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 279 \
    name K_tile_V_21 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_21 \
    op interface \
    ports { K_tile_V_21_address0 { O 7 vector } K_tile_V_21_ce0 { O 1 bit } K_tile_V_21_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_21'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 281 \
    name K_tile_V_22 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_22 \
    op interface \
    ports { K_tile_V_22_address0 { O 7 vector } K_tile_V_22_ce0 { O 1 bit } K_tile_V_22_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_22'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 283 \
    name K_tile_V_23 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_23 \
    op interface \
    ports { K_tile_V_23_address0 { O 7 vector } K_tile_V_23_ce0 { O 1 bit } K_tile_V_23_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_23'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 285 \
    name K_tile_V_24 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_24 \
    op interface \
    ports { K_tile_V_24_address0 { O 7 vector } K_tile_V_24_ce0 { O 1 bit } K_tile_V_24_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_24'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 287 \
    name K_tile_V_25 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_25 \
    op interface \
    ports { K_tile_V_25_address0 { O 7 vector } K_tile_V_25_ce0 { O 1 bit } K_tile_V_25_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_25'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 289 \
    name K_tile_V_26 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_26 \
    op interface \
    ports { K_tile_V_26_address0 { O 7 vector } K_tile_V_26_ce0 { O 1 bit } K_tile_V_26_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_26'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 291 \
    name K_tile_V_27 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_27 \
    op interface \
    ports { K_tile_V_27_address0 { O 7 vector } K_tile_V_27_ce0 { O 1 bit } K_tile_V_27_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_27'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 293 \
    name K_tile_V_28 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_28 \
    op interface \
    ports { K_tile_V_28_address0 { O 7 vector } K_tile_V_28_ce0 { O 1 bit } K_tile_V_28_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_28'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 295 \
    name K_tile_V_29 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_29 \
    op interface \
    ports { K_tile_V_29_address0 { O 7 vector } K_tile_V_29_ce0 { O 1 bit } K_tile_V_29_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_29'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 297 \
    name K_tile_V_30 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_30 \
    op interface \
    ports { K_tile_V_30_address0 { O 7 vector } K_tile_V_30_ce0 { O 1 bit } K_tile_V_30_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_30'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 299 \
    name K_tile_V_31 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_31 \
    op interface \
    ports { K_tile_V_31_address0 { O 7 vector } K_tile_V_31_ce0 { O 1 bit } K_tile_V_31_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_31'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 301 \
    name K_tile_V_32 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_32 \
    op interface \
    ports { K_tile_V_32_address0 { O 7 vector } K_tile_V_32_ce0 { O 1 bit } K_tile_V_32_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_32'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 303 \
    name K_tile_V_33 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_33 \
    op interface \
    ports { K_tile_V_33_address0 { O 7 vector } K_tile_V_33_ce0 { O 1 bit } K_tile_V_33_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_33'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 305 \
    name K_tile_V_34 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_34 \
    op interface \
    ports { K_tile_V_34_address0 { O 7 vector } K_tile_V_34_ce0 { O 1 bit } K_tile_V_34_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_34'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 307 \
    name K_tile_V_35 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_35 \
    op interface \
    ports { K_tile_V_35_address0 { O 7 vector } K_tile_V_35_ce0 { O 1 bit } K_tile_V_35_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_35'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 309 \
    name K_tile_V_36 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_36 \
    op interface \
    ports { K_tile_V_36_address0 { O 7 vector } K_tile_V_36_ce0 { O 1 bit } K_tile_V_36_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_36'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 311 \
    name K_tile_V_37 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_37 \
    op interface \
    ports { K_tile_V_37_address0 { O 7 vector } K_tile_V_37_ce0 { O 1 bit } K_tile_V_37_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_37'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 313 \
    name K_tile_V_38 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_38 \
    op interface \
    ports { K_tile_V_38_address0 { O 7 vector } K_tile_V_38_ce0 { O 1 bit } K_tile_V_38_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_38'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 315 \
    name K_tile_V_39 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_39 \
    op interface \
    ports { K_tile_V_39_address0 { O 7 vector } K_tile_V_39_ce0 { O 1 bit } K_tile_V_39_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_39'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 317 \
    name K_tile_V_40 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_40 \
    op interface \
    ports { K_tile_V_40_address0 { O 7 vector } K_tile_V_40_ce0 { O 1 bit } K_tile_V_40_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_40'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 319 \
    name K_tile_V_41 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_41 \
    op interface \
    ports { K_tile_V_41_address0 { O 7 vector } K_tile_V_41_ce0 { O 1 bit } K_tile_V_41_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_41'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 321 \
    name K_tile_V_42 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_42 \
    op interface \
    ports { K_tile_V_42_address0 { O 7 vector } K_tile_V_42_ce0 { O 1 bit } K_tile_V_42_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_42'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 323 \
    name K_tile_V_43 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_43 \
    op interface \
    ports { K_tile_V_43_address0 { O 7 vector } K_tile_V_43_ce0 { O 1 bit } K_tile_V_43_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_43'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 325 \
    name K_tile_V_44 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_44 \
    op interface \
    ports { K_tile_V_44_address0 { O 7 vector } K_tile_V_44_ce0 { O 1 bit } K_tile_V_44_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_44'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 327 \
    name K_tile_V_45 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_45 \
    op interface \
    ports { K_tile_V_45_address0 { O 7 vector } K_tile_V_45_ce0 { O 1 bit } K_tile_V_45_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_45'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 329 \
    name K_tile_V_46 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_46 \
    op interface \
    ports { K_tile_V_46_address0 { O 7 vector } K_tile_V_46_ce0 { O 1 bit } K_tile_V_46_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_46'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 331 \
    name K_tile_V_47 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_47 \
    op interface \
    ports { K_tile_V_47_address0 { O 7 vector } K_tile_V_47_ce0 { O 1 bit } K_tile_V_47_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_47'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 333 \
    name K_tile_V_48 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_48 \
    op interface \
    ports { K_tile_V_48_address0 { O 7 vector } K_tile_V_48_ce0 { O 1 bit } K_tile_V_48_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_48'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 335 \
    name K_tile_V_49 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_49 \
    op interface \
    ports { K_tile_V_49_address0 { O 7 vector } K_tile_V_49_ce0 { O 1 bit } K_tile_V_49_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_49'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 337 \
    name K_tile_V_50 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_50 \
    op interface \
    ports { K_tile_V_50_address0 { O 7 vector } K_tile_V_50_ce0 { O 1 bit } K_tile_V_50_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_50'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 339 \
    name K_tile_V_51 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_51 \
    op interface \
    ports { K_tile_V_51_address0 { O 7 vector } K_tile_V_51_ce0 { O 1 bit } K_tile_V_51_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_51'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 341 \
    name K_tile_V_52 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_52 \
    op interface \
    ports { K_tile_V_52_address0 { O 7 vector } K_tile_V_52_ce0 { O 1 bit } K_tile_V_52_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_52'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 343 \
    name K_tile_V_53 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_53 \
    op interface \
    ports { K_tile_V_53_address0 { O 7 vector } K_tile_V_53_ce0 { O 1 bit } K_tile_V_53_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_53'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 345 \
    name K_tile_V_54 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_54 \
    op interface \
    ports { K_tile_V_54_address0 { O 7 vector } K_tile_V_54_ce0 { O 1 bit } K_tile_V_54_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_54'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 347 \
    name K_tile_V_55 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_55 \
    op interface \
    ports { K_tile_V_55_address0 { O 7 vector } K_tile_V_55_ce0 { O 1 bit } K_tile_V_55_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_55'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 349 \
    name K_tile_V_56 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_56 \
    op interface \
    ports { K_tile_V_56_address0 { O 7 vector } K_tile_V_56_ce0 { O 1 bit } K_tile_V_56_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_56'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 351 \
    name K_tile_V_57 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_57 \
    op interface \
    ports { K_tile_V_57_address0 { O 7 vector } K_tile_V_57_ce0 { O 1 bit } K_tile_V_57_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_57'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 353 \
    name K_tile_V_58 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_58 \
    op interface \
    ports { K_tile_V_58_address0 { O 7 vector } K_tile_V_58_ce0 { O 1 bit } K_tile_V_58_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_58'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 355 \
    name K_tile_V_59 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_59 \
    op interface \
    ports { K_tile_V_59_address0 { O 7 vector } K_tile_V_59_ce0 { O 1 bit } K_tile_V_59_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_59'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 357 \
    name K_tile_V_60 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_60 \
    op interface \
    ports { K_tile_V_60_address0 { O 7 vector } K_tile_V_60_ce0 { O 1 bit } K_tile_V_60_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_60'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 359 \
    name K_tile_V_61 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_61 \
    op interface \
    ports { K_tile_V_61_address0 { O 7 vector } K_tile_V_61_ce0 { O 1 bit } K_tile_V_61_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_61'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 361 \
    name K_tile_V_62 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_62 \
    op interface \
    ports { K_tile_V_62_address0 { O 7 vector } K_tile_V_62_ce0 { O 1 bit } K_tile_V_62_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_62'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 363 \
    name K_tile_V_63 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename K_tile_V_63 \
    op interface \
    ports { K_tile_V_63_address0 { O 7 vector } K_tile_V_63_ce0 { O 1 bit } K_tile_V_63_q0 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'K_tile_V_63'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 369 \
    name scores \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename scores \
    op interface \
    ports { scores_address0 { O 7 vector } scores_ce0 { O 1 bit } scores_we0 { O 1 bit } scores_d0 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 370 \
    name scores_1 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename scores_1 \
    op interface \
    ports { scores_1_address0 { O 7 vector } scores_1_ce0 { O 1 bit } scores_1_we0 { O 1 bit } scores_1_d0 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_1'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 371 \
    name scores_2 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename scores_2 \
    op interface \
    ports { scores_2_address0 { O 7 vector } scores_2_ce0 { O 1 bit } scores_2_we0 { O 1 bit } scores_2_d0 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_2'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 372 \
    name scores_3 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename scores_3 \
    op interface \
    ports { scores_3_address0 { O 7 vector } scores_3_ce0 { O 1 bit } scores_3_we0 { O 1 bit } scores_3_d0 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_3'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 373 \
    name scores_4 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename scores_4 \
    op interface \
    ports { scores_4_address0 { O 7 vector } scores_4_ce0 { O 1 bit } scores_4_we0 { O 1 bit } scores_4_d0 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_4'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 374 \
    name scores_5 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename scores_5 \
    op interface \
    ports { scores_5_address0 { O 7 vector } scores_5_ce0 { O 1 bit } scores_5_we0 { O 1 bit } scores_5_d0 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_5'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 375 \
    name scores_6 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename scores_6 \
    op interface \
    ports { scores_6_address0 { O 7 vector } scores_6_ce0 { O 1 bit } scores_6_we0 { O 1 bit } scores_6_d0 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_6'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 376 \
    name scores_7 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename scores_7 \
    op interface \
    ports { scores_7_address0 { O 7 vector } scores_7_ce0 { O 1 bit } scores_7_we0 { O 1 bit } scores_7_d0 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_7'"
}
}


# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 238 \
    name Q_tile_V_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_load_cast \
    op interface \
    ports { Q_tile_V_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 240 \
    name Q_tile_V_1_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_1_load_cast \
    op interface \
    ports { Q_tile_V_1_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 242 \
    name Q_tile_V_2_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_2_load_cast \
    op interface \
    ports { Q_tile_V_2_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 244 \
    name Q_tile_V_3_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_3_load_cast \
    op interface \
    ports { Q_tile_V_3_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 246 \
    name Q_tile_V_4_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_4_load_cast \
    op interface \
    ports { Q_tile_V_4_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 248 \
    name Q_tile_V_5_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_5_load_cast \
    op interface \
    ports { Q_tile_V_5_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 250 \
    name Q_tile_V_6_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_6_load_cast \
    op interface \
    ports { Q_tile_V_6_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 252 \
    name Q_tile_V_7_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_7_load_cast \
    op interface \
    ports { Q_tile_V_7_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 254 \
    name Q_tile_V_8_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_8_load_cast \
    op interface \
    ports { Q_tile_V_8_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 256 \
    name Q_tile_V_9_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_9_load_cast \
    op interface \
    ports { Q_tile_V_9_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 258 \
    name Q_tile_V_10_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_10_load_cast \
    op interface \
    ports { Q_tile_V_10_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 260 \
    name Q_tile_V_11_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_11_load_cast \
    op interface \
    ports { Q_tile_V_11_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 262 \
    name Q_tile_V_12_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_12_load_cast \
    op interface \
    ports { Q_tile_V_12_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 264 \
    name Q_tile_V_13_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_13_load_cast \
    op interface \
    ports { Q_tile_V_13_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 266 \
    name Q_tile_V_14_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_14_load_cast \
    op interface \
    ports { Q_tile_V_14_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 268 \
    name Q_tile_V_15_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_15_load_cast \
    op interface \
    ports { Q_tile_V_15_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 270 \
    name Q_tile_V_16_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_16_load_cast \
    op interface \
    ports { Q_tile_V_16_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 272 \
    name Q_tile_V_17_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_17_load_cast \
    op interface \
    ports { Q_tile_V_17_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 274 \
    name Q_tile_V_18_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_18_load_cast \
    op interface \
    ports { Q_tile_V_18_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 276 \
    name Q_tile_V_19_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_19_load_cast \
    op interface \
    ports { Q_tile_V_19_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 278 \
    name Q_tile_V_20_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_20_load_cast \
    op interface \
    ports { Q_tile_V_20_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 280 \
    name Q_tile_V_21_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_21_load_cast \
    op interface \
    ports { Q_tile_V_21_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 282 \
    name Q_tile_V_22_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_22_load_cast \
    op interface \
    ports { Q_tile_V_22_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 284 \
    name Q_tile_V_23_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_23_load_cast \
    op interface \
    ports { Q_tile_V_23_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 286 \
    name Q_tile_V_24_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_24_load_cast \
    op interface \
    ports { Q_tile_V_24_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 288 \
    name Q_tile_V_25_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_25_load_cast \
    op interface \
    ports { Q_tile_V_25_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 290 \
    name Q_tile_V_26_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_26_load_cast \
    op interface \
    ports { Q_tile_V_26_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 292 \
    name Q_tile_V_27_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_27_load_cast \
    op interface \
    ports { Q_tile_V_27_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 294 \
    name Q_tile_V_28_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_28_load_cast \
    op interface \
    ports { Q_tile_V_28_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 296 \
    name Q_tile_V_29_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_29_load_cast \
    op interface \
    ports { Q_tile_V_29_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 298 \
    name Q_tile_V_30_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_30_load_cast \
    op interface \
    ports { Q_tile_V_30_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 300 \
    name Q_tile_V_31_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_31_load_cast \
    op interface \
    ports { Q_tile_V_31_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 302 \
    name Q_tile_V_32_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_32_load_cast \
    op interface \
    ports { Q_tile_V_32_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 304 \
    name Q_tile_V_33_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_33_load_cast \
    op interface \
    ports { Q_tile_V_33_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 306 \
    name Q_tile_V_34_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_34_load_cast \
    op interface \
    ports { Q_tile_V_34_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 308 \
    name Q_tile_V_35_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_35_load_cast \
    op interface \
    ports { Q_tile_V_35_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 310 \
    name Q_tile_V_36_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_36_load_cast \
    op interface \
    ports { Q_tile_V_36_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 312 \
    name Q_tile_V_37_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_37_load_cast \
    op interface \
    ports { Q_tile_V_37_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 314 \
    name Q_tile_V_38_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_38_load_cast \
    op interface \
    ports { Q_tile_V_38_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 316 \
    name Q_tile_V_39_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_39_load_cast \
    op interface \
    ports { Q_tile_V_39_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 318 \
    name Q_tile_V_40_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_40_load_cast \
    op interface \
    ports { Q_tile_V_40_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 320 \
    name Q_tile_V_41_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_41_load_cast \
    op interface \
    ports { Q_tile_V_41_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 322 \
    name Q_tile_V_42_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_42_load_cast \
    op interface \
    ports { Q_tile_V_42_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 324 \
    name Q_tile_V_43_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_43_load_cast \
    op interface \
    ports { Q_tile_V_43_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 326 \
    name Q_tile_V_44_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_44_load_cast \
    op interface \
    ports { Q_tile_V_44_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 328 \
    name Q_tile_V_45_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_45_load_cast \
    op interface \
    ports { Q_tile_V_45_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 330 \
    name Q_tile_V_46_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_46_load_cast \
    op interface \
    ports { Q_tile_V_46_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 332 \
    name Q_tile_V_47_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_47_load_cast \
    op interface \
    ports { Q_tile_V_47_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 334 \
    name Q_tile_V_48_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_48_load_cast \
    op interface \
    ports { Q_tile_V_48_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 336 \
    name Q_tile_V_49_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_49_load_cast \
    op interface \
    ports { Q_tile_V_49_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 338 \
    name Q_tile_V_50_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_50_load_cast \
    op interface \
    ports { Q_tile_V_50_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 340 \
    name Q_tile_V_51_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_51_load_cast \
    op interface \
    ports { Q_tile_V_51_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 342 \
    name Q_tile_V_52_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_52_load_cast \
    op interface \
    ports { Q_tile_V_52_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 344 \
    name Q_tile_V_53_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_53_load_cast \
    op interface \
    ports { Q_tile_V_53_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 346 \
    name Q_tile_V_54_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_54_load_cast \
    op interface \
    ports { Q_tile_V_54_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 348 \
    name Q_tile_V_55_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_55_load_cast \
    op interface \
    ports { Q_tile_V_55_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 350 \
    name Q_tile_V_56_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_56_load_cast \
    op interface \
    ports { Q_tile_V_56_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 352 \
    name Q_tile_V_57_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_57_load_cast \
    op interface \
    ports { Q_tile_V_57_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 354 \
    name Q_tile_V_58_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_58_load_cast \
    op interface \
    ports { Q_tile_V_58_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 356 \
    name Q_tile_V_59_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_59_load_cast \
    op interface \
    ports { Q_tile_V_59_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 358 \
    name Q_tile_V_60_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_60_load_cast \
    op interface \
    ports { Q_tile_V_60_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 360 \
    name Q_tile_V_61_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_61_load_cast \
    op interface \
    ports { Q_tile_V_61_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 362 \
    name Q_tile_V_62_load_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_Q_tile_V_62_load_cast \
    op interface \
    ports { Q_tile_V_62_load_cast { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 364 \
    name sext_ln146 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_sext_ln146 \
    op interface \
    ports { sext_ln146 { I 8 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 365 \
    name q_scale \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_q_scale \
    op interface \
    ports { q_scale { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 366 \
    name p_cast \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_p_cast \
    op interface \
    ports { p_cast { I 7 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 367 \
    name i_2 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_i_2 \
    op interface \
    ports { i_2 { I 3 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 368 \
    name trunc_ln155_1 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_trunc_ln155_1 \
    op interface \
    ports { trunc_ln155_1 { I 3 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 377 \
    name rmax_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_rmax_out \
    op interface \
    ports { rmax_out { O 32 vector } rmax_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id -1 \
    name ap_ctrl \
    type ap_ctrl \
    reset_level 1 \
    sync_rst true \
    corename ap_ctrl \
    op interface \
    ports { ap_start { I 1 bit } ap_ready { O 1 bit } ap_done { O 1 bit } ap_idle { O 1 bit } } \
} "
}


# Adapter definition:
set PortName ap_clk
set DataWd 1 
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc cg_default_interface_gen_clock] == "cg_default_interface_gen_clock"} {
eval "cg_default_interface_gen_clock { \
    id -2 \
    name ${PortName} \
    reset_level 1 \
    sync_rst true \
    corename apif_ap_clk \
    data_wd ${DataWd} \
    op interface \
}"
} else {
puts "@W \[IMPL-113\] Cannot find bus interface model in the library. Ignored generation of bus interface for '${PortName}'"
}
}


# Adapter definition:
set PortName ap_rst
set DataWd 1 
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc cg_default_interface_gen_reset] == "cg_default_interface_gen_reset"} {
eval "cg_default_interface_gen_reset { \
    id -3 \
    name ${PortName} \
    reset_level 1 \
    sync_rst true \
    corename apif_ap_rst \
    data_wd ${DataWd} \
    op interface \
}"
} else {
puts "@W \[IMPL-114\] Cannot find bus interface model in the library. Ignored generation of bus interface for '${PortName}'"
}
}



# merge
if {${::AESL::PGuard_autoexp_gen}} {
    cg_default_interface_gen_dc_end
    cg_default_interface_gen_bundle_end
    AESL_LIB_XILADAPTER::native_axis_end
}


# flow_control definition:
set InstName attention_int8_kernel_flow_control_loop_pipe_sequential_init_U
set CompName attention_int8_kernel_flow_control_loop_pipe_sequential_init
set name flow_control_loop_pipe_sequential_init
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_UPC_flow_control] == "::AESL_LIB_VIRTEX::xil_gen_UPC_flow_control"} {
eval "::AESL_LIB_VIRTEX::xil_gen_UPC_flow_control { \
    name ${name} \
    prefix attention_int8_kernel_ \
}"
} else {
puts "@W \[IMPL-107\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_UPC_flow_control, check your platform lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $CompName BINDTYPE interface TYPE internal_upc_flow_control INSTNAME $InstName
}


