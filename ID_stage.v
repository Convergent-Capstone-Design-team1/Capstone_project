module ID_STAGE
(   
    input           clk             ,
    input           rst             ,
    input   [31:0]  INST            ,
    input   [4:0]   WR              ,
    input   [4:0]   RD              ,
    input   [31:0]  WD              ,
    input           RegWrite        ,
    input           MEMRead         ,
    input           flush           ,
    input           hit             ,
    
    output          stall           ,
    output  [31:0]  RD1             ,
    output  [31:0]  RD2             ,
    output  [31:0]  S_INST          ,
    output  [5:0]   f_id_ctrl       ,
    output  [3:0]   ALU_control     
);

    wire    [7:0]   control;

    HAZARD_DETECTION HAZARD_DETECTION
    (   
        //INPUT
        .MEMRead(MEMRead)           ,
        .RD(RD)                     ,
        .RS1(INST[19:15])           ,
        .RS2(INST[24:20])           ,
        
        //OUTPUT
        .stall(stall)               
    );

    CONTROL CONTROL
    (
        //INPUT
        .CtrlSrc(stall)             ,
        .opcode(INST[6:0])          ,
        
        //OUTPUT
        .control(control)
    );

    REGISTER_FILE REGISTER_FILE
    (
        //INPUT
        .clk(clk)                   ,
        .rst(rst)                   ,
        .RR1(INST[19:15])           ,
        .RR2(INST[24:20])           ,
        .WR(WR)                     ,
        .WD(WD)                     ,
        .WE(RegWrite)               ,
        
        //OUTPUT
        .RD1(RD1)                   ,
        .RD2(RD2)
    );

    IMMGEN IMMGEN
    (
        //INPUT
        .INST(INST)                 ,    
       
        //OUTPUT
        .S_INST(S_INST)
    );

    ALU_CONTROL ALU_CONTROL
    (
        //INPUT
        .funct7(INST[30])           , 
        .funct3(INST[14:12])        , 
        .ALUOp(control[1:0])        , 
        
        //OUTPUT
        .ALU_control(ALU_control)
    );

    ID_EX_FLUSH ID_EX_FLUSH
    (
        //INPUT
        .flush(flush)               ,
        .hit(hit)                   ,
        .id_ex_ctrl(control[7:2])   ,
       
        //OUTPUT
        .id_ex_f_ctrl(f_id_ctrl)    
    );
    
endmodule