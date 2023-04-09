`timescale  1ps / 100fs 

//Single-cycle CPU Top module
module Vr_TopCPU
(
	input rst, 
	input clk
);
	wire    [31:0] 	ALU_output;
	wire    [31:0] 	ImmG32bit;
	wire 	[31:0] 	PC;
	wire 	[31:0] 	n_pc;
	wire 	[31:0] 	INST;
	wire 	[31:0] 	RD1;
	wire	[31:0] 	RD2;
	wire 	[31:0] 	WD;
	wire 	[31:0] 	RD;
	wire 	[31:0] 	ALU_MUX;
	wire 	[3:0] 	ALU_control;
	wire 	[6:0] 	control;
	wire      	  	zero;
	wire       	  	pc_mux_clt;
    //
    wire    [31:0]  data_mem;

    Vr_PC P 
    (
        .rst(rst)                   , 
        .clk(clk)                   , 
        .n_pc(n_pc)                 , 
        .PC(PC)
    );

	Vr_next_PC NP 
    (
        .branchMUX(pc_mux_clt)      , 
        .immGen(ImmG32bit)          , 
        .pc(PC)                     , 
        .n_pc(n_pc)
    );

	INST_MEM IM 
    (
        .ADDR(PC)                   , 
        .INST(INST)
    );
	
    Vr_control CON 
    (
        .opcode(INST[6:0])          , 
        .zero(zero)                 , 
        .control(control)           , 
        .pc_mux(pc_mux_clt)
    );
	
	assign WD = control[5] ? RD : ALU_output; //Data memory MUX control signal
	Vr_register_file RF
    (
        .CLK(clk)                   , 
        .RST(rst)                   , 
        .RR1(INST[19:15])           , 
        .RR2(INST[24:20])           , 
        .WR(INST[11:7])             , 
        .WD(WD)                     , 
        .WE(control[4])             , 
        .RD1(RD1)                   , 
        .RD2(RD2)
    );

	Vr_Imm_Gen IG
    (
        .Inst(INST)                 , 
        .ImmG32bit(ImmG32bit)
    );	

	Vr_ALU_control AC 
    (
        .funct7(INST[30])           , 
        .funct3(INST[14:12])        , 
        .ALUOp(control[1:0])        , 
        .ALU_control(ALU_control)
    );
	
    Vr_ALU A 
    (
        .A(RD1)                     , 
        .B(ALU_MUX)                 , 
        .ALU_control(ALU_control)   , 
        .zero(zero)                 , 
        .ALU_output(ALU_output)
    );
	
    Vr_ALU_MUX AM 
    (
        .RD2(RD2)                   , 
        .ImmG32bit(ImmG32bit)       , 
        .control(control[6])        , 
        .ALU_MUX(ALU_MUX)
    );
	
    Vr_data_mem DM 
    (
        .CLK(clk)                   , 
        .ADDR(ALU_output)           , 
        .RW(control[3])             , 
        .WD(RD2)                    , 
        .RD(RD)                     
    );

endmodule 