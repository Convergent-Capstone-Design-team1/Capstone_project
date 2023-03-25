module IF_STAGE
(   
    input           t_addr  ,
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
    wire    [1:0]   history;
    //BHT
    wire    [1:0]   taken;
    //BTB
    wire    [31:0]  n_pc;

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

    PREDICTOR PREDICTOR
    (   
        //INPUT
        .history(history)   ,
        .pc(pc)             ,
        //OUTPUT
        .taken(taken)       ,
    );
                   
    BHT BHT
    (
        //INPUT
        .clk(clk)           ,
        .rst(rst)           ,
        .pc(pc)             ,
        .prediction(taken)  .
        //OUTPUT
        .result(history)
    );
    
    BTB BTB
    (
        //INPUT
        .clk(clk)           ,
        .rst(rst)           ,
        .pc(pc)             ,
        .taken(history)     ,
        .target(t_addr)     ,
        //OUTPUT
        .next_pc(n_pc)      ,
    );

    INST_MEM INST_MEM
    (
        .ADDR(pc)           ,
        .INST(inst)
    );

endmodule