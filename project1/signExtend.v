module signExtend(
	data_in,
	data_out
);

input 	[15:0]	data_in;
output	[31:0]	data_out;

assign data_out = {{16{data_in[15]}}, {data_in}};
endmodule