// lw, addi와 같은 I-tpye 명령어는 12bit immediate를 사용하기 때문에
// I-tpye 명령어가 fetch되면 ALUSrc control 신호가 1이되어 32bit으로 Sign extend 시킨 값이 ALU의 B intput으로 들어가게 되고
// 그 외에 R-tpye 혹은 branch 명령어가 fetch되면 Data Hazard가 해결된 값이 ALU의 B input으로 들어간다.

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
		if 	(ALUSrc) 	ALU_MUX_OUTPUT_r = S_INST;					// ALUSrc = 1 : Sign 확장된 immediate 값을  ALU MUX 출력으로
		else 			ALU_MUX_OUTPUT_r = ForwardB_MUX_OUTPUT;		// ALUSrc = 0 : Fowarding Unit의 B출력을 ALU ALU MUX 출력으로
	end
	
	assign ALU_MUX_OUTPUT = ALU_MUX_OUTPUT_r;

endmodule