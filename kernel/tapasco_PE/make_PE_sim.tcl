# check if PE name was given on CLI
if {[llength $argv] < 6} {
	puts "Need to provide PE name. Usage: 'make ... PE=<name>'"
	exit
}

# get CLI flags
set device           [lindex $argv 0]
set repo_hls_cores   [lindex $argv 1]
set src_dir          [lindex $argv 2]
set sim_export       [lindex $argv 3]
set prj_name         [lindex $argv 4]

# set user_ip_name "ethz.systems.fpga:hls:$prj_name:1.0"
set user_ip_name "esa.informatik.tu-darmstadt.de:user:$prj_name:1.0"
set repo_nw_kernel "../network_krnl/PackagedPE"

puts "===========================================
Using HLS ip repo: $repo_hls_cores
Using NW  ip repo: $repo_nw_kernel
Using USR ip     : $user_ip_name
Using part       : $device
Using sim dir    : $sim_export
==========================================="

# base design
set use_bram 1
set build_dir "build_sim"
source $src_dir/PE_base.tcl
puts "Base design done!"

save_bd_design
generate_target all [get_files  $prj_name.bd]
ipx::package_project -module $prj_name -generated_files -import_files

# do not expose two addr regions, since tapasco does not know how to handle this
# instead expose one with twice the size
ipx::remove_address_block Reg1 [ipx::get_memory_maps S00_AXI_0 -of_objects [ipx::current_core]]
set_property range {0x20000} [ipx::get_address_blocks Reg0 -of_objects [ipx::get_memory_maps S00_AXI_0 -of_objects [ipx::current_core]]]

# export simulation
set ip_dir [get_property ip.user_files_dir [current_project]]
set_property top $prj_name [current_fileset -simset]
export_simulation -force -simulator xsim -directory $sim_export \
	-ip_user_files_dir $ip_dir -ipstatic_source_dir $ip_dir/ipstatic -use_ip_compiled_libs
