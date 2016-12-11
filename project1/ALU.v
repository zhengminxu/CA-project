module ALU
(
ALUCtrl_i,
data1_i,
data2_i,
data_o
);

input		[3:0]	ALUCtrl_i;
input		[31:0]	data1_i, data2_i;
output reg 	[31:0]	data_o;


always@(*) begin
	case (ALUCtrl_i)
		4'b0010: data_o = data1_i + data2_i;
		4'b0110: data_o = data1_i - data2_i;
		4'b0000: data_o = data1_i & data2_i;
		4'b0001: data_o = data1_i | data2_i;
		4'b1010: data_o = data1_i * data2_i;
		default: data_o = 32'd0;
	endcase
end
endmodule