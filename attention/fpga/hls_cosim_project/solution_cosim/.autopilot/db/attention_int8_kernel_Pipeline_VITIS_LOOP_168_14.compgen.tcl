# This script segment is generated automatically by AutoPilot

set id 388
set name attention_int8_kernel_mux_83_32_1_1
set corename simcore_mux
set op mux
set stage_num 1
set din0_width 32
set din0_signed 0
set din1_width 32
set din1_signed 0
set din2_width 32
set din2_signed 0
set din3_width 32
set din3_signed 0
set din4_width 32
set din4_signed 0
set din5_width 32
set din5_signed 0
set din6_width 32
set din6_signed 0
set din7_width 32
set din7_signed 0
set din8_width 3
set din8_signed 0
set dout_width 32
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


set id 389
set name attention_int8_kernel_mux_1287_32_1_1
set corename simcore_mux
set op mux
set stage_num 1
set din0_width 32
set din0_signed 0
set din1_width 32
set din1_signed 0
set din2_width 32
set din2_signed 0
set din3_width 32
set din3_signed 0
set din4_width 32
set din4_signed 0
set din5_width 32
set din5_signed 0
set din6_width 32
set din6_signed 0
set din7_width 32
set din7_signed 0
set din8_width 32
set din8_signed 0
set din9_width 32
set din9_signed 0
set din10_width 32
set din10_signed 0
set din11_width 32
set din11_signed 0
set din12_width 32
set din12_signed 0
set din13_width 32
set din13_signed 0
set din14_width 32
set din14_signed 0
set din15_width 32
set din15_signed 0
set din16_width 32
set din16_signed 0
set din17_width 32
set din17_signed 0
set din18_width 32
set din18_signed 0
set din19_width 32
set din19_signed 0
set din20_width 32
set din20_signed 0
set din21_width 32
set din21_signed 0
set din22_width 32
set din22_signed 0
set din23_width 32
set din23_signed 0
set din24_width 32
set din24_signed 0
set din25_width 32
set din25_signed 0
set din26_width 32
set din26_signed 0
set din27_width 32
set din27_signed 0
set din28_width 32
set din28_signed 0
set din29_width 32
set din29_signed 0
set din30_width 32
set din30_signed 0
set din31_width 32
set din31_signed 0
set din32_width 32
set din32_signed 0
set din33_width 32
set din33_signed 0
set din34_width 32
set din34_signed 0
set din35_width 32
set din35_signed 0
set din36_width 32
set din36_signed 0
set din37_width 32
set din37_signed 0
set din38_width 32
set din38_signed 0
set din39_width 32
set din39_signed 0
set din40_width 32
set din40_signed 0
set din41_width 32
set din41_signed 0
set din42_width 32
set din42_signed 0
set din43_width 32
set din43_signed 0
set din44_width 32
set din44_signed 0
set din45_width 32
set din45_signed 0
set din46_width 32
set din46_signed 0
set din47_width 32
set din47_signed 0
set din48_width 32
set din48_signed 0
set din49_width 32
set din49_signed 0
set din50_width 32
set din50_signed 0
set din51_width 32
set din51_signed 0
set din52_width 32
set din52_signed 0
set din53_width 32
set din53_signed 0
set din54_width 32
set din54_signed 0
set din55_width 32
set din55_signed 0
set din56_width 32
set din56_signed 0
set din57_width 32
set din57_signed 0
set din58_width 32
set din58_signed 0
set din59_width 32
set din59_signed 0
set din60_width 32
set din60_signed 0
set din61_width 32
set din61_signed 0
set din62_width 32
set din62_signed 0
set din63_width 32
set din63_signed 0
set din64_width 32
set din64_signed 0
set din65_width 32
set din65_signed 0
set din66_width 32
set din66_signed 0
set din67_width 32
set din67_signed 0
set din68_width 32
set din68_signed 0
set din69_width 32
set din69_signed 0
set din70_width 32
set din70_signed 0
set din71_width 32
set din71_signed 0
set din72_width 32
set din72_signed 0
set din73_width 32
set din73_signed 0
set din74_width 32
set din74_signed 0
set din75_width 32
set din75_signed 0
set din76_width 32
set din76_signed 0
set din77_width 32
set din77_signed 0
set din78_width 32
set din78_signed 0
set din79_width 32
set din79_signed 0
set din80_width 32
set din80_signed 0
set din81_width 32
set din81_signed 0
set din82_width 32
set din82_signed 0
set din83_width 32
set din83_signed 0
set din84_width 32
set din84_signed 0
set din85_width 32
set din85_signed 0
set din86_width 32
set din86_signed 0
set din87_width 32
set din87_signed 0
set din88_width 32
set din88_signed 0
set din89_width 32
set din89_signed 0
set din90_width 32
set din90_signed 0
set din91_width 32
set din91_signed 0
set din92_width 32
set din92_signed 0
set din93_width 32
set din93_signed 0
set din94_width 32
set din94_signed 0
set din95_width 32
set din95_signed 0
set din96_width 32
set din96_signed 0
set din97_width 32
set din97_signed 0
set din98_width 32
set din98_signed 0
set din99_width 32
set din99_signed 0
set din100_width 32
set din100_signed 0
set din101_width 32
set din101_signed 0
set din102_width 32
set din102_signed 0
set din103_width 32
set din103_signed 0
set din104_width 32
set din104_signed 0
set din105_width 32
set din105_signed 0
set din106_width 32
set din106_signed 0
set din107_width 32
set din107_signed 0
set din108_width 32
set din108_signed 0
set din109_width 32
set din109_signed 0
set din110_width 32
set din110_signed 0
set din111_width 32
set din111_signed 0
set din112_width 32
set din112_signed 0
set din113_width 32
set din113_signed 0
set din114_width 32
set din114_signed 0
set din115_width 32
set din115_signed 0
set din116_width 32
set din116_signed 0
set din117_width 32
set din117_signed 0
set din118_width 32
set din118_signed 0
set din119_width 32
set din119_signed 0
set din120_width 32
set din120_signed 0
set din121_width 32
set din121_signed 0
set din122_width 32
set din122_signed 0
set din123_width 32
set din123_signed 0
set din124_width 32
set din124_signed 0
set din125_width 32
set din125_signed 0
set din126_width 32
set din126_signed 0
set din127_width 32
set din127_signed 0
set din128_width 7
set din128_signed 0
set dout_width 32
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
    din9_width ${din9_width} \
    din9_signed ${din9_signed} \
    din10_width ${din10_width} \
    din10_signed ${din10_signed} \
    din11_width ${din11_width} \
    din11_signed ${din11_signed} \
    din12_width ${din12_width} \
    din12_signed ${din12_signed} \
    din13_width ${din13_width} \
    din13_signed ${din13_signed} \
    din14_width ${din14_width} \
    din14_signed ${din14_signed} \
    din15_width ${din15_width} \
    din15_signed ${din15_signed} \
    din16_width ${din16_width} \
    din16_signed ${din16_signed} \
    din17_width ${din17_width} \
    din17_signed ${din17_signed} \
    din18_width ${din18_width} \
    din18_signed ${din18_signed} \
    din19_width ${din19_width} \
    din19_signed ${din19_signed} \
    din20_width ${din20_width} \
    din20_signed ${din20_signed} \
    din21_width ${din21_width} \
    din21_signed ${din21_signed} \
    din22_width ${din22_width} \
    din22_signed ${din22_signed} \
    din23_width ${din23_width} \
    din23_signed ${din23_signed} \
    din24_width ${din24_width} \
    din24_signed ${din24_signed} \
    din25_width ${din25_width} \
    din25_signed ${din25_signed} \
    din26_width ${din26_width} \
    din26_signed ${din26_signed} \
    din27_width ${din27_width} \
    din27_signed ${din27_signed} \
    din28_width ${din28_width} \
    din28_signed ${din28_signed} \
    din29_width ${din29_width} \
    din29_signed ${din29_signed} \
    din30_width ${din30_width} \
    din30_signed ${din30_signed} \
    din31_width ${din31_width} \
    din31_signed ${din31_signed} \
    din32_width ${din32_width} \
    din32_signed ${din32_signed} \
    din33_width ${din33_width} \
    din33_signed ${din33_signed} \
    din34_width ${din34_width} \
    din34_signed ${din34_signed} \
    din35_width ${din35_width} \
    din35_signed ${din35_signed} \
    din36_width ${din36_width} \
    din36_signed ${din36_signed} \
    din37_width ${din37_width} \
    din37_signed ${din37_signed} \
    din38_width ${din38_width} \
    din38_signed ${din38_signed} \
    din39_width ${din39_width} \
    din39_signed ${din39_signed} \
    din40_width ${din40_width} \
    din40_signed ${din40_signed} \
    din41_width ${din41_width} \
    din41_signed ${din41_signed} \
    din42_width ${din42_width} \
    din42_signed ${din42_signed} \
    din43_width ${din43_width} \
    din43_signed ${din43_signed} \
    din44_width ${din44_width} \
    din44_signed ${din44_signed} \
    din45_width ${din45_width} \
    din45_signed ${din45_signed} \
    din46_width ${din46_width} \
    din46_signed ${din46_signed} \
    din47_width ${din47_width} \
    din47_signed ${din47_signed} \
    din48_width ${din48_width} \
    din48_signed ${din48_signed} \
    din49_width ${din49_width} \
    din49_signed ${din49_signed} \
    din50_width ${din50_width} \
    din50_signed ${din50_signed} \
    din51_width ${din51_width} \
    din51_signed ${din51_signed} \
    din52_width ${din52_width} \
    din52_signed ${din52_signed} \
    din53_width ${din53_width} \
    din53_signed ${din53_signed} \
    din54_width ${din54_width} \
    din54_signed ${din54_signed} \
    din55_width ${din55_width} \
    din55_signed ${din55_signed} \
    din56_width ${din56_width} \
    din56_signed ${din56_signed} \
    din57_width ${din57_width} \
    din57_signed ${din57_signed} \
    din58_width ${din58_width} \
    din58_signed ${din58_signed} \
    din59_width ${din59_width} \
    din59_signed ${din59_signed} \
    din60_width ${din60_width} \
    din60_signed ${din60_signed} \
    din61_width ${din61_width} \
    din61_signed ${din61_signed} \
    din62_width ${din62_width} \
    din62_signed ${din62_signed} \
    din63_width ${din63_width} \
    din63_signed ${din63_signed} \
    din64_width ${din64_width} \
    din64_signed ${din64_signed} \
    din65_width ${din65_width} \
    din65_signed ${din65_signed} \
    din66_width ${din66_width} \
    din66_signed ${din66_signed} \
    din67_width ${din67_width} \
    din67_signed ${din67_signed} \
    din68_width ${din68_width} \
    din68_signed ${din68_signed} \
    din69_width ${din69_width} \
    din69_signed ${din69_signed} \
    din70_width ${din70_width} \
    din70_signed ${din70_signed} \
    din71_width ${din71_width} \
    din71_signed ${din71_signed} \
    din72_width ${din72_width} \
    din72_signed ${din72_signed} \
    din73_width ${din73_width} \
    din73_signed ${din73_signed} \
    din74_width ${din74_width} \
    din74_signed ${din74_signed} \
    din75_width ${din75_width} \
    din75_signed ${din75_signed} \
    din76_width ${din76_width} \
    din76_signed ${din76_signed} \
    din77_width ${din77_width} \
    din77_signed ${din77_signed} \
    din78_width ${din78_width} \
    din78_signed ${din78_signed} \
    din79_width ${din79_width} \
    din79_signed ${din79_signed} \
    din80_width ${din80_width} \
    din80_signed ${din80_signed} \
    din81_width ${din81_width} \
    din81_signed ${din81_signed} \
    din82_width ${din82_width} \
    din82_signed ${din82_signed} \
    din83_width ${din83_width} \
    din83_signed ${din83_signed} \
    din84_width ${din84_width} \
    din84_signed ${din84_signed} \
    din85_width ${din85_width} \
    din85_signed ${din85_signed} \
    din86_width ${din86_width} \
    din86_signed ${din86_signed} \
    din87_width ${din87_width} \
    din87_signed ${din87_signed} \
    din88_width ${din88_width} \
    din88_signed ${din88_signed} \
    din89_width ${din89_width} \
    din89_signed ${din89_signed} \
    din90_width ${din90_width} \
    din90_signed ${din90_signed} \
    din91_width ${din91_width} \
    din91_signed ${din91_signed} \
    din92_width ${din92_width} \
    din92_signed ${din92_signed} \
    din93_width ${din93_width} \
    din93_signed ${din93_signed} \
    din94_width ${din94_width} \
    din94_signed ${din94_signed} \
    din95_width ${din95_width} \
    din95_signed ${din95_signed} \
    din96_width ${din96_width} \
    din96_signed ${din96_signed} \
    din97_width ${din97_width} \
    din97_signed ${din97_signed} \
    din98_width ${din98_width} \
    din98_signed ${din98_signed} \
    din99_width ${din99_width} \
    din99_signed ${din99_signed} \
    din100_width ${din100_width} \
    din100_signed ${din100_signed} \
    din101_width ${din101_width} \
    din101_signed ${din101_signed} \
    din102_width ${din102_width} \
    din102_signed ${din102_signed} \
    din103_width ${din103_width} \
    din103_signed ${din103_signed} \
    din104_width ${din104_width} \
    din104_signed ${din104_signed} \
    din105_width ${din105_width} \
    din105_signed ${din105_signed} \
    din106_width ${din106_width} \
    din106_signed ${din106_signed} \
    din107_width ${din107_width} \
    din107_signed ${din107_signed} \
    din108_width ${din108_width} \
    din108_signed ${din108_signed} \
    din109_width ${din109_width} \
    din109_signed ${din109_signed} \
    din110_width ${din110_width} \
    din110_signed ${din110_signed} \
    din111_width ${din111_width} \
    din111_signed ${din111_signed} \
    din112_width ${din112_width} \
    din112_signed ${din112_signed} \
    din113_width ${din113_width} \
    din113_signed ${din113_signed} \
    din114_width ${din114_width} \
    din114_signed ${din114_signed} \
    din115_width ${din115_width} \
    din115_signed ${din115_signed} \
    din116_width ${din116_width} \
    din116_signed ${din116_signed} \
    din117_width ${din117_width} \
    din117_signed ${din117_signed} \
    din118_width ${din118_width} \
    din118_signed ${din118_signed} \
    din119_width ${din119_width} \
    din119_signed ${din119_signed} \
    din120_width ${din120_width} \
    din120_signed ${din120_signed} \
    din121_width ${din121_width} \
    din121_signed ${din121_signed} \
    din122_width ${din122_width} \
    din122_signed ${din122_signed} \
    din123_width ${din123_width} \
    din123_signed ${din123_signed} \
    din124_width ${din124_width} \
    din124_signed ${din124_signed} \
    din125_width ${din125_width} \
    din125_signed ${din125_signed} \
    din126_width ${din126_width} \
    din126_signed ${din126_signed} \
    din127_width ${din127_width} \
    din127_signed ${din127_signed} \
    din128_width ${din128_width} \
    din128_signed ${din128_signed} \
    dout_width ${dout_width} \
}"
} else {
puts "@W \[IMPL-101\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_pipemux, check your platform lib"
}
}


