module PC(
clk_i,
rst_i,
PCWrite_i,
pc_i,
pc_o,
);

input   PCWrite_i;
input   clk_i, rst_i;
input   [31:0]  pc_i;
output reg  [31:0]  pc_o;



always @(posedge clk_i or negedge rst_i) begin
    if(~rst_i)
        pc_o <= 32'b0;
    
    else begin
    	if(PCWrite_i == 1'b0)
    	    pc_o <= pc_o;
    	else
    	    pc_o <= pc_i;
    end
end

endmodule
