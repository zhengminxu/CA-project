## 組員分工
### 組員
- 許正忞，李柚昇，鐘紫育

### 分工
（1）Module部分
- 李柚昇：PC, Add_pc, Adder, Data memory, Control, IF/ID
- 鐘紫育：Sign_extend, muxes, Forwarding unit, EX/MEM, MEM/WB
- 許正忞：ALU, ALU control, Hazard Detection unit, Eq, ID/EX

（2）CPU部分
- 李柚昇：stage 1, 4, 5
- 鐘紫育：stage 3
- 許正忞：stage 2

（3）Report部分
- 組員分工：許正忞
- 其他部分：李柚昇，鐘紫育，許正忞

## CPU Implementation
	我們依照投影片最後一張圖，先分別將 modle算出來有多少，每個人認領部分。完成 modle後，再去分 Stage接線。
### Stage 1
- Stage 1 使用到的 module有 PC, mux1, mux2, Add_PC, Instruction_Memory, IF_ID。
- 設定一些wire來連接各個module。
- Branch & Flush 使用邏輯判斷寫在 CPU.v中，不獨立出 module。

### Stage 2
- Stage 2 會用到的module有Control, Sign_extend, Adder, mux8, Registers, Hazard Detection, Eq, ID/EX。
- 設定一些wire來連接各個module。
- Jump的地址中用到的shift left和concatenate是直接把PC的前4位、instruction的最後26位和兩位0串起來。
- 同理，shift left 2位的immediate number也是直接把number的後30位和兩位0連在一起。

### Stage 3
- Stage 3 使用到的 module有 mux3, mux4, mux6, mux7, ALU, ALU Control, Fowarding Unit, EX_MEM。
- 設定一些wire來連接各個module。
- 將 IE_EX 中各條訊號線接好。

### Stage 4
- Stage 4 使用到的 module有 Data_Memory, MEM_WB。
- 設定一些wire來連接各個module。
- 這個Stage才將RegWrite信號送到forwardingUnit裡做判斷。
- ALU result連回stage 3做forwarding。

### Stage 5
- Stage 5 使用到的 module有 mux5。
- 設定一些wire來連接各個module。
- 這個stage的MemWrite也被送到forwardingUnit裡做判斷，以及Register file裡決定是否寫入。

## Each module
(1) PC
- 四個input端：clk_i, rst_i, PCWrite_i(以上1 bit), pc_i(32 bits)，一個output端：pc_o(32 bits)。
- 在rising edge時，預設pc_o為32'b0，在RegWrite=1'b0時，pc_o由pc_i來update。

(2) Add_PC
- 一個input端：pc_i(32 bits)，一個output端：pc_o(32 bits)。
-藉由wire將pc_i + 4輸出到pc_o。

(3) IF_ID
- 五個input端：clk_i, IFIDWrite_i, IFFlush_i(以上1 bit), pc4_i, instr_i(32 bits)，兩個output端：pc4_o, instr_o(32 bits)。
- 在rising edge時，預設pc4_i輸出給pc4_o，instr_i輸出給instr_o。
- 若IFIDWrite_i = 1'b0，維持預設。若IFFlush_i = 1'b1，兩output都輸出32'b0。

(4) Instruction_Memory
- 一個input端：addr_i(32 bits)，一個output端：instr_o(32 bits)。
- 將addr_i右移2 bits，作為memory陣列的index，輸出該address的instr_o。

(5) Control
- 一個input端：Op_i(6 bits)，三個output端：Branch_o, Jump_o(1 bit), ConMux_o(8 bits)。
- 依照Logic Design的方式，對應Op code的Truth Table決定instruction類型，接著依此再對照另一個Truth Table決定對應的Control signal，由高到低為RegWrite, MemtoReg, MemRead, MemWrite, ALUSrc, ALUOp(2 bits), RegDst(all 1 bit except for ALUOp)，輸出到ConMux_o。
- 若instruction類型顯示為branch或jump，Branch_o或Jump_o輸出為1'b1。

(6) ALU
- 定義3個input端口（ALUCtrl以及兩個要進行計算的data）和一個output端口（計算結果）。ALUCtrl是4位， 其他端口都是32位。
- 在一個always block中，根據ALUCtrl的不同，進行不同類型的計算。其中，新增的lw和sw的ALUCtrl signal與add相同，因為它們是要計算offset和base register地址的和。
- ALUCtrl都是四位二進制數，具體數值來源於課本Chapter 4。

(7) ALU control
- 定義兩個input端口：funct (6 bits), ALUOp (2 bits), 一個output端口：ALUCtrl (4 bits)。
- 先判斷ALUOp。如果ALUOp等於10，說明當前執行的instruction是R type，下面再根據funct判斷當前的instruction具體要執行哪種運算，并分配相應的ALUCtrl的數值。
- 如果ALUOp等於00，說明當前執行的instruction是lw, sw, addi三個中的某一個，它們都是要執行相加的運算，所以讓ALUCtrl對應於add的ALUCtrl數值。

(8) Hazard Detection unit
- 四個input端口：MemRead, ID/EX.Rt, IF/ID.Rs, IF/ID.Rt。四個output端口：PCWrite, IF/IDWrite, mux8_select, flush。input中除了MemRead是1位，其他都是5位。output都是1位。
- 如果MemRead等於1（說明instruction是sw），且ID/EX.Rt等於IF/ID.Rs或IF/ID.Rt，說明會發生load-use hazard，所以把PCWrite和IF/IDWrite設0，mux8_select和flush設1。
- 反之，就把PCWrtie和IF/IDWrite設1，mux8_select和flush設0，讓程式正常運行下去。

(9) Eq
- 兩個input：data1和data2 (32 bits)，output：1位數值，指示data1與data2是否相等。
- 如果data1等於data2，output設1，否則output設0。

(10) ID/EX
- 定義兩個input：clk，in (N bits)，一個output：out (N bits)，另外定義一個parameter N。
- 在clk的posedge，令out等於in。
- 在CPU中會定義不同長度的input。

(11) Sign_Extend:
- 將輸入的16bits，用最後面的第16bit 重複放在 17-32的位置上。

(12) Mux: 
- 在 mux的部分，我依照三種不同的輸入輸出，將 mux寫成三種形式分別為兩個輸入(1,2,4,5,8)、三個輸入(6,7)、五個bits 的兩個輸入(3)。

(13) Forwarding unit
- 依照作業投影片P.7上的 pseudocode，改成 verilog。

(14) EX/MEM & MEM/WB
- 幫每一個 output先設定預設值都為 0,之後將輸入接近輸出。


## 問題和解決
(1) PC需要設定初始值為0
- 在PC和testbench里加了一個input：reset。

(2) 前幾個instruction執行時，後面stage的一些signal還沒有有效值
- 更改了相關control signal的條件語句，首先設0，遇到trigger條件再修改值。

(3) Forwarding Unit的條件設置不夠準確
- 修改了條件語句，首先把forwarding的signal都設0，遇到trigger再改成01或10。

(4) PC能夠正常運作，但從 register中輸出的 read data1 & read data2 都會是 32‘h0。

(5) 在debug的時候發現設定各個reg跟wire的時候有些缺陷，只有考慮到1,0而忽略了x的可能，導致第一次跑的時候許多值都出不來，後來經過修改後才有所改善。

