`timescale  1ps / 100fs 

//Program Counter
module Vr_PC 
(
	input		  	rst		,
	input		  	clk		,
	input	[31:0] 	n_pc		,
	output 	[31:0] 	PC
);	

	reg[31:0] r_PC;
	always @ (posedge clk) begin
		if (rst) 
			r_PC <= 0;
		else
			r_PC <= n_pc;
	end

	assign PC = r_PC;

endmodule	

//Program Counter to next instrunction 
module Vr_next_PC
(
	input			branchMUX	,
	input 	[31:0] 	immGen		,		
	input   [31:0] 	pc			, 		
	output 	[31:0] 	n_pc
);

	reg [31:0] r_next_pc;
	always @ (branchMUX, immGen, pc) begin
		if (branchMUX) 
			r_next_pc <= pc + (immGen <<< 1);	
		else
			r_next_pc <= pc + 4;
	end

	assign n_pc = r_next_pc;

endmodule

//ALU
module Vr_ALU
(
	input    	[31:0] 	A				,
	input		[31:0] 	B				,
	input		[3:0]  	ALU_control		,
	output             	zero			,
	output		[31:0] 	ALU_output
);
 
	reg  		   		r_zero;
	reg			[31:0] 	r_ALU_output;
	always @ (A, B, ALU_control) begin
		if (ALU_control == 2) begin			//add
			r_ALU_output = A + B;
			r_zero = 1;
		end 
		else if (ALU_control == 6) begin	//sub
			r_ALU_output = A - B;
			r_zero = 1;
		end 
		else if (ALU_control == 4) begin	//xor
			r_ALU_output = A ^ B;
			r_zero = 1;
		end 
		else if (ALU_control == 7) begin	//bge
			r_ALU_output = 32'b0;
			r_zero = (A < B) ? 0 : 1;
		end 
		else if (ALU_control == 5) begin	//beq
			r_ALU_output = 32'b0;
			r_zero = (A != B) ? 0 : 1;
		end
	end

	assign zero = r_zero;
	assign ALU_output = r_ALU_output;

endmodule

//ALU_MUX
module Vr_ALU_MUX 
(
	input		[31:0] RD2			,
	input		[31:0] ImmG32bit	,
	input			   control		,
	output		[31:0] ALU_MUX
);
	reg [31:0] r_ALU_MUX;
	always @ (RD2, ImmG32bit, control) begin
		if (control) 	r_ALU_MUX = ImmG32bit;	
		else 			r_ALU_MUX = RD2;
	end
	
	assign ALU_MUX = r_ALU_MUX;

endmodule

//ALU Control
module Vr_ALU_control
(
	input	     funct7			,
	input  [2:0] funct3			,
	input  [1:0] ALUOp			,
	output [3:0] ALU_control
);

	reg [3:0] r_ALU_control;
	always @ (funct7, funct3 ,ALUOp) begin
		if (ALUOp == 2'b01) begin  			//beq, bge
			case (funct3)
				0 :  r_ALU_control = 5;  	//beq
				5 :  r_ALU_control = 7;   	//bge 
			endcase 
		end 
		else if (ALUOp == 2'b00) begin 		//lw, sw 
			r_ALU_control = 2;				
		end 
		else if (ALUOp == 2'b10) begin
			case ({funct7, funct3})		
				0 : r_ALU_control = 2;   	//add
				4 : r_ALU_control = 4;   	//xor
				8 : r_ALU_control = 6;  	//sub
			endcase
		end 
		else if (ALUOp == 2'b11) begin 		//addi
			r_ALU_control = 2;
		end
	end	
	
	assign ALU_control = r_ALU_control;

endmodule

//Control
module Vr_control
(
	input      [6:0] opcode		,
	input	         zero		,
	output     [6:0] control	, 
	output           pc_mux
);
	//No need MemRead or MemWrite -> remove MemRead because of Vr_data_mem condition
	//opcode[6] = ALUSrc   ,   opcode[5] = MemtoReg  ,    opcode[4] = RegWrite,
	//opcode[3] = MemWrite ,   opcode[2] = Branch    ,    opcode[1:0] = ALUOp

	reg [6:0] r_control;
	always @ (opcode) begin
		case (opcode)
			7'b0110011 : r_control = 7'b0010010;	//R-type : add, sub, xor -> ALUSrc '0'
			7'b0010011 : r_control = 7'b1010011;	//I-type : addi -> ALUSrc '1'
			7'b0000011 : r_control = 7'b1110000;	//I-type : lw
			7'b0100011 : r_control = 7'b1x01000;	//S-type : sw
			7'b1100011 : r_control = 7'b0x00101;	//SB-type : beg, bge
			default    : r_control = 7'bxxxxxxx;
		endcase
	end

	assign pc_mux = zero & control[2];
	assign control = r_control;

endmodule 

//implement sign extention 
module Vr_Imm_Gen
(	
	input		[31:0] Inst			,
	output		[31:0] ImmG32bit
);

	reg [31:0] r_immG32bit; 	
	always @ (Inst) begin
		case (Inst[6:0])
			7'b0010011, 7'b0000011 : r_immG32bit = {{20{Inst[31]}}, Inst[31:20]};									//addi, lw
			7'b0100011 		       : r_immG32bit = {{20{Inst[31]}}, Inst[31:25], Inst[11:7]};						//sw
			7'b1100011			   : r_immG32bit = {{20{Inst[31]}}, Inst[31], Inst[7], Inst[30:25], Inst[11:8]};	//beq, bge
		endcase
	end

	assign ImmG32bit = r_immG32bit;

 endmodule
