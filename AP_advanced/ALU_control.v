module ALU_CONTROL
(
	input  [1:0] funct7			,
	input  [2:0] funct3			,
	input  [1:0] ALUOp			,

	output [3:0] ALU_control
);

	reg [3:0] ALU_control_r;
	always @ (funct7, funct3, ALUOp) 
	begin
		ALU_control_r = 4'b0;
		if (ALUOp == 2'b01) begin  					//beq, bge
			case (funct3)
				3'd0 :  ALU_control_r = 5;  		//beq
				3'd5 :  ALU_control_r = 7;   		//bge 
				default : ALU_control_r = 4'b0;
			endcase 
		end 
		else if (ALUOp == 2'b00) begin 				//lw, sw 
			ALU_control_r = 2;				
		end 
		else if (ALUOp == 2'b10) begin
			case ({funct7, funct3})		
				5'b00000 : ALU_control_r = 2;   	//add
				5'b00100 : ALU_control_r = 4;   	//xor
				5'b10000 : ALU_control_r = 6;  		//sub
				5'b01000 : ALU_control_r = 1;  		//mult
				5'b00001 : ALU_control_r = 8;       //matr
				default : ALU_control_r = 4'b0;
			endcase
		end 
		else if (ALUOp == 2'b11) begin 		
			case (funct3)
				1 :  ALU_control_r = 3;  			//slli
				0 :  ALU_control_r = 2;				//addi
				default : ALU_control_r = 4'b0;
			endcase
		end
		else begin 
				ALU_control_r = 4'b0;
		end
	end	
	
	assign ALU_control = ALU_control_r;

endmodule