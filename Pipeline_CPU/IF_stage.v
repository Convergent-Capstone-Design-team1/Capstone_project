module IF_STAGE
(   
    input           clk             ,
    input           clk_50          ,
    input           rst             ,
    input           rst_switch      ,

    input  [7:0]    btb_addr        ,
    input  [7:0]    bht_addr        ,
    input  [39:0]   btb_init        ,
    input  [1:0]    bht_init        ,

    input           PCSrc           ,
    input           PCWrite         ,
    input   [31:0]  mem_pc          ,
    input   [31:0]  t_addr          ,
    input           mem_is_taken    ,

    output          is_branch       ,
    output          T_NT            ,
    output          hit             ,
    output  [31:0]  pc              ,
    output  [31:0]  inst            ,
    output  [31:0]  PC_4            ,
    output          miss_predict    
);
    
    //Predictor
    wire    [31:0]  b_pc;  
    //BHT
    wire            n_jump;
    //BTB
    wire    [31:0]  next_pc;
    //PC_MUX
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
        .opcode(inst[6:0])              ,
        .pc(pc)                         ,
        
        //OUTPUT
        .is_branch(is_branch)           ,       //명령어가 branch임을 알려주는 신호
        .b_pc(b_pc)
    );

    BHT BHT
    (
        //INPUT
        .clk(clk)                       ,
        .rst_i(rst_switch)              ,
        .bht_addr(bht_addr)             ,
        .bht_init(bht_init)             ,

        .mem_is_taken(mem_is_taken)     ,
        .PCSrc(PCSrc)                   ,
        .b_pc(b_pc)                     ,
        .mem_pc(mem_pc)                 ,
        
        //OUTPUT
        .T_NT(T_NT)                     ,
        .miss_predict(miss_predict)               
    );
    
    BTB BTB
    (
        //INPUT
        .clk(clk)                       ,
        .rst_i(rst_switch)              ,
        .btb_addr(btb_addr)             ,
        .btb_init(btb_init)             ,

        .is_branch(is_branch)           ,
        .pc(b_pc)                       ,
        .mem_pc(mem_pc)                 ,
        .target(t_addr)                 ,
        .is_taken(T_NT)                 ,
        .PCSrc(PCSrc)                   ,
        .miss_predict(miss_predict)     ,
        
        //OUTPUT
        .hit(hit)                       ,
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
        .clk_50(clk_50)                 ,
        .ADDR(pc)                       ,
        .INST(inst)
    );

endmodule