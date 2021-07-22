#include <stdio.h>
#include "ethernet_frame_padding.hpp"

int main() {
	int expected, read;
	hls::stream<net_axis<DATA_WIDTH>> in_fifo;
	hls::stream<net_axis<DATA_WIDTH>> out_fifo;

	net_axis<DATA_WIDTH> rvcWord;
	net_axis<DATA_WIDTH> sendWord;

	sendWord.keep = 1;
	sendWord.last = 1;
	sendWord.data = 123;
	in_fifo.write(sendWord);

	expected = (60 * 8 + DATA_WIDTH-1) / DATA_WIDTH;
	read = 0;
	while (read < expected) {
		ethernet_frame_padding(in_fifo, out_fifo);
		if (!out_fifo.empty()) {
			out_fifo.read(rvcWord);
			printf("Pkt %d: last=%s, keep=%s, data=%s\n", read,
				rvcWord.last.to_string().c_str(),
				rvcWord.keep.to_string(16).c_str(),
				rvcWord.data.to_string(10).c_str()
			);
			read++;
		}
	}

	return 0;
}
