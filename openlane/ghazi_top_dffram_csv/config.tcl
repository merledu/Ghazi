
set script_dir [file dirname [file normalize [info script]]]
set ::env(DESIGN_NAME) ghazi_top_dffram_csv

# Change if needed
set ::env(VERILOG_FILES) [glob $script_dir/../../verilog/rtl/defines.v $script_dir/../../verilog/rtl/ghazi/*.v]
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 2300 3000"
set ::env(FP_CORE_UTIL) 50
set ::env(PL_TARGET_DENSITY) 0.3
set ::env(GENERATE_FINAL_SUMMARY_REPORT) 1
set ::env(SYNTH_STRATEGY) 0 
set ::env(SYNTH_MAX_FANOUT) 4
set ::env(FP_PIN_ORDER_CFG) /$script_dir/pin_order.cfg
set ::env(PDN_CFG) $script_dir/pdn.tcl
set ::env(GLB_RT_MAXLAYER) 5
set ::env(GLB_RT_ALLOW_CONGESTION) 1
set ::env(DIODE_INSERTION_STRATEGY) 3 
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1 
#defaults
set ::env(BASE_SDC_FILE) $script_dir/ghazi_top_dffram_csv.sdc
# Fill this
set ::env(CLOCK_PERIOD) "80"
set ::env(CLOCK_PORT) "wb_clk_i"
