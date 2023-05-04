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
    input           copying             ,
    input    [31:0]  w_data_0,
    input    [31:0]  w_data_1,
    input    [31:0]  w_data_2,
    input    [31:0]  w_data_3,
    input    [31:0]  w_data_4,
    input    [31:0]  w_data_5,
    input    [31:0]  w_data_6,
    input    [31:0]  w_data_7,
    input    [31:0]  w_data_8,
    input    [31:0]  w_data_9,
    input    [31:0]  w_data_10,
    input    [31:0]  w_data_11,
    input    [31:0]  w_data_12,
    input    [31:0]  w_data_13,
    input    [31:0]  w_data_14,
    input    [31:0]  w_data_15,
    input    [31:0]  w_data_16,
    input    [31:0]  w_data_17,
    input    [31:0]  w_data_18,
    input    [31:0]  w_data_19,
    input    [31:0]  w_data_20,
    input    [31:0]  w_data_21,
    input    [31:0]  w_data_22,
    input    [31:0]  w_data_23,
    input    [31:0]  w_data_24,
    input    [31:0]  w_data_25,
    input    [31:0]  w_data_26,

    output          branch              ,
    output  [31:0]  R_DATA              ,
    output  [31:0]  mem_pc_o            
);

    assign branch = MEM_control[0] & zero; //& !hit;
    assign mem_pc_o = mem_pc;

    DATA_MEM DUT_DATA_MEM
    (   
        //INPUT
        .clk_50(clk_50)                 ,
        .MEMRead(MEM_control[2])        ,
        .MEMWrite(MEM_control[1])       ,
        .ADDR(result)                   ,
        .WD(WD)                         ,
        .copying(copying)               ,
        .in_data_0(w_data_0),
        .in_data_1(w_data_1),
        .in_data_2(w_data_2),
        .in_data_3(w_data_3),
        .in_data_4(w_data_4),
        .in_data_5(w_data_5),
        .in_data_6(w_data_6),
        .in_data_7(w_data_7),
        .in_data_8(w_data_8),
        .in_data_9(w_data_9),
        .in_data_10(w_data_10),
        .in_data_11(w_data_11),
        .in_data_12(w_data_12),
        .in_data_13(w_data_13),
        .in_data_14(w_data_14),
        .in_data_15(w_data_15),
        .in_data_16(w_data_16),
        .in_data_17(w_data_17),
        .in_data_18(w_data_18),
        .in_data_19(w_data_19),
        .in_data_20(w_data_20),
        .in_data_21(w_data_21),
        .in_data_22(w_data_22),
        .in_data_23(w_data_23),
        .in_data_24(w_data_24),
        .in_data_25(w_data_25),
        .in_data_26(w_data_26),
        
        //OUTPUT        
        .RD(R_DATA)
    );

endmodule