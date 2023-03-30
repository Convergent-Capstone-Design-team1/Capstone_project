module IF_STAGE
(   
    input           clk     ,
    input           rst     ,
    input           PCSrc   ,
    input           PCWrite ,
    input           mem_is_taken,
    input   [31:0]  mem_pc      ,
    input   [31:0]  t_addr  ,

    output          T_NT    ,
    output          hit     ,
    output  [31:0]  pc      ,
    output  [31:0]  inst          
);
    //PC
    wire    [31:0]  pc; 
    //Predictor
    wire    [1:0]   taken;
    wire            T_NT;
    wire    [31:0]  b_pc;
    //BHT
    wire    [1:0]   state;
    wire            hit;
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
        .opcode(inst[6:0])              ,
        .pc(pc)                         ,
        //OUTPUT
        .branch(branch)                 ,       //명령어가 branch임을 알려주는 신호
        .b_pc(b_pc)
    );
                   
    BHT BHT
    (
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .jump(PCSrc)                    ,
        .is_branch(branch)              ,
        .b_pc(b_pc)                     ,
        .hit(hit)                       ,
        //OUTPUT
        .T_NT(T_NT)                     ,
        .state(state)          
    );
    
    BTB BTB
    (
        //INPUT
        //.clk(clk)                       ,
        .rst(rst)                       ,
        .is_branch(is_branch)           ,
        .pc(b_pc)                       ,
        .mem_pc(mem_pc)                 ,
        .is_taken(T_NT)                 ,
        .target(t_addr)                 ,
        .state(state)                   ,
        .b_valid(b_valid)               ,
        .m_valid(m_valid)               ,
        .PCSrc(PCSrc)                   ,
        
        //OUTPUT
        .hit(hit)                       ,
        .next_pc(next_pc)       
    );

    assign PC_4 = pc + 32'd4;
    
    PC_MUX PC_MUX
    (
        //INPUT
        .sel_mux(T_NT)                               ,
        .PC_4(PC_4)                                  ,
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