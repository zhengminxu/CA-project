//使用於 mux 6,7
module mux3(
	input 	[31:0]	a, b, c,
	input	[1:0]	select,
	output	reg	[31:0]	d
	);
always	@	(*)
	case(select)
		00:	d	<=	c;
		01:	d	<=	b;
		10:	d	<=	a;
	endcase
endmodule