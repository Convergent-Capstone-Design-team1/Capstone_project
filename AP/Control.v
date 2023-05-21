module CONTROL
(
	input			CtrlSrc		,
	input	[6:0] 	opcode  	,

	output  [7:0] 	control 
);
	/***************************************************************************/
	/*opcode[7] = ALUSrc   ,   opcode[6] = MemtoReg  ,    opcode[5] = RegWrite,*/
	/*opcode[4] = MEMRead  ,   opcode[3] = MEMWrite  ,    opcode[2] = Branch,  */
	/*opcode[1:0] = ALUOp                                                      */ 
	/***************************************************************************/

	reg [7:0] control_r;
	always @ (opcode) 
	begin
		casex (opcode)
			7'b0110011 : control_r = 8'b00100010;	//R-type : add, sub, xor, mult, matr -> ALUSrc '0'
			7'b0010011 : control_r = 8'b10110011;	//I-type : addi -> ALUSrc '1'
			7'b0000011 : control_r = 8'b11110000;	//I-type : lw
			7'b0100011 : control_r = 8'b1x001000;	//S-type : sw			//8'b1x001000
			7'b1100011 : control_r = 8'b0x000101;	//SB-type : beg, bge	//8'b0x000101
			default    : control_r = 8'bxxxxxxxx;
		endcase
	end

	assign control = CtrlSrc ? 8'b0 : control_r;

endmodule