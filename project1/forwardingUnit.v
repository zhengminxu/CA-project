module forwardingUnit(
	//ID_EX
	input	[4:0]	ID_EX_Rs,
	input	[4:0]	ID_EX_Rt,
	//EX_MEM
	input	[4:0]	EX_MEM_Rd,
	input	EX_MEM_RegWrite,
	input	[4:0]	MEM_WB_Rd,
	//MEM_WB
	input	MEM_WB_RegWrite,

	output	reg 	[1:0]	forward_a_select,
	output	reg 	[1:0]	forward_b_select
	);

always	@	(*)	begin

	forward_a_select	=	2'b00;
	forward_b_select	=	2'b00;
	//EX
	if(EX_MEM_RegWrite == 1'b1 && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs))
	begin
		forward_a_select	=	2'b10;
	end

	if(EX_MEM_RegWrite == 1'b1 && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rt))
	begin
		forward_b_select	=	2'b10;
	end


	//MEM
	if(MEM_WB_RegWrite == 1'b1 && (MEM_WB_Rd != 0) && (EX_MEM_Rd != ID_EX_Rs) &&(MEM_WB_Rd == ID_EX_Rs))
	begin
		forward_a_select	=	2'b01;
	end

	if(MEM_WB_RegWrite == 1'b1 &&(MEM_WB_Rd != 0) && (EX_MEM_Rd != ID_EX_Rt) &&(MEM_WB_Rd == ID_EX_Rt))
	begin
		forward_b_select	=	2'b01;
	end

end
endmodule