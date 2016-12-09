module HazardDetection
(
MemRead_i,
ID_EX_Rt_i,
IF_ID_Rs_i,
IF_ID_Rt_i,
PCWrite_o,
IF_IDWrite_o,
mux8_o
);

input 	MemRead_i;
input 	[4:0]	ID_EX_Rt_i, IF_ID_Rs_i, IF_ID_Rt_i;
output	reg	PCWrite_o, IF_IDWrite_o, mux8_o;

always@(*)begin
	if(MemRead_i && ((ID_EX_Rt_i == IF_ID_Rs_i) || (ID_EX_Rt_i == IF_ID_Rt_i))) begin
		PCWrite_o = 1'b0;
		IF_IDWrite_o = 1'b0;
		mux8_o = 1'b0;
	end
	else begin
		PCWrite_o = 1'b1;
		IF_IDWrite_o = 1'b1;
		mux8_o = 1'b1;
	end

end
endmodule