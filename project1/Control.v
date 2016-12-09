module Control(
Op_i,
ConMux_o,
Branch_o,
Jump_o);

input   [5:0]   Op_i;
output reg  [7:0]   ConMux_o;
output reg  Branch_o;
output reg  Jump_o;

reg r, addi, lw, sw, beq, j;
reg RegWrite, MemtoReg, MemRead, MemWrite, ALUSrc, RegDst;
reg [1:0] ALUOp;

always@(Op_i) begin
	r = !Op_i[5] & !Op_i[4] & !Op_i[3] & !Op_i[2] & !Op_i[1] & !Op_i[0];
	addi = !Op_i[5] & !Op_i[4] & Op_i[3] & Op_i[2] & !Op_i[1] & !Op_i[0];
	lw = Op_i[5] & !Op_i[4] & !Op_i[3] & !Op_i[2] & Op_i[1] & Op_i[0];
	sw = Op_i[5] & !Op_i[4] & Op_i[3] & !Op_i[2] & Op_i[1] & Op_i[0];
	beq = !Op_i[5] & !Op_i[4] & !Op_i[3] & Op_i[2] & !Op_i[1] & !Op_i[0];
	j = !Op_i[5] & !Op_i[4] & !Op_i[3] & !Op_i[2] & Op_i[1] & !Op_i[0];


	RegWrite <= r | lw | addi;
	MemtoReg <= lw;
	MemRead <= lw;
	MemWrite <= sw;
	ALUSrc <= lw | sw | addi;
	ALUOp <= {r, beq};
	RegDst <= r;


	ConMux_o <= {RegWrite, MemtoReg, MemRead, MemWrite, ALUSrc, ALUOp, RegDst};
	Branch_o <= beq;
	Jump_o <= j;
end

endmodule
