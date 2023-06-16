module DATA_MEM
(
  input           clk_50    ,             // reference clk에 위상이 반전된 clock을 사용 -> setup time violation 문제 해결하기 위함
  input           rst       ,
  input           MEMRead   ,
  input           MEMWrite  ,  
  input   [31:0]  ADDR      ,
  input   [31:0]  WD        ,             // Write Data

  output  [31:0]  RD                      // Read Data

);

  /**********************************************************/
  generate
    genvar  idx;
    for (idx = 0; idx < 1024; idx = idx+1) begin: datamem
	    wire [31:0] tmp;
	    assign tmp = mem_cell[idx];
    end
  endgenerate
  /**********************************************************/


  wire    [9:0]   word_addr;              // mem_cell은 1024 (2^10)의 word를 가지므로 32bit의 pc값 중에서 10bit를 사용
  reg     [31:0]  mem_cell [0:1023];

  assign word_addr = ADDR [11:2];         // 32bit 명령어 체계를 가지므로 pc는 4byte씩 증가 -> 하위 2bit는 항상 00이기 때문에 [11:2]의 bit 사용

/*
  // matrix multiplication test data
  initial
  begin
    // Put your initial data 
    mem_cell[0] = 9;
    mem_cell[1] = 8;
    mem_cell[2] = 7;
    mem_cell[3] = 6;
    mem_cell[4] = 5;
    mem_cell[5] = 4;
    mem_cell[6] = 3;
    mem_cell[7] = 2;
    mem_cell[8] = 1;
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
 */ 
  
  // Bubble sort test data
  initial
  begin
    mem_cell[0] = 9;
    mem_cell[1] = 5;
    mem_cell[2] = 4;
    mem_cell[3] = 2;
    mem_cell[4] = 8;
    mem_cell[5] = 7;
    mem_cell[6] = 10;
    mem_cell[7] = 6;
    mem_cell[8] = 3;
    mem_cell[9] = 1;
  end
  
  /* write */
  always @ (posedge clk_50)
  begin
	  if (MEMWrite)
      mem_cell[word_addr] <= WD;
  end

  /* read */
  reg [31:0]  RD_r;
  always @ (posedge clk_50 or posedge rst)
  begin
    if (rst)
      RD_r <= 0;
    else if (MEMRead) 
      RD_r <= mem_cell[word_addr];
    else
      RD_r <= 32'hz;
  end

  assign RD = RD_r;

endmodule
