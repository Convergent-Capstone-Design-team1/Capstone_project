module REGISTER_FILE
(
  input           clk_50    , 
  input           rst       , 
  input   [4:0]   reg_addr  ,
  input   [31:0]  reg_init  ,

  input   [4:0]   RR1       ,   //Read register1
  input   [4:0]   RR2       ,   //Read register2
  input   [4:0]   WR        ,   //write register
  input   [31:0]  WD        ,   //write data
  input 	        WE        ,   //RegWrite (by Control)
  
  output  [31:0]  RD1       ,   //to directly ALU
  output  [31:0]  RD2           //to MUX
);

/*******************************************************/
  generate
    genvar 		 idx;
    for(idx = 0; idx < 32; idx = idx+1) begin: register
	    wire [31:0] tmp;
	    assign tmp = register_file[idx];
    end
  endgenerate
/*******************************************************/

  reg [31:0] 	register_file[0:31];
  assign RD1 = register_file[RR1];
  assign RD2 = register_file[RR2];

  always @ (posedge clk_50 or posedge rst  ) begin
    if (rst  )
      register_file[reg_addr] <= reg_init;
    else if (WE)
	    register_file[WR] <= WD;
  end

endmodule
