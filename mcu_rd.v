module mcu_rd(sample_end, mcu_rd_clk, mem_addr);

input sample_end;
input mcu_rd_clk;
output[19:0] mem_addr;

reg[19:0] rd_addr;

assign mem_addr = rd_addr[19:0];

always @ (posedge mcu_rd_clk, negedge sample_end)
begin
	if(!sample_end)
	begin
		rd_addr <= 20'b0;
	end
	else
	begin
		if(rd_addr < 20'h80000)
		begin
			rd_addr <= rd_addr + 1'b1;
		end
		else
		begin
			rd_addr <= 20'b0;
		end
	end
end


endmodule