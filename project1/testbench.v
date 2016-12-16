`define CYCLE_TIME 50            

module TestBench;

reg                Clk;
reg                Start;
reg                Reset;
integer            i, outfile, counter;
integer            stall, flush;

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU CPU(
    .clk_i  (Clk),
    .start_i(Start),
    .rst_i  (Reset)
);
  
initial begin
    counter = 0;
    stall = 0;
    flush = 0;
    $dumpfile("mytest.vcd");
    $dumpvars;
    
    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        CPU.Instruction_Memory.memory[i] = 32'b0;
    end
    
    // initialize data memory
    for(i=0; i<32; i=i+1) begin
        CPU.Data_Memory.memory[i] = 8'b0;
    end    
        
    // initialize Register File
    for(i=0; i<32; i=i+1) begin
        CPU.Registers.register[i] = 32'b0;
    end
    
    // Load instructions into instruction memory
    $readmemb("Fibonacci_instruction.txt", CPU.Instruction_Memory.memory);
    
    // Open output file
    outfile = $fopen("output.txt") | 1;
    
    // Set Input n into data memory at 0x00
    CPU.Data_Memory.memory[0] = 8'h5;       // n = 5 for example
    
    Clk = 1;
    Reset = 0;
    Start = 0;
    
    #(`CYCLE_TIME/4) 
    Reset = 1;
    Start = 1;
        
    
end
  
