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
    + 假如old block is dirty，要寫memory並進入WRITE BACK STATE，所以mem_enable, mem_write以及write_back都設為1，並將state改為STATE_WRITEBACK。
    + 反之，若old block is clean，要讀memory並進入ALLOCATE STATE，所以mem_enable設為1，mem_write, write_back設為0，並將state改為STATE_READMISS。
- STATE_READMISS
    + 這個state作用在於等待data memory ready，假如mem_ack_i為1，代表memory is ready，mem_enable設為0，cache_we設為1，state變成STATE_READMISSOK。
    + 若mem_ack_i為零，代表memory is not ready，state保持在STATE_READMISS。
- STATE_READMISSOK
    + READMISS已解決，讓cache_we變回0，state回到STATE_IDLE。
- STATE_WRITEBACK
    + 一樣是在等memory ready，把相關參數變回原狀，若mem_ack_i為1，write_back和mem_write設成0，state跳到STATE_READMISS。
    + 相反地，要是memory還沒好，state保持在STATE_WRITEBACK。

# 問題及解決
(1) 最初沒注意到testbench中已經把data memory單獨拿出來，沒有放在CPU中了，所以剛開始在CPU里重複寫了data memory的部分，出現了一些錯誤。
解決：把data memory部分刪除。