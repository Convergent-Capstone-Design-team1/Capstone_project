module DATA_MEM
(
  input           clk_50    ,
  input           rst       ,
  input           MEMRead   ,
  input           MEMWrite  ,  
  input   [31:0]  ADDR      ,
  input   [31:0]  WD        ,
  input           copying   ,
  input    [31:0]  in_data_0,
  input    [31:0]  in_data_1,
  input    [31:0]  in_data_2,
  input    [31:0]  in_data_3,
  input    [31:0]  in_data_4,
  input    [31:0]  in_data_5,
  input    [31:0]  in_data_6,
  input    [31:0]  in_data_7,
  input    [31:0]  in_data_8,
  input    [31:0]  in_data_9,
  input    [31:0]  in_data_10,
  input    [31:0]  in_data_11,
  input    [31:0]  in_data_12,
  input    [31:0]  in_data_13,
  input    [31:0]  in_data_14,
  input    [31:0]  in_data_15,
  input    [31:0]  in_data_16,
  input    [31:0]  in_data_17,
  input    [31:0]  in_data_18,
  input    [31:0]  in_data_19,
  input    [31:0]  in_data_20,
  input    [31:0]  in_data_21,
  input    [31:0]  in_data_22,
  input    [31:0]  in_data_23,
  input    [31:0]  in_data_24,
  input    [31:0]  in_data_25,
  input    [31:0]  in_data_26,

  output  [31:0]  RD        

);

  wire    [9:0]   word_addr;
  reg     [31:0]  mem_cell [0:1023];
  
  assign word_addr = ADDR [11:2];

  generate
    genvar  idx;
    for (idx = 0; idx < 1024; idx = idx+1) begin: datamem
	    wire [31:0] tmp;
	    assign tmp = mem_cell[idx];
    end
  endgenerate

  /* read */
  reg [31:0]  RD_r = 32'b0;
  always @ (posedge clk_50 or posedge rst)
  begin
    if (rst)
      RD_r <= 0;
    else if (MEMRead) 
      RD_r <= mem_cell[$unsigned(word_addr)];
    else
      RD_r <= 32'hz;
  end

  /* write */
  always @ (posedge clk_50)
  begin
	  if (MEMWrite) begin
      mem_cell[$unsigned(word_addr)] = WD;
    end
    else if(copying) begin
      mem_cell[0] <= in_data_0;
      mem_cell[1] <= in_data_1;
      mem_cell[2] <= in_data_2;
      mem_cell[3] <= in_data_3;
      mem_cell[4] <= in_data_4;
      mem_cell[5] <= in_data_5;
      mem_cell[6] <= in_data_6;
      mem_cell[7] <= in_data_7;
      mem_cell[8] <= in_data_8;
      mem_cell[9] <= in_data_9;
      mem_cell[10] <= in_data_10;
      mem_cell[11] <= in_data_11;
      mem_cell[12] <= in_data_12;
      mem_cell[13] <= in_data_13;
      mem_cell[14] <= in_data_14;
      mem_cell[15] <= in_data_15;
      mem_cell[16] <= in_data_16;
      mem_cell[17] <= in_data_17;
      mem_cell[18] <= in_data_18;
      mem_cell[19] <= in_data_19;
      mem_cell[20] <= in_data_20;
      mem_cell[21] <= in_data_21;
      mem_cell[22] <= in_data_22;
      mem_cell[23] <= in_data_23;
      mem_cell[24] <= in_data_24;
      mem_cell[25] <= in_data_25;
      mem_cell[26] <= in_data_26;
    end

    else begin
      RD_r = 32'b0;
    end
  end

  assign RD = RD_r;


endmodule
