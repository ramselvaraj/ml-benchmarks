# This script segment is generated automatically by AutoPilot

set name attention_int8_kernel_sptohp_32ns_16_2_no_dsp_1
if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $name BINDTYPE {op} TYPE {sptohp} IMPL {auto} LATENCY 1 ALLOW_PRAGMA 1
}


if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler attention_int8_kernel_sparsemux_129_6_32_1_1 BINDTYPE {op} TYPE {sparsemux} IMPL {auto}
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
    id 2261 \
    name O_tile \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename O_tile \
    op interface \
    ports { O_tile_address0 { O 10 vector } O_tile_ce0 { O 1 bit } O_tile_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 2262 \
    name O_tile_1 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename O_tile_1 \
    op interface \
    ports { O_tile_1_address0 { O 10 vector } O_tile_1_ce0 { O 1 bit } O_tile_1_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_1'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 2263 \
    name O_tile_2 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename O_tile_2 \
    op interface \
    ports { O_tile_2_address0 { O 10 vector } O_tile_2_ce0 { O 1 bit } O_tile_2_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_2'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 2264 \
    name O_tile_3 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename O_tile_3 \
    op interface \
    ports { O_tile_3_address0 { O 10 vector } O_tile_3_ce0 { O 1 bit } O_tile_3_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_3'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 2265 \
    name O_tile_4 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename O_tile_4 \
    op interface \
    ports { O_tile_4_address0 { O 10 vector } O_tile_4_ce0 { O 1 bit } O_tile_4_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_4'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 2266 \
    name O_tile_5 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename O_tile_5 \
    op interface \
    ports { O_tile_5_address0 { O 10 vector } O_tile_5_ce0 { O 1 bit } O_tile_5_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_5'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 2267 \
    name O_tile_6 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename O_tile_6 \
    op interface \
    ports { O_tile_6_address0 { O 10 vector } O_tile_6_ce0 { O 1 bit } O_tile_6_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_6'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 2268 \
    name O_tile_7 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename O_tile_7 \
    op interface \
    ports { O_tile_7_address0 { O 10 vector } O_tile_7_ce0 { O 1 bit } O_tile_7_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'O_tile_7'"
}
}


# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2195 \
    name gmem3 \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_gmem3 \
    op interface \
    ports { m_axi_gmem3_AWVALID { O 1 bit } m_axi_gmem3_AWREADY { I 1 bit } m_axi_gmem3_AWADDR { O 64 vector } m_axi_gmem3_AWID { O 1 vector } m_axi_gmem3_AWLEN { O 32 vector } m_axi_gmem3_AWSIZE { O 3 vector } m_axi_gmem3_AWBURST { O 2 vector } m_axi_gmem3_AWLOCK { O 2 vector } m_axi_gmem3_AWCACHE { O 4 vector } m_axi_gmem3_AWPROT { O 3 vector } m_axi_gmem3_AWQOS { O 4 vector } m_axi_gmem3_AWREGION { O 4 vector } m_axi_gmem3_AWUSER { O 1 vector } m_axi_gmem3_WVALID { O 1 bit } m_axi_gmem3_WREADY { I 1 bit } m_axi_gmem3_WDATA { O 16 vector } m_axi_gmem3_WSTRB { O 2 vector } m_axi_gmem3_WLAST { O 1 bit } m_axi_gmem3_WID { O 1 vector } m_axi_gmem3_WUSER { O 1 vector } m_axi_gmem3_ARVALID { O 1 bit } m_axi_gmem3_ARREADY { I 1 bit } m_axi_gmem3_ARADDR { O 64 vector } m_axi_gmem3_ARID { O 1 vector } m_axi_gmem3_ARLEN { O 32 vector } m_axi_gmem3_ARSIZE { O 3 vector } m_axi_gmem3_ARBURST { O 2 vector } m_axi_gmem3_ARLOCK { O 2 vector } m_axi_gmem3_ARCACHE { O 4 vector } m_axi_gmem3_ARPROT { O 3 vector } m_axi_gmem3_ARQOS { O 4 vector } m_axi_gmem3_ARREGION { O 4 vector } m_axi_gmem3_ARUSER { O 1 vector } m_axi_gmem3_RVALID { I 1 bit } m_axi_gmem3_RREADY { O 1 bit } m_axi_gmem3_RDATA { I 16 vector } m_axi_gmem3_RLAST { I 1 bit } m_axi_gmem3_RID { I 1 vector } m_axi_gmem3_RFIFONUM { I 10 vector } m_axi_gmem3_RUSER { I 1 vector } m_axi_gmem3_RRESP { I 2 vector } m_axi_gmem3_BVALID { I 1 bit } m_axi_gmem3_BREADY { O 1 bit } m_axi_gmem3_BRESP { I 2 vector } m_axi_gmem3_BID { I 1 vector } m_axi_gmem3_BUSER { I 1 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2196 \
    name sext_ln81 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_sext_ln81 \
    op interface \
    ports { sext_ln81 { I 63 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2197 \
    name l_state \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state \
    op interface \
    ports { l_state { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2198 \
    name l_state_1 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_1 \
    op interface \
    ports { l_state_1 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2199 \
    name l_state_2 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_2 \
    op interface \
    ports { l_state_2 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2200 \
    name l_state_3 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_3 \
    op interface \
    ports { l_state_3 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2201 \
    name l_state_4 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_4 \
    op interface \
    ports { l_state_4 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2202 \
    name l_state_5 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_5 \
    op interface \
    ports { l_state_5 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2203 \
    name l_state_6 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_6 \
    op interface \
    ports { l_state_6 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2204 \
    name l_state_7 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_7 \
    op interface \
    ports { l_state_7 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2205 \
    name l_state_8 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_8 \
    op interface \
    ports { l_state_8 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2206 \
    name l_state_9 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_9 \
    op interface \
    ports { l_state_9 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2207 \
    name l_state_10 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_10 \
    op interface \
    ports { l_state_10 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2208 \
    name l_state_11 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_11 \
    op interface \
    ports { l_state_11 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2209 \
    name l_state_12 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_12 \
    op interface \
    ports { l_state_12 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2210 \
    name l_state_13 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_13 \
    op interface \
    ports { l_state_13 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2211 \
    name l_state_14 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_14 \
    op interface \
    ports { l_state_14 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2212 \
    name l_state_15 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_15 \
    op interface \
    ports { l_state_15 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2213 \
    name l_state_16 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_16 \
    op interface \
    ports { l_state_16 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2214 \
    name l_state_17 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_17 \
    op interface \
    ports { l_state_17 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2215 \
    name l_state_18 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_18 \
    op interface \
    ports { l_state_18 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2216 \
    name l_state_19 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_19 \
    op interface \
    ports { l_state_19 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2217 \
    name l_state_20 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_20 \
    op interface \
    ports { l_state_20 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2218 \
    name l_state_21 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_21 \
    op interface \
    ports { l_state_21 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2219 \
    name l_state_22 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_22 \
    op interface \
    ports { l_state_22 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2220 \
    name l_state_23 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_23 \
    op interface \
    ports { l_state_23 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2221 \
    name l_state_24 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_24 \
    op interface \
    ports { l_state_24 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2222 \
    name l_state_25 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_25 \
    op interface \
    ports { l_state_25 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2223 \
    name l_state_26 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_26 \
    op interface \
    ports { l_state_26 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2224 \
    name l_state_27 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_27 \
    op interface \
    ports { l_state_27 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2225 \
    name l_state_28 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_28 \
    op interface \
    ports { l_state_28 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2226 \
    name l_state_29 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_29 \
    op interface \
    ports { l_state_29 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2227 \
    name l_state_30 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_30 \
    op interface \
    ports { l_state_30 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2228 \
    name l_state_31 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_31 \
    op interface \
    ports { l_state_31 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2229 \
    name l_state_32 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_32 \
    op interface \
    ports { l_state_32 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2230 \
    name l_state_33 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_33 \
    op interface \
    ports { l_state_33 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2231 \
    name l_state_34 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_34 \
    op interface \
    ports { l_state_34 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2232 \
    name l_state_35 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_35 \
    op interface \
    ports { l_state_35 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2233 \
    name l_state_36 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_36 \
    op interface \
    ports { l_state_36 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2234 \
    name l_state_37 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_37 \
    op interface \
    ports { l_state_37 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2235 \
    name l_state_38 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_38 \
    op interface \
    ports { l_state_38 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2236 \
    name l_state_39 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_39 \
    op interface \
    ports { l_state_39 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2237 \
    name l_state_40 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_40 \
    op interface \
    ports { l_state_40 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2238 \
    name l_state_41 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_41 \
    op interface \
    ports { l_state_41 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2239 \
    name l_state_42 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_42 \
    op interface \
    ports { l_state_42 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2240 \
    name l_state_43 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_43 \
    op interface \
    ports { l_state_43 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2241 \
    name l_state_44 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_44 \
    op interface \
    ports { l_state_44 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2242 \
    name l_state_45 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_45 \
    op interface \
    ports { l_state_45 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2243 \
    name l_state_46 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_46 \
    op interface \
    ports { l_state_46 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2244 \
    name l_state_47 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_47 \
    op interface \
    ports { l_state_47 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2245 \
    name l_state_48 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_48 \
    op interface \
    ports { l_state_48 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2246 \
    name l_state_49 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_49 \
    op interface \
    ports { l_state_49 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2247 \
    name l_state_50 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_50 \
    op interface \
    ports { l_state_50 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2248 \
    name l_state_51 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_51 \
    op interface \
    ports { l_state_51 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2249 \
    name l_state_52 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_52 \
    op interface \
    ports { l_state_52 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2250 \
    name l_state_53 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_53 \
    op interface \
    ports { l_state_53 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2251 \
    name l_state_54 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_54 \
    op interface \
    ports { l_state_54 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2252 \
    name l_state_55 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_55 \
    op interface \
    ports { l_state_55 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2253 \
    name l_state_56 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_56 \
    op interface \
    ports { l_state_56 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2254 \
    name l_state_57 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_57 \
    op interface \
    ports { l_state_57 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2255 \
    name l_state_58 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_58 \
    op interface \
    ports { l_state_58 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2256 \
    name l_state_59 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_59 \
    op interface \
    ports { l_state_59 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2257 \
    name l_state_60 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_60 \
    op interface \
    ports { l_state_60 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2258 \
    name l_state_61 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_61 \
    op interface \
    ports { l_state_61 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2259 \
    name l_state_62 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_62 \
    op interface \
    ports { l_state_62 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2260 \
    name l_state_63 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_l_state_63 \
    op interface \
    ports { l_state_63 { I 32 vector } } \
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


