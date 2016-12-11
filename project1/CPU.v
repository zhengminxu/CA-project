module CPU
(
    clk_i,
    start_i,
    rst_i
);

// Ports
input               clk_i;
input               start_i;
input               rst_i;



//stage 1
wire    [31:0]  mux2_out, pc_out, instr_out, pc4, mux1_out;
wire            flush_in, beq;
wire [31:0] inst;

wire  [7:0] control_all;
wire        branch, jump, mux8_select, PCWrite, IF_IDWrite, equal, hazard_flush;
wire [1:0]  control_WB_s2, control_MEM_s2;
wire [3:0]  control_EX_s2;
wire [31:0] pc_s2, seimm_s2, seimm_sl2, branch_addr, rs_data_s2, rt_data_s2;
wire [31:0] jump_addr;

wire    control_MEM_s4_write, control_MEM_s4_read;
wire [1:0]  control_WB_s3, control_MEM_s3, forward_data1_o, forward_data2_o;
wire [1:0]  control_WB_s4, control_WB_s5;
wire [3:0]  control_EX_s3, alu_control_o;
wire [31:0] pc_s3, seimm_s3, rs_data_s3, rt_data_s3, alu_data_o,mux7_o, mux7_o_s4, mux4_o, mux6_o;
wire [31:0] alu_result_o_s4, mux5_o_s5;

wire [31:0]  mw_read_data_in, mw_read_data_out, alu_result_s5;
wire [4:0] write_reg_out,rs_addr_s3, rt_addr_s3, rt_addr_fw, rd_addr_s3,mux3_o, mux3_o_s4, mux3_o_s5;
wire [1:0] ctrl_wb_out;


PC PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .PCWrite_i(PCWrite),
    .pc_i(mux2_out),
    .pc_o(pc_out)
);

Add_PC Add_PC(
    .pc_i(pc_out),
    .pc_o(pc4)
);


Instruction_Memory Instruction_Memory(
    .addr_i(pc_out),
    .instr_o(instr_out)
);

assign beq = branch & equal;
assign flush_in = beq & jump;

mux2 mux1(
    .select(beq),
    .data1_i(branch_addr),
    .data2_i(pc4),
    .data_o(mux1_out)
);

mux2 mux2(
    .select(jump),
    .data1_i(jump_addr),
    .data2_i(mux1_out),
    .data_o(mux2_out)        
);

IF_ID IF_ID(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc4_i(pc4),
    .instr_i(instr_out),
    .IFIDWrite_i(IF_IDWrite),
    .IFFlush_i(flush_in),
    .pc4_o(pc_s2),
    .instr_o(inst)
);


//stage 2

assign jump_addr = {mux1_out[31:28], inst[25:0], 2'b0};

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

assign seimm_sl2 = {seimm_s2[29:0], 2'b0};
Adder Adder(
    .a      (pc_s2), //
    .b      (seimm_sl2),
    .out    (branch_addr)
);

mux8 mux8(
    .control_i      (control_all),
    .rst_i          (rst_i),
    .select_i       (mux8_select),
    .control_WB     (control_WB_s2),
    .control_MEM    (control_MEM_s2),
    .control_EX     (control_EX_s2)
);


Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (inst[25:21]), //
    .RTaddr_i   (inst[20:16]), //
    .RDaddr_i   (write_reg_out), //
    .RDdata_i   (mux5_o_s5), //
    .RegWrite_i (control_WB_s5[1]), //where??control_WB_s5[1]
    .RSdata_o   (rs_data_s2),
    .RTdata_o   (rt_data_s2)
);

HazardDetection HazardDetection(
    .MemRead_i      (MemRead_s3), //
    .ID_EX_Rt_i     (rt_addr_s3), //
    .IF_ID_Rs_i     (inst[25:21]), //
    .IF_ID_Rt_i     (inst[20:16]), //
    .PCWrite_o      (PCWrite),
    .IF_IDWrite_o   (IF_IDWrite),
    .mux8_o         (mux8_select),
    .Flush_o        (hazard_flush)
);

Eq eq(
    .data1_i     (rs_data_s2),
    .data2_i     (rt_data_s2),
    .eq_o        (equal)
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


//stage 3
mux_5bits mux3(
    .select     (control_EX_s3[0]),//RegDst
    .data1_i    (rt_addr_s3),
    .data2_i    (rd_addr_s3),
    .data_o     (mux3_o)
    );
mux2 mux4(
    .select     (control_EX_s3[3]),//ALUSrc
    .data1_i    (mux7_o),
    .data2_i    (seimm_s3),
    .data_o     (mux4_o)
    );
mux3 mux6(
    .select     (forward_data1_o),
    .data1_i    (alu_result_o_s4),
    .data2_i    (mux5_o_s5),
    .data3_i    (rs_data_s3),
    .data_o     (mux6_o)
    );
mux3 mux7(
    .select     (forward_data2_o),
    .data1_i    (alu_result_o_s4),
    .data2_i    (mux5_o_s5),
    .data3_i    (rt_data_s3),
    .data_o     (mux7_o)
    );

ALU ALU(
    .ALUCtrl_i  (alu_control_o),
    .data1_i    (mux6_o),
    .data2_i    (mux4_o),
    .data_o     (alu_data_o)
);

ALU_Control ALU_Control(
    .funct_i    (seimm_s3[5:0]),
    .ALUOp_i    (control_EX_s3[2:1]),//ALUOp
    .ALUCtrl_o  (alu_control_o)
);

forwardingUnit forwordingUnit(
    .rst_i  (rst_i),
    .rs     (rs_addr_s3),
    .rt     (rt_addr_fw),
    .mux3_out   (mux3_o_s4),
    .ex_mem_wb_out  (control_WB_s4),
    .mem_write_reg  (mux3_o_s5),
    .mem_wb_wb  (control_WB_s5),
    .forward_a_select   (forward_data1_o),
    .forward_b_select   (forward_data2_o)
    );

EX_MEM EX_MEM(
    .clk     (clk_i),
    .ctrl_wb_in (control_WB_s3),
    .ctrl_m_in  (control_MEM_s3),
    .alu_result_in  (alu_data_o),
    .mux7_in    (mux7_o),
    .mux3_in    (mux3_o),
    .ctrl_wb_out    (control_WB_s4),
    .ctrl_m_mem_write   (control_MEM_s4_write),
    .ctrl_m_mem_read    (control_MEM_s4_read),
    .alu_result_out (alu_result_o_s4),
    .mux7_out   (mux7_o_s4),
    .mux3_out   (mux3_o_s4)
    );

//stage 4
Data_memory Data_Memory(
    .clk_i(clk_i),
    .MemWrite_i(control_MEM_s4_write),
    .MemRead_i(control_MEM_s4_read),
    .addr_i(alu_result_o_s4),
    .WriteData_i(alu_result_o_s4),
    .ReadData_o(mw_read_data_in)
);

MEM_WB MEM_WB(
    .clk(clk_i),
    .ctrl_wb_in(control_WB_s4),
    .read_data_in(mw_read_data_in),
    .alu_result_in(alu_result_o_s4),
    .write_reg_in(mux3_o_s4),
    .mem_ctrl_wb(ctrl_wb_out),
    .read_data(mw_read_data_out),
    .mem_alu_result(alu_result_s5),
    .mem_write_reg(write_reg_out)
);


//stage 5

mux2 mux5(
    .select(control_WB_s5[0]),//MemtoReg
    .data1_i(mw_read_data_out), 
    .data2_i(alu_result_s5),
    .data_o(mux5_o_s5)
    );

endmodule
