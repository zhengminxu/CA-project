module Add_PC(
pc_i,
pc_o);

input   [31:0]  pc_i;
output  [31:0]  pc_o;

wire    [31:0]  pc_add;

assign pc_add = pc_i + 4;
assign pc_o = pc_add;

endmodule
