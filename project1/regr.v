module regr (
	input clk,
	input wire [N-1:0] in,
	output reg [N-1:0] out);

parameter N = 1;

always @(posedge clk)
	out = in;

endmodule