set id 390
set name attention_int8_kernel_mux_6432_32_1_1
set corename simcore_mux
set op mux
set stage_num 1
set din0_width 32
set din0_signed 0
set din1_width 32
set din1_signed 0
set din2_width 32
set din2_signed 0
set din3_width 32
set din3_signed 0
set din4_width 32
set din4_signed 0
set din5_width 32
set din5_signed 0
set din6_width 32
set din6_signed 0
set din7_width 32
set din7_signed 0
set din8_width 32
set din8_signed 0
set din9_width 32
set din9_signed 0
set din10_width 32
set din10_signed 0
set din11_width 32
set din11_signed 0
set din12_width 32
set din12_signed 0
set din13_width 32
set din13_signed 0
set din14_width 32
set din14_signed 0
set din15_width 32
set din15_signed 0
set din16_width 32
set din16_signed 0
set din17_width 32
set din17_signed 0
set din18_width 32
set din18_signed 0
set din19_width 32
set din19_signed 0
set din20_width 32
set din20_signed 0
set din21_width 32
set din21_signed 0
set din22_width 32
set din22_signed 0
set din23_width 32
set din23_signed 0
set din24_width 32
set din24_signed 0
set din25_width 32
set din25_signed 0
set din26_width 32
set din26_signed 0
set din27_width 32
set din27_signed 0
set din28_width 32
set din28_signed 0
set din29_width 32
set din29_signed 0
set din30_width 32
set din30_signed 0
set din31_width 32
set din31_signed 0
set din32_width 32
set din32_signed 0
set din33_width 32
set din33_signed 0
set din34_width 32
set din34_signed 0
set din35_width 32
set din35_signed 0
set din36_width 32
set din36_signed 0
set din37_width 32
set din37_signed 0
set din38_width 32
set din38_signed 0
set din39_width 32
set din39_signed 0
set din40_width 32
set din40_signed 0
set din41_width 32
set din41_signed 0
set din42_width 32
set din42_signed 0
set din43_width 32
set din43_signed 0
set din44_width 32
set din44_signed 0
set din45_width 32
set din45_signed 0
set din46_width 32
set din46_signed 0
set din47_width 32
set din47_signed 0
set din48_width 32
set din48_signed 0
set din49_width 32
set din49_signed 0
set din50_width 32
set din50_signed 0
set din51_width 32
set din51_signed 0
set din52_width 32
set din52_signed 0
set din53_width 32
set din53_signed 0
set din54_width 32
set din54_signed 0
set din55_width 32
set din55_signed 0
set din56_width 32
set din56_signed 0
set din57_width 32
set din57_signed 0
set din58_width 32
set din58_signed 0
set din59_width 32
set din59_signed 0
set din60_width 32
set din60_signed 0
set din61_width 32
set din61_signed 0
set din62_width 32
set din62_signed 0
set din63_width 32
set din63_signed 0
set din64_width 32
set din64_signed 0
set dout_width 32
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
    din9_width ${din9_width} \
    din9_signed ${din9_signed} \
    din10_width ${din10_width} \
    din10_signed ${din10_signed} \
    din11_width ${din11_width} \
    din11_signed ${din11_signed} \
    din12_width ${din12_width} \
    din12_signed ${din12_signed} \
    din13_width ${din13_width} \
    din13_signed ${din13_signed} \
    din14_width ${din14_width} \
    din14_signed ${din14_signed} \
    din15_width ${din15_width} \
    din15_signed ${din15_signed} \
    din16_width ${din16_width} \
    din16_signed ${din16_signed} \
    din17_width ${din17_width} \
    din17_signed ${din17_signed} \
    din18_width ${din18_width} \
    din18_signed ${din18_signed} \
    din19_width ${din19_width} \
    din19_signed ${din19_signed} \
    din20_width ${din20_width} \
    din20_signed ${din20_signed} \
    din21_width ${din21_width} \
    din21_signed ${din21_signed} \
    din22_width ${din22_width} \
    din22_signed ${din22_signed} \
    din23_width ${din23_width} \
    din23_signed ${din23_signed} \
    din24_width ${din24_width} \
    din24_signed ${din24_signed} \
    din25_width ${din25_width} \
    din25_signed ${din25_signed} \
    din26_width ${din26_width} \
    din26_signed ${din26_signed} \
    din27_width ${din27_width} \
    din27_signed ${din27_signed} \
    din28_width ${din28_width} \
    din28_signed ${din28_signed} \
    din29_width ${din29_width} \
    din29_signed ${din29_signed} \
    din30_width ${din30_width} \
    din30_signed ${din30_signed} \
    din31_width ${din31_width} \
    din31_signed ${din31_signed} \
    din32_width ${din32_width} \
    din32_signed ${din32_signed} \
    din33_width ${din33_width} \
    din33_signed ${din33_signed} \
    din34_width ${din34_width} \
    din34_signed ${din34_signed} \
    din35_width ${din35_width} \
    din35_signed ${din35_signed} \
    din36_width ${din36_width} \
    din36_signed ${din36_signed} \
    din37_width ${din37_width} \
    din37_signed ${din37_signed} \
    din38_width ${din38_width} \
    din38_signed ${din38_signed} \
    din39_width ${din39_width} \
    din39_signed ${din39_signed} \
    din40_width ${din40_width} \
    din40_signed ${din40_signed} \
    din41_width ${din41_width} \
    din41_signed ${din41_signed} \
    din42_width ${din42_width} \
    din42_signed ${din42_signed} \
    din43_width ${din43_width} \
    din43_signed ${din43_signed} \
    din44_width ${din44_width} \
    din44_signed ${din44_signed} \
    din45_width ${din45_width} \
    din45_signed ${din45_signed} \
    din46_width ${din46_width} \
    din46_signed ${din46_signed} \
    din47_width ${din47_width} \
    din47_signed ${din47_signed} \
    din48_width ${din48_width} \
    din48_signed ${din48_signed} \
    din49_width ${din49_width} \
    din49_signed ${din49_signed} \
    din50_width ${din50_width} \
    din50_signed ${din50_signed} \
    din51_width ${din51_width} \
    din51_signed ${din51_signed} \
    din52_width ${din52_width} \
    din52_signed ${din52_signed} \
    din53_width ${din53_width} \
    din53_signed ${din53_signed} \
    din54_width ${din54_width} \
    din54_signed ${din54_signed} \
    din55_width ${din55_width} \
    din55_signed ${din55_signed} \
    din56_width ${din56_width} \
    din56_signed ${din56_signed} \
    din57_width ${din57_width} \
    din57_signed ${din57_signed} \
    din58_width ${din58_width} \
    din58_signed ${din58_signed} \
    din59_width ${din59_width} \
    din59_signed ${din59_signed} \
    din60_width ${din60_width} \
    din60_signed ${din60_signed} \
    din61_width ${din61_width} \
    din61_signed ${din61_signed} \
    din62_width ${din62_width} \
    din62_signed ${din62_signed} \
    din63_width ${din63_width} \
    din63_signed ${din63_signed} \
    din64_width ${din64_width} \
    din64_signed ${din64_signed} \
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
    id 396 \
    name scores \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename scores \
    op interface \
    ports { scores_address0 { O 7 vector } scores_ce0 { O 1 bit } scores_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 397 \
    name scores_1 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename scores_1 \
    op interface \
    ports { scores_1_address0 { O 7 vector } scores_1_ce0 { O 1 bit } scores_1_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_1'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 398 \
    name scores_2 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename scores_2 \
    op interface \
    ports { scores_2_address0 { O 7 vector } scores_2_ce0 { O 1 bit } scores_2_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_2'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 399 \
    name scores_3 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename scores_3 \
    op interface \
    ports { scores_3_address0 { O 7 vector } scores_3_ce0 { O 1 bit } scores_3_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_3'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 400 \
    name scores_4 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename scores_4 \
    op interface \
    ports { scores_4_address0 { O 7 vector } scores_4_ce0 { O 1 bit } scores_4_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_4'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 401 \
    name scores_5 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename scores_5 \
    op interface \
    ports { scores_5_address0 { O 7 vector } scores_5_ce0 { O 1 bit } scores_5_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_5'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 402 \
    name scores_6 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename scores_6 \
    op interface \
    ports { scores_6_address0 { O 7 vector } scores_6_ce0 { O 1 bit } scores_6_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_6'"
}
}


# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 403 \
    name scores_7 \
    reset_level 1 \
    sync_rst true \
    dir I \
    corename scores_7 \
    op interface \
    ports { scores_7_address0 { O 7 vector } scores_7_ce0 { O 1 bit } scores_7_q0 { I 32 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'scores_7'"
}
}


# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 394 \
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
    id 395 \
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
    id 404 \
    name m_new \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_m_new \
    op interface \
    ports { m_new { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 405 \
    name P_row_127_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_127_out \
    op interface \
    ports { P_row_127_out { O 32 vector } P_row_127_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 406 \
    name P_row_126_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_126_out \
    op interface \
    ports { P_row_126_out { O 32 vector } P_row_126_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 407 \
    name P_row_125_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_125_out \
    op interface \
    ports { P_row_125_out { O 32 vector } P_row_125_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 408 \
    name P_row_124_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_124_out \
    op interface \
    ports { P_row_124_out { O 32 vector } P_row_124_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 409 \
    name P_row_123_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_123_out \
    op interface \
    ports { P_row_123_out { O 32 vector } P_row_123_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 410 \
    name P_row_122_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_122_out \
    op interface \
    ports { P_row_122_out { O 32 vector } P_row_122_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 411 \
    name P_row_121_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_121_out \
    op interface \
    ports { P_row_121_out { O 32 vector } P_row_121_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 412 \
    name P_row_120_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_120_out \
    op interface \
    ports { P_row_120_out { O 32 vector } P_row_120_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 413 \
    name P_row_119_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_119_out \
    op interface \
    ports { P_row_119_out { O 32 vector } P_row_119_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 414 \
    name P_row_118_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_118_out \
    op interface \
    ports { P_row_118_out { O 32 vector } P_row_118_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 415 \
    name P_row_117_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_117_out \
    op interface \
    ports { P_row_117_out { O 32 vector } P_row_117_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 416 \
    name P_row_116_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_116_out \
    op interface \
    ports { P_row_116_out { O 32 vector } P_row_116_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 417 \
    name P_row_115_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_115_out \
    op interface \
    ports { P_row_115_out { O 32 vector } P_row_115_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 418 \
    name P_row_114_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_114_out \
    op interface \
    ports { P_row_114_out { O 32 vector } P_row_114_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 419 \
    name P_row_113_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_113_out \
    op interface \
    ports { P_row_113_out { O 32 vector } P_row_113_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 420 \
    name P_row_112_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_112_out \
    op interface \
    ports { P_row_112_out { O 32 vector } P_row_112_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 421 \
    name P_row_111_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_111_out \
    op interface \
    ports { P_row_111_out { O 32 vector } P_row_111_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 422 \
    name P_row_110_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_110_out \
    op interface \
    ports { P_row_110_out { O 32 vector } P_row_110_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 423 \
    name P_row_109_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_109_out \
    op interface \
    ports { P_row_109_out { O 32 vector } P_row_109_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 424 \
    name P_row_108_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_108_out \
    op interface \
    ports { P_row_108_out { O 32 vector } P_row_108_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 425 \
    name P_row_107_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_107_out \
    op interface \
    ports { P_row_107_out { O 32 vector } P_row_107_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 426 \
    name P_row_106_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_106_out \
    op interface \
    ports { P_row_106_out { O 32 vector } P_row_106_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 427 \
    name P_row_105_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_105_out \
    op interface \
    ports { P_row_105_out { O 32 vector } P_row_105_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 428 \
    name P_row_104_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_104_out \
    op interface \
    ports { P_row_104_out { O 32 vector } P_row_104_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 429 \
    name P_row_103_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_103_out \
    op interface \
    ports { P_row_103_out { O 32 vector } P_row_103_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 430 \
    name P_row_102_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_102_out \
    op interface \
    ports { P_row_102_out { O 32 vector } P_row_102_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 431 \
    name P_row_101_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_101_out \
    op interface \
    ports { P_row_101_out { O 32 vector } P_row_101_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 432 \
    name P_row_100_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_100_out \
    op interface \
    ports { P_row_100_out { O 32 vector } P_row_100_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 433 \
    name P_row_99_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_99_out \
    op interface \
    ports { P_row_99_out { O 32 vector } P_row_99_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 434 \
    name P_row_98_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_98_out \
    op interface \
    ports { P_row_98_out { O 32 vector } P_row_98_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 435 \
    name P_row_97_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_97_out \
    op interface \
    ports { P_row_97_out { O 32 vector } P_row_97_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 436 \
    name P_row_96_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_96_out \
    op interface \
    ports { P_row_96_out { O 32 vector } P_row_96_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 437 \
    name P_row_95_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_95_out \
    op interface \
    ports { P_row_95_out { O 32 vector } P_row_95_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 438 \
    name P_row_94_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_94_out \
    op interface \
    ports { P_row_94_out { O 32 vector } P_row_94_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 439 \
    name P_row_93_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_93_out \
    op interface \
    ports { P_row_93_out { O 32 vector } P_row_93_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 440 \
    name P_row_92_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_92_out \
    op interface \
    ports { P_row_92_out { O 32 vector } P_row_92_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 441 \
    name P_row_91_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_91_out \
    op interface \
    ports { P_row_91_out { O 32 vector } P_row_91_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 442 \
    name P_row_90_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_90_out \
    op interface \
    ports { P_row_90_out { O 32 vector } P_row_90_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 443 \
    name P_row_89_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_89_out \
    op interface \
    ports { P_row_89_out { O 32 vector } P_row_89_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 444 \
    name P_row_88_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_88_out \
    op interface \
    ports { P_row_88_out { O 32 vector } P_row_88_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 445 \
    name P_row_87_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_87_out \
    op interface \
    ports { P_row_87_out { O 32 vector } P_row_87_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 446 \
    name P_row_86_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_86_out \
    op interface \
    ports { P_row_86_out { O 32 vector } P_row_86_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 447 \
    name P_row_85_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_85_out \
    op interface \
    ports { P_row_85_out { O 32 vector } P_row_85_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 448 \
    name P_row_84_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_84_out \
    op interface \
    ports { P_row_84_out { O 32 vector } P_row_84_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 449 \
    name P_row_83_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_83_out \
    op interface \
    ports { P_row_83_out { O 32 vector } P_row_83_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 450 \
    name P_row_82_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_82_out \
    op interface \
    ports { P_row_82_out { O 32 vector } P_row_82_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 451 \
    name P_row_81_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_81_out \
    op interface \
    ports { P_row_81_out { O 32 vector } P_row_81_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 452 \
    name P_row_80_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_80_out \
    op interface \
    ports { P_row_80_out { O 32 vector } P_row_80_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 453 \
    name P_row_79_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_79_out \
    op interface \
    ports { P_row_79_out { O 32 vector } P_row_79_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 454 \
    name P_row_78_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_78_out \
    op interface \
    ports { P_row_78_out { O 32 vector } P_row_78_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 455 \
    name P_row_77_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_77_out \
    op interface \
    ports { P_row_77_out { O 32 vector } P_row_77_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 456 \
    name P_row_76_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_76_out \
    op interface \
    ports { P_row_76_out { O 32 vector } P_row_76_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 457 \
    name P_row_75_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_75_out \
    op interface \
    ports { P_row_75_out { O 32 vector } P_row_75_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 458 \
    name P_row_74_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_74_out \
    op interface \
    ports { P_row_74_out { O 32 vector } P_row_74_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 459 \
    name P_row_73_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_73_out \
    op interface \
    ports { P_row_73_out { O 32 vector } P_row_73_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 460 \
    name P_row_72_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_72_out \
    op interface \
    ports { P_row_72_out { O 32 vector } P_row_72_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 461 \
    name P_row_71_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_71_out \
    op interface \
    ports { P_row_71_out { O 32 vector } P_row_71_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 462 \
    name P_row_70_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_70_out \
    op interface \
    ports { P_row_70_out { O 32 vector } P_row_70_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 463 \
    name P_row_69_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_69_out \
    op interface \
    ports { P_row_69_out { O 32 vector } P_row_69_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 464 \
    name P_row_68_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_68_out \
    op interface \
    ports { P_row_68_out { O 32 vector } P_row_68_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 465 \
    name P_row_67_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_67_out \
    op interface \
    ports { P_row_67_out { O 32 vector } P_row_67_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 466 \
    name P_row_66_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_66_out \
    op interface \
    ports { P_row_66_out { O 32 vector } P_row_66_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 467 \
    name P_row_65_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_65_out \
    op interface \
    ports { P_row_65_out { O 32 vector } P_row_65_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 468 \
    name P_row_64_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_64_out \
    op interface \
    ports { P_row_64_out { O 32 vector } P_row_64_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 469 \
    name P_row_63_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_63_out \
    op interface \
    ports { P_row_63_out { O 32 vector } P_row_63_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 470 \
    name P_row_62_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_62_out \
    op interface \
    ports { P_row_62_out { O 32 vector } P_row_62_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 471 \
    name P_row_61_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_61_out \
    op interface \
    ports { P_row_61_out { O 32 vector } P_row_61_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 472 \
    name P_row_60_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_60_out \
    op interface \
    ports { P_row_60_out { O 32 vector } P_row_60_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 473 \
    name P_row_59_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_59_out \
    op interface \
    ports { P_row_59_out { O 32 vector } P_row_59_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 474 \
    name P_row_58_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_58_out \
    op interface \
    ports { P_row_58_out { O 32 vector } P_row_58_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 475 \
    name P_row_57_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_57_out \
    op interface \
    ports { P_row_57_out { O 32 vector } P_row_57_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 476 \
    name P_row_56_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_56_out \
    op interface \
    ports { P_row_56_out { O 32 vector } P_row_56_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 477 \
    name P_row_55_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_55_out \
    op interface \
    ports { P_row_55_out { O 32 vector } P_row_55_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 478 \
    name P_row_54_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_54_out \
    op interface \
    ports { P_row_54_out { O 32 vector } P_row_54_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 479 \
    name P_row_53_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_53_out \
    op interface \
    ports { P_row_53_out { O 32 vector } P_row_53_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 480 \
    name P_row_52_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_52_out \
    op interface \
    ports { P_row_52_out { O 32 vector } P_row_52_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 481 \
    name P_row_51_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_51_out \
    op interface \
    ports { P_row_51_out { O 32 vector } P_row_51_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 482 \
    name P_row_50_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_50_out \
    op interface \
    ports { P_row_50_out { O 32 vector } P_row_50_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 483 \
    name P_row_49_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_49_out \
    op interface \
    ports { P_row_49_out { O 32 vector } P_row_49_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 484 \
    name P_row_48_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_48_out \
    op interface \
    ports { P_row_48_out { O 32 vector } P_row_48_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 485 \
    name P_row_47_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_47_out \
    op interface \
    ports { P_row_47_out { O 32 vector } P_row_47_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 486 \
    name P_row_46_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_46_out \
    op interface \
    ports { P_row_46_out { O 32 vector } P_row_46_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 487 \
    name P_row_45_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_45_out \
    op interface \
    ports { P_row_45_out { O 32 vector } P_row_45_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 488 \
    name P_row_44_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_44_out \
    op interface \
    ports { P_row_44_out { O 32 vector } P_row_44_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 489 \
    name P_row_43_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_43_out \
    op interface \
    ports { P_row_43_out { O 32 vector } P_row_43_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 490 \
    name P_row_42_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_42_out \
    op interface \
    ports { P_row_42_out { O 32 vector } P_row_42_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 491 \
    name P_row_41_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_41_out \
    op interface \
    ports { P_row_41_out { O 32 vector } P_row_41_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 492 \
    name P_row_40_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_40_out \
    op interface \
    ports { P_row_40_out { O 32 vector } P_row_40_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 493 \
    name P_row_39_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_39_out \
    op interface \
    ports { P_row_39_out { O 32 vector } P_row_39_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 494 \
    name P_row_38_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_38_out \
    op interface \
    ports { P_row_38_out { O 32 vector } P_row_38_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 495 \
    name P_row_37_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_37_out \
    op interface \
    ports { P_row_37_out { O 32 vector } P_row_37_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 496 \
    name P_row_36_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_36_out \
    op interface \
    ports { P_row_36_out { O 32 vector } P_row_36_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 497 \
    name P_row_35_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_35_out \
    op interface \
    ports { P_row_35_out { O 32 vector } P_row_35_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 498 \
    name P_row_34_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_34_out \
    op interface \
    ports { P_row_34_out { O 32 vector } P_row_34_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 499 \
    name P_row_33_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_33_out \
    op interface \
    ports { P_row_33_out { O 32 vector } P_row_33_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 500 \
    name P_row_32_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_32_out \
    op interface \
    ports { P_row_32_out { O 32 vector } P_row_32_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 501 \
    name P_row_31_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_31_out \
    op interface \
    ports { P_row_31_out { O 32 vector } P_row_31_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 502 \
    name P_row_30_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_30_out \
    op interface \
    ports { P_row_30_out { O 32 vector } P_row_30_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 503 \
    name P_row_29_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_29_out \
    op interface \
    ports { P_row_29_out { O 32 vector } P_row_29_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 504 \
    name P_row_28_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_28_out \
    op interface \
    ports { P_row_28_out { O 32 vector } P_row_28_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 505 \
    name P_row_27_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_27_out \
    op interface \
    ports { P_row_27_out { O 32 vector } P_row_27_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 506 \
    name P_row_26_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_26_out \
    op interface \
    ports { P_row_26_out { O 32 vector } P_row_26_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 507 \
    name P_row_25_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_25_out \
    op interface \
    ports { P_row_25_out { O 32 vector } P_row_25_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 508 \
    name P_row_24_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_24_out \
    op interface \
    ports { P_row_24_out { O 32 vector } P_row_24_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 509 \
    name P_row_23_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_23_out \
    op interface \
    ports { P_row_23_out { O 32 vector } P_row_23_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 510 \
    name P_row_22_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_22_out \
    op interface \
    ports { P_row_22_out { O 32 vector } P_row_22_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 511 \
    name P_row_21_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_21_out \
    op interface \
    ports { P_row_21_out { O 32 vector } P_row_21_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 512 \
    name P_row_20_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_20_out \
    op interface \
    ports { P_row_20_out { O 32 vector } P_row_20_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 513 \
    name P_row_19_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_19_out \
    op interface \
    ports { P_row_19_out { O 32 vector } P_row_19_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 514 \
    name P_row_18_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_18_out \
    op interface \
    ports { P_row_18_out { O 32 vector } P_row_18_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 515 \
    name P_row_17_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_17_out \
    op interface \
    ports { P_row_17_out { O 32 vector } P_row_17_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 516 \
    name P_row_16_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_16_out \
    op interface \
    ports { P_row_16_out { O 32 vector } P_row_16_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 517 \
    name P_row_15_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_15_out \
    op interface \
    ports { P_row_15_out { O 32 vector } P_row_15_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 518 \
    name P_row_14_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_14_out \
    op interface \
    ports { P_row_14_out { O 32 vector } P_row_14_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 519 \
    name P_row_13_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_13_out \
    op interface \
    ports { P_row_13_out { O 32 vector } P_row_13_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 520 \
    name P_row_12_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_12_out \
    op interface \
    ports { P_row_12_out { O 32 vector } P_row_12_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 521 \
    name P_row_11_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_11_out \
    op interface \
    ports { P_row_11_out { O 32 vector } P_row_11_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 522 \
    name P_row_10_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_10_out \
    op interface \
    ports { P_row_10_out { O 32 vector } P_row_10_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 523 \
    name P_row_9_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_9_out \
    op interface \
    ports { P_row_9_out { O 32 vector } P_row_9_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 524 \
    name P_row_8_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_8_out \
    op interface \
    ports { P_row_8_out { O 32 vector } P_row_8_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 525 \
    name P_row_7_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_7_out \
    op interface \
    ports { P_row_7_out { O 32 vector } P_row_7_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 526 \
    name P_row_6_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_6_out \
    op interface \
    ports { P_row_6_out { O 32 vector } P_row_6_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 527 \
    name P_row_5_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_5_out \
    op interface \
    ports { P_row_5_out { O 32 vector } P_row_5_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 528 \
    name P_row_4_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_4_out \
    op interface \
    ports { P_row_4_out { O 32 vector } P_row_4_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 529 \
    name P_row_3_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_3_out \
    op interface \
    ports { P_row_3_out { O 32 vector } P_row_3_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 530 \
    name P_row_2_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_2_out \
    op interface \
    ports { P_row_2_out { O 32 vector } P_row_2_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 531 \
    name P_row_1_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_1_out \
    op interface \
    ports { P_row_1_out { O 32 vector } P_row_1_out_ap_vld { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 532 \
    name P_row_out \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_P_row_out \
    op interface \
    ports { P_row_out { O 32 vector } P_row_out_ap_vld { O 1 bit } } \
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


