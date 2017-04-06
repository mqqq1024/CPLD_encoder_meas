
module sample(clk, ch_sgn_in, ch_sync_in, mcu_n_rst, mcu_rd_clk, sample_end, ram_nrd, ram_nwr, ram_addr, ram_data, addr_base, mem_addr, mem_data, sample_en, sync_cnt);

input clk;
input ch_sgn_in;
input ch_sync_in;
input mcu_n_rst;//0:reset 1:set
input mcu_rd_clk;
input sample_end;

input[19:0] mem_addr;
output[7:0] mem_data;

output ram_nrd;
output ram_nwr;
output[19:0] ram_addr;
inout[7:0] ram_data;

input[19:0] addr_base;
input sample_en;
input[7:0] sync_cnt;

reg[15:0] pulse_cnt;
initial pulse_cnt = 16'b0;
reg[31:0] clk_cnt;
initial clk_cnt = 32'b0;

reg ch_sgn_delay1;
initial ch_sgn_delay1 = 1'b0;
reg ch_sgn_delay2;
initial ch_sgn_delay2 = 1'b0;
reg ch_sync_delay1;
initial ch_sync_delay1 = 1'b0;
reg ch_sync_delay2;
initial ch_sync_delay2 = 1'b0;

reg[19:0] sample_addr;
initial sample_addr = 20'b0;
reg[19:0] sample_addr_tmp;
initial sample_addr_tmp = 20'b0;
reg[31:0] sample_data;
initial sample_data = 32'b0;
//reg ram_nwr_tmp;
//initial ram_nwr_tmp = 1'b0;
reg[7:0] ram_data_tmp;
initial ram_data_tmp = 1'b0;

parameter IDLE = 6'b000001,
			 W0 = 6'b000010,
			 W1 = 6'b000100,
			 W2 = 6'b001000,
			 W3 = 6'b010000,
			 W4 = 6'b100000;
reg[5:0] state;

//assign ram_nwr = sample_end ? 1'b1 : ram_nwr_tmp;
assign ram_nwr = (state==IDLE || state==W0) ? 1'b1 : clk;
assign ram_nrd = sample_end ?  mcu_rd_clk : 1'b1; 
assign ram_addr = sample_end ? mem_addr : sample_addr_tmp;
assign ram_data = sample_end ? 8'hz : ram_data_tmp;
assign mem_data = sample_end ? ram_data : 8'hz;
//assign mem_data = ram_data;

always @ (posedge clk)
begin
   if(!mcu_n_rst || !sample_en || sample_end)
	begin
		state <= IDLE;
	end 
	else
	begin
	clk_cnt <= clk_cnt + 32'h1;
	case (state)
	IDLE: begin
//				ram_nwr_tmp<=1'b1;
				ch_sync_delay1 <= ch_sync_in;
				ch_sync_delay2 <= ch_sync_delay1;
				ch_sgn_delay1 <= ch_sgn_in;
				ch_sgn_delay2 <= ch_sgn_delay1;
				if(ch_sync_delay1 == 1'b1 && ch_sync_delay2 == 1'b0)
					begin		
						pulse_cnt <= 16'b0;
						if(ch_sgn_in)
						begin
							clk_cnt <= 32'h80000000;
						end
						else
						begin
							clk_cnt <= 32'h0;	
						end
						
						if(sync_cnt >= 2)
						begin	
							sample_addr <= {13'b0,{sync_cnt[4:0]-5'd2,2'b00}};
							sample_data <= {15'b0,pulse_cnt};
							state <= W0;
						end	
						else
						begin
							sample_addr <= 20'hz;
							sample_data <= 32'hz;						
							state<=IDLE;
						end
					end
				else if((ch_sgn_delay1 ^ ch_sgn_delay2 == 1'b1) && (sync_cnt >= 1))
					begin
						pulse_cnt <= pulse_cnt + 16'b1;
						sample_addr <= addr_base + {2'b0,{pulse_cnt, 2'b00}};
						sample_data <= clk_cnt;	
						state <= W0;	
					end
				else
					begin
						sample_addr <= 20'hz;
						sample_data <= 32'hz;	
						state<=IDLE;
					end
			end						
		W0:begin
			ram_data_tmp<=sample_data[7:0]; sample_addr_tmp<=sample_addr; state<=W1;
			end
		W1:begin
			ram_data_tmp<=sample_data[15:8]; sample_addr_tmp<=sample_addr+20'd1; state<=W2;
			end
		W2:begin
			ram_data_tmp<=sample_data[23:16]; sample_addr_tmp<=sample_addr+20'd2; state<=W3;
			end
		W3:begin
			ram_data_tmp<=sample_data[31:24]; sample_addr_tmp<=sample_addr+20'd3; state<=W4;
			end	
		W4:begin
			state<=IDLE; 
			end
		default: state<=IDLE; 
		endcase
	end
end

endmodule