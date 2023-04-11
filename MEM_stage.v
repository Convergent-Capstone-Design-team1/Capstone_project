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

    assign branch = MEM_control[0] & zero;
    assign mem_pc_o = mem_pc;

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