module ALU
(
	input    	[31:0] 	A			,
	input		[31:0] 	B			,
	input		[3:0]  	ALU_control	,
	output             	zero		,
	output		[31:0] 	result
);
 
	reg  		   		zero_r;
	reg			[31:0] 	result_r;

	always @ (A, B, ALU_control) 
	begin
		if (ALU_control == 2) begin			//add
			result_r = A + B;
			zero_r = 0;
		end 
		else if (ALU_control == 6) begin	//sub
			result_r = A - B;
			zero_r = 0;
		end 
		else if (ALU_control == 4) begin	//xor
			result_r = A ^ B;
			zero_r = 0;
		end 
		else if (ALU_control == 7) begin	//bge
			//result_r = 32'b0;
			zero_r = (A < B) ? 0 : 1;
		end 
		else if (ALU_control == 5) begin	//beq
			//result_r = 32'b0;
			zero_r = (A != B) ? 0 : 1;
		end
	end

	assign zero = zero_r;
	assign result = result_r;

endmodule