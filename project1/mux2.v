//使用於 mux 1,2,4,5,8
module mux2(
	input	[31:0]	data1_i, data2_i,
	input	select,
	output	[31:0]	data_o
	);
assign	data_o = select ? data1_i, data2_i;
endmodule