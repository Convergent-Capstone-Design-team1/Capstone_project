module MEM_STAGE
(
    input   [2:0]   M           ,
    input           zero        ,
    input   [31:0]  result      ,
    input   [31:0]  WD          ,

    output          branch      ,
    output  [31:0]  R_DATA              
);

    assign branch = M[0] & zero;

    DATA_MEM DATA_MEM
    (   
        //INPUT
        .CLK(clk)       ,
        .MEMRead(M[2])  ,
        .MEMWrite(M[1]) ,
        .ADDR(result)   ,
        .WD(WD)         ,
        //OUTPUT
        .RD(R_DATA)
    );

endmodule