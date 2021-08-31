create_project $prj_name ./$build_dir -part $device -force

# add own IP repos
set old_repo [get_property ip_repo_paths [current_project]]
set_property ip_repo_paths [concat $old_repo [list $repo_nw_kernel $repo_hls_cores]] [current_project]
update_ip_catalog

# new BD
create_bd_design "$prj_name"
open_bd_design "$prj_name.bd"
set_property top $prj_name [get_filesets sources_1]
update_compile_order -fileset sources_1

# instantiate IP cores
create_bd_cell -type ip -vlnv xilinx.com:RTLKernel:network_krnl:1.0 network_krnl_0
create_bd_cell -type ip -vlnv $user_ip_name user_krnl_0

# expose these pins that are later the iface of the PE
make_bd_pins_external  [get_bd_pins user_krnl_0/ap_clk]
make_bd_pins_external  [get_bd_pins user_krnl_0/ap_rst_n]
make_bd_pins_external  [get_bd_pins user_krnl_0/interrupt]

make_bd_intf_pins_external  [get_bd_intf_pins network_krnl_0/axis_net_tx]
make_bd_intf_pins_external  [get_bd_intf_pins network_krnl_0/axis_net_rx]

# connect user -> netwrk
connect_bd_net [get_bd_ports ap_clk_0] [get_bd_pins network_krnl_0/ap_clk]
connect_bd_net [get_bd_ports ap_rst_n_0] [get_bd_pins network_krnl_0/ap_rst_n]
connect_bd_intf_net [get_bd_intf_pins user_krnl_0/m_axis_udp_tx] [get_bd_intf_pins network_krnl_0/s_axis_udp_tx]
connect_bd_intf_net [get_bd_intf_pins user_krnl_0/m_axis_udp_tx_meta] [get_bd_intf_pins network_krnl_0/s_axis_udp_tx_meta]
connect_bd_intf_net [get_bd_intf_pins user_krnl_0/m_axis_tcp_listen_port] [get_bd_intf_pins network_krnl_0/s_axis_tcp_listen_port]
connect_bd_intf_net [get_bd_intf_pins user_krnl_0/m_axis_tcp_open_connection] [get_bd_intf_pins network_krnl_0/s_axis_tcp_open_connection]
connect_bd_intf_net [get_bd_intf_pins user_krnl_0/m_axis_tcp_close_connection] [get_bd_intf_pins network_krnl_0/s_axis_tcp_close_connection]
connect_bd_intf_net [get_bd_intf_pins user_krnl_0/m_axis_tcp_read_pkg] [get_bd_intf_pins network_krnl_0/s_axis_tcp_read_pkg]
connect_bd_intf_net [get_bd_intf_pins user_krnl_0/m_axis_tcp_tx_meta] [get_bd_intf_pins network_krnl_0/s_axis_tcp_tx_meta]
connect_bd_intf_net [get_bd_intf_pins user_krnl_0/m_axis_tcp_tx_data] [get_bd_intf_pins network_krnl_0/s_axis_tcp_tx_data]

# connect netwrk -> user
connect_bd_intf_net [get_bd_intf_pins network_krnl_0/m_axis_udp_rx] [get_bd_intf_pins user_krnl_0/s_axis_udp_rx]
connect_bd_intf_net [get_bd_intf_pins network_krnl_0/m_axis_udp_rx_meta] [get_bd_intf_pins user_krnl_0/s_axis_udp_rx_meta]
connect_bd_intf_net [get_bd_intf_pins network_krnl_0/m_axis_tcp_port_status] [get_bd_intf_pins user_krnl_0/s_axis_tcp_port_status]
connect_bd_intf_net [get_bd_intf_pins network_krnl_0/m_axis_tcp_open_status] [get_bd_intf_pins user_krnl_0/s_axis_tcp_open_status]
connect_bd_intf_net [get_bd_intf_pins network_krnl_0/m_axis_tcp_notification] [get_bd_intf_pins user_krnl_0/s_axis_tcp_notification]
connect_bd_intf_net [get_bd_intf_pins network_krnl_0/m_axis_tcp_rx_meta] [get_bd_intf_pins user_krnl_0/s_axis_tcp_rx_meta]
connect_bd_intf_net [get_bd_intf_pins network_krnl_0/m_axis_tcp_rx_data] [get_bd_intf_pins user_krnl_0/s_axis_tcp_rx_data]
connect_bd_intf_net [get_bd_intf_pins network_krnl_0/m_axis_tcp_tx_status] [get_bd_intf_pins user_krnl_0/s_axis_tcp_tx_status]

# expose both control ports through interconnect
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0
set_property -dict [list CONFIG.NUM_CLKS {1} CONFIG.NUM_MI {2} CONFIG.NUM_SI {1}] [get_bd_cells smartconnect_0]
connect_bd_net [get_bd_pins smartconnect_0/aclk] [get_bd_ports ap_clk_0]
connect_bd_net [get_bd_pins smartconnect_0/aresetn] [get_bd_ports ap_rst_n_0]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins user_krnl_0/s_axi_AXILiteS]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins network_krnl_0/s_axi_control]
make_bd_intf_pins_external  [get_bd_intf_pins smartconnect_0/S00_AXI]
set_property -dict [list CONFIG.ADDR_WIDTH {17} CONFIG.DATA_WIDTH {64} CONFIG.PROTOCOL {AXI4LITE}] [get_bd_intf_ports S00_AXI_0]

# assign addr
assign_bd_address -offset 0x00000 -range 64K [get_bd_addr_segs {user_krnl_0/s_axi_AXILiteS/*}]
assign_bd_address -offset 0x10000 -range 64K [get_bd_addr_segs {network_krnl_0/s_axi_control/Reg0}]

# Memory ports can either attach to tapasco's memory subsystem, or to internal BRAM
if {$use_bram == 1} {
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
	assign_bd_address -offset 0x00000000A0000000 -range 512K [get_bd_addr_segs {axi_bram_ctrl_0/S_AXI/Mem0 }]
} else {
	make_bd_intf_pins_external  [get_bd_intf_pins network_krnl_0/m01_axi]
	make_bd_intf_pins_external  [get_bd_intf_pins network_krnl_0/m00_axi]
}

# simple plugin system to allow for further cores/connections within the PE
set plugin_file "$repo_hls_cores/../../../kernel/tapasco_PE/${prj_name}_plugin.tcl"
if { [file exists $plugin_file] == 1} {
	puts "Running plugin"
	source $plugin_file
}
