module TOPCPU
(
    // INPUT
	input           clk                 ,
	input           rst                 ,
    input           rst_switch          ,
    input           start_switch        ,
    //BTB initialization
    input   [39:0]  btb_init            ,
    input   [7:0]   btb_addr            ,
    //BHT initialization
    input   [1:0]   bht_init            ,
    input   [7:0]   bht_addr            ,      
    //REGISTER_FILE initialization
    input   [4:0]   reg_addr            ,
    input   [31:0]  reg_init            ,
    //MEMORY initilization
    input   [31:0]  mem_init_addr       ,
    input   [31:0]  mem_init_data       ,

    input           acquire_npu         ,
    input   [31:0]  R_DATA              ,
    input           mem_haz             ,

    // OUTPUT
    output          EN_NPU              ,
    output          clk_50              ,
    output          memread_c           ,
    output          memwrite_c          ,
    output  [31:0]  addr_c              ,
    output  [31:0]  wd_c                ,
    output  [9:0]   matA                ,
    output  [9:0]   matB                ,
    output  [9:0]   matC                
);  
    wire            cpu_rst;
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

    //IF_ID register
    wire    [64:0]  IF_ID_D;
    wire    [64:0]  IF_ID_Q;

    //ID stage
    wire 	[31:0] 	RD1;
	wire	[31:0] 	RD2;
    wire    [31:0]  S_INST;
    wire    [31:0]  f_INST;
    wire    [5:0]   ID_control;
    wire 	[3:0] 	ALU_control;
    wire            stall;
    wire            double_matr;

    //ID_EX register
    wire    [153:0] ID_EX_D;
    wire    [153:0] ID_EX_Q;

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
    wire            mem_rd_w;
    wire            mem_wr_w;
    wire    [1:0]   MEM_control;
    wire    [31:0]  R_DATA;
    wire    [31:0]  mem_pc;
    wire    [31:0]  update_mem_addr;
    wire    [31:0]  update_mem_data;

    //MEM_WB register
    wire    [70:0]  MEM_WB_D;
    wire    [70:0]  MEM_WB_Q;
    
    //WB stage
    wire            WB_RegWrite;
    wire    [31:0]  WB_OUTPUT;

    //fall_detected
    wire            clk_50;
    /*******************************/
    /*     Module Instatiation     */
    /*******************************/

    assign target_address = EX_MEM_Q[101:70];
    assign cpu_rst = rst & start_switch;
    
    IF_STAGE IF_STAGE
    (   
        //INPUT
        .clk(clk)                       ,
        .clk_50(clk_50)                 ,
        .rst(cpu_rst)                   ,
        .rst_switch(rst_switch)         ,
        
        .btb_addr(btb_addr)             ,
        .btb_init(btb_init)             ,
        .bht_addr(bht_addr)             ,
        .bht_init(bht_init)             ,
        
        .PCSrc(branch)                  ,
        .PCWrite(stall)                 ,  
        .mem_pc(EX_MEM_Q[138:107])      ,
        .t_addr(target_address)         , 
        .mem_is_taken(EX_MEM_Q[139])    ,
        .double_matr(double_matr)       ,
        
        //OUTPUT
        .is_branch(is_branch)           ,
        .T_NT(Flush)                    ,
        .hit(hit)                       ,
        .pc(PC)                         ,
        .inst(INST)                     ,
        .PC_4(PC_4)                     ,
        .miss_predict(miss_predict)     
    );

    //IF_ID => 66bit 
    assign f_INST = (Flush && !hit) ? 32'h00000013 : INST;
    assign IF_ID_D = {hit, PC, f_INST};
    IF_ID IF_ID
    (
        //INPUT
        .clk(clk)                       ,
        .rst(cpu_rst)                   ,
        .IF_IDWrite(stall)              ,
        .D(IF_ID_D)                     ,
        
        //OUTPUT
        .Q(IF_ID_Q)
    );

    ID_STAGE ID_STAGE
    (   
        //INPUT
        .clk_50(clk_50)                 ,
        .rst(rst_switch)                ,
        .reg_addr(reg_addr)             ,
        .reg_init(reg_init)             ,
        .ack(acquire_npu)               ,
        .mem_wr_addr(addr_c[9:0])       ,
        .mem_wr_en(mem_wr_w)            ,

        //register file
        .INST(IF_ID_Q[31:0])            ,
        .WR(MEM_WB_Q[4:0])              ,
        .RD(ID_EX_Q[4:0])               ,
        .WD(WB_OUTPUT)                  ,     
        .RegWrite(MEM_WB_Q[69])         ,
        .MEMRead(ID_EX_Q[149])          ,   
        .flush(Flush)                   , 
        .hit(hit)                       ,
 
        //OUTPUT 
        //Hazard Detecting Unit
        .stall(stall)                   ,
        .double_matr(double_matr)       ,
        //Register file
        .RD1(RD1)                       ,      
        .RD2(RD2)                       ,
        //ImmGen
        .S_INST(S_INST)                 ,  
        //Control Unit
        .f_id_ctrl(ID_control)          ,
        //ALU control
        .ALU_control(ALU_control)       ,
        .EN_NPU(EN_NPU)                 ,
        .matA_addr(matA)                ,
        .matB_addr(matB)                ,
        .matC_addr(matC)
    );

                // ALUSrc                MR  MW  B         ALUOP
    //ID_EX 153 -> 152 [[ 151 150 ]] [[ 149 148 147 ]] [[ 146 145 ]] 
                     //   106  105      104  103 102
    assign ID_EX_D = {IF_ID_Q[64], ID_control, IF_ID_Q[63:32], S_INST, IF_ID_Q[19:15], IF_ID_Q[24:20], RD1, RD2, ALU_control, IF_ID_Q[11:7]};
    ID_EX ID_EX
    (   
        //INPUT
        .clk(clk)                       ,
        .rst(cpu_rst)                   ,
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
        .rst(cpu_rst)                   ,
        .EN(1'b0)                       ,
        .D(EX_MEM_D)                    ,
        
        //OUTPUT
        .Q(EX_MEM_Q)                
    );

    assign memread_c = mem_rd_w;
    assign memwrite_c = mem_wr_w;
    assign addr_c = EX_MEM_Q[68:37];
    assign wd_c = EX_MEM_Q[36:5];
    MEM_STAGE MEM_STAGE
    (   
        //INPUT
        .MEM_control(EX_MEM_Q[104:102]) ,
        .zero(EX_MEM_Q[69])             ,
        
        //OUTPUT
        .branch(branch)                 ,
        .memrd(mem_rd_w),
        .memwr(mem_wr_w)                
);
    
    assign MEM_control = EX_MEM_Q[106:105];
    assign MEM_WB_D = {MEM_control, R_DATA, EX_MEM_Q[68:37], EX_MEM_Q[4:0]};
    MEM_WB MEM_WB
    (
        //INPUT
        .clk(clk)                       ,
        .rst(cpu_rst)                   ,
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
        .rst(cpu_rst)                   ,
        
        //OUTPUT
        .fall_detected(clk_50)          
    );
    
endmodule 
