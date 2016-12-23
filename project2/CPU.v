module CPU
(
    clk_i,
    start_i,
    rst_i,

    mem_data_i, 
    mem_ack_i,  
    mem_data_o, 
    mem_addr_o,     
    mem_enable_o, 
    mem_write_o
);

// Ports
input               clk_i;
input               start_i;
input               rst_i;

input   [256-1:0]   mem_data_i; 
input               mem_ack_i;  
output  [256-1:0]   mem_data_o; 
output  [32-1:0]    mem_addr_o;     
output              mem_enable_o; 
output              mem_write_o; 



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
wire [4:0] write_reg_out,rs_addr_s3, rt_addr_s3, rt_addr_fw, rd_addr_s3,mux3_o, mux3_o_s4;

//for cache
wire  mem_stall;


//stage 1
PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .stall_i    (mem_stall),
    .pcEnable_i (PCWrite),
    .pc_i       (mux2_out),
    .pc_o       (pc_out)
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
assign flush_in = beq | jump;

muxfor2 mux1(
    .select(beq),
    .data1_i(branch_addr),
    .data2_i(pc4),
    .data_o(mux1_out)
);

muxfor2 mux2(
    .select(jump),
    .data1_i(jump_addr),
    .data2_i(mux1_out),
    .data_o(mux2_out)        
);

IF_ID IF_ID(
    .clk_i(clk_i),
    .pc4_i(pc4),
    .mem_stall_i(mem_stall),
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
    .MemRead_i      (control_MEM_s3[1]), //
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
    .eq_o        (equal)
);

ID_EX ID_EX(
    .clk            (clk_i),
    .mem_stall_i    (mem_stall),
    .control_WB_s2  (control_WB_s2 ),          
    .control_MEM_s2 (control_MEM_s2) ,   
    .control_EX_s2  (control_EX_s2 ) ,   
    .pc_s2          (pc_s2 ) ,   
    .rs_data_s2     (rs_data_s2 ),
    .rt_data_s2     (rt_data_s2 ),
    .seimm_s2       (seimm_s2   ),
    .rs_addr_s2     (inst[25:21]),
    .rt_addr_s2     (inst[20:16]),
    .rd_addr_s2     (inst[15:11]),

    .control_WB_s3  (control_WB_s3 ),          
    .control_MEM_s3 (control_MEM_s3) ,   
    .control_EX_s3  (control_EX_s3 ) ,   
    .pc_s3          (pc_s3 ) ,   
    .rs_data_s3     (rs_data_s3   ),
    .rt_data_s3     (rt_data_s3   ),
    .seimm_s3       (seimm_s3),
    .rs_addr_s3     (rs_addr_s3),
    .rt_addr_s3     (rt_addr_s3),
    .rt_addr_fw     (rt_addr_fw),
    .rd_addr_s3     (rd_addr_s3)
);



//stage 3
mux_5bits mux3(
    .select     (control_EX_s3[0]),//RegDst
    .data1_i    (rd_addr_s3),
    .data2_i    (rt_addr_s3),
    .data_o     (mux3_o)
    );
muxfor2 mux4(
    .select     (control_EX_s3[3]),//ALUSrc
    .data1_i    (seimm_s3),
    .data2_i    (mux7_o),
    .data_o     (mux4_o)
    );
muxfor3 mux6(
    .select     (forward_data1_o),
    .data1_i    (alu_result_o_s4),
    .data2_i    (mux5_o_s5),
    .data3_i    (rs_data_s3),
    .data_o     (mux6_o)
    );
muxfor3 mux7(
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
    .ID_EX_Rs     (rs_addr_s3),
    .ID_EX_Rt     (rt_addr_fw),
    .EX_MEM_Rd    (mux3_o_s4),
    .EX_MEM_RegWrite  (control_WB_s4[1]),
    .MEM_WB_Rd   (write_reg_out),
    .MEM_WB_RegWrite  (control_WB_s5[1]),
    .forward_a_select   (forward_data1_o),
    .forward_b_select   (forward_data2_o)
    );

EX_MEM EX_MEM(
    .clk     (clk_i),
    .mem_stall_i(mem_stall),
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



dcache_top dcache(
    .clk_i      (clk_i), 
    .rst_i      (rst_i),
    
    // to Data Memory interface     

    .mem_data_i(mem_data_i), 
    .mem_ack_i(mem_ack_i),  
    .mem_data_o(mem_data_o), 
    .mem_addr_o(mem_addr_o),    
    .mem_enable_o(mem_enable_o), 
    .mem_write_o(mem_write_o),
    
    // to CPU interface 
    .p1_data_i      (mux7_o_s4), 
    .p1_addr_i      (alu_result_o_s4), 
    .p1_MemRead_i   (control_MEM_s4_read), 
    .p1_MemWrite_i  (control_MEM_s4_write), 
    .p1_data_o      (mw_read_data_in), 
    .p1_stall_o     (mem_stall)

);
/*
Data_Memory Data_Memory(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .addr_i     (mem_addr_o),
    .data_i     (mem_data_o),
    .enable_i   (mem_enable_o),
    .write_i    (mem_write_o),
    .ack_o      (mem_ack_i),
    .data_o     (mem_data_i)
);
*/
MEM_WB MEM_WB(
    .clk(clk_i),
    .mem_stall_i(mem_stall),
    .ctrl_wb_in(control_WB_s4),
    .read_data_in(mw_read_data_in),
    .alu_result_in(alu_result_o_s4),
    .write_reg_in(mux3_o_s4),
    .mem_ctrl_wb(control_WB_s5),
    .read_data(mw_read_data_out),
    .mem_alu_result(alu_result_s5),
    .mem_write_reg(write_reg_out)
);


//stage 5

muxfor2 mux5(
    .select(control_WB_s5[0]),//MemtoReg
    .data1_i(mw_read_data_out), 
    .data2_i(alu_result_s5),
    .data_o(mux5_o_s5)
    );

endmodule
