package require openlane
set script_dir [file dirname [file normalize [info script]]]

prep -design $script_dir -tag 7dec_rc5_updated_2300_3000_TD_0p3 
set save_path $script_dir/../..

run_magic_spice_export
run_lvs
run_magic_antenna_check
generate_final_summary_report


