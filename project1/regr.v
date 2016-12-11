module regr #(parameter N = 1)(
	input clk,
	input wire [N-1:0] in,
	output reg [N-1:0] out);

always @(posedge clk)
	out <= in;

endmodule