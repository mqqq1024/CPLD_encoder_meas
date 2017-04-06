module channel_sel(clk, ch_sgn_in, ch_sgn_out, ch_sync_in, ch_c_in, ch_sync_out, mcu_n_rst, mcu_data, mcu_start, mcu_end, mcu_data_sel, addr_base, mem_data, sample_en, pulse_cnt, sync_cnt_out, clk_cnt);

input clk;
input[14:0] ch_sgn_in;
input[2:0] ch_c_in;
output ch_sgn_out;
input ch_sync_in;
output ch_sync_out;

input mcu_n_rst;//0:reset 1:set
output[7:0] mcu_data;
reg[7:0] mcu_data;
input[7:0] mem_data;

input mcu_start;
output mcu_end;//tell mcu at the end of test
input [2:0] mcu_data_sel;

output [19:0] addr_base;
output sample_en;
input [15:0] pulse_cnt;
output [7:0] sync_cnt_out;
input [31:0] clk_cnt;

reg[7:0] sync_cnt;
initial sync_cnt = 8'b0;

reg sample_enable;
reg sample_end;//set '1' at the end of test
initial sample_end=1'b0;

parameter MAX_SYNC_NUM=26;

parameter ch1_addr_base=20'h00000;//4k
parameter ch2_addr_base=20'h01000;
parameter ch3_addr_base=20'h02000;
parameter ch4_addr_base=20'h03000;
parameter ch5_addr_base=20'h04000;
parameter ch6_addr_base=20'h05000;
parameter ch7_addr_base=20'h06000;
parameter ch8_addr_base=20'h07000;
parameter ch9_addr_base=20'h08000;
parameter ch10_addr_base=20'h09000;//64k
parameter ch11_addr_base=20'h19000;
parameter ch12_addr_base=20'h29000;
parameter ch13_addr_base=20'h39000;
parameter ch14_addr_base=20'h49000;//4k
parameter ch15_addr_base=20'h4a000;
parameter ch16_addr_base=20'h4b000;
parameter ch17_addr_base=20'h4c000;
parameter ch18_addr_base=20'h4d000;
parameter ch19_addr_base=20'h4e000;
parameter ch20_addr_base=20'h4f000;
parameter ch21_addr_base=20'h50000;
parameter ch22_addr_base=20'h51000;
parameter ch23_addr_base=20'h52000;
parameter ch24_addr_base=20'h53000;
parameter ch25_addr_base=20'h54000;//128k


assign ch_sync_out = (sample_enable&&!sample_end) ? ch_sync_in : 1'b0;//tell mcu the sync signal of cycle num
assign mcu_end = sample_end;
//assign mcu_data = sample_end ? mem_data : sync_cnt;
assign sample_en = sample_enable;

//assign mcu_data = sample_end == 1'b1 ? mem_data :
//						mcu_data_sel == 3'b000 ? sync_cnt:
//						mcu_data_sel == 3'b001 ? pulse_cnt[7:0]:
//						mcu_data_sel == 3'b010 ? pulse_cnt[15:8]:
//						mcu_data_sel == 3'b011 ? clk_cnt[7:0]:
//						mcu_data_sel == 3'b100 ? clk_cnt[15:8]:
//						mcu_data_sel == 3'b101 ? clk_cnt[23:16]:
//						mcu_data_sel == 3'b110 ? clk_cnt[31:24]: 8'h27;


assign sync_cnt_out = sync_cnt;

