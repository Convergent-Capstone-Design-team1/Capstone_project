module IMMGEN
(	
	input		[31:0] INST         ,
	output		[31:0] S_INST
);

	reg [31:0] INST_r; 	
	always @ (INST) 
	begin
		INST_r = 32'b0;
		case (INST[6:0])
			7'b0010011, 7'b0000011 	: INST_r = {{20{INST[31]}}, INST[31:20]};									//addi, lw
			7'b0100011 		       	: INST_r = {{20{INST[31]}}, INST[31:25], INST[11:7]};						//sw
			7'b1100011			   	: INST_r = {{20{INST[31]}}, INST[31], INST[7], INST[30:25], INST[11:8]};	//beq, bge
			default 				: INST_r = 32'b0;
		endcase
	end

	assign S_INST = INST_r;

 endmodule