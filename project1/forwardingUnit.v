module forwardingUnit(
	input	rst_i,
	//ID_EX
	input	[4:0]	rs,
	input	[4:0]	rt,
	//EX_MEM
	input	[4:0]	mux3_out,
	input	[1:0]	ex_mem_wb_out,
	input	[4:0]	mem_write_reg,
	//MEM_WB
	input	[1:0]	mem_wb_wb,

	output	reg 	[1:0]	forward_a_select,
	output	reg 	[1:0]	forward_b_select
	);

always	@	(negedge rst_i)	begin
	if(~rst_i)begin
		forward_a_select	<=	2'b00;
		forward_b_select	<=	2'b00;
	end
	else begin
	//EX
	if(ex_mem_wb_out[1] &&
		(mux3_out != 0) &&
		(mux3_out == rs))
	begin
		forward_a_select	<=	2'b10;
	end

	if(ex_mem_wb_out[1] &&
		(mux3_out != 0) &&
		(mux3_out == rt))
	begin
		forward_b_select	<=	2'b10;
	end

	//MEM
	if(mem_wb_wb[1] &&
	 	(mem_write_reg != 0) && 
	 	!(ex_mem_wb_out[1] && 
	 	(mux3_out != 0) && 
	 	(mux3_out != rs)) &&
	 	(mem_write_reg == rs))
	begin
		forward_a_select	<=	2'b01;
	end

	if(mem_wb_wb[1] &&
	 	(mem_write_reg != 0) && 
	 	!(ex_mem_wb_out[1] && 
	 	(mux3_out != 0) && 
	 	(mux3_out != rt)) &&
	 	(mem_write_reg == rt))
	begin
		forward_b_select	<=	2'b01;
	end
	end
end
endmodule