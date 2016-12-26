Report

# 組員及分工
## 組員
- 許正忞，鐘紫育，李柚昇

## 分工
- Controller部分：鐘紫育，李柚昇
- 連線及整合：許正忞

# Implementation
- dcache top
    + tag comparator
        * todo
    + write data & read data
        * todo
    + controller
        * todo
- connect dcache top to CPU
    + 把project1中連接到Data memory的線改成連接到cache。
    + 添加一條mem stall的線，從cache連接到PC, IF/ID, ID/EX, EX/MEM, MEM/WB，讓它們在cache miss的時候可以保持其中的值不變。

# Cache Controller in detail
- STATE_MISS
    + todo
- STATE_READMISS
    + todo
- STATE_READMISSOK
    + todo
- STATE_WRITEBACK
    + todo

# 問題及解決
(1) 最初沒注意到testbench中已經把data memory單獨拿出來，沒有放在CPU中了，所以剛開始在CPU里重複寫了data memory的部分，出現了一些錯誤。
解決：把data memory部分刪除。