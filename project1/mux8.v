module mux8
(
rst_i,
control_i,
select_i,
control_WB,
control_MEM,
control_EX
);

input	[7:0]	control_i;
input	select_i, rst_i;
output reg	[1:0]	control_WB, control_MEM;
output reg	[3:0]	control_EX;


always@(control_i or negedge rst_i)begin
	if(~rst_i) begin
		control_WB = control_i[7:6];
		control_MEM = control_i[5:4];
		control_EX = control_i[3:0];
	end
	else begin
		if(select_i == 1'b1) begin
			control_WB = 2'b0;
			control_MEM = 2'b0;
			control_EX = 4'b0;
			
		end
		else begin
			control_WB = control_i[7:6];
			control_MEM = control_i[5:4];
			control_EX = control_i[3:0];
		end
	end
end
endmodule