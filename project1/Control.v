module Control(
Op_i,
ConMux_o,
Branch_o,
Jump_o);

input   [5:0]   Op_i;
output  [7:0]   ConMux_o;
output  Branch_o;
output  Jump_o;

reg r, addi, lw, sw, beq, j;
wire RegWrite, MemtoReg, MemRead, MemWrite, ALUSrc, RegDst;
wire [1:0] ALUOp;

always @(*) begin
    r = !Op_i[5] && !Op_i[4] && !Op_i[3] && !Op_i[2] && !Op_i[1] && !Op_i[0];
    addi = !Op_i[5] && !Op_i[4] && Op_i[3] && Op_i[2] && !Op_i[1] && !Op_i[0];
    lw = Op_i[5] && !Op_i[4] && !Op_i[3] && !Op_i[2] && Op_i[1] && Op_i[0];
    sw = Op_i[5] && !Op_i[4] && Op_i[3] && !Op_i[2] && Op_i[1] && Op_i[0];
    beq = !Op_i[5] && !Op_i[4] && !Op_i[3] && Op_i[2] && !Op_i[1] && !Op_i[0];
    j = !Op_i[5] && !Op_i[4] && !Op_i[3] && !Op_i[2] && Op_i[1] && !Op_i[0];
end

assign RegWrite = r | lw | addi;
assign MemtoReg = lw;
assign MemRead = lw;
assign MemWrite = sw;
assign ALUSrc = lw | sw | addi;
assign ALUOp = {r, beq};
assign RegDst = r;

assign ConMux_o = {RegWrite, MemtoReg, MemRead, MemWrite, ALUSrc, ALUOp, RegDst};
assign Branch_o = beq;
assign Jump_o = j;

endmodule
