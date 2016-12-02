module IF_ID(
clk_i,
pc4_i,
instr_i,
IFIDWrite_i,
IFFlush_i,
pc4_o,
instr_o);

input   clk_i;
input   [31:0]  pc4_i;
input   [31:0]  instr_i;
input   IFIDWrite_i;
input   IFFlush_i;
output  [31:0]  pc4_o;
output  [31:0]  instr_o;

initial begin
    pc4_o = 32'b0;
    instr_o = 32'b0;
end

always @(posedge clk) begin
    if(IFFlush_i) begin
        pc4_o <= 32'b0;
        instr_o <= 32'b0;
    end
    else if(IFIDWrite_i) begin
        pc4_o <= pc4_i;
        instr_o <= instr_i;
    end
end

endmodule
