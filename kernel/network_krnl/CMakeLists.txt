cmake_minimum_required(VERSION 3.0)

set (PROJECT_NAME nw_standalone)
project(${PROJECT_NAME})

# Installation
if (DEFINED ENV{IPREPO_DIR})
   set(IPREPO_DIR $ENV{IPREPO_DIR})
elseif(NOT  IPREPO_DIR)
   set(IPREPO_DIR ${CMAKE_CURRENT_SOURCE_DIR}/iprepo/)
endif()

# Find Xilinx Vivado
find_package(Vivado REQUIRED)
if (NOT VIVADO_FOUND)
  message(FATAL_ERROR "Vivado not found.")
endif()


include_directories(${CMAKE_CURRENT_BINARY_DIR})


#Setup custom targets
add_custom_target(nw_standalone
  COMMAND ${VIVADO_BINARY} -mode batch -source ${CMAKE_CURRENT_SOURCE_DIR}/nw_standalone_build.tcl -tclargs ${CMAKE_CURRENT_SOURCE_DIR} ${FPGA_PART} ${IPREPO_DIR}
)
