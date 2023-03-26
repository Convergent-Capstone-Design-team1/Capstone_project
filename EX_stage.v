module EX_STAGE
(
    /*******************************/
    /*            INPUT            */
    /*******************************/
    
    //Control
    input           EX              ,
    //target address adder
    input   [31:0]  pc              ,
    /**************ALU**************/
    //ImmGen output
    input   [31:0]  S_INST          ,
    //Fowarding Unit input
    input   [4:0]   RS1             ,            
    input   [4:0]   RS2             ,
    input   [4:0]   EX_MEM_RD       ,
    input   [4:0]   MEM_WB_RD       ,          
    input   EX_MEM_RegWrite         ,
    input   MEM_WB_RegWrite         ,
    //Forwarding Mux input
	input	[31:0]	ALU_result		,
	input	[31:0]	WB_OUTPUT	    ,
	input	[31:0]	RD1				,
	input	[31:0] 	RD2				,   
    //ALU control output
    input   [3:0]   ALU_control     ,
    
    /*******************************/
    /*           OUTPUT            */
    /*******************************/
    
    //calculated target address 
    output  [31:0]  t_addr          ,
    //ALU result
    output  [31:0]  result          ,
    //ForwardB MUX output
    output  [31:0]  F_B             ,
    output          zero            
);
    //Forwarding Unit output
    wire    [1:0]   ForwardA;
    wire    [1:0]   ForwardB;
    //Forwarding MUX output
    wire    [31:0]  A;        
    wire    [31:0]  B;
    //ALU MUX output
    wire    [31:0]  ALU_MUX_OUTPUT;

    ALU ALU
    (   
        //INPUT
        .A(A)                               ,
        .B(ALU_MUX_OUTPUT)                  ,
        .ALU_control(ALU_control)           ,
        //OUTPUT
        .zero(zero)                         ,
        .result(result) 
    );

    ALU_MUX ALU_MUX
    (
        //INPUT
        .ForwardB_MUX_OUTPUT(B)             ,
        .S_INST(S_INST)                     ,
        .ALUSrc(EX)                         ,
        //OUTPUT
        .ALU_MUX_OUTPUT(ALU_MUX_OUTPUT)
    );

    FORWARDING_UNIT FORWARDING_UNIT
    (
        //INPUT
        .EX_MEM_RegWrite(EX_MEM_RegWrite)   ,
        .MEM_WB_RegWrite(MEM_WB_RegWrite)   ,
        .EX_MEM_RD(EX_MEM_RD)               ,
        .MEM_WB_RD(MEM_WB_RD)               ,
        .RS1(RS1)                           ,
        .RS2(RS2)                           ,
        //OUTPUT
        .ForwardA(ForwardA)                 ,
        .ForwardB(ForwardB)
    );

    FORWARDING_MUX FORWARDING_MUX
    (
        //INPUT
        .ForwardA(ForwardA)		            ,
	    .ForwardB(ForwardB)		            ,
	    .ALU_result(ALU_result)	            ,
	    .WB_OUTPUT(WB_OUTPUT)	            ,
	    .RD1(RD1)				            ,
	    .RD2(RD2)				            ,
        //OUTPUT
	    .A(A)				                ,
	    .B(B)
);
    
    assign F_B = B;
    assign t_addr = pc + (S_INST << 1);
    
endmodule