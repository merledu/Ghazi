package require openlane
set script_dir [file dirname [file normalize [info script]]]

prep -design $script_dir -tag 23_Dec_without_X_Virus 
set save_path $script_dir/../..
run_magic        
run_magic_spice_export

        if {  [info exists flags_map(-save) ] } {
                if { ! [info exists arg_values(-save_path)] } {
                        set arg_values(-save_path) ""
}
                save_views      -lef_path $::env(magic_result_file_tag).lef \
                        -def_path $::env(tritonRoute_result_file_tag).def \
                        -gds_path $::env(magic_result_file_tag).gds \
                        -mag_path $::env(magic_result_file_tag).mag \
                        -mag_path $::env(magic_result_file_tag).lef.mag \
                        -spice_path $::env(magic_result_file_tag).spice \
                        -verilog_path $::env(CURRENT_NETLIST) \
                        -save_path $arg_values(-save_path) \
                        -tag $::env(RUN_TAG)
        }

        # Physical verification

        run_magic_drc

        run_lvs; # requires run_magic_spice_export

        run_antenna_check

        generate_final_summary_report

        puts_success "Flow Completed Wajeh, Without Fatal Errors."

