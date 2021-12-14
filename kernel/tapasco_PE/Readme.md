# 100 Gbps TCP/IP Stack with TaPaSCo

This directory contains build scripts to generate a [TaPaSCo](https://github.com/esa-tu-darmstadt/tapasco) PE with integrated TCP/IP stack.

## Build Instructions

```bash
mkdir build
cd build
cmake .. -DFDEV_NAME=xupvvh -DTCP_STACK_EN=1 -DTCP_STACK_RX_DDR_BYPASS_EN=1 -DDATA_WIDTH=64

# Build the individual HLS cores
make installip

# Build the Network Kernel from individual HLS cores
make nw_standalone

# Build and package a TaPaSCo PE
make tapasco_pe PE=<PE_NAME>
```

Notes:
- TCP RX buffers are necessary, for example, for out-of-order reception of TCP segments. Buffers are used by setting `TCP_STACK_RX_DDR_BYPASS_EN=0`.
By default, RX buffers are bypassed, which will lead to improved latencies.
- TCP buffers can be implemented in BRAM by changing `set use_bram 0` to `set use_bram 1` in `kernel/tapasco_PE/make_PE.tcl`
- `FDEV_NAME` can be `xupvvh` or `u280`.
- In the last command, `PE_NAME` is the name of a User Kernel IP core that has previously been copied to `build/fpga-network-stack/iprepo/`.

## Further Build Commands
- Export a simulation model of the PE `PE_NAME` to path `SIM_EXPORT_PATH`
> `make tapasco_pe_sim PE=<PE_NAME> PATH_SIM_EXPORT=<SIM_EXPORT_PATH>`
- Update the User Kernel without rebuilding the whole PE
> `make update_tapasco_pe PE=<PE_NAME>`

## User Kernel IP cores
The User Kernel implements the application layer and interacts with the TCP/IP stack. See also [this figure](../../README.md#architecture-overview).
- HLS-based User Kernel IP cores may use the C++ library in [kernel/common/include/communication.hpp](../common/include/communication.hpp)
- Bluespec-based User Kernel IP cores may use the [BlueNET](https://git.esa.informatik.tu-darmstadt.de/net/bluenet) library

## Example
See [NetSimulator](https://git.esa.informatik.tu-darmstadt.de/net/net-sim) for a **UDP Echo** example design.
