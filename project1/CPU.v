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
Control

Adder

Registers

Sign_Extend

hazardDetetion

eq

ID/EX
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

