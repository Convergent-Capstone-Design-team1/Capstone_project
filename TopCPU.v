module TOPCPU
(
	input           clk,
	input           rst   
);
    //IF stage
    wire    [31:0]  PC;
    wire    [31:0]  target_address;
    wire 	[31:0] 	INST;
    wire            PCWrite;
    //IF_ID register
    wire    [63:0]  IF_ID_D;
    wire    [63:0]  IF_ID_Q;
    //ID stage
    wire 	[31:0] 	RD1;
	wire	[31:0] 	RD2;
    wire    [31:0]  S_INST;
    wire    [7:0]   ID_control;
    wire 	[3:0] 	ALU_control;
    wire            stall;
    //ID_EX register
    wire    [152:0] ID_EX_D;
    wire    [152:0] ID_EX_Q;
    //EX_stage
    wire    [31:0]  t_addr;
    wire    [31:0]  result;
    wire    [31:0]  F_B;
    wire            zero;
    //EX_MEM register
    wire    [106:0] EX_MEM_D;
    wire    [106:0] EX_MEM_Q;    
    //MEM stage
    wire            branch;
    wire            MEM_control;
    wire    [31:0]  R_DATA;
    //MEM_WB register
    wire    [70:0]  MEM_WB_D;
    wire    [70:0]  MEM_WB_Q;
    //WB stage
    wire    [31:0]  WB_OUTPUT;

    /*******************************/
    /*     Module Instatiation     */
    /*******************************/

    assign target_address = EX_MEM_Q[101:70];

    IF_STAGE IF_STAGE
    (   
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .PCSrc(branch)                  ,
        .PCWrite(stall)                 ,  
        .t_addr(target_address)         ,    
        
        //OUTPUT
        .pc(PC)                         ,
        .inst(INST)
    );

    //IF_ID => 64bit 
    assign IF_ID_D = {PC, INST};
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

    ID_STAGE ID_STAGE
    (   
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .INST(IF_ID_Q[31:0])            ,
        //register file
        .WR(MEM_WB_Q[4:0])              ,
        .RD(ID_EX_Q[4:0])               ,
        .WD(WB_OUTPUT)                  ,     
        .RegWrite(MEM_WB_Q[69])         ,
        .MEMRead(ID_EX_Q[150])          ,      
        
        //OUTPUT 
        //Hazard Detecting Unit
        .stall(stall)                   ,
        //Register file
        .RD1(RD1)                       ,      
        .RD2(RD2)                       ,
        //ImmGen
        .S_INST(S_INST)                 ,  
        //Control Unit
        .control(ID_control)            ,
        //ALU control
        .ALU_control(ALU_control)       
    );
                // ALUSrc                MR  MW  B         ALUOP
    //ID_EX 155 -> 152 [[ 151 150 ]] [[ 149 148 147 ]] [[ 146 145 ]] 
                     //   106  105      104  103 102
    assign ID_EX_D = {ID_control[7:2], IF_ID_Q[63:32], S_INST, IF_ID_Q[19:15], IF_ID_Q[24:20], RD1, RD2, ALU_control, IF_ID_Q[11:7]};
    ID_EX ID_EX
    (   
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .D(ID_EX_D)                     ,
        
        //OUTPUT
        .Q(ID_EX_Q)
    );

    EX_STAGE EX_STAGE
    (
        //INPUT
        //Control
        .EX(ID_EX_Q[152])               ,
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
        .zero(zero)      
    );

    //EX_MEM_D = 107
    assign EX_MEM_D = {ID_EX_Q[151:147], t_addr, zero, result, F_B, ID_EX_Q[4:0]};
    EX_MEM EX_MEM
    (   
        //INPUT
        .clk(clk)                       ,
        .rst(rst)                       ,
        .D(EX_MEM_D)                    ,
        
        //OUTPUT
        .Q(EX_MEM_Q)                
    );

    MEM_STAGE MEM_STAGE
    (   
        //INPUT
        //branch
        .M(EX_MEM_Q[104:102])           ,
        .zero(EX_MEM_Q[69])             ,
        //data memory
        .result(EX_MEM_Q[68:37])        ,
        .WD(EX_MEM_Q[36:5])             ,  
        
        //OUTPUT
        .branch(branch)                 ,
        .R_DATA(R_DATA)             
    );

    assign MEM_WB_D = {EX_MEM_Q[106:105], R_DATA, EX_MEM_Q[68:37], EX_MEM_Q[4:0]};
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

endmodule 
