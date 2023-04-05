module REGISTER_FILE
(
  input           clk   ,
  input           rst   ,   
  input   [4:0]   RR1   ,   //Read register1
  input   [4:0]   RR2   ,   //Read register2
  input   [4:0]   WR    ,   //write register
  input   [31:0]  WD    ,   //write data
  input 	        WE    ,   //RegWrite (by Control)
  
  output  [31:0]  RD1   ,   //to directly ALU
  output  [31:0]  RD2       //to MUX
);

  reg [31:0] 	register_file[0:31];
  assign RD1 = register_file[RR1];
  assign RD2 = register_file[RR2];
  integer i;

  generate
    genvar  idx;
    for(idx = 0; idx < 32; idx = idx+1) begin: register
	    wire [31:0] tmp;
	    assign tmp = register_file[idx];
    end
  endgenerate

  always @(posedge clk) begin
	  if (rst)
	  begin
	    for (i = 0; i < 32; i = i + 1)
	      register_file[i] = i;
	  end
	  else if (WE)
	    register_file[WR] = WD;
  end
  
endmodule
