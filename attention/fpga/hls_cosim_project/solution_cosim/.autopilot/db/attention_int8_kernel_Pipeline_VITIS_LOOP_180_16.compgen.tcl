# This script segment is generated automatically by AutoPilot

set name attention_int8_kernel_fadd_32ns_32ns_32_6_no_dsp_1
if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $name BINDTYPE {op} TYPE {fadd} IMPL {fabric} LATENCY 5 ALLOW_PRAGMA 1
}


set id 587
set name attention_int8_kernel_mux_83_8_1_1
set corename simcore_mux
set op mux
set stage_num 1
set din0_width 8
set din0_signed 0
set din1_width 8
set din1_signed 0
set din2_width 8
set din2_signed 0
set din3_width 8
set din3_signed 0
set din4_width 8
set din4_signed 0
set din5_width 8
set din5_signed 0
set din6_width 8
set din6_signed 0
set din7_width 8
set din7_signed 0
set din8_width 3
set din8_signed 0
set dout_width 8
if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $name BINDTYPE {op} TYPE {mux} IMPL {auto} LATENCY 0 ALLOW_PRAGMA 1
}


set op mux
set corename Multiplexer
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_pipemux] == "::AESL_LIB_VIRTEX::xil_gen_pipemux"} {
eval "::AESL_LIB_VIRTEX::xil_gen_pipemux { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    din0_width ${din0_width} \
    din0_signed ${din0_signed} \
    din1_width ${din1_width} \
    din1_signed ${din1_signed} \
    din2_width ${din2_width} \
    din2_signed ${din2_signed} \
    din3_width ${din3_width} \
    din3_signed ${din3_signed} \
    din4_width ${din4_width} \
    din4_signed ${din4_signed} \
    din5_width ${din5_width} \
    din5_signed ${din5_signed} \
    din6_width ${din6_width} \
    din6_signed ${din6_signed} \
    din7_width ${din7_width} \
    din7_signed ${din7_signed} \
    din8_width ${din8_width} \
    din8_signed ${din8_signed} \
    dout_width ${dout_width} \
}"
} else {
puts "@W \[IMPL-101\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_pipemux, check your platform lib"
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
    id 605 \
    name O_tile \
    reset_level 1 \
    sync_rst true \
    dir IO \
    corename O_tile \
    op interface \
    ports { O_tile_address0 { O 6 vector } O_tile_ce0 { O 1 bit } O_tile_we0 { O 1 bit } O_tile_d0 { O 32 vector } O_tile_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 606 \
    name O_tile_1 \
    reset_level 1 \
    sync_rst true \
    dir IO \
    corename O_tile_1 \
    op interface \
    ports { O_tile_1_address0 { O 6 vector } O_tile_1_ce0 { O 1 bit } O_tile_1_we0 { O 1 bit } O_tile_1_d0 { O 32 vector } O_tile_1_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_1'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 607 \
    name O_tile_2 \
    reset_level 1 \
    sync_rst true \
    dir IO \
    corename O_tile_2 \
    op interface \
    ports { O_tile_2_address0 { O 6 vector } O_tile_2_ce0 { O 1 bit } O_tile_2_we0 { O 1 bit } O_tile_2_d0 { O 32 vector } O_tile_2_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_2'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 608 \
    name O_tile_3 \
    reset_level 1 \
    sync_rst true \
    dir IO \
    corename O_tile_3 \
    op interface \
    ports { O_tile_3_address0 { O 6 vector } O_tile_3_ce0 { O 1 bit } O_tile_3_we0 { O 1 bit } O_tile_3_d0 { O 32 vector } O_tile_3_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_3'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 609 \
    name O_tile_4 \
    reset_level 1 \
    sync_rst true \
    dir IO \
    corename O_tile_4 \
    op interface \
    ports { O_tile_4_address0 { O 6 vector } O_tile_4_ce0 { O 1 bit } O_tile_4_we0 { O 1 bit } O_tile_4_d0 { O 32 vector } O_tile_4_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_4'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 610 \
    name O_tile_5 \
    reset_level 1 \
    sync_rst true \
    dir IO \
    corename O_tile_5 \
    op interface \
    ports { O_tile_5_address0 { O 6 vector } O_tile_5_ce0 { O 1 bit } O_tile_5_we0 { O 1 bit } O_tile_5_d0 { O 32 vector } O_tile_5_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_5'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 611 \
    name O_tile_6 \
    reset_level 1 \
    sync_rst true \
    dir IO \
    corename O_tile_6 \
    op interface \
    ports { O_tile_6_address0 { O 6 vector } O_tile_6_ce0 { O 1 bit } O_tile_6_we0 { O 1 bit } O_tile_6_d0 { O 32 vector } O_tile_6_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_6'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 612 \
    name O_tile_7 \
    reset_level 1 \
    sync_rst true \
    dir IO \
    corename O_tile_7 \
    op interface \
    ports { O_tile_7_address0 { O 6 vector } O_tile_7_ce0 { O 1 bit } O_tile_7_we0 { O 1 bit } O_tile_7_d0 { O 32 vector } O_tile_7_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_7'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 613 \
    name V_tile_V \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename V_tile_V \
    op interface \
    ports { V_tile_V_address0 { O 10 vector } V_tile_V_ce0 { O 1 bit } V_tile_V_q0 { I 8 vector } V_tile_V_address1 { O 10 vector } V_tile_V_ce1 { O 1 bit } V_tile_V_q1 { I 8 vector } V_tile_V_address2 { O 10 vector } V_tile_V_ce2 { O 1 bit } V_tile_V_q2 { I 8 vector } V_tile_V_address3 { O 10 vector } V_tile_V_ce3 { O 1 bit } V_tile_V_q3 { I 8 vector } V_tile_V_address4 { O 10 vector } V_tile_V_ce4 { O 1 bit } V_tile_V_q4 { I 8 vector } V_tile_V_address5 { O 10 vector } V_tile_V_ce5 { O 1 bit } V_tile_V_q5 { I 8 vector } V_tile_V_address6 { O 10 vector } V_tile_V_ce6 { O 1 bit } V_tile_V_q6 { I 8 vector } V_tile_V_address7 { O 10 vector } V_tile_V_ce7 { O 1 bit } V_tile_V_q7 { I 8 vector } V_tile_V_address8 { O 10 vector } V_tile_V_ce8 { O 1 bit } V_tile_V_q8 { I 8 vector } V_tile_V_address9 { O 10 vector } V_tile_V_ce9 { O 1 bit } V_tile_V_q9 { I 8 vector } V_tile_V_address10 { O 10 vector } V_tile_V_ce10 { O 1 bit } V_tile_V_q10 { I 8 vector } V_tile_V_address11 { O 10 vector } V_tile_V_ce11 { O 1 bit } V_tile_V_q11 { I 8 vector } V_tile_V_address12 { O 10 vector } V_tile_V_ce12 { O 1 bit } V_tile_V_q12 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'V_tile_V'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 614 \
    name V_tile_V_1 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename V_tile_V_1 \
    op interface \
    ports { V_tile_V_1_address0 { O 10 vector } V_tile_V_1_ce0 { O 1 bit } V_tile_V_1_q0 { I 8 vector } V_tile_V_1_address1 { O 10 vector } V_tile_V_1_ce1 { O 1 bit } V_tile_V_1_q1 { I 8 vector } V_tile_V_1_address2 { O 10 vector } V_tile_V_1_ce2 { O 1 bit } V_tile_V_1_q2 { I 8 vector } V_tile_V_1_address3 { O 10 vector } V_tile_V_1_ce3 { O 1 bit } V_tile_V_1_q3 { I 8 vector } V_tile_V_1_address4 { O 10 vector } V_tile_V_1_ce4 { O 1 bit } V_tile_V_1_q4 { I 8 vector } V_tile_V_1_address5 { O 10 vector } V_tile_V_1_ce5 { O 1 bit } V_tile_V_1_q5 { I 8 vector } V_tile_V_1_address6 { O 10 vector } V_tile_V_1_ce6 { O 1 bit } V_tile_V_1_q6 { I 8 vector } V_tile_V_1_address7 { O 10 vector } V_tile_V_1_ce7 { O 1 bit } V_tile_V_1_q7 { I 8 vector } V_tile_V_1_address8 { O 10 vector } V_tile_V_1_ce8 { O 1 bit } V_tile_V_1_q8 { I 8 vector } V_tile_V_1_address9 { O 10 vector } V_tile_V_1_ce9 { O 1 bit } V_tile_V_1_q9 { I 8 vector } V_tile_V_1_address10 { O 10 vector } V_tile_V_1_ce10 { O 1 bit } V_tile_V_1_q10 { I 8 vector } V_tile_V_1_address11 { O 10 vector } V_tile_V_1_ce11 { O 1 bit } V_tile_V_1_q11 { I 8 vector } V_tile_V_1_address12 { O 10 vector } V_tile_V_1_ce12 { O 1 bit } V_tile_V_1_q12 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'V_tile_V_1'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 615 \
    name V_tile_V_2 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename V_tile_V_2 \
    op interface \
    ports { V_tile_V_2_address0 { O 10 vector } V_tile_V_2_ce0 { O 1 bit } V_tile_V_2_q0 { I 8 vector } V_tile_V_2_address1 { O 10 vector } V_tile_V_2_ce1 { O 1 bit } V_tile_V_2_q1 { I 8 vector } V_tile_V_2_address2 { O 10 vector } V_tile_V_2_ce2 { O 1 bit } V_tile_V_2_q2 { I 8 vector } V_tile_V_2_address3 { O 10 vector } V_tile_V_2_ce3 { O 1 bit } V_tile_V_2_q3 { I 8 vector } V_tile_V_2_address4 { O 10 vector } V_tile_V_2_ce4 { O 1 bit } V_tile_V_2_q4 { I 8 vector } V_tile_V_2_address5 { O 10 vector } V_tile_V_2_ce5 { O 1 bit } V_tile_V_2_q5 { I 8 vector } V_tile_V_2_address6 { O 10 vector } V_tile_V_2_ce6 { O 1 bit } V_tile_V_2_q6 { I 8 vector } V_tile_V_2_address7 { O 10 vector } V_tile_V_2_ce7 { O 1 bit } V_tile_V_2_q7 { I 8 vector } V_tile_V_2_address8 { O 10 vector } V_tile_V_2_ce8 { O 1 bit } V_tile_V_2_q8 { I 8 vector } V_tile_V_2_address9 { O 10 vector } V_tile_V_2_ce9 { O 1 bit } V_tile_V_2_q9 { I 8 vector } V_tile_V_2_address10 { O 10 vector } V_tile_V_2_ce10 { O 1 bit } V_tile_V_2_q10 { I 8 vector } V_tile_V_2_address11 { O 10 vector } V_tile_V_2_ce11 { O 1 bit } V_tile_V_2_q11 { I 8 vector } V_tile_V_2_address12 { O 10 vector } V_tile_V_2_ce12 { O 1 bit } V_tile_V_2_q12 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'V_tile_V_2'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 616 \
    name V_tile_V_3 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename V_tile_V_3 \
    op interface \
    ports { V_tile_V_3_address0 { O 10 vector } V_tile_V_3_ce0 { O 1 bit } V_tile_V_3_q0 { I 8 vector } V_tile_V_3_address1 { O 10 vector } V_tile_V_3_ce1 { O 1 bit } V_tile_V_3_q1 { I 8 vector } V_tile_V_3_address2 { O 10 vector } V_tile_V_3_ce2 { O 1 bit } V_tile_V_3_q2 { I 8 vector } V_tile_V_3_address3 { O 10 vector } V_tile_V_3_ce3 { O 1 bit } V_tile_V_3_q3 { I 8 vector } V_tile_V_3_address4 { O 10 vector } V_tile_V_3_ce4 { O 1 bit } V_tile_V_3_q4 { I 8 vector } V_tile_V_3_address5 { O 10 vector } V_tile_V_3_ce5 { O 1 bit } V_tile_V_3_q5 { I 8 vector } V_tile_V_3_address6 { O 10 vector } V_tile_V_3_ce6 { O 1 bit } V_tile_V_3_q6 { I 8 vector } V_tile_V_3_address7 { O 10 vector } V_tile_V_3_ce7 { O 1 bit } V_tile_V_3_q7 { I 8 vector } V_tile_V_3_address8 { O 10 vector } V_tile_V_3_ce8 { O 1 bit } V_tile_V_3_q8 { I 8 vector } V_tile_V_3_address9 { O 10 vector } V_tile_V_3_ce9 { O 1 bit } V_tile_V_3_q9 { I 8 vector } V_tile_V_3_address10 { O 10 vector } V_tile_V_3_ce10 { O 1 bit } V_tile_V_3_q10 { I 8 vector } V_tile_V_3_address11 { O 10 vector } V_tile_V_3_ce11 { O 1 bit } V_tile_V_3_q11 { I 8 vector } V_tile_V_3_address12 { O 10 vector } V_tile_V_3_ce12 { O 1 bit } V_tile_V_3_q12 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'V_tile_V_3'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 617 \
    name V_tile_V_4 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename V_tile_V_4 \
    op interface \
    ports { V_tile_V_4_address0 { O 10 vector } V_tile_V_4_ce0 { O 1 bit } V_tile_V_4_q0 { I 8 vector } V_tile_V_4_address1 { O 10 vector } V_tile_V_4_ce1 { O 1 bit } V_tile_V_4_q1 { I 8 vector } V_tile_V_4_address2 { O 10 vector } V_tile_V_4_ce2 { O 1 bit } V_tile_V_4_q2 { I 8 vector } V_tile_V_4_address3 { O 10 vector } V_tile_V_4_ce3 { O 1 bit } V_tile_V_4_q3 { I 8 vector } V_tile_V_4_address4 { O 10 vector } V_tile_V_4_ce4 { O 1 bit } V_tile_V_4_q4 { I 8 vector } V_tile_V_4_address5 { O 10 vector } V_tile_V_4_ce5 { O 1 bit } V_tile_V_4_q5 { I 8 vector } V_tile_V_4_address6 { O 10 vector } V_tile_V_4_ce6 { O 1 bit } V_tile_V_4_q6 { I 8 vector } V_tile_V_4_address7 { O 10 vector } V_tile_V_4_ce7 { O 1 bit } V_tile_V_4_q7 { I 8 vector } V_tile_V_4_address8 { O 10 vector } V_tile_V_4_ce8 { O 1 bit } V_tile_V_4_q8 { I 8 vector } V_tile_V_4_address9 { O 10 vector } V_tile_V_4_ce9 { O 1 bit } V_tile_V_4_q9 { I 8 vector } V_tile_V_4_address10 { O 10 vector } V_tile_V_4_ce10 { O 1 bit } V_tile_V_4_q10 { I 8 vector } V_tile_V_4_address11 { O 10 vector } V_tile_V_4_ce11 { O 1 bit } V_tile_V_4_q11 { I 8 vector } V_tile_V_4_address12 { O 10 vector } V_tile_V_4_ce12 { O 1 bit } V_tile_V_4_q12 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'V_tile_V_4'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 618 \
    name V_tile_V_5 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename V_tile_V_5 \
    op interface \
    ports { V_tile_V_5_address0 { O 10 vector } V_tile_V_5_ce0 { O 1 bit } V_tile_V_5_q0 { I 8 vector } V_tile_V_5_address1 { O 10 vector } V_tile_V_5_ce1 { O 1 bit } V_tile_V_5_q1 { I 8 vector } V_tile_V_5_address2 { O 10 vector } V_tile_V_5_ce2 { O 1 bit } V_tile_V_5_q2 { I 8 vector } V_tile_V_5_address3 { O 10 vector } V_tile_V_5_ce3 { O 1 bit } V_tile_V_5_q3 { I 8 vector } V_tile_V_5_address4 { O 10 vector } V_tile_V_5_ce4 { O 1 bit } V_tile_V_5_q4 { I 8 vector } V_tile_V_5_address5 { O 10 vector } V_tile_V_5_ce5 { O 1 bit } V_tile_V_5_q5 { I 8 vector } V_tile_V_5_address6 { O 10 vector } V_tile_V_5_ce6 { O 1 bit } V_tile_V_5_q6 { I 8 vector } V_tile_V_5_address7 { O 10 vector } V_tile_V_5_ce7 { O 1 bit } V_tile_V_5_q7 { I 8 vector } V_tile_V_5_address8 { O 10 vector } V_tile_V_5_ce8 { O 1 bit } V_tile_V_5_q8 { I 8 vector } V_tile_V_5_address9 { O 10 vector } V_tile_V_5_ce9 { O 1 bit } V_tile_V_5_q9 { I 8 vector } V_tile_V_5_address10 { O 10 vector } V_tile_V_5_ce10 { O 1 bit } V_tile_V_5_q10 { I 8 vector } V_tile_V_5_address11 { O 10 vector } V_tile_V_5_ce11 { O 1 bit } V_tile_V_5_q11 { I 8 vector } V_tile_V_5_address12 { O 10 vector } V_tile_V_5_ce12 { O 1 bit } V_tile_V_5_q12 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'V_tile_V_5'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 619 \
    name V_tile_V_6 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename V_tile_V_6 \
    op interface \
    ports { V_tile_V_6_address0 { O 10 vector } V_tile_V_6_ce0 { O 1 bit } V_tile_V_6_q0 { I 8 vector } V_tile_V_6_address1 { O 10 vector } V_tile_V_6_ce1 { O 1 bit } V_tile_V_6_q1 { I 8 vector } V_tile_V_6_address2 { O 10 vector } V_tile_V_6_ce2 { O 1 bit } V_tile_V_6_q2 { I 8 vector } V_tile_V_6_address3 { O 10 vector } V_tile_V_6_ce3 { O 1 bit } V_tile_V_6_q3 { I 8 vector } V_tile_V_6_address4 { O 10 vector } V_tile_V_6_ce4 { O 1 bit } V_tile_V_6_q4 { I 8 vector } V_tile_V_6_address5 { O 10 vector } V_tile_V_6_ce5 { O 1 bit } V_tile_V_6_q5 { I 8 vector } V_tile_V_6_address6 { O 10 vector } V_tile_V_6_ce6 { O 1 bit } V_tile_V_6_q6 { I 8 vector } V_tile_V_6_address7 { O 10 vector } V_tile_V_6_ce7 { O 1 bit } V_tile_V_6_q7 { I 8 vector } V_tile_V_6_address8 { O 10 vector } V_tile_V_6_ce8 { O 1 bit } V_tile_V_6_q8 { I 8 vector } V_tile_V_6_address9 { O 10 vector } V_tile_V_6_ce9 { O 1 bit } V_tile_V_6_q9 { I 8 vector } V_tile_V_6_address10 { O 10 vector } V_tile_V_6_ce10 { O 1 bit } V_tile_V_6_q10 { I 8 vector } V_tile_V_6_address11 { O 10 vector } V_tile_V_6_ce11 { O 1 bit } V_tile_V_6_q11 { I 8 vector } V_tile_V_6_address12 { O 10 vector } V_tile_V_6_ce12 { O 1 bit } V_tile_V_6_q12 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'V_tile_V_6'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 620 \
    name V_tile_V_7 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename V_tile_V_7 \
    op interface \
    ports { V_tile_V_7_address0 { O 10 vector } V_tile_V_7_ce0 { O 1 bit } V_tile_V_7_q0 { I 8 vector } V_tile_V_7_address1 { O 10 vector } V_tile_V_7_ce1 { O 1 bit } V_tile_V_7_q1 { I 8 vector } V_tile_V_7_address2 { O 10 vector } V_tile_V_7_ce2 { O 1 bit } V_tile_V_7_q2 { I 8 vector } V_tile_V_7_address3 { O 10 vector } V_tile_V_7_ce3 { O 1 bit } V_tile_V_7_q3 { I 8 vector } V_tile_V_7_address4 { O 10 vector } V_tile_V_7_ce4 { O 1 bit } V_tile_V_7_q4 { I 8 vector } V_tile_V_7_address5 { O 10 vector } V_tile_V_7_ce5 { O 1 bit } V_tile_V_7_q5 { I 8 vector } V_tile_V_7_address6 { O 10 vector } V_tile_V_7_ce6 { O 1 bit } V_tile_V_7_q6 { I 8 vector } V_tile_V_7_address7 { O 10 vector } V_tile_V_7_ce7 { O 1 bit } V_tile_V_7_q7 { I 8 vector } V_tile_V_7_address8 { O 10 vector } V_tile_V_7_ce8 { O 1 bit } V_tile_V_7_q8 { I 8 vector } V_tile_V_7_address9 { O 10 vector } V_tile_V_7_ce9 { O 1 bit } V_tile_V_7_q9 { I 8 vector } V_tile_V_7_address10 { O 10 vector } V_tile_V_7_ce10 { O 1 bit } V_tile_V_7_q10 { I 8 vector } V_tile_V_7_address11 { O 10 vector } V_tile_V_7_ce11 { O 1 bit } V_tile_V_7_q11 { I 8 vector } V_tile_V_7_address12 { O 10 vector } V_tile_V_7_ce12 { O 1 bit } V_tile_V_7_q12 { I 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'V_tile_V_7'"
}
}


# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 603 \
    name i_3 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_i_3 \
    op interface \
    ports { i_3 { I 3 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 604 \
    name trunc_ln187 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_trunc_ln187 \
    op interface \
    ports { trunc_ln187 { I 3 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 621 \
    name v_scale \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_v_scale \
    op interface \
    ports { v_scale { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 622 \
    name P_row_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_reload \
    op interface \
    ports { P_row_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 623 \
    name P_row_1_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_1_reload \
    op interface \
    ports { P_row_1_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 624 \
    name P_row_2_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_2_reload \
    op interface \
    ports { P_row_2_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 625 \
    name P_row_3_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_3_reload \
    op interface \
    ports { P_row_3_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 626 \
    name P_row_4_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_4_reload \
    op interface \
    ports { P_row_4_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 627 \
    name P_row_5_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_5_reload \
    op interface \
    ports { P_row_5_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 628 \
    name P_row_6_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_6_reload \
    op interface \
    ports { P_row_6_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 629 \
    name P_row_7_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_7_reload \
    op interface \
    ports { P_row_7_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 630 \
    name P_row_8_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_8_reload \
    op interface \
    ports { P_row_8_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 631 \
    name P_row_9_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_9_reload \
    op interface \
    ports { P_row_9_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 632 \
    name P_row_10_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_10_reload \
    op interface \
    ports { P_row_10_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 633 \
    name P_row_11_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_11_reload \
    op interface \
    ports { P_row_11_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 634 \
    name P_row_12_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_12_reload \
    op interface \
    ports { P_row_12_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 635 \
    name P_row_13_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_13_reload \
    op interface \
    ports { P_row_13_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 636 \
    name P_row_14_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_14_reload \
    op interface \
    ports { P_row_14_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 637 \
    name P_row_15_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_15_reload \
    op interface \
    ports { P_row_15_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 638 \
    name P_row_16_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_16_reload \
    op interface \
    ports { P_row_16_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 639 \
    name P_row_17_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_17_reload \
    op interface \
    ports { P_row_17_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 640 \
    name P_row_18_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_18_reload \
    op interface \
    ports { P_row_18_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 641 \
    name P_row_19_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_19_reload \
    op interface \
    ports { P_row_19_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 642 \
    name P_row_20_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_20_reload \
    op interface \
    ports { P_row_20_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 643 \
    name P_row_21_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_21_reload \
    op interface \
    ports { P_row_21_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 644 \
    name P_row_22_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_22_reload \
    op interface \
    ports { P_row_22_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 645 \
    name P_row_23_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_23_reload \
    op interface \
    ports { P_row_23_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 646 \
    name P_row_24_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_24_reload \
    op interface \
    ports { P_row_24_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 647 \
    name P_row_25_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_25_reload \
    op interface \
    ports { P_row_25_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 648 \
    name P_row_26_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_26_reload \
    op interface \
    ports { P_row_26_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 649 \
    name P_row_27_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_27_reload \
    op interface \
    ports { P_row_27_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 650 \
    name P_row_28_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_28_reload \
    op interface \
    ports { P_row_28_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 651 \
    name P_row_29_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_29_reload \
    op interface \
    ports { P_row_29_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 652 \
    name P_row_30_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_30_reload \
    op interface \
    ports { P_row_30_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 653 \
    name P_row_31_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_31_reload \
    op interface \
    ports { P_row_31_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 654 \
    name P_row_32_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_32_reload \
    op interface \
    ports { P_row_32_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 655 \
    name P_row_33_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_33_reload \
    op interface \
    ports { P_row_33_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 656 \
    name P_row_34_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_34_reload \
    op interface \
    ports { P_row_34_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 657 \
    name P_row_35_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_35_reload \
    op interface \
    ports { P_row_35_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 658 \
    name P_row_36_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_36_reload \
    op interface \
    ports { P_row_36_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 659 \
    name P_row_37_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_37_reload \
    op interface \
    ports { P_row_37_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 660 \
    name P_row_38_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_38_reload \
    op interface \
    ports { P_row_38_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 661 \
    name P_row_39_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_39_reload \
    op interface \
    ports { P_row_39_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 662 \
    name P_row_40_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_40_reload \
    op interface \
    ports { P_row_40_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 663 \
    name P_row_41_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_41_reload \
    op interface \
    ports { P_row_41_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 664 \
    name P_row_42_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_42_reload \
    op interface \
    ports { P_row_42_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 665 \
    name P_row_43_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_43_reload \
    op interface \
    ports { P_row_43_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 666 \
    name P_row_44_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_44_reload \
    op interface \
    ports { P_row_44_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 667 \
    name P_row_45_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_45_reload \
    op interface \
    ports { P_row_45_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 668 \
    name P_row_46_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_46_reload \
    op interface \
    ports { P_row_46_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 669 \
    name P_row_47_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_47_reload \
    op interface \
    ports { P_row_47_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 670 \
    name P_row_48_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_48_reload \
    op interface \
    ports { P_row_48_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 671 \
    name P_row_49_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_49_reload \
    op interface \
    ports { P_row_49_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 672 \
    name P_row_50_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_50_reload \
    op interface \
    ports { P_row_50_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 673 \
    name P_row_51_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_51_reload \
    op interface \
    ports { P_row_51_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 674 \
    name P_row_52_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_52_reload \
    op interface \
    ports { P_row_52_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 675 \
    name P_row_53_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_53_reload \
    op interface \
    ports { P_row_53_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 676 \
    name P_row_54_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_54_reload \
    op interface \
    ports { P_row_54_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 677 \
    name P_row_55_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_55_reload \
    op interface \
    ports { P_row_55_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 678 \
    name P_row_56_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_56_reload \
    op interface \
    ports { P_row_56_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 679 \
    name P_row_57_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_57_reload \
    op interface \
    ports { P_row_57_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 680 \
    name P_row_58_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_58_reload \
    op interface \
    ports { P_row_58_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 681 \
    name P_row_59_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_59_reload \
    op interface \
    ports { P_row_59_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 682 \
    name P_row_60_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_60_reload \
    op interface \
    ports { P_row_60_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 683 \
    name P_row_61_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_61_reload \
    op interface \
    ports { P_row_61_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 684 \
    name P_row_62_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_62_reload \
    op interface \
    ports { P_row_62_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 685 \
    name P_row_63_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_63_reload \
    op interface \
    ports { P_row_63_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 686 \
    name P_row_64_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_64_reload \
    op interface \
    ports { P_row_64_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 687 \
    name P_row_65_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_65_reload \
    op interface \
    ports { P_row_65_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 688 \
    name P_row_66_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_66_reload \
    op interface \
    ports { P_row_66_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 689 \
    name P_row_67_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_67_reload \
    op interface \
    ports { P_row_67_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 690 \
    name P_row_68_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_68_reload \
    op interface \
    ports { P_row_68_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 691 \
    name P_row_69_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_69_reload \
    op interface \
    ports { P_row_69_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 692 \
    name P_row_70_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_70_reload \
    op interface \
    ports { P_row_70_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 693 \
    name P_row_71_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_71_reload \
    op interface \
    ports { P_row_71_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 694 \
    name P_row_72_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_72_reload \
    op interface \
    ports { P_row_72_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 695 \
    name P_row_73_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_73_reload \
    op interface \
    ports { P_row_73_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 696 \
    name P_row_74_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_74_reload \
    op interface \
    ports { P_row_74_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 697 \
    name P_row_75_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_75_reload \
    op interface \
    ports { P_row_75_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 698 \
    name P_row_76_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_76_reload \
    op interface \
    ports { P_row_76_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 699 \
    name P_row_77_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_77_reload \
    op interface \
    ports { P_row_77_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 700 \
    name P_row_78_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_78_reload \
    op interface \
    ports { P_row_78_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 701 \
    name P_row_79_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_79_reload \
    op interface \
    ports { P_row_79_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 702 \
    name P_row_80_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_80_reload \
    op interface \
    ports { P_row_80_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 703 \
    name P_row_81_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_81_reload \
    op interface \
    ports { P_row_81_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 704 \
    name P_row_82_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_82_reload \
    op interface \
    ports { P_row_82_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 705 \
    name P_row_83_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_83_reload \
    op interface \
    ports { P_row_83_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 706 \
    name P_row_84_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_84_reload \
    op interface \
    ports { P_row_84_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 707 \
    name P_row_85_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_85_reload \
    op interface \
    ports { P_row_85_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 708 \
    name P_row_86_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_86_reload \
    op interface \
    ports { P_row_86_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 709 \
    name P_row_87_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_87_reload \
    op interface \
    ports { P_row_87_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 710 \
    name P_row_88_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_88_reload \
    op interface \
    ports { P_row_88_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 711 \
    name P_row_89_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_89_reload \
    op interface \
    ports { P_row_89_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 712 \
    name P_row_90_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_90_reload \
    op interface \
    ports { P_row_90_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 713 \
    name P_row_91_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_91_reload \
    op interface \
    ports { P_row_91_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 714 \
    name P_row_92_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_92_reload \
    op interface \
    ports { P_row_92_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 715 \
    name P_row_93_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_93_reload \
    op interface \
    ports { P_row_93_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 716 \
    name P_row_94_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_94_reload \
    op interface \
    ports { P_row_94_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 717 \
    name P_row_95_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_95_reload \
    op interface \
    ports { P_row_95_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 718 \
    name P_row_96_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_96_reload \
    op interface \
    ports { P_row_96_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 719 \
    name P_row_97_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_97_reload \
    op interface \
    ports { P_row_97_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 720 \
    name P_row_98_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_98_reload \
    op interface \
    ports { P_row_98_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 721 \
    name P_row_99_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_99_reload \
    op interface \
    ports { P_row_99_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 722 \
    name P_row_100_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_100_reload \
    op interface \
    ports { P_row_100_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 723 \
    name P_row_101_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_101_reload \
    op interface \
    ports { P_row_101_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 724 \
    name P_row_102_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_102_reload \
    op interface \
    ports { P_row_102_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 725 \
    name P_row_103_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_103_reload \
    op interface \
    ports { P_row_103_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 726 \
    name P_row_104_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_104_reload \
    op interface \
    ports { P_row_104_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 727 \
    name P_row_105_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_105_reload \
    op interface \
    ports { P_row_105_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 728 \
    name P_row_106_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_106_reload \
    op interface \
    ports { P_row_106_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 729 \
    name P_row_107_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_107_reload \
    op interface \
    ports { P_row_107_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 730 \
    name P_row_108_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_108_reload \
    op interface \
    ports { P_row_108_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 731 \
    name P_row_109_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_109_reload \
    op interface \
    ports { P_row_109_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 732 \
    name P_row_110_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_110_reload \
    op interface \
    ports { P_row_110_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 733 \
    name P_row_111_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_111_reload \
    op interface \
    ports { P_row_111_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 734 \
    name P_row_112_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_112_reload \
    op interface \
    ports { P_row_112_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 735 \
    name P_row_113_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_113_reload \
    op interface \
    ports { P_row_113_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 736 \
    name P_row_114_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_114_reload \
    op interface \
    ports { P_row_114_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 737 \
    name P_row_115_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_115_reload \
    op interface \
    ports { P_row_115_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 738 \
    name P_row_116_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_116_reload \
    op interface \
    ports { P_row_116_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 739 \
    name P_row_117_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_117_reload \
    op interface \
    ports { P_row_117_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 740 \
    name P_row_118_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_118_reload \
    op interface \
    ports { P_row_118_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 741 \
    name P_row_119_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_119_reload \
    op interface \
    ports { P_row_119_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 742 \
    name P_row_120_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_120_reload \
    op interface \
    ports { P_row_120_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 743 \
    name P_row_121_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_121_reload \
    op interface \
    ports { P_row_121_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 744 \
    name P_row_122_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_122_reload \
    op interface \
    ports { P_row_122_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 745 \
    name P_row_123_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_123_reload \
    op interface \
    ports { P_row_123_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 746 \
    name P_row_124_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_124_reload \
    op interface \
    ports { P_row_124_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 747 \
    name P_row_125_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_125_reload \
    op interface \
    ports { P_row_125_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 748 \
    name P_row_126_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_126_reload \
    op interface \
    ports { P_row_126_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 749 \
    name P_row_127_reload \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_127_reload \
    op interface \
    ports { P_row_127_reload { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 750 \
    name rescale_old \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_rescale_old \
    op interface \
    ports { rescale_old { I 32 vector } } \
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


