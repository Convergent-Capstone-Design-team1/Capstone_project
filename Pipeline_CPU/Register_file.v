// Register file 구현

module REGISTER_FILE
(
  input           clk_50    ,   //위상 반전된 clk 사용
  input           rst       , 
  input   [4:0]   reg_addr  ,   //Register file 초기화 하기 위한 address
  input   [31:0]  reg_init  ,   //Register file 초기화 하기 위한 init data

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
  
  /* (always) Read */
  assign RD1 = register_file[RR1];
  assign RD2 = register_file[RR2];


  /* Write */
  always @ (posedge clk_50 or posedge rst  ) begin
    if (rst)
      register_file[reg_addr] <= reg_init;
    else if (WE)
	    register_file[WR] <= WD;
  end

endmodule
