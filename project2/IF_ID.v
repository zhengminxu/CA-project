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
output reg [31:0]  pc4_o;
output reg [31:0]  instr_o;


always @(posedge clk_i) begin
    pc4_o <= pc4_i;
    instr_o <= instr_i;
    
    if(IFFlush_i == 1'b1) begin
        pc4_o <= 32'b0;
        instr_o <= 32'b0;
    end
    if(IFIDWrite_i == 1'b0) begin
        pc4_o <= pc4_o;
        instr_o <= instr_o;
    end
    
    
end

endmodule
