module PC_CONTROLLER
(	
	input			PCSrc   ,
	input	[31:0] 	t_addr  ,		//target PC
	input	[31:0] 	pc      , 		//from cpu 
	output	[31:0] 	n_pc  
);
	wire	[31:0]	n_addr = pc + 32'd4;
	
	assign	n_pc = PCSrc ? t_addr : n_addr;
	
endmodule
