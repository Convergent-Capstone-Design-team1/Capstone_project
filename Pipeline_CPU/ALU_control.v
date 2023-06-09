// Fetch된 명령어가 어떤 연산을 하는지에 따라
// ALU에 들어가는 control 신호를 생성해준다.

module ALU_CONTROL
(
	input  [1:0] funct7			,	// 명령어의 funct7 부분
	input  [2:0] funct3			,	// 명령어의 funct3 부분
	input  [1:0] ALUOp			,	// Control 신호에서 나온 ALUOP control signal

	output [3:0] ALU_control	
);

	reg [3:0] ALU_control_r;
	always @ (funct7, funct3 ,ALUOp) 		
	begin
		ALU_control_r = 4'b0;						//To prevent latch
		if (ALUOp == 2'b01) begin  					//beq, bge instructions
			case (funct3)
				0 :  ALU_control_r = 5;  			//beq
				5 :  ALU_control_r = 7;   			//bge 
				default : ALU_control_r = 4'b0;
			endcase 
		end 
		else if (ALUOp == 2'b00) begin 				//lw, sw instructions
			ALU_control_r = 2;				
		end 	
		else if (ALUOp == 2'b10) begin				//R-type instructions
			case ({funct7, funct3})		
				5'b00000 : ALU_control_r = 2;   	//add
				5'b00100 : ALU_control_r = 4;   	//xor
				5'b10000 : ALU_control_r = 6;  		//sub
				5'b01000 : ALU_control_r = 1;  		//mult
				5'b00001 : ALU_control_r = 8;       //matr
				default : ALU_control_r = 4'b0;		//default
			endcase
		end 
		else if (ALUOp == 2'b11) begin 				//addi, slli instructions 
			case (funct3)
				1 :  ALU_control_r = 3;  			//slli
				0 :  ALU_control_r = 2;				//addi
				default : ALU_control_r = 4'b0;		//default
			endcase
		end
		else begin 
				ALU_control_r = 4'b0;
		end
	end	
	
	assign ALU_control = ALU_control_r;

endmodule