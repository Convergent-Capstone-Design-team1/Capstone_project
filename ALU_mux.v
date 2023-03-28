module ALU_MUX
(	
	input	[31:0] 	ForwardB_MUX_OUTPUT	,
	input	[31:0] 	S_INST			    ,
	input		 	ALUSrc			    ,

	output	[31:0]	ALU_MUX_OUTPUT
);
    
    reg [31:0] ALU_MUX_OUTPUT_r;
	always @ (*) 
	begin
		if 	(ALUSrc) 	ALU_MUX_OUTPUT_r = S_INST;	
		else 			ALU_MUX_OUTPUT_r = ForwardB_MUX_OUTPUT;
	end
	
	assign ALU_MUX_OUTPUT = ALU_MUX_OUTPUT_r;

endmodule