# Convenience Makefile for the FPGA HLS flow.
#
# All real work is done by Vitis HLS; this just chains the stages.
#
# Default targets:
#   make testvectors     — regenerate Q/K/V/reference binaries for both precisions
#   make csim_int8       — C-simulation of the INT8 kernel
#   make cosim_int8      — cycle-accurate RTL cosim
#   make synth_int8      — HLS synthesis, emit csynth.rpt
#   make jsonl_int8      — scrape reports into results/<model>_fpga_u280_int8.jsonl
#   make all_int8        — csim → cosim → synth → jsonl
#
# Overrides:
#   MODEL=starcoder_7b_mqa  VARIANT=MQA  PRECISION=int4  make all_<p>

MODEL     ?= llama2_7b_mha
VARIANT   ?= MHA
PRECISION ?= int8

.PHONY: testvectors csim_int8 cosim_int8 synth_int8 jsonl_int8 all_int8 \
        csim_int4 cosim_int4 synth_int4 jsonl_int4 all_int4 clean

testvectors:
	python scripts/dump_testvectors.py --precision int8
	python scripts/dump_testvectors.py --precision int4

csim_int8:
	vitis_hls -f scripts/run_csim.tcl

cosim_int8:
	vitis_hls -f scripts/run_cosim.tcl

synth_int8:
	vitis_hls -f scripts/run_synth.tcl

jsonl_int8:
	python scripts/parse_reports.py \
	    --model $(MODEL) --variant $(VARIANT) --precision int8 \
	    --csynth reports/csynth.rpt \
	    --cosim  reports/cosim.rpt \
	    --out ../results/$(MODEL)_fpga_u280_int8.jsonl

all_int8: testvectors csim_int8 cosim_int8 synth_int8 jsonl_int8

# ---- INT4 variants below — swap set_top + testbench file in the TCL scripts
#      or run the kernel files independently. Shown here for completeness. ----

csim_int4:
	@echo "Edit scripts/run_csim.tcl: set_top attention_int4_kernel;"
	@echo "     add_files src/attention_int4.cpp  (instead of _int8.cpp)"
	@echo "     add_files -tb tb/tb_attention_int4.cpp"
	@echo "Then re-run: vitis_hls -f scripts/run_csim.tcl"

clean:
	rm -rf hls_project reports/*.rpt reports/summary.txt