always @ (*)//(sample_end or mem_data or sync_cnt or pulse_cnt or clk_cnt or mcu_data_sel)
begin
	if(sample_end == 1'b1)
	begin
		mcu_data <= mem_data;
	end
	else if(mcu_data_sel == 3'b000)
	begin
		mcu_data <= sync_cnt;
	end
	else if(mcu_data_sel == 3'b001)
	begin
		mcu_data <= pulse_cnt[7:0];
	end
	else if(mcu_data_sel == 3'b010)
	begin
		mcu_data <= pulse_cnt[15:8];
	end
	else if(mcu_data_sel == 3'b011)
	begin
		mcu_data <= clk_cnt[7:0];
	end
	else if(mcu_data_sel == 3'b100)
	begin
		mcu_data <= clk_cnt[15:8];
	end
	else if(mcu_data_sel == 3'b101)
	begin
		mcu_data <= clk_cnt[23:16];
	end
	else if(mcu_data_sel == 3'b110)
	begin
		mcu_data <= clk_cnt[31:24];
	end
	else
	begin
		mcu_data <= 8'h26;
	end
end

						
always @ (posedge mcu_start, negedge mcu_n_rst)
begin
	if(!mcu_n_rst)
	begin
		sample_enable <= 1'b0;
	end
	else
	begin
		sample_enable <= 1'b1;
	end
end

always @ (posedge ch_sync_in, negedge sample_enable)
begin
	if(!sample_enable)
	begin
	  sync_cnt <= 8'b0;  
	  sample_end <= 1'b0;
	end	
	else
	begin
	  sync_cnt <= sync_cnt + 8'b1;
	  if(sync_cnt >= MAX_SYNC_NUM)
	  begin
		 sync_cnt <= 8'b0;
		 sample_end <= 1'b1; 
	  end
	end
end

assign ch_sgn_out = sync_cnt == 8'd1 ? ch_c_in[0] : //U
						  sync_cnt == 8'd2 ? ch_c_in[1] : //V
						  sync_cnt == 8'd3 ? ch_c_in[2] : //W
						  sync_cnt == 8'd4 ? ch_sgn_in[3] : //U+ /H1 /Hu /H1
						  sync_cnt == 8'd5 ? ch_sgn_in[4] : //U-
						  sync_cnt == 8'd6 ? ch_sgn_in[5] : //V+ /H2 /Hv /H2
						  sync_cnt == 8'd7 ? ch_sgn_in[6] : //V-
						  sync_cnt == 8'd8 ? ch_sgn_in[7] : //W+ /H3 /Hw /H3
						  sync_cnt == 8'd9 ? ch_sgn_in[8] : //W- /H4 /0  /ENCODER SENSOR
						  sync_cnt == 8'd10 ? ch_sgn_in[9] :  //A+ 
						  sync_cnt == 8'd11 ? ch_sgn_in[10] : //A-
						  sync_cnt == 8'd12 ? ch_sgn_in[11] : //B+ 
						  sync_cnt == 8'd13 ? ch_sgn_in[12] : //B-
						  sync_cnt == 8'd14 ? ch_sgn_in[13] : //Z+ 
						  sync_cnt == 8'd15 ? ch_sgn_in[14] : //Z- 
						  sync_cnt == 8'd16 ? ch_c_in[0] ^ ch_c_in[1] : 
						  sync_cnt == 8'd17 ? ch_c_in[0] ^ ch_c_in[2] : 
						  sync_cnt == 8'd18 ? ch_c_in[1] ^ ch_c_in[2] : 
						  sync_cnt == 8'd19 ? ch_sgn_in[3] ^ ch_sgn_in[5] : 
						  sync_cnt == 8'd20 ? ch_sgn_in[3] ^ ch_sgn_in[7] : 
						  sync_cnt == 8'd21 ? ch_sgn_in[5] ^ ch_sgn_in[7] : 
						  sync_cnt == 8'd22 ? ch_c_in[0] ^ ch_sgn_in[3] : 
						  sync_cnt == 8'd23 ? ch_c_in[1] ^ ch_sgn_in[5] : 
						  sync_cnt == 8'd24 ? ch_c_in[2] ^ ch_sgn_in[7] : 
						  sync_cnt == 8'd25 ? ch_sgn_in[9] ^ ch_sgn_in[11] : 1'b0;	
			  
						  
assign addr_base  = sync_cnt == 8'd1 ? ch1_addr_base : 
						  sync_cnt == 8'd2 ? ch2_addr_base : 
						  sync_cnt == 8'd3 ? ch3_addr_base : 
						  sync_cnt == 8'd4 ? ch4_addr_base : 
						  sync_cnt == 8'd5 ? ch5_addr_base : 
						  sync_cnt == 8'd6 ? ch6_addr_base : 
						  sync_cnt == 8'd7 ? ch7_addr_base : 
						  sync_cnt == 8'd8 ? ch8_addr_base : 
						  sync_cnt == 8'd9 ? ch9_addr_base : 
						  sync_cnt == 8'd10 ? ch10_addr_base : 
						  sync_cnt == 8'd11 ? ch11_addr_base : 
						  sync_cnt == 8'd12 ? ch12_addr_base : 
						  sync_cnt == 8'd13 ? ch13_addr_base : 
						  sync_cnt == 8'd14 ? ch14_addr_base : 
						  sync_cnt == 8'd15 ? ch15_addr_base : 
						  sync_cnt == 8'd16 ? ch16_addr_base : 
						  sync_cnt == 8'd17 ? ch17_addr_base : 
						  sync_cnt == 8'd18 ? ch18_addr_base : 
						  sync_cnt == 8'd19 ? ch19_addr_base : 
						  sync_cnt == 8'd20 ? ch20_addr_base : 
						  sync_cnt == 8'd21 ? ch21_addr_base : 
						  sync_cnt == 8'd22 ? ch22_addr_base : 
						  sync_cnt == 8'd23 ? ch23_addr_base : 
						  sync_cnt == 8'd24 ? ch24_addr_base : 
						  sync_cnt == 8'd25 ? ch25_addr_base : 20'h7fff0;
						  
endmodule