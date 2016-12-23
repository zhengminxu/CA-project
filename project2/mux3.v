//使用於 mux 6,7
module muxfor3(
	input 	[31:0]	data1_i, data2_i, data3_i,
	input	[1:0]	select,
	output	reg	[31:0]	data_o
	);
always	@	(*) begin
	case(select)
		2'b00:  data_o	=	data3_i;
		2'b01:	data_o	=	data2_i;
		2'b10:	data_o	=	data1_i;
	endcase
end
endmodule