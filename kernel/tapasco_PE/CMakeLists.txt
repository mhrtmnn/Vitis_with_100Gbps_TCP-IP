cmake_minimum_required(VERSION 3.0)

set (PROJECT_NAME tapasco_pe)
project(${PROJECT_NAME})

# Find Xilinx Vivado
find_package(Vivado REQUIRED)
if (NOT VIVADO_FOUND)
  message(FATAL_ERROR "Vivado not found.")
endif()

set(PATH_SIM_EXPORT "~/Desktop/sim_export/xsim" CACHE STRING "Path to exported simulation")

include_directories(${CMAKE_CURRENT_BINARY_DIR})

#Setup custom targets
add_custom_target(tapasco_pe
  COMMAND ${VIVADO_BINARY} -mode batch -source ${CMAKE_CURRENT_SOURCE_DIR}/make_PE.tcl -tclargs ${FPGA_PART} ${IPREPO_DIR} ${CMAKE_CURRENT_SOURCE_DIR} $(PE)
)

add_custom_target(tapasco_pe_sim
  COMMAND ${VIVADO_BINARY} -mode batch -source ${CMAKE_CURRENT_SOURCE_DIR}/make_PE_sim.tcl -tclargs ${FPGA_PART} ${IPREPO_DIR} ${CMAKE_CURRENT_SOURCE_DIR} ${PATH_SIM_EXPORT} $(PE)
)

add_custom_target(update_tapasco_pe
  COMMAND ${VIVADO_BINARY} -mode batch -source ${CMAKE_CURRENT_SOURCE_DIR}/update_PE.tcl -tclargs ${PATH_SIM_EXPORT} $(PE)
)
