module CPU
(
    clk_i, 
    start_i
);

// Ports
input               clk_i;
input               start_i;


---------------------------
//stage 1
PC

Instruction_Memory

IF/ID

flush
----------------------------
//stage 2
wire [31:0] inst;

wire  [7:0] control_all;
wire        branch, jump, mux8_select, PCWrite, IF_IDWrite, eq;
wire [1:0]  control_WB_s2, control_MEM_s2;
wire [3:0]  control_EX_s2;
wire [31:0] pc_s2, seimm_s2, seimm_sl2, branch_addr, rs_data_s2, rt_data_s2;

Control Control(
    .Op_i       (inst[31:26]), //
    .ConMux_o   (control_all),
    .Branch_o   (branch),
    .Jump_o     (jump)
);

signExtend Sign_Extend(
    .data_in    (inst[15:0]), //
    .data_out   (seimm_s2)
);

assign seimm_sl2 = {seimm_s2[29:0], 2'b0}
Adder Adder(
    .a      (pc_s2), //
    .b      (seimm_sl2),
    .out    (branch_addr)
);

mux8 mux8(
    .control_i      (control_all),
    .select_i       (mux8_select),
    .control_WB     (control_WB_s2),
    .control_MEM    (control_MEM_s2),
    .control_EX     (control_EX_s2)
);


Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (inst[25:21]), //
    .RTaddr_i   (inst[20:16]), //
    .RDaddr_i   (rd_addr), //
    .RDdata_i   (rd_data), //
    .RegWrite_i (RegWrite_s3), //
    .RSdata_o   (rs_data_s2), 
    .RTdata_o   (rt_data_s2)
);

HazardDetetion HazardDetetion(
    .MemRead_i      (MemRead_s3), //
    .ID_EX_Rt_i     (rt_addr_s3), //
    .IF_ID_Rs_i     (inst[25:21]), //
    .IF_ID_Rt_i     (inst[20:16]), //
    .PCWrite_o      (PCWrite),
    .IF_IDWrite_o   (IF_IDWrite),
    .mux8_o         (mux8_select)
);

Eq eq(
    .data1_i     (rs_data_s2),
    .data2_i     (rt_data_s2),
    .eq_o        (eq)
);

regr #(.N(8)) ID_EX_control(
    .clk    (clk_i),
    .in     ({control_WB_s2, control_MEM_s2, control_EX_s2}),
    .out    ({control_WB_s3, control_MEM_s3, control_EX_s3}) //
);

regr #(.N(32)) ID_EX_pc(
    .clk    (clk_i),
    .in     (pc_s2), //
    .out    (pc_s3) //
);

regr #(.N(64)) ID_EX_registerData(
    .clk    (clk_i),
    .in     ({rs_data_s2, rt_data_s2}),
    .out    ({rs_data_s3, rt_data_s3})  //
);

regr #(.N(32)) ID_EX_seimm(
    .clk    (clk_i),
    .in     (seimm_s2),
    .out    (seimm_s3) //
);

regr #(.N(20)) ID_EX_rsrtrd(
    .clk    (clk_i),
    .in     ({inst[25:21], inst[20:16], inst[20:16], inst[15:11]}), //
    .out    ({rs_addr_s3, rt_addr_s3, rt_addr_fw, rd_addr_s3}) //
);

----------------------------
//stage 3

ALU

ALU_Control

forwording

EX/MEM
----------------------------
//stage 4

data memory

MEM/WB
----------------------------
//stage 5

mux

endmodule

