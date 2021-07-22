#include "ap_axi_sdata.h"
#include <ap_fixed.h>
#include "ap_int.h"
#include "../../../../common/include/communication.hpp"
#include "hls_stream.h"

ap_uint<64> num2keep(int num) {
     ap_uint<64> keep;
     ap_uint<65> x = 1;
     for (int i=0; i<64; i++) {
          if (i < num) {
               x = 2*x;
          }
     }
     keep = x-1;
     return keep;
}

void traffic_gen(ap_uint<16> bytes_in_pkg, int expectedTxPkgCnt,
                 ap_uint<32> ipAddr, ap_uint<16> dst_port,
                 hls::stream<pkt512>& m_axis_udp_tx,
                 hls::stream<pkt256>& m_axis_udp_tx_meta)
{
#pragma HLS dataflow

     ap_uint<16> my_port = 6666;
     for (int i = 0; i < expectedTxPkgCnt; ++i)
     {
          // announce packet
          pkt256 metaPkt;
          metaPkt.data( 31,  0) = ipAddr;
          metaPkt.data( 63, 32) = ipAddr;
          metaPkt.data( 95, 64) = ipAddr;
          metaPkt.data(127, 96) = ipAddr;
          metaPkt.data(143,128) = dst_port;
          metaPkt.data(159,144) = my_port;
          metaPkt.data(175,160) = bytes_in_pkg;
          m_axis_udp_tx_meta.write(metaPkt);

          // send data
          pkt512 currWord;
          currWord.keep = num2keep(bytes_in_pkg);
          currWord.last = 1;
          currWord.data = 0;
          char s[] = "Hello World! This is a test ... !!!";
          for (int i=0; i<35; i++)
               currWord.data(i*8+7, i*8) = s[i];
          m_axis_udp_tx.write(currWord);
     }
}


extern "C" {
int hls_UDP_send_krnl(
               // Internal Stream
               hls::stream<pkt512>& s_axis_udp_rx, 
               hls::stream<pkt512>& m_axis_udp_tx, 
               hls::stream<pkt256>& s_axis_udp_rx_meta, 
               hls::stream<pkt256>& m_axis_udp_tx_meta, 
               
               hls::stream<pkt16>& m_axis_tcp_listen_port, 
               hls::stream<pkt8>& s_axis_tcp_port_status, 
               hls::stream<pkt64>& m_axis_tcp_open_connection, 
               hls::stream<pkt32>& s_axis_tcp_open_status, 
               hls::stream<pkt16>& m_axis_tcp_close_connection, 
               hls::stream<pkt128>& s_axis_tcp_notification, 
               hls::stream<pkt32>& m_axis_tcp_read_pkg, 
               hls::stream<pkt16>& s_axis_tcp_rx_meta, 
               hls::stream<pkt512>& s_axis_tcp_rx_data, 
               hls::stream<pkt32>& m_axis_tcp_tx_meta, 
               hls::stream<pkt512>& m_axis_tcp_tx_data, 
               hls::stream<pkt64>& s_axis_tcp_tx_status,
               int useConn, 
               int pkgWordCount,
               int basePort, 
               int expectedTxPkgCnt, 
               int baseIpAddress
                      ) {

#pragma HLS INTERFACE axis port = s_axis_udp_rx
#pragma HLS INTERFACE axis port = m_axis_udp_tx
#pragma HLS INTERFACE axis port = s_axis_udp_rx_meta
#pragma HLS INTERFACE axis port = m_axis_udp_tx_meta
#pragma HLS INTERFACE axis port = m_axis_tcp_listen_port
#pragma HLS INTERFACE axis port = s_axis_tcp_port_status
#pragma HLS INTERFACE axis port = m_axis_tcp_open_connection
#pragma HLS INTERFACE axis port = s_axis_tcp_open_status
#pragma HLS INTERFACE axis port = m_axis_tcp_close_connection
#pragma HLS INTERFACE axis port = s_axis_tcp_notification
#pragma HLS INTERFACE axis port = m_axis_tcp_read_pkg
#pragma HLS INTERFACE axis port = s_axis_tcp_rx_meta
#pragma HLS INTERFACE axis port = s_axis_tcp_rx_data
#pragma HLS INTERFACE axis port = m_axis_tcp_tx_meta
#pragma HLS INTERFACE axis port = m_axis_tcp_tx_data
#pragma HLS INTERFACE axis port = s_axis_tcp_tx_status

#pragma HLS dataflow

          // send data via UDP
          traffic_gen(pkgWordCount,
                      expectedTxPkgCnt,
                      baseIpAddress,
                      basePort,
                      m_axis_udp_tx,
                      m_axis_udp_tx_meta);

         
          // tie off unused connections
          tie_off_udp_rx(s_axis_udp_rx, s_axis_udp_rx_meta);

          tie_off_tcp_open_connection(m_axis_tcp_open_connection, 
               s_axis_tcp_open_status);

          tie_off_tcp_listen_port(m_axis_tcp_listen_port, 
               s_axis_tcp_port_status);

          tie_off_tcp_tx(m_axis_tcp_tx_meta, 
                         m_axis_tcp_tx_data, 
                         s_axis_tcp_tx_status);
          
          tie_off_tcp_rx(s_axis_tcp_notification, 
               m_axis_tcp_read_pkg, 
               s_axis_tcp_rx_meta, 
               s_axis_tcp_rx_data);
    
          tie_off_tcp_close_con(m_axis_tcp_close_connection);

          return 0;
     }
}


// --- TB ---

// uint32_t make_ip(uint8_t o0, uint8_t o1, uint8_t o2, uint8_t o3) {
//      return (o0 << 24) | (o1 << 16) | (o2 << 8) | o3;
// }

// int main() {
//      for (int i=0; i<64; i++)
//           printf("Test %3d: tkeep = %s\n", i, num2keep(i).to_string().c_str());


//           pkt512 currWord;
//           currWord.keep = num2keep(35);
//           currWord.last = 1;
//           currWord.data = 0;
//           char s[] = "Hello World! This is a test ... !!!";
//           for (int i=0; i<35; i++)
//                currWord.data(i*8+7, i*8) = s[i];

//           printf("Pkt: %s\n", currWord.data.to_string(16).c_str());

//           uint32_t ipAddr = make_ip(10,3,3,55);
//           pkt256 metaPkt;
//           metaPkt.data( 31,  0) = ipAddr;
//           metaPkt.data( 63, 32) = ipAddr;
//           metaPkt.data( 95, 64) = ipAddr;
//           metaPkt.data(127, 96) = ipAddr;
//           printf("IP = 0x%x\n", ipAddr);
//           printf("Pkt2: %s\n", metaPkt.data.to_string(16).c_str());

// }
