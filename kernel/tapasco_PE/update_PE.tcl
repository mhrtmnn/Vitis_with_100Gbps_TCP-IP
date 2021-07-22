# check if PE name was given on CLI
if {[llength $argv] < 2} {
	puts "Need to provide PE name. Usage: 'make ... PE=<name>'"
	exit
}

set sim_export [lindex $argv 0]
set prj_name   [lindex $argv 1]

open_project build_sim/$prj_name.xpr

set user_kernel_postfix "_user_krnl_0_0"
set PE_ip [get_ips  $prj_name$user_kernel_postfix]
upgrade_ip -vlnv esa.informatik.tu-darmstadt.de:user:$prj_name:1.0 $PE_ip
generate_target all [get_files  $prj_name.bd]

# export modified simulation
set ip_dir [get_property ip.user_files_dir [current_project]]
set_property top $prj_name [current_fileset -simset]
export_simulation -force -simulator xsim -directory $sim_export \
	-ip_user_files_dir $ip_dir -ipstatic_source_dir $ip_dir/ipstatic -use_ip_compiled_libs

exit
