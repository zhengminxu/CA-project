module MEM_WB(
	input clk,
	input mem_stall_i,
	input 	[1:0]	ctrl_wb_in,
	input	[31:0]	read_data_in,
	input	[31:0]	alu_result_in,
	input	[4:0]	write_reg_in,
	output reg 	[1:0]	mem_ctrl_wb,
	output reg 	[31:0]	read_data,
	output reg 	[31:0]	mem_alu_result,
	output reg 	[4:0]	mem_write_reg
);


	always @ (posedge clk) begin
		if(mem_stall_i == 1'b1) begin
			mem_ctrl_wb <= mem_ctrl_wb;
			read_data 	<= read_data;
			mem_alu_result	<= mem_alu_result;
			mem_write_reg 	<= mem_write_reg;
		end
		else begin
			mem_ctrl_wb <= ctrl_wb_in;
			read_data 	<= read_data_in;
			mem_alu_result	<= alu_result_in;
			mem_write_reg 	<= write_reg_in;
		end
	end
endmodule