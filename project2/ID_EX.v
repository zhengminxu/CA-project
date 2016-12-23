module ID_EX
(
input clk,
input [1:0] control_WB_s2, control_MEM_s2,
input [3:0] control_EX_s2, 
input [31:0] pc_s2, rs_data_s2, rt_data_s2,seimm_s2,
input [4:0] rs_addr_s2, rt_addr_s2, rd_addr_s2,
input mem_stall_i,

output reg [1:0] control_WB_s3, control_MEM_s3,
output reg [3:0] control_EX_s3, 
output reg [31:0] pc_s3, rs_data_s3, rt_data_s3,seimm_s3,
output reg [4:0] rs_addr_s3, rt_addr_s3, rt_addr_fw, rd_addr_s3

);

always@(posedge clk)begin
	if(mem_stall_i == 1'b1) begin
		control_WB_s3 <= control_WB_s3;
		control_MEM_s3 <= control_MEM_s3;
		control_EX_s3 <= control_EX_s3;
		pc_s3 <= pc_s3;
		rs_data_s3 <= rs_data_s3;
		rt_data_s3 <= rt_data_s3;
		seimm_s3 <= seimm_s3;
		rs_addr_s3 <= rs_addr_s3;
		rt_addr_s3 <= rt_addr_s3; 
		rt_addr_fw <= rt_addr_s3;
	end
	else begin
		control_WB_s3 <= control_WB_s2;
		control_MEM_s3 <= control_MEM_s2;
		control_EX_s3 <= control_EX_s2;
 		pc_s3 <= pc_s2;
 		rs_data_s3 <= rs_data_s2;
 		rt_data_s3 <= rt_data_s2;
 		seimm_s3 <= seimm_s2;
		rs_addr_s3 <= rs_addr_s2;
		rt_addr_s3 <= rt_addr_s2; 
		rt_addr_fw <= rt_addr_s2;
		rd_addr_s3 <= rd_addr_s2;
	end

end
endmodule