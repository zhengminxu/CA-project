module Data_memory(
clk_i,
MemWrite_i,
MemRead_i,
addr_i,
WriteData_i,
ReadData_o);

input   clk_i;
input   MemWrite_i;
input   MemRead_i;
input   [31:0]  addr_i;
input   [31:0]  WriteData_i;
output reg  [31:0]  ReadData_o;

reg [31:0]  memory  [0:255];

always @(posedge clk_i) begin
    if(MemWrite_i)
        memory[addr_i] <= WriteData_i;
end

always @(posedge clk_i) begin
    if(MemRead_i)
        ReadData_o <= memory[addr_i];
end

endmodule