always@(posedge Clk) begin
    if(counter == 70)    // stop after 30 cycles
        $stop;

    // put in your own signal to count stall and flush
    if(CPU.HazardDetection.mux8_o == 1 && CPU.Control.Jump_o == 0 && CPU.Control.Branch_o == 0)stall = stall + 1;
    if(CPU.IF_ID.IFFlush_i == 1)flush = flush + 1;  

    // print PC
    $fdisplay(outfile, "cycle = %d, Start = %d, Stall = %d, Flush = %d\nPC = %d", counter, Start, stall, flush, CPU.PC.pc_o);
    $fdisplay(outfile, "inst = %b", CPU.Instruction_Memory.instr_o);

    
    $fdisplay(outfile, "mux1_select = %b, mux1_data_o = %b", CPU.mux1.select, CPU.mux1.data_o);
    $fdisplay(outfile, "mux2_select = %b, mux2_data_o = %b", CPU.mux2.select, CPU.mux2.data_o);
    $fdisplay(outfile, "IF/ID.IFFlush_i = %d",CPU.IF_ID.IFFlush_i);
    $fdisplay(outfile, "eq = %d",CPU.eq.eq_o);
    $fdisplay(outfile, "----------------------------------------------");
    $fdisplay(outfile, "pc4 = %d, instr = %b", CPU.IF_ID.pc4_o, CPU.IF_ID.instr_o);
    
    $fdisplay(outfile, "opcode = %b, control all = %b, jump = %b, branch = %b", CPU.Control.Op_i,CPU.Control.ConMux_o, CPU.Control.Jump_o, CPU.Control.Branch_o);
    $fdisplay(outfile, "HazardDetection: MemRead_i = %b,ID_EX_Rt_i = %b,IF_ID_Rs_i = %b,IF_ID_Rt_i = %b,PCWrite_o = %b,IF_IDWrite_o = %b,mux8_o = %b", CPU.HazardDetection.MemRead_i,CPU.HazardDetection.ID_EX_Rt_i,CPU.HazardDetection.IF_ID_Rs_i,CPU.HazardDetection.IF_ID_Rt_i,CPU.HazardDetection.PCWrite_o,CPU.HazardDetection.IF_IDWrite_o,CPU.HazardDetection.mux8_o);
    $fdisplay(outfile, "mux8_control_i = %b, select_i = %b", CPU.mux8.control_i,CPU.mux8.select_i);
    $fdisplay(outfile, "WB = %b, MEM = %b, EX = %b", CPU.mux8.control_WB, CPU.mux8.control_MEM, CPU.mux8.control_EX);
    $fdisplay(outfile, "control_WB = %b, control_MEM = %b, control_EX = %b", CPU.ID_EX.control_WB_s2,CPU.ID_EX.control_MEM_s2,CPU.ID_EX.control_EX_s2);

    $fdisplay(outfile, "rsdata = %b, rtdata = %b", CPU.Registers.RSdata_o,CPU.Registers.RTdata_o);
    $fdisplay(outfile, "rdaddr = %b, rddata = %b", CPU.Registers.RDaddr_i,CPU.Registers.RDdata_i);
    $fdisplay(outfile, "seimm = %d", CPU.Sign_Extend.data_out);
    $fdisplay(outfile, "----------------------------------------------");



    $fdisplay(outfile, "rsdata = %d, rtdata = %d",CPU.ID_EX.rs_data_s3,CPU.ID_EX.rt_data_s3);
    $fdisplay(outfile, "mux6_s = %b, mux7_s = %b, mux7_data3_i = %d, mux7_data_o = %d", CPU.mux6.select, CPU.mux7.select,  CPU.mux7.data3_i, CPU.mux7.data_o);
    $fdisplay(outfile, "ForwardingUnit: ID_EX_Rs =%b,ID_EX_Rt = %b,EX_MEM_Rd = %b,EX_MEM_RegWrite= %b,MEM_WB_Rd = %b,MEM_WB_RegWrite= %b", CPU.forwordingUnit.ID_EX_Rs     ,CPU.forwordingUnit.ID_EX_Rt     ,CPU.forwordingUnit.EX_MEM_Rd    ,CPU.forwordingUnit.EX_MEM_RegWrite,CPU.forwordingUnit.MEM_WB_Rd,   CPU.forwordingUnit.MEM_WB_RegWrite);
    $fdisplay(outfile, "ForwardingUnit: mux6_s = %b,mux7_s = %b", CPU.forwordingUnit.forward_a_select,CPU.forwordingUnit.forward_b_select);
    $fdisplay(outfile, "control_MEM = %b, control_WB = %b, control_EX = %b", CPU.ID_EX.control_MEM_s3,CPU.ID_EX.control_WB_s3,CPU.ID_EX.control_EX_s3);
    $fdisplay(outfile, "alu ctrl = %b", CPU.ALU.ALUCtrl_i);
    $fdisplay(outfile, "ALU data1 = %b, ALU data2 = %b", CPU.ALU.data1_i, CPU.ALU.data2_i);
    $fdisplay(outfile, "alu out = %b", CPU.ALU.data_o);
    $fdisplay(outfile, "alu out = %b", CPU.EX_MEM.alu_result_out);
    $fdisplay(outfile, "mux3_select = %b, mux3_data1 = %b, mux3_data2 = %b, mux3_out = %b,", CPU.mux3.select,CPU.mux3.data1_i, CPU.mux3.data2_i,CPU.mux3.data_o);

    $fdisplay(outfile, "----------------------------------------------");
    
    $fdisplay(outfile, "EX/MEM: ctrl_WB = %b, memWrite = %b, memRead = %b, alu_result_out = %b, mux7_out = %b, mux3_out = %b",CPU.EX_MEM.ctrl_wb_out,CPU.EX_MEM.ctrl_m_mem_write,CPU.EX_MEM.ctrl_m_mem_read ,CPU.EX_MEM.alu_result_out,CPU.EX_MEM.mux7_out,CPU.EX_MEM.mux3_out);
    $fdisplay(outfile, "EX/MEM.mux7out = %d", CPU.EX_MEM.mux7_out);
    $fdisplay(outfile, "Data_Memory.addr_i = %b, Data_Memory.WriteData_i = %d, Data_Memory.ReadData_o = %d", CPU.Data_Memory.addr_i,CPU.Data_Memory.WriteData_i, CPU.Data_Memory.ReadData_o);
    $fdisplay(outfile, "----------------------------------------------");
    $fdisplay(outfile, "MEM_WB.write register addr = %b, MEM_WB.mem_ctrl_wb = %b", CPU.MEM_WB.mem_write_reg, CPU.MEM_WB.mem_ctrl_wb);
    $fdisplay(outfile, "mux5_o = %b, mux5_s = %b", CPU.mux5.data_o, CPU.mux5.select);


    


    // print Registers
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "R0(r0) = %d, R8 (t0) = %d, R16(s0) = %d, R24(t8) = %d", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
    $fdisplay(outfile, "R1(at) = %d, R9 (t1) = %d, R17(s1) = %d, R25(t9) = %d", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
    $fdisplay(outfile, "R2(v0) = %d, R10(t2) = %d, R18(s2) = %d, R26(k0) = %d", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
    $fdisplay(outfile, "R3(v1) = %d, R11(t3) = %d, R19(s3) = %d, R27(k1) = %d", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
    $fdisplay(outfile, "R4(a0) = %d, R12(t4) = %d, R20(s4) = %d, R28(gp) = %d", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
    $fdisplay(outfile, "R5(a1) = %d, R13(t5) = %d, R21(s5) = %d, R29(sp) = %d", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
    $fdisplay(outfile, "R6(a2) = %d, R14(t6) = %d, R22(s6) = %d, R30(s8) = %d", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
    $fdisplay(outfile, "R7(a3) = %d, R15(t7) = %d, R23(s7) = %d, R31(ra) = %d", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);

    // print Data Memory
    $fdisplay(outfile, "Data Memory: 0x00 = %d", {CPU.Data_Memory.memory[3] , CPU.Data_Memory.memory[2] , CPU.Data_Memory.memory[1] , CPU.Data_Memory.memory[0] });
    $fdisplay(outfile, "Data Memory: 0x04 = %d", {CPU.Data_Memory.memory[7] , CPU.Data_Memory.memory[6] , CPU.Data_Memory.memory[5] , CPU.Data_Memory.memory[4] });
    $fdisplay(outfile, "Data Memory: 0x08 = %d", {CPU.Data_Memory.memory[11], CPU.Data_Memory.memory[10], CPU.Data_Memory.memory[9] , CPU.Data_Memory.memory[8] });
    $fdisplay(outfile, "Data Memory: 0x0c = %d", {CPU.Data_Memory.memory[15], CPU.Data_Memory.memory[14], CPU.Data_Memory.memory[13], CPU.Data_Memory.memory[12]});
    $fdisplay(outfile, "Data Memory: 0x10 = %d", {CPU.Data_Memory.memory[19], CPU.Data_Memory.memory[18], CPU.Data_Memory.memory[17], CPU.Data_Memory.memory[16]});
    $fdisplay(outfile, "Data Memory: 0x14 = %d", {CPU.Data_Memory.memory[23], CPU.Data_Memory.memory[22], CPU.Data_Memory.memory[21], CPU.Data_Memory.memory[20]});
    $fdisplay(outfile, "Data Memory: 0x18 = %d", {CPU.Data_Memory.memory[27], CPU.Data_Memory.memory[26], CPU.Data_Memory.memory[25], CPU.Data_Memory.memory[24]});
    $fdisplay(outfile, "Data Memory: 0x1c = %d", {CPU.Data_Memory.memory[31], CPU.Data_Memory.memory[30], CPU.Data_Memory.memory[29], CPU.Data_Memory.memory[28]});
	
    $fdisplay(outfile, "\n");
    
    counter = counter + 1;
    
      
end

  
endmodule
