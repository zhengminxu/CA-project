module EX_MEM(
	input clk,
	input	[1:0]	ctrl_wb_in,
	input	[1:0]	ctrl_m_in,
	input	alu_zero,
	input	[31:0]	alu_result_in,
	input	[31:0]	mux7_in,
	input	[4:0]	mux8_in,
	output	reg	[1:0]	ctrl_wb_out,
	output	reg		ctrl_m_mem_write, //size 1
	output	reg		ctrl_m_mem_read, //size 1
	output	reg	zero,
	output	reg	[31:0]	alu_result_out,
	output	reg	[31:0]	mux7_out,
	output	reg [4:0]	mux8_out
);

initial begin
	ctrl_wb_out	<=	0;
	ctrl_m_mem_write	<=	0;
	ctrl_m_mem_read		<=	0;
	zero 	<=	0;
	alu_result_out	<=	0;
	mux7_out	<=	0;
	mux8_out	<=	0;
end

always	@	(posedge	clk)
	begin
		ctrl_wb_out	<=	ctrl_wb_in;
		ctrl_m_mem_write	<=	ctrl_m_in[0];
		ctrl_m_mem_read		<=	ctrl_m_in[1];
		zero 	<=	0;
		alu_result_out	<=	alu_result_in;
		mux7_out	<=	mux7_in;
		mux8_out	<=	mux8_in;
	end
endmodule