module TOPCPU
(
	input           clk ,
	input           rst   
);
    //IF stage
    wire    [31:0]  PC;
    wire    [31:0]  PC_4;
    wire    [31:0]  target_address;
    wire 	[31:0] 	INST;
    wire            miss_predict;
    wire            PCWrite;
    wire            Flush;
    wire            hit;
    wire            is_branch;
    wire            flush2;
    wire            flush3;

    //IF_ID register
    wire    [65:0]  IF_ID_D;
    wire    [65:0]  IF_ID_Q;

    //ID stage
    wire 	[31:0] 	RD1;
	wire	[31:0] 	RD2;
    wire    [31:0]  S_INST;
    wire    [31:0]  f_INST;
    wire    [5:0]   ID_control;
    wire 	[3:0] 	ALU_control;
    wire            stall;

    //ID_EX register
    wire    [154:0] ID_EX_D;
    wire    [154:0] ID_EX_Q;
    wire            back_RegWrite;
    wire    [31:0]  back_WD;

    //EX_stage
    wire    [31:0]  t_addr;
    wire    [31:0]  result;
    wire    [31:0]  F_B;
    wire    [4:0]   EX_control;
    wire            zero;

    //EX_MEM register
    wire    [139:0] EX_MEM_D;
    wire    [139:0] EX_MEM_Q;    

    //MEM stage
    wire            branch;
    wire    [1:0]   MEM_control;
    wire    [31:0]  R_DATA;
    wire    [31:0]  mem_pc;

    //MEM_WB register
    wire    [71:0]  MEM_WB_D;
    wire    [71:0]  MEM_WB_Q;
    
    //WB stage
    wire    [31:0]  WB_OUTPUT;

    //fall_detected
    wire            clk_50;
    /*******************************/
    /*     Module Instatiation     */
    /*******************************/

    assign target_address = EX_MEM_Q[101:70];
    
    
    IF_STAGE IF_STAGE
    (   
        //INPUT
        .clk(clk)                       ,
        .clk_50(clk_50)                 ,
        .rst(rst)                       ,
        .PCSrc(branch)                  ,
        .PCWrite(stall)                 ,  
        .mem_pc(mem_pc)                 ,
        .t_addr(target_address)         , 
        .mem_is_taken(EX_MEM_Q[139])    ,
        .ex_is_branch(ID_EX_Q[154])     ,
        .mem_is_branch(EX_MEM_Q[140])   ,
        .wb_is_branch(MEM_WB_Q[71])     ,
        .stall(stall)                   ,
        //OUTPUT
        .is_branch(is_branch)           ,
        .T_NT(Flush)                    ,
        .hit(hit)                       ,
        .pc(PC)                         ,
        .inst(INST)                     ,
        .PC_4(PC_4)                     ,
        .miss_predict(miss_predict)     ,
        .f_2(flush2)                    ,
        .f_3(flush3)
    );

    //IF_ID => 66bit 
    assign f_INST = (Flush && !hit) ? 32'h00000013 : INST;
    assign IF_ID_D = {is_branch, hit, PC, f_INST};
    IF_ID IF_ID
    (
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .IF_IDWrite(stall)              ,
        .D(IF_ID_D)                     ,
        
        //OUTPUT
        .Q(IF_ID_Q)
    );

    assign {back_WD, back_RegWrite} = flush3 ? 33'b0 : {WB_OUTPUT, MEM_WB_Q[69]};
    ID_STAGE ID_STAGE
    (   
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .INST(IF_ID_Q[31:0])            ,
        //register file
        .WR(MEM_WB_Q[4:0])              ,
        .RD(ID_EX_Q[4:0])               ,
        .WD(back_WD)                  ,     
        .RegWrite(back_RegWrite)         ,
        .MEMRead(ID_EX_Q[150])          ,   
        .flush(Flush)                   , 
        .hit(hit)                       ,  
 
        //OUTPUT 
        //Hazard Detecting Unit
        .stall(stall)                   ,
        //Register file
        .RD1(RD1)                       ,      
        .RD2(RD2)                       ,
        //ImmGen
        .S_INST(S_INST)                 ,  
        //Control Unit
        .f_id_ctrl(ID_control)          ,
        //ALU control
        .ALU_control(ALU_control)       
    );

                    // ALUSrc                MR  MW  B         ALUOP
    //ID_EX : 154 [[ 151 150 ]] [[ 149 148 147 ]] [[ 146 145 ]] 
                //   106  105      104  103 102
    assign ID_EX_D = {IF_ID_Q[65], IF_ID_Q[64], ID_control, IF_ID_Q[63:32], S_INST, IF_ID_Q[19:15], IF_ID_Q[24:20], RD1, RD2, ALU_control, IF_ID_Q[11:7]};
    ID_EX ID_EX
    (   
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .EN(1'b0)                       ,
        .flush(Flush)                   ,
        .D(ID_EX_D)                     ,
        
        //OUTPUT
        .Q(ID_EX_Q)
    );

    EX_STAGE EX_STAGE
    (
        //INPUT
        //Control
        .flush(Flush)                   ,
        .hit(hit)                       ,
        .EX_control(ID_EX_Q[151:147])   ,
        .ALUSrc(ID_EX_Q[152])           ,
        //target address adder
        .pc(ID_EX_Q[146:115])           ,

        /**************ALU**************/
        //IMMGen output
        .S_INST(ID_EX_Q[114:83])        ,
        //Fowarding Unit input
        .RS1(ID_EX_Q[82:78])            ,
        .RS2(ID_EX_Q[77:73])            ,
        .EX_MEM_RD(EX_MEM_Q[4:0])       ,
        .MEM_WB_RD(MEM_WB_Q[4:0])       ,         
        .EX_MEM_RegWrite(EX_MEM_Q[105]) ,
        .MEM_WB_RegWrite(MEM_WB_Q[69])  ,
        //Forwarding Mux input
        .ALU_result(EX_MEM_Q[68:37])    ,
        .WB_OUTPUT(WB_OUTPUT)           ,
        .RD1(ID_EX_Q[72:41])            ,
        .RD2(ID_EX_Q[40:9])             ,
        //ALU control output
        .ALU_control(ID_EX_Q[8:5])      ,
        
        //OUTPUT
        .t_addr(t_addr)                 ,
        .result(result)                 ,
        .F_B(F_B)                       ,     
        .zero(zero)                     ,
        .f_ex_ctrl(EX_control)          
    );

    //EX_MEM_D = 107 + 32 = 139 + 1 = 140
    assign EX_MEM_D = {ID_EX_Q[153], ID_EX_Q[146:115], EX_control, t_addr, zero, result, F_B, ID_EX_Q[4:0]};
    EX_MEM EX_MEM
    (   
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .EN(1'b0)                       ,
        .D(EX_MEM_D)                    ,
        
        //OUTPUT
        .Q(EX_MEM_Q)
    );

    MEM_STAGE MEM_STAGE //EX_MEM_Q[138:107]
    (   
        //INPUT
        //branch
        .clk_50(clk_50)                 ,
        .rst(rst)                       ,
        .MEM_control(EX_MEM_Q[106:102]) ,
        .zero(EX_MEM_Q[69])             ,
        //data memory
        .result(EX_MEM_Q[68:37])        ,
        .WD(EX_MEM_Q[36:5])             ,
        .mem_pc(EX_MEM_Q[138:107])      ,
        .hit(EX_MEM_Q[139])             ,
        
        //OUTPUT
        .branch(branch)                 ,
        .R_DATA(R_DATA)                 ,
        .mem_pc_o(mem_pc)               
    );

    // 72
    assign MEM_WB_D = {EX_MEM_Q[140], EX_MEM_Q[106:105], R_DATA, EX_MEM_Q[68:37], EX_MEM_Q[4:0]};
    MEM_WB MEM_WB
    (
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .D(MEM_WB_D)                    ,
        
        //OUTPUT
        .Q(MEM_WB_Q) 
    );

    WB_STAGE WB_STAGE
    (   
        //INPUT
        .WB(MEM_WB_Q[70])               ,
        .R_DATA(MEM_WB_Q[68:37])        ,
        .result(MEM_WB_Q[36:5])         ,
        //OUTPUT
        .WB_OUTPUT(WB_OUTPUT)
    );

    FALLING_EDGE_DETECTOR FALLING_EDGE_DETECTOR
    (   
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        
        //OUTPUT
        .fall_detected(clk_50)          
    );

endmodule 