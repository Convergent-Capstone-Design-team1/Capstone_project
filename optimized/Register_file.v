module REGISTER_FILE
(
  input           clk   ,
  input           rst   ,   
  input   [4:0]   RR1   ,  //Read register1
  input   [4:0]   RR2   ,  //Read register2
  input   [4:0]   WR    ,   //write register
  input   [31:0]  WD    ,   //write data
  input 	        WE    ,   //RegWrite (by Control)
  
  output  [31:0]  RD1   ,  //to directly ALU
  output  [31:0]  RD2   //to MUX
);

  reg [31:0] 	register_file[0:31];
  assign RD1 = register_file[RR1];
  assign RD2 = register_file[RR2];

  reg[6:0] i = 7'b0;

  always @(posedge clk or posedge rst) begin
	  if (rst)
	  begin
	    for (i = 0; i < 32; i = i + 1)
	      register_file[i] = 0;
	  end
	  else if (WE)
	    register_file[WR] = WD;
  end

endmodule
