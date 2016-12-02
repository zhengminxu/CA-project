//使用於 mux 1,2,4,5,8
module mux2(
	input	[31:0]	a, b,
	input	select,
	output	[31:0]	c
	);
assign	c = select ? a, b;
endmodule