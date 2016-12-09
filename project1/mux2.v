//使用於 mux 1,2,4,5,8
module mux2(
	input	[31:0]	data1_i, data2_i,
	input	select,
	output reg  [31:0]	data_o
	);


always@(*)begin
	if (select == 1'b1)
		data_o = data1_i;
	else
		data_o = data2_i;
end
endmodule