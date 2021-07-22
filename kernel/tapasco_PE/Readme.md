# 100 Gbps TCP/IP Stack with TaPaSCo

This directory contains build scripts to generate a [TaPaSCo](https://github.com/esa-tu-darmstadt/tapasco) PE with integrated TCP/IP stack.

## Build Instructions

```bash
mkdir build
cd build
cmake .. -DFDEV_NAME=xupvvh -DTCP_STACK_EN=1 -DTCP_STACK_RX_DDR_BYPASS_EN=1 -DDATA_WIDTH=64

# Build the HLS cores
make installip

# Build the Network Kernel
make nw_standalone

# Build the TaPaSCo PE
make tapasco_pe_sim PE=<PE_NAME>
```

In the last command `PE_NAME` is the name of a User Kernel IP core that has been exported to `build/fpga-network-stack/iprepo/`.

## Further Commands
- Export the PE for simulation
> `make tapasco_pe_sim PE=<PE_NAME>`
- Update the User Kernel without rebuilding the whole PE
> `make update_tapasco_pe PE=<PE_NAME>`
