module MEM_STAGE
(
    input   [4:0]   MEM_control         ,
    input           zero                ,
    input   [31:0]  result              ,
    input   [31:0]  WD                  ,

    output          branch              ,
    output  [31:0]  R_DATA              
);

    assign branch = MEM_control[0] & zero;

    DATA_MEM DATA_MEM
    (   
        //INPUT
        .MEMRead(MEM_control[2])        ,
        .MEMWrite(MEM_control[1])       ,
        .ADDR(result)                   ,
        .WD(WD)                         ,
        
        //OUTPUT        
        .RD(R_DATA)
    );

endmodule