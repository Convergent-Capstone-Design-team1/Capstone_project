module Vr_data_mem
(
  input         CLK,
  input  [31:0] ADDR,
  input         RW, /* 0: Read, 1: Write //  MUX (from control_module)*/ 
  input  [31:0] WD,
  output [31:0] RD
);

  wire [9:0] 	 word_addr;
  reg [31:0] 	 mem_cell [0:1023];

  assign word_addr = ADDR[11:2];

  /*
    This block is for debugging purpose.
    Do not use initial block for initilization in your production code
  */
  
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

  /*
  initial
  begin  
    mem_cell[0] = 87;
    mem_cell[1] = 23;
    mem_cell[2] = 99;
    mem_cell[3] = 58;
    mem_cell[4] = 35;
    mem_cell[5] = 79;
    mem_cell[6] = 60;
    mem_cell[7] = 47;
    mem_cell[8] = 9;
    mem_cell[9] = 26;
    mem_cell[10] = 42;
    mem_cell[11] = 5;
    mem_cell[12] = 61;
    mem_cell[13] = 67;
    mem_cell[14] = 33;
    mem_cell[15] = 28;
    mem_cell[16] = 44;
    mem_cell[17] = 90;
    mem_cell[18] = 69;
    mem_cell[19] = 72;
    mem_cell[20] = 14;
    mem_cell[21] = 31;
    mem_cell[22] = 78;
    mem_cell[23] = 21;
    mem_cell[24] = 98;
    mem_cell[25] = 80;
    mem_cell[26] = 22;
    mem_cell[27] = 16;
    mem_cell[28] = 75;
    mem_cell[29] = 71;
    mem_cell[30] = 54;
    mem_cell[31] = 40;
    mem_cell[32] = 56;
    mem_cell[33] = 89;
    mem_cell[34] = 95;
    mem_cell[35] = 37;
    mem_cell[36] = 7;
    mem_cell[37] = 70;
    mem_cell[38] = 15;
    mem_cell[39] = 53;
    mem_cell[40] = 36;
    mem_cell[41] = 94;
    mem_cell[42] = 43;
    mem_cell[43] = 63;
    mem_cell[44] = 2;
    mem_cell[45] = 92;
    mem_cell[46] = 64;
    mem_cell[47] = 24;
    mem_cell[48] = 68;
    mem_cell[49] = 76;
    mem_cell[50] = 38;
    mem_cell[51] = 12;
    mem_cell[52] = 50;
    mem_cell[53] = 85;
    mem_cell[54] = 49;
    mem_cell[55] = 1;
    mem_cell[56] = 8;
    mem_cell[57] = 55;
    mem_cell[58] = 32;
    mem_cell[59] = 27;
    mem_cell[60] = 30;
    mem_cell[61] = 97;
    mem_cell[62] = 18;
    mem_cell[63] = 62;
    mem_cell[64] = 45;
    mem_cell[65] = 20;
    mem_cell[66] = 41;
    mem_cell[67] = 91;
    mem_cell[68] = 11;
    mem_cell[69] = 84;
    mem_cell[70] = 25;
    mem_cell[71] = 51;
    mem_cell[72] = 77;
    mem_cell[73] = 83;
    mem_cell[74] = 39;
    mem_cell[75] = 29;
    mem_cell[76] = 73;
    mem_cell[77] = 66;
    mem_cell[78] = 46;
    mem_cell[79] = 6;
    mem_cell[80] = 86;
    mem_cell[81] = 34;
    mem_cell[82] = 81;
    mem_cell[83] = 96;
    mem_cell[84] = 48;
    mem_cell[85] = 13;
    mem_cell[86] = 65;
    mem_cell[87] = 3;
    mem_cell[88] = 4;
    mem_cell[89] = 10;
    mem_cell[90] = 19;
    mem_cell[91] = 52;
    mem_cell[92] = 57;
    mem_cell[93] = 88;
    mem_cell[94] = 82;
    mem_cell[95] = 17;
    mem_cell[96] = 59;
    mem_cell[97] = 74;
    mem_cell[98] = 93;
    mem_cell[99] = 100;
  end
  */
  // Dumpvars does not dump array entries
  // To detour the limitation, assign each register entry to a temporal wire.
  generate
    genvar 		 idx;
    for (idx = 0; idx < 1024; idx = idx+1) begin: datamem
	    wire [31:0] tmp;
	    assign tmp = mem_cell[idx];
    end
  endgenerate

  /* write */
  always @ (posedge CLK)
  begin
	  if (ADDR <1024)
	    if (RW)
        mem_cell[$unsigned(word_addr)] = WD;
  end

  /* read */
  assign RD = RW ? 32'hz : mem_cell[$unsigned(word_addr)];

endmodule
