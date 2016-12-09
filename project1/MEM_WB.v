module MEM_WB(
	input clk,
	input 	[1:0]	ctrl_wb_in,
	input	[31:0]	read_data_in,
	input	[31:0]	alu_result_in,
	input	[4:0]	write_reg_in,
	output reg 	[1:0]	mem_ctrl_wb,
	output reg 	[31:0]	read_data,
	output reg 	[31:0]	mem_alu_result,
	output reg 	[4:0]	mem_write_reg
);

	initial
		begin
			mem_ctrl_wb <= 0;
			read_data <= 0;
			mem_alu_result <= 0;
			mem_write_reg <=0;
		end

	always @ (posedge clk)
		begin
			mem_ctrl_wb <= ctrl_wb_in;
			read_data 	<= read_data_in;
			mem_alu_result	<= alu_result_in;
			mem_write_reg 	<= write_reg_in;
		end
endmodule