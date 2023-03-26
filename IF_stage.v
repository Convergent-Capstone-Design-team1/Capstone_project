module IF_STAGE
(   
    input           clk     ,
    input           rst     ,
    input           PCSrc   ,
    input           PCWrite ,
    input   [31:0]  t_addr  ,
    output  [31:0]  pc      ,
    output  [31:0]  inst          
);
    //PC
    wire    [31:0]  pc; 
    //Predictor
    wire            T_NT;
    wire    [31:0]  b_pc;
    //BHT
    wire    [1:0]   taken;
    //BTB
    wire            branch;
    wire    [33:0]  next_pc;
    //PC_MUX
    wire    [31:0]  PC_4;
    wire    [31:0]  n_pc;
    
    PC PC
    (   
        //INPUT
        .rst(rst)                       ,
        .clk(clk)                       ,
        .PCWrite(PCWrite)               ,
        .n_pc(n_pc)                     ,
        //OUTPUT
        .pc(pc) 
    );

    PREDICTOR PREDICTOR
    (   
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .opcode(inst[6:0])              ,
        .history(T_NT)                  ,
        .pc(pc)                         ,
        //OUTPUT
        .branch(branch)                 ,
        .taken(taken)                   ,
        .b_pc(b_pc)
    );
                   
    BHT BHT
    (
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .b_pc(b_pc)                     ,
        .prediction(taken)              ,
        //OUTPUT
        .result(T_NT)
    );
    
    BTB BTB
    (
        //INPUT
        .rst(rst)                       ,
        .branch(branch)                 ,
        .pc(pc)                         ,
        .taken(taken)                   ,
        .target(t_addr)                 ,
        //OUTPUT
        .next_pc(next_pc)      
    );

    assign PC_4 = pc + 32'd4;
    
    PC_MUX PC_MUX
    (
        //INPUT
        .sel_mux(T_NT)                  ,
        .PC_4(PC_4)                     ,
        .target_address(next_pc[31:0])  ,

        //OUTPUT
        .next_pc(n_pc)
    );

    INST_MEM INST_MEM
    (
        .ADDR(pc)                       ,
        .INST(inst)
    );

    

endmodule
