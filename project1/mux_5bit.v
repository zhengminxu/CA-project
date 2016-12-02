//使用於 mux 3
module mux_5bits(
	input	[4:0]	a,b,
	input	select,
	output	[4:0]	c
	);
assign	c = select ? a : b;
endmodule
