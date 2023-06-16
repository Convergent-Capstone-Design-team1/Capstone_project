// MEM stage : Data mem 

module MEM_STAGE
(
    input           clk_50              ,
    input           rst                 ,
    input   [4:0]   MEM_control         ,
    input           zero                ,
    input   [31:0]  result              ,
    input   [31:0]  WD                  ,
    input   [31:0]  mem_pc              ,
    input           hit                 ,

    output          branch              ,
    output  [31:0]  R_DATA              ,
    output  [31:0]  mem_pc_o            
);


    assign branch = MEM_control[0] & zero;          // PC_MUX에 들어가는 select signal 계산
    assign mem_pc_o = mem_pc;                       // mem stage의 pc값을 사용하도록 하기 위함 ex) BHT

    DATA_MEM DATA_MEM
    (   
        //INPUT
        .clk_50(clk_50)                 ,
        .MEMRead(MEM_control[2])        ,
        .MEMWrite(MEM_control[1])       ,
        .ADDR(result)                   ,
        .WD(WD)                         ,
        
        //OUTPUT        
        .RD(R_DATA)
    );

endmodule