module Eq
(
data1_i,
data2_i,
eq_o

);

input	[31:0]	data1_i, data2_i;
output	eq_o;

always@(*)begin
	if(data1_i == data2_i)
		eq_o = 1'b1;
	else
		eq_o = 1'b0;
end