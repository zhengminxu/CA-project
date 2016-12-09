//使用於 mux 3
module mux_5bits(
	input	[4:0]	data1_i,data2_i,
	input	select,
	output	[4:0]	data_o
	);
assign	data_o = select ? data1_i : data2_i;
endmodule