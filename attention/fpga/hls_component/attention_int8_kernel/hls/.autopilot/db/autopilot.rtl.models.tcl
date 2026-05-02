set SynModuleInfo {
  {SRCNAME attention_int8_kernel_Pipeline_VITIS_LOOP_101_3_VITIS_LOOP_102_4 MODELNAME attention_int8_kernel_Pipeline_VITIS_LOOP_101_3_VITIS_LOOP_102_4 RTLNAME attention_int8_kernel_attention_int8_kernel_Pipeline_VITIS_LOOP_101_3_VITIS_LOOP_102_4
    SUBMODULES {
      {MODELNAME attention_int8_kernel_flow_control_loop_pipe_sequential_init RTLNAME attention_int8_kernel_flow_control_loop_pipe_sequential_init BINDTYPE interface TYPE internal_upc_flow_control INSTNAME attention_int8_kernel_flow_control_loop_pipe_sequential_init_U}
    }
  }
  {SRCNAME attention_int8_kernel_Pipeline_VITIS_LOOP_108_5 MODELNAME attention_int8_kernel_Pipeline_VITIS_LOOP_108_5 RTLNAME attention_int8_kernel_attention_int8_kernel_Pipeline_VITIS_LOOP_108_5}
  {SRCNAME attention_int8_kernel_Pipeline_VITIS_LOOP_130_8_VITIS_LOOP_131_9 MODELNAME attention_int8_kernel_Pipeline_VITIS_LOOP_130_8_VITIS_LOOP_131_9 RTLNAME attention_int8_kernel_attention_int8_kernel_Pipeline_VITIS_LOOP_130_8_VITIS_LOOP_131_9}
  {SRCNAME attention_int8_kernel_Pipeline_VITIS_LOOP_146_11 MODELNAME attention_int8_kernel_Pipeline_VITIS_LOOP_146_11 RTLNAME attention_int8_kernel_attention_int8_kernel_Pipeline_VITIS_LOOP_146_11
    SUBMODULES {
      {MODELNAME attention_int8_kernel_sitofp_32s_32_6_no_dsp_1 RTLNAME attention_int8_kernel_sitofp_32s_32_6_no_dsp_1 BINDTYPE op TYPE sitofp IMPL auto LATENCY 5 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_mul_8s_8s_16_1_1 RTLNAME attention_int8_kernel_mul_8s_8s_16_1_1 BINDTYPE op TYPE mul IMPL auto LATENCY 0 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_mac_muladd_8s_8s_16s_17_4_1 RTLNAME attention_int8_kernel_mac_muladd_8s_8s_16s_17_4_1 BINDTYPE op TYPE all IMPL dsp_slice LATENCY 3 ALLOW_PRAGMA 1}
    }
  }
  {SRCNAME attention_int8_kernel_Pipeline_VITIS_LOOP_168_14 MODELNAME attention_int8_kernel_Pipeline_VITIS_LOOP_168_14 RTLNAME attention_int8_kernel_attention_int8_kernel_Pipeline_VITIS_LOOP_168_14
    SUBMODULES {
      {MODELNAME attention_int8_kernel_sparsemux_17_3_32_1_1 RTLNAME attention_int8_kernel_sparsemux_17_3_32_1_1 BINDTYPE op TYPE sparsemux IMPL auto}
      {MODELNAME attention_int8_kernel_sparsemux_131_7_32_1_1 RTLNAME attention_int8_kernel_sparsemux_131_7_32_1_1 BINDTYPE op TYPE sparsemux IMPL auto}
    }
  }
  {SRCNAME attention_int8_kernel_Pipeline_VITIS_LOOP_180_16 MODELNAME attention_int8_kernel_Pipeline_VITIS_LOOP_180_16 RTLNAME attention_int8_kernel_attention_int8_kernel_Pipeline_VITIS_LOOP_180_16
    SUBMODULES {
      {MODELNAME attention_int8_kernel_sparsemux_17_3_8_1_1 RTLNAME attention_int8_kernel_sparsemux_17_3_8_1_1 BINDTYPE op TYPE sparsemux IMPL auto}
    }
  }
  {SRCNAME attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19 MODELNAME attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19 RTLNAME attention_int8_kernel_attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19
    SUBMODULES {
      {MODELNAME attention_int8_kernel_sptohp_32ns_16_2_no_dsp_1 RTLNAME attention_int8_kernel_sptohp_32ns_16_2_no_dsp_1 BINDTYPE op TYPE sptohp IMPL auto LATENCY 1 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_sparsemux_129_6_32_1_1 RTLNAME attention_int8_kernel_sparsemux_129_6_32_1_1 BINDTYPE op TYPE sparsemux IMPL auto}
    }
  }
  {SRCNAME attention_int8_kernel MODELNAME attention_int8_kernel RTLNAME attention_int8_kernel IS_TOP 1
    SUBMODULES {
      {MODELNAME attention_int8_kernel_faddfsub_32ns_32ns_32_7_full_dsp_1 RTLNAME attention_int8_kernel_faddfsub_32ns_32ns_32_7_full_dsp_1 BINDTYPE op TYPE fadd IMPL fulldsp LATENCY 6 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_fadd_32ns_32ns_32_7_full_dsp_1 RTLNAME attention_int8_kernel_fadd_32ns_32ns_32_7_full_dsp_1 BINDTYPE op TYPE fadd IMPL fulldsp LATENCY 6 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_fmul_32ns_32ns_32_4_max_dsp_1 RTLNAME attention_int8_kernel_fmul_32ns_32ns_32_4_max_dsp_1 BINDTYPE op TYPE fmul IMPL maxdsp LATENCY 3 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_fdiv_32ns_32ns_32_16_no_dsp_1 RTLNAME attention_int8_kernel_fdiv_32ns_32ns_32_16_no_dsp_1 BINDTYPE op TYPE fdiv IMPL fabric LATENCY 15 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_sitofp_32ns_32_6_no_dsp_1 RTLNAME attention_int8_kernel_sitofp_32ns_32_6_no_dsp_1 BINDTYPE op TYPE sitofp IMPL auto LATENCY 5 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_fcmp_32ns_32ns_1_2_no_dsp_1 RTLNAME attention_int8_kernel_fcmp_32ns_32ns_1_2_no_dsp_1 BINDTYPE op TYPE fcmp IMPL auto LATENCY 1 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_Q_tile_RAM_AUTO_1R1W RTLNAME attention_int8_kernel_Q_tile_RAM_AUTO_1R1W BINDTYPE storage TYPE ram IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_O_tile_RAM_AUTO_1R1W RTLNAME attention_int8_kernel_O_tile_RAM_AUTO_1R1W BINDTYPE storage TYPE ram IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_V_tile_RAM_AUTO_1R1W RTLNAME attention_int8_kernel_V_tile_RAM_AUTO_1R1W BINDTYPE storage TYPE ram IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_scores_RAM_AUTO_1R1W RTLNAME attention_int8_kernel_scores_RAM_AUTO_1R1W BINDTYPE storage TYPE ram IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME attention_int8_kernel_gmem0_m_axi RTLNAME attention_int8_kernel_gmem0_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME attention_int8_kernel_gmem1_m_axi RTLNAME attention_int8_kernel_gmem1_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME attention_int8_kernel_gmem2_m_axi RTLNAME attention_int8_kernel_gmem2_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME attention_int8_kernel_gmem3_m_axi RTLNAME attention_int8_kernel_gmem3_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME attention_int8_kernel_control_s_axi RTLNAME attention_int8_kernel_control_s_axi BINDTYPE interface TYPE interface_s_axilite}
    }
  }
}
