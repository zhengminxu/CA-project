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
### Stage 2
- Stage 2會用到的module有Control, Sign_extend, Adder, mux8, Registers, Hazard Detection, Eq, ID/EX。
- 設定一些wire來連接各個module。
- Jump的地址中用到的shift left和concatenate是直接把PC的前4位、instruction的最後26位和兩位0concat起來。
- 同理，shift left 2位的immediate number也是直接把number的後30位和兩位0連在一起。

## Each module
() ALU
- 定義3個input端口（ALUCtrl以及兩個要進行計算的data）和一個output端口（計算結果）。ALUCtrl是4位， 其他端口都是32位。
- 在一個always block中，根據ALUCtrl的不同，進行不同類型的計算。其中，新增的lw和sw的ALUCtrl signal與add相同，因為它們是要計算offset和base register地址的和。
- ALUCtrl都是四位二進制數，具體數值來源於課本Chapter 4。

() ALU control
- 定義兩個input端口：funct (6 bits), ALUOp (2 bits), 一個output端口：ALUCtrl (4 bits)。
- 先判斷ALUOp。如果ALUOp等於10，說明當前執行的instruction是R type，下面再根據funct判斷當前的instruction具體要執行哪種運算，并分配相應的ALUCtrl的數值。
- 如果ALUOp等於00，說明當前執行的instruction是lw, sw, addi三個中的某一個，它們都是要執行相加的運算，所以讓ALUCtrl對應於add的ALUCtrl數值。

() Hazard Detection unit
- 四個input端口：MemRead, ID/EX.Rt, IF/ID.Rs, IF/ID.Rt。四個output端口：PCWrite, IF/IDWrite, mux8_select, flush。input中除了MemRead是1位，其他都是5位。output都是1位。
- 如果MemRead等於1（說明instruction是sw），且ID/EX.Rt等於IF/ID.Rs或IF/ID.Rt，說明會發生load-use hazard，所以把PCWrite和IF/IDWrite設0，mux8_select和flush設1。
- 反之，就把PCWrtie和IF/IDWrite設1，mux8_select和flush設0，讓程式正常運行下去。

() Eq
- 兩個input：data1和data2 (32 bits)，output：1位數值，指示data1與data2是否相等。
- 如果data1等於data2，output設1，否則output設0。

() ID/EX
- 定義兩個input：clk，in (N bits)，一個output：out (N bits)，另外定義一個parameter N。
- 在clk的posedge，令out等於in。
- 在CPU中會定義不同長度的input。

## 問題和解決
（1）PC需要設定初始值為0
- 在PC和testbench里加了一個input：reset。
（2）前幾個instruction執行時，後面stage的一些signal還沒有有效值
- 更改了相關control signal的條件語句，首先設0，遇到trigger條件再修改值。
（3）Forwarding Unit的條件設置不夠準確
- 修改了條件語句，首先把forwarding的signal都設0，遇到trigger再改成01或10。
