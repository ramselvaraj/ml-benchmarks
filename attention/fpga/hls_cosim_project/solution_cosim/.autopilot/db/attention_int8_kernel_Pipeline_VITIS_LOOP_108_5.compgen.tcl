# This script segment is generated automatically by AutoPilot

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
    id 67 \
    name O_tile \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename O_tile \
    op interface \
    ports { O_tile_address0 { O 6 vector } O_tile_ce0 { O 1 bit } O_tile_we0 { O 1 bit } O_tile_d0 { O 32 vector } O_tile_address1 { O 6 vector } O_tile_ce1 { O 1 bit } O_tile_we1 { O 1 bit } O_tile_d1 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 68 \
    name O_tile_1 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename O_tile_1 \
    op interface \
    ports { O_tile_1_address0 { O 6 vector } O_tile_1_ce0 { O 1 bit } O_tile_1_we0 { O 1 bit } O_tile_1_d0 { O 32 vector } O_tile_1_address1 { O 6 vector } O_tile_1_ce1 { O 1 bit } O_tile_1_we1 { O 1 bit } O_tile_1_d1 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_1'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 69 \
    name O_tile_2 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename O_tile_2 \
    op interface \
    ports { O_tile_2_address0 { O 6 vector } O_tile_2_ce0 { O 1 bit } O_tile_2_we0 { O 1 bit } O_tile_2_d0 { O 32 vector } O_tile_2_address1 { O 6 vector } O_tile_2_ce1 { O 1 bit } O_tile_2_we1 { O 1 bit } O_tile_2_d1 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_2'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 70 \
    name O_tile_3 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename O_tile_3 \
    op interface \
    ports { O_tile_3_address0 { O 6 vector } O_tile_3_ce0 { O 1 bit } O_tile_3_we0 { O 1 bit } O_tile_3_d0 { O 32 vector } O_tile_3_address1 { O 6 vector } O_tile_3_ce1 { O 1 bit } O_tile_3_we1 { O 1 bit } O_tile_3_d1 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_3'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 71 \
    name O_tile_4 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename O_tile_4 \
    op interface \
    ports { O_tile_4_address0 { O 6 vector } O_tile_4_ce0 { O 1 bit } O_tile_4_we0 { O 1 bit } O_tile_4_d0 { O 32 vector } O_tile_4_address1 { O 6 vector } O_tile_4_ce1 { O 1 bit } O_tile_4_we1 { O 1 bit } O_tile_4_d1 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_4'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 72 \
    name O_tile_5 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename O_tile_5 \
    op interface \
    ports { O_tile_5_address0 { O 6 vector } O_tile_5_ce0 { O 1 bit } O_tile_5_we0 { O 1 bit } O_tile_5_d0 { O 32 vector } O_tile_5_address1 { O 6 vector } O_tile_5_ce1 { O 1 bit } O_tile_5_we1 { O 1 bit } O_tile_5_d1 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_5'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 73 \
    name O_tile_6 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename O_tile_6 \
    op interface \
    ports { O_tile_6_address0 { O 6 vector } O_tile_6_ce0 { O 1 bit } O_tile_6_we0 { O 1 bit } O_tile_6_d0 { O 32 vector } O_tile_6_address1 { O 6 vector } O_tile_6_ce1 { O 1 bit } O_tile_6_we1 { O 1 bit } O_tile_6_d1 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_6'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 74 \
    name O_tile_7 \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename O_tile_7 \
    op interface \
    ports { O_tile_7_address0 { O 6 vector } O_tile_7_ce0 { O 1 bit } O_tile_7_we0 { O 1 bit } O_tile_7_d0 { O 32 vector } O_tile_7_address1 { O 6 vector } O_tile_7_ce1 { O 1 bit } O_tile_7_we1 { O 1 bit } O_tile_7_d1 { O 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_7'"
}
}


# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 75 \
    name l_state_7_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_7_out \
    op interface \
    ports { l_state_7_out { O 32 vector } l_state_7_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 76 \
    name l_state_6_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_6_out \
    op interface \
    ports { l_state_6_out { O 32 vector } l_state_6_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 77 \
    name l_state_5_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_5_out \
    op interface \
    ports { l_state_5_out { O 32 vector } l_state_5_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 78 \
    name l_state_4_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_4_out \
    op interface \
    ports { l_state_4_out { O 32 vector } l_state_4_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 79 \
    name l_state_3_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_3_out \
    op interface \
    ports { l_state_3_out { O 32 vector } l_state_3_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 80 \
    name l_state_2_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_2_out \
    op interface \
    ports { l_state_2_out { O 32 vector } l_state_2_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 81 \
    name l_state_1_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_1_out \
    op interface \
    ports { l_state_1_out { O 32 vector } l_state_1_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 82 \
    name l_state_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_out \
    op interface \
    ports { l_state_out { O 32 vector } l_state_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 83 \
    name m_state_7_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_m_state_7_out \
    op interface \
    ports { m_state_7_out { O 32 vector } m_state_7_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 84 \
    name m_state_6_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_m_state_6_out \
    op interface \
    ports { m_state_6_out { O 32 vector } m_state_6_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 85 \
    name m_state_5_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_m_state_5_out \
    op interface \
    ports { m_state_5_out { O 32 vector } m_state_5_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 86 \
    name m_state_4_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_m_state_4_out \
    op interface \
    ports { m_state_4_out { O 32 vector } m_state_4_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 87 \
    name m_state_3_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_m_state_3_out \
    op interface \
    ports { m_state_3_out { O 32 vector } m_state_3_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 88 \
    name m_state_2_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_m_state_2_out \
    op interface \
    ports { m_state_2_out { O 32 vector } m_state_2_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 89 \
    name m_state_1_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_m_state_1_out \
    op interface \
    ports { m_state_1_out { O 32 vector } m_state_1_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 90 \
    name m_state_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_m_state_out \
    op interface \
    ports { m_state_out { O 32 vector } m_state_out_ap_vld { O 1 bit } } \
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


