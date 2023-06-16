// Forwarding Unit에서 나온 signal에 따라 ALU의 input A, B를 결정해주는 MUX module
// 이를 통해서 최종적으로 data forwarding 기법을 사용해 Data Hazard를 해결

module FORWARDING_MUX
(	
	input	[1:0]	ForwardA		,
	input	[1:0]	ForwardB		,
	input	[31:0]	ALU_result		,
	input	[31:0]	WB_OUTPUT		,
	input	[31:0]	RD1				,
	input	[31:0] 	RD2				,

	output	[31:0]	A				,
	output	[31:0] 	B
);

	/* case문을 통해서 MUX 구현 */
	
	//ALU input A 
	reg		[31:0]	A_r;
	always @ (*) begin
		casex (ForwardA)
			2'b00 	:  A_r = RD1;
			2'b01 	:  A_r = WB_OUTPUT;
			2'b10 	:  A_r = ALU_result;
			default	:  A_r = 32'bx;
		endcase
	end

	//ALU input B
	reg		[31:0]	B_r; 
	always @ (*) begin
		casex (ForwardB)
			2'b00 	:  B_r = RD2;
			2'b01 	:  B_r = WB_OUTPUT;
			2'b10 	:  B_r = ALU_result;
			default	:  B_r = 32'bx;
		endcase
	end

	assign A = A_r;
	assign B = B_r;
	
endmodule