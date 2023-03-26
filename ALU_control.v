module ALU_CONTROL
(
	input	     funct7			,
	input  [2:0] funct3			,
	input  [1:0] ALUOp			,

	output [3:0] ALU_control
);

	reg [3:0] ALU_control_r;
	always @ (funct7, funct3 ,ALUOp) 
	begin
		if (ALUOp == 2'b01) begin  			//beq, bge
			case (funct3)
				0 :  ALU_control_r = 5;  	//beq
				5 :  ALU_control_r = 7;   	//bge 
			endcase 
		end 
		else if (ALUOp == 2'b00) begin 		//lw, sw 
			ALU_control_r = 2;				
		end 
		else if (ALUOp == 2'b10) begin
			case ({funct7, funct3})		
				0 : ALU_control_r = 2;   	//add
				4 : ALU_control_r = 4;   	//xor
				8 : ALU_control_r = 6;  	//sub
			endcase
		end 
		else if (ALUOp == 2'b11) begin 		//addi
			ALU_control_r = 2;
		end
	end	
	
	assign ALU_control = ALU_control_r;

endmodule