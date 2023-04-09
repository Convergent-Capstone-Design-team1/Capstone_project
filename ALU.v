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
	reg			[63:0] 	result_mult_r;

	always @ (A, B, ALU_control) 
	begin
		zero_r = 1'b0;
		result_r = 32'b0;
		result_mult_r = 64'b0;
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
			result_r = result_r;
			zero_r = (A < B) ? 0 : 1;
		end 
		else if (ALU_control == 3) begin    //ble
			result_r = result_r;
			zero_r = (A > B) ? 0 : 1;
		end
		else if (ALU_control == 5) begin	//beq
			result_r = result_r;
			zero_r = (A != B) ? 0 : 1;
		end
		else if (ALU_control == 1) begin	//mult
			result_mult_r = A * B;
			result_r = result_mult_r[31:0];
			zero_r = 0;
		end
		
	end

	assign zero = zero_r;
	assign result = result_r;

endmodule