module IF_STAGE
(   
    input           branch  ,
    input           clk     ,
    input           rst     ,
    input           PCSrc   ,
    input           PCWrite ,
    input   [31:0]  t_addr  ,
    output  [31:0]  pc      ,
    output  [31:0]  inst          
);
    //PC
    wire   [31:0]   pc;   
    //Predictor
    wire   [1:0]    taken;

    PREDICTOR PREDICTOR
    (   
        //INPUT
        .branch(branch)     ,
        .pc(pc)             ,
        //OUTPUT
        .taken(taken)       ,
    )
    //BTB
    wire   [31:0]   n_pc;               

    PC PC
    (   
        //INPUT
        .rst(rst)           ,
        .clk(clk)           ,
        .PCWrite(PCWrite)   ,
        .n_pc(n_pc)         ,
        //OUTPUT
        .pc(pc) 
    );

    BHT BHT
    (
        .clk(clk)           ,
        .rst(rst)           ,
        .pc(pc)             ,
        .prediction()
    )
    INST_MEM INST_MEM
    (
        .ADDR(pc)           ,
        .INST(inst)
    );

endmodule