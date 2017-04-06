module encoder_meas(clk, mcu_n_rst, mcu_start, mcu_end, mcu_sync, mcu_rd_clk, mcu_data, mcu_data_sel, ch_sgn_in, ch_c_in, ch_sync, ram_nrd, ram_nwr, ram_ncs, ram_addr, ram_data);

input clk, mcu_n_rst;
input mcu_start;
output mcu_end;
output mcu_sync;
input mcu_rd_clk;
output[7:0] mcu_data;
input [2:0] mcu_data_sel;

input[14:0] ch_sgn_in;
input[2:0] ch_c_in;
input ch_sync;

output ram_nrd, ram_nwr, ram_ncs;
output[19:0] ram_addr;
inout[7:0] ram_data;

wire[19:0] mem_addr;
wire[7:0] mem_data;
wire ch_sgn;
wire[19:0] addr_base;
wire sample_en;
wire [15:0] pulse_cnt;//wire
wire [7:0] sync_cnt;
wire [31:0] clk_cnt;
assign ram_ncs = 1'b0;

channel_sel u1(
	.clk(clk),
	.ch_sgn_in(ch_sgn_in),
	.ch_c_in(ch_c_in),
	.ch_sgn_out(ch_sgn),
	.ch_sync_in(ch_sync), 
	.ch_sync_out(mcu_sync), 	
	.mcu_n_rst(mcu_n_rst),
	.mcu_data(mcu_data),
	.sync_cnt_out(sync_cnt),
	.mcu_start(mcu_start),  
	.mcu_end(mcu_end), 
	.mcu_data_sel(mcu_data_sel),
	.addr_base(addr_base),
	.mem_data(mem_data),
	.sample_en(sample_en),
	.pulse_cnt(pulse_cnt),
	.clk_cnt(clk_cnt)
);

sample u2(
	.clk(clk),
	.ch_sgn_in(ch_sgn),
	.ch_sync_in(ch_sync),
	.mcu_n_rst(mcu_n_rst),
	.mcu_rd_clk(mcu_rd_clk),
	.sample_end(mcu_end),
	.ram_nrd(ram_nrd),
	.ram_nwr(ram_nwr),
	.ram_addr(ram_addr),
	.ram_data(ram_data),
	.addr_base(addr_base),
	.mem_addr(mem_addr),
	.mem_data(mem_data),
	.sample_en(sample_en),
	.sync_cnt(sync_cnt),
	.pulse_cnt_out(pulse_cnt),
	.clk_cnt_out(clk_cnt)
);

mcu_rd u3(
	.sample_end(mcu_end),
	.mcu_rd_clk(mcu_rd_clk),
	.mem_addr(mem_addr)
);

endmodule
