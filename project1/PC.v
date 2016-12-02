module PC(
clk_i,
PCWrite_i,
pc_i,
pc_o,
);

input   PCWrite_i;
input   clk_i;
input   [31:0]  pc_i;
output  [31:0]  pc_o;

reg [31:0]  pc_o;

initial begin
    pc_o <= 32'b0;
end

always @(posedge clk_i) begin
    if(PCWrite_i)
        pc_o <= pc_i;
    else
        pc_o <= pc_o;
end

endmodule
