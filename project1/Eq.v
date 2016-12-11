module Eq
(
data1_i,
data2_i,
eq_o

);

input	[31:0]	data1_i, data2_i;
output reg	eq_o;

always@(*)begin
	eq_o = 1'b0;
	if(data1_i == data2_i)
		eq_o = 1'b1;
end
endmodule