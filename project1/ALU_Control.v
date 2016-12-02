module ALU_Control
(
funct_i,
ALUOp_i,
ALUCtrl_o
);

input	[5:0]	funct_i;
input	[1:0]	ALUOp_i;
output reg	[3:0]	ALUCtrl_o;

always@(ALUOp_i or funct_i) begin
	if(ALUOp_i == 2'b10) begin
		case (funct_i)
			6'b100000: ALUCtrl_o <= 4'b0010; //add
			6'b100010: ALUCtrl_o <= 4'b0110; //sub
			6'b100100: ALUCtrl_o <= 4'b0000; //and
			6'b100101: ALUCtrl_o <= 4'b0001; //or
			6'b011000: ALUCtrl_o <= 4'b1010; //mul
			default: ALUCtrl_o <= 4'd0;
		endcase
	end
	else if(ALUOp_i == 2'b00) begin  //lw, sw, addi
		ALUCtrl_o <= 4'b0010;  //add
	end
end
endmodule
