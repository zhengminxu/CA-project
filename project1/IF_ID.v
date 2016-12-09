module IF_ID(
clk_i,
rst_i,
pc4_i,
instr_i,
IFIDWrite_i,
IFFlush_i,
pc4_o,
instr_o);

input   clk_i, rst_i;
input   [31:0]  pc4_i;
input   [31:0]  instr_i;
input   IFIDWrite_i;
input   IFFlush_i;
output reg [31:0]  pc4_o;
output reg [31:0]  instr_o;

reg ini;
initial begin
	ini = 1'b0;
end

always @(posedge clk_i or negedge rst_i) begin
	if(rst_i) begin
        pc4_o <= pc4_i;
    	instr_o <= instr_i;
    	//ini <= 1'b1;
    end
    else begin
    	if(IFFlush_i) begin
    	    pc4_o <= 32'b0;
    	    instr_o <= 32'b0;
    	end
    	else if(IFIDWrite_i == 1'b0) begin
    	    pc4_o <= pc4_o;
    	    instr_o <= instr_o;
    	end
    	else begin
    		pc4_o <= pc4_i;
    	    instr_o <= instr_i;
    	end
    end
end

endmodule
