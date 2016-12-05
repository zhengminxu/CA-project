//使用於 mux 6,7
module mux3(
	input 	[31:0]	data1_i, data2_i, data3_i,
	input	[1:0]	select,
	output	reg	[31:0]	data_o
	);
always	@	(*)
	case(select)
		00:	data_o	<=	data3_i;
		01:	data_o	<=	data2_i;
		10:	data_o	<=	data1_i;
	endcase
endmodule