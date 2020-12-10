package require openlane
set script_dir [file dirname [file normalize [info script]]]

prep -design $script_dir -tag CORE_UTILIZATION -overwrite
set save_path $script_dir/../..

run_synthesis
init_floorplan
place_io
run_sta
global_placement_or
tap_decap_or
detailed_placement
run_cts
run_sta
gen_pdn
run_routing
write_powered_verilog
run_magic
run_magic_spice_export
run_magic_drc
generate_final_summary_report
run_lvs
run_magic_antenna_check
generate_final_summary_report


