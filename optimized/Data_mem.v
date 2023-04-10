module DATA_MEM
(
  input           clk_50    ,
  input           rst       ,
  input           MEMRead   ,
  input           MEMWrite  ,  
  input   [31:0]  ADDR      ,
  input   [31:0]  WD        ,

  output  [31:0]  RD        

);

  wire    [9:0]   word_addr;
  reg     [31:0]  mem_cell [0:1023];

  assign word_addr = ADDR [11:2];

  initial
  begin
    // Put your initial data 
    mem_cell[0] = 1;
    mem_cell[1] = 2;
    mem_cell[2] = 3;
    mem_cell[3] = 4;
    mem_cell[4] = 5;
    mem_cell[5] = 6;
    mem_cell[6] = 7;
    mem_cell[7] = 8;
    mem_cell[8] = 9;
    mem_cell[9] = 1;
    mem_cell[10] = 2;
    mem_cell[11] = 3;
    mem_cell[12] = 4;
    mem_cell[13] = 5;
    mem_cell[14] = 6;
    mem_cell[15] = 7;
    mem_cell[16] = 8;
    mem_cell[17] = 9;
    mem_cell[18] = 0;
    mem_cell[19] = 0;
    mem_cell[20] = 0;
    mem_cell[21] = 0;
    mem_cell[22] = 0;
    mem_cell[23] = 0;
    mem_cell[24] = 0;
    mem_cell[25] = 0;
    mem_cell[26] = 0;    
  end

  /* read */
  reg [31:0]  RD_r = 32'b0;
  always @ (posedge clk_50 or posedge rst)
  begin
    if (rst) begin
      RD_r <= 0;
    end
    else if (MEMWrite) begin
      mem_cell[$unsigned(word_addr)] = WD;
    end
    else if (MEMRead) begin
      RD_r <= mem_cell[$unsigned(word_addr)];
    end
    else begin
      RD_r <= 32'hz;
    end
  end

  assign RD = RD_r;


endmodule
