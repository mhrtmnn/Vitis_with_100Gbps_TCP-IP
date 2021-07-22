### config ###
set debug 0
set debug_ctrl 0
set debug_tcp 0
set debug_udp 0
set debug_VIO_reset 0
#############

# check if PE name was given on CLI
if {[llength $argv] < 5} {
	puts "Need to provide PE name. Usage: 'make ... PE=<name>'"
	exit
}

# get CLI flags
set device         [lindex $argv 0]
set repo_hls_cores [lindex $argv 1]
set src_dir        [lindex $argv 2]
set prj_name       [lindex $argv 3]

# set user_ip_name "ethz.systems.fpga:hls:$prj_name:1.0"
set user_ip_name "esa.informatik.tu-darmstadt.de:user:$prj_name:1.0"
set repo_nw_kernel "../network_krnl/PackagedPE"

puts "===========================================
Using HLS ip repo: $repo_hls_cores
Using NW  ip repo: $repo_nw_kernel
Using USR ip     : $user_ip_name
Using part       : $device
==========================================="

set build_dir "build_ip"
source $src_dir/PE_base.tcl
puts "Base design done!"

if {$debug == 1} {
	if {$debug_ctrl == 1} {
		# jtag axi bridge
		# create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi:1.2 jtag_axi_0
		# connect_bd_intf_net [get_bd_intf_pins jtag_axi_0/M_AXI] [get_bd_intf_pins smartconnect_0/S01_AXI]
		# connect_bd_net [get_bd_ports ap_rst_n_0] [get_bd_pins jtag_axi_0/aresetn]
		# connect_bd_net [get_bd_ports ap_clk_0] [get_bd_pins jtag_axi_0/aclk]

		# ILA
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {S00_AXI_0_1}]
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {smartconnect_0_M00_AXI}]
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {smartconnect_0_M01_AXI}]
		apply_bd_automation -rule xilinx.com:bd_rule:debug -dict [list \
			[get_bd_intf_nets S00_AXI_0_1] {AXI_R_ADDRESS "Data and Trigger" AXI_R_DATA "Data and Trigger" AXI_W_ADDRESS "Data and Trigger" AXI_W_DATA "Data and Trigger" AXI_W_RESPONSE "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets smartconnect_0_M00_AXI] {AXI_R_ADDRESS "Data and Trigger" AXI_R_DATA "Data and Trigger" AXI_W_ADDRESS "Data and Trigger" AXI_W_DATA "Data and Trigger" AXI_W_RESPONSE "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets smartconnect_0_M01_AXI] {AXI_R_ADDRESS "Data and Trigger" AXI_R_DATA "Data and Trigger" AXI_W_ADDRESS "Data and Trigger" AXI_W_DATA "Data and Trigger" AXI_W_RESPONSE "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
		]
	}

	if {$debug_tcp == 1} {
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {user_krnl_0_m_axis_tcp_tx_meta}]
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {user_krnl_0_m_axis_tcp_tx_data}]
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {network_krnl_0_m_axis_tcp_tx_status}]
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {user_krnl_0_m_axis_tcp_open_connection}]
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {network_krnl_0_m_axis_tcp_open_status}]
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {network_krnl_0_m_axis_tcp_notification}]
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {network_krnl_0_m_axis_tcp_rx_meta}]
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {user_krnl_0_m_axis_tcp_read_pkg}]
		set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {network_krnl_0_m_axis_tcp_rx_data}]

		apply_bd_automation -rule xilinx.com:bd_rule:debug -dict [list \
			[get_bd_intf_nets network_krnl_0_m_axis_tcp_tx_status] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets user_krnl_0_m_axis_tcp_tx_data] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets user_krnl_0_m_axis_tcp_tx_meta] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets network_krnl_0_m_axis_tcp_open_status] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets user_krnl_0_m_axis_tcp_open_connection] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets network_krnl_0_m_axis_tcp_notification] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets network_krnl_0_m_axis_tcp_rx_data] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets network_krnl_0_m_axis_tcp_rx_meta] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets user_krnl_0_m_axis_tcp_read_pkg] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
		]
	}

	if {$debug_udp == 1} {
		set_property HDL_ATTRIBUTE.DEBUG true [ \
			get_bd_intf_nets {network_krnl_0_m_axis_udp_rx network_krnl_0_m_axis_udp_rx_meta user_krnl_0_m_axis_udp_tx user_krnl_0_m_axis_udp_tx_meta} \
		]
		apply_bd_automation -rule xilinx.com:bd_rule:debug -dict [list \
			[get_bd_intf_nets network_krnl_0_m_axis_udp_rx] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets network_krnl_0_m_axis_udp_rx_meta] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets user_krnl_0_m_axis_udp_tx] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
			[get_bd_intf_nets user_krnl_0_m_axis_udp_tx_meta] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
		]
	}

	set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {network_krnl_0_axis_net_tx axis_net_rx_0_1}]
	apply_bd_automation -rule xilinx.com:bd_rule:debug -dict [list \
		[get_bd_intf_nets axis_net_rx_0_1] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
		[get_bd_intf_nets network_krnl_0_axis_net_tx] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/ap_clk_0" SYSTEM_ILA "Auto" APC_EN "0" } \
	]
	set_property -dict [list CONFIG.C_ADV_TRIGGER {true} CONFIG.C_DATA_DEPTH {2048}] [get_bd_cells system_ila_0]

	# VIO for manual reset
	if {$debug_VIO_reset == 1} {
		set vio [create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_0]
		set_property -dict [list \
			CONFIG.C_NUM_PROBE_IN {0} \
			CONFIG.C_NUM_PROBE_OUT {1} \
			CONFIG.C_PROBE_OUT1_INIT_VAL {0x1} \
		] $vio
		connect_bd_net [get_bd_pins ap_clk_0] [get_bd_pins $vio/clk]

		set reset_and [create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0]
		set_property -dict [list \
			CONFIG.C_SIZE {1} \
			CONFIG.C_OPERATION {and} \
			CONFIG.LOGO_FILE {data/sym_andgate.png} \
		] $reset_and

		# disconnect_bd_net /ap_rst_n_0_1 [get_bd_pins user_krnl_0/ap_rst_n]
		disconnect_bd_net /ap_rst_n_0_1 [get_bd_pins network_krnl_0/ap_rst_n]
		# connect_bd_net [get_bd_pins $reset_and/Res] [get_bd_pins user_krnl_0/ap_rst_n]
		connect_bd_net [get_bd_pins $reset_and/Res] [get_bd_pins network_krnl_0/ap_rst_n]

		connect_bd_net [get_bd_ports ap_rst_n_0] [get_bd_pins $reset_and/Op1]
		connect_bd_net [get_bd_pins $vio/probe_out0] [get_bd_pins $reset_and/Op2]
	}
}

save_bd_design
generate_target all [get_files  $prj_name.bd]
ipx::package_project -module $prj_name -generated_files -import_files

# do not expose two addr regions, since tapasco does not know how to handle this
# instead expose one with twice the size
ipx::remove_address_block Reg1 [ipx::get_memory_maps S00_AXI_0 -of_objects [ipx::current_core]]
set_property range {0x20000} [ipx::get_address_blocks Reg0 -of_objects [ipx::get_memory_maps S00_AXI_0 -of_objects [ipx::current_core]]]

# clock cfg: prevents ap_clk from becoming non-parameterizable (read-only)
set_property interface_mode monitor [ipx::get_bus_interfaces CLK.AP_CLK_0 -of_objects [ipx::current_core]]
ipx::remove_bus_parameter FREQ_HZ [ipx::get_bus_interfaces CLK.AP_CLK_0 -of_objects [ipx::current_core]]
ipx::remove_bus_parameter PHASE [ipx::get_bus_interfaces CLK.AP_CLK_0 -of_objects [ipx::current_core]]

# export IP core
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core "./$prj_name.zip" [ipx::current_core]

exit
