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
    wire   [31:0]   pc;   
    //PC_controller
    wire   [31:0]   n_pc;               

    
    PC_CONTROLLER PC_C
    (
        .PCSrc(PCSrc)       ,
        .t_addr(t_addr)     ,
        .pc(pc)             ,
        .n_pc(n_pc)        
    );

    PC PC
    (
        .rst(rst)           ,
        .clk(clk)           ,
        .PCWrite(PCWrite)   ,
        .n_pc(n_pc)         ,
        .pc(pc) 
    );

    INST_MEM INST_MEM
    (
        .ADDR(pc)           ,
        .INST(inst)
    );

endmodule