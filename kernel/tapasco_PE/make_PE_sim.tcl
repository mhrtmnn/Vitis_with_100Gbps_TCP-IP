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
set build_dir "build_sim"
source $src_dir/PE_base.tcl
puts "Base design done!"

# delete external pins, connect to internal BRAM instead
delete_bd_objs [get_bd_intf_nets network_krnl_0_m00_axi] [get_bd_intf_ports m00_axi_0]
delete_bd_objs [get_bd_intf_nets network_krnl_0_m01_axi] [get_bd_intf_ports m01_axi_0]

set bram_ctrl [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0]
set_property -dict [list \
	CONFIG.DATA_WIDTH {512} \
	CONFIG.SINGLE_PORT_BRAM {1} \
	CONFIG.ECC_TYPE {0} \
] $bram_ctrl
connect_bd_net [get_bd_ports ap_rst_n_0] [get_bd_pins $bram_ctrl/s_axi_aresetn]
connect_bd_net [get_bd_ports ap_clk_0] [get_bd_pins $bram_ctrl/s_axi_aclk]

set bram_intercon [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_1]
connect_bd_intf_net [get_bd_intf_pins $bram_intercon/M00_AXI] [get_bd_intf_pins $bram_ctrl/S_AXI]
connect_bd_intf_net [get_bd_intf_pins network_krnl_0/m00_axi] [get_bd_intf_pins $bram_intercon/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins network_krnl_0/m01_axi] [get_bd_intf_pins $bram_intercon/S01_AXI]
connect_bd_net [get_bd_ports ap_rst_n_0] [get_bd_pins $bram_intercon/aresetn]
connect_bd_net [get_bd_ports ap_clk_0] [get_bd_pins $bram_intercon/aclk]

set bram_gen [create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0]
set_property -dict [list \
	CONFIG.EN_SAFETY_CKT {false} \
] $bram_gen
connect_bd_intf_net [get_bd_intf_pins $bram_ctrl/BRAM_PORTA] [get_bd_intf_pins $bram_gen/BRAM_PORTA]
assign_bd_address -offset 0x00000000A0000000 -range 1M [get_bd_addr_segs {axi_bram_ctrl_0/S_AXI/Mem0 }]

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
