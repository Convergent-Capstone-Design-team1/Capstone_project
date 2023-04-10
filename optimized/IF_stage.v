module IF_STAGE
(   
    input           clk         ,
    input           clk_50      ,
    input           rst         ,
    input           PCSrc       ,
    input           PCWrite     ,
    input   [31:0]  mem_pc      ,
    input   [31:0]  t_addr      ,
    input           mem_is_taken,
    input           ex_is_branch,

    output          is_branch   ,
    output          T_NT        ,
    output          hit         ,
    output  [31:0]  pc          ,
    output  [31:0]  inst        ,
    output  [31:0]  PC_4        ,
    output          miss_predict         
);
    
    //Predictor
    wire    [31:0]  b_pc;  
    //BHT
    wire    [1:0]   state;
    wire            miss_predict;
    //BTB
    wire    [31:0]  next_pc;
    //PC_MUX
    wire    [31:0]  n_pc;
    
    PC DUT_PC
    (   
        //INPUT
        .rst(rst)                       ,
        .clk(clk)                       ,
        .PCWrite(PCWrite)               ,
        .n_pc(n_pc)                     ,
        
        //OUTPUT
        .pc(pc) 
    );

    PREDICTOR DUT_PREDICTOR
    (   
        //INPUT
        .state(state)                   ,
        .opcode(inst[6:0])              ,
        .pc(pc)                         ,
        
        //OUTPUT
        .is_branch(is_branch)           ,       //명령어가 branch임을 알려주는 신호
        .b_pc(b_pc)
    );

    BHT DUT_BHT
    (
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .is_taken(hit)                  ,
        .mem_is_taken(mem_is_taken)     ,
        .PCSrc(PCSrc)                   ,
        .ex_is_branch(ex_is_branch)     ,
        .b_pc(b_pc)                     ,
        .mem_pc(mem_pc)                 ,
        
        //OUTPUT
        .T_NT(T_NT)                     ,
        .state(state)                   ,
        .miss_predict(miss_predict)     
    );
    
    BTB DUT_BTB
    (
        //INPUT
        .is_branch(is_branch)           ,
        .pc(b_pc)                       ,
        .mem_pc(mem_pc)                 ,
        .is_taken(T_NT)                 ,
        .target(t_addr)                 ,
        .state(state)                   ,
        .PCSrc(PCSrc)                   ,
        .miss_predict(miss_predict)     ,
        
        //OUTPUT
        .hit(hit)                       ,
        .next_pc(next_pc)       
    );

    assign PC_4 = pc + 32'd4;
    
    PC_MUX DUT_PC_MUX
    (
        //INPUT
        .sel_mux(T_NT)                  ,
        .PC_4(PC_4)                     ,
        .target_address(next_pc[31:0])  ,

        //OUTPUT
        .next_pc(n_pc)
    );

    INST_MEM DUT_INST_MEM
    (
        .clk_50(clk_50)                 ,
        .rst(rst)                       ,
        .ADDR(pc)                       ,
        .INST(inst)
    );

endmodule