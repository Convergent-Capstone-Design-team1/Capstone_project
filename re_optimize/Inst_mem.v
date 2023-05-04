module INST_MEM
(
   input             clk_50   ,
   input             rst      ,
   input    [31:0]   ADDR     ,
   output   [31:0]   INST
);
  
   //bge 3개, beq 3개
   reg    [31:0]   INST_r = 32'b0;
   always @ (posedge clk_50)
   begin
      if (rst) begin
         INST_r <= 1'b0;
      end
      else begin
         case(ADDR)
         0: INST_r = 32'h00000013;                             // addi x0, x0, 0
         4: INST_r = 32'h00000013;                             // addi x0, x0, 0
         8: INST_r = 32'h00000013;                             // addi x0, x0, 0
         12: INST_r = 32'h00000013;                            // addi x0, x0, 0
         16: INST_r = 32'h00000013;                            // addi x0, x0, 0
         20: INST_r = 32'hfec10113;
         24: INST_r = 32'h01412823;
         28: INST_r = 32'h01212623;
         32: INST_r = 32'h01312423;
         36: INST_r = 32'h01512223;
         40: INST_r = 32'h01612023;
         44: INST_r = 32'h00000a13;
         48: INST_r = 32'h00000913;
         52: INST_r = 32'h00000993;
         56: INST_r = 32'h00000513;
         60: INST_r = 32'h02450593;
         64: INST_r = 32'h04850613;
         68: INST_r = 32'h00300693;                            // L1
         72: INST_r = 32'h000a0293;                            // L2
         76: INST_r = 32'b00000010110100101000001010110011;    // MULT
         80: INST_r = 32'h01228333;
         84: INST_r = 32'h00231313;
         88: INST_r = 32'h00c30333;
         92: INST_r = 32'h00032023;
         96: INST_r = 32'h013283b3;                            // L3
         100: INST_r = 32'h00239393;
         104: INST_r = 32'h00a383b3;
         108: INST_r = 32'b00000000000000111010101010000011;   // LW
         112: INST_r = 32'b00000011001101101000111000110011;   // MULT
         116: INST_r = 32'h01c90e33;
         120: INST_r = 32'h002e1e13;
         124: INST_r = 32'h00be0e33;
         128: INST_r = 32'b00000000000011100010101100000011;   // LW
         132: INST_r = 32'h01228eb3;
         136: INST_r = 32'h002e9e93;
         140: INST_r = 32'h00ce8eb3;
         144: INST_r = 32'b00000011011010101000111100110011;   // MULT
         148: INST_r = 32'b00000000000011101010111110000011;   // LW
         152: INST_r = 32'h01ff0f33;
         156: INST_r = 32'h01eea023;
         160: INST_r = 32'b00000010000000000000001001100011;   // beq zero zero KPP, imm is 18
         164: INST_r = 32'h00000913;                           // IPP
         168: INST_r = 32'h001a0a13;
         172: INST_r = 32'b00000010110110100101001001100011;   // bge s4 a3 Exit, imm is 18
         176: INST_r = 32'b11111000000000000000101011100011;   // beq zero zero L1, imm is -54
         180: INST_r = 32'h00000993;                           // JPP
         184: INST_r = 32'h00190913;
         188: INST_r = 32'b11111110110110010101010011100011;   // bge s2 a3 IPP, imm is -12
         192: INST_r = 32'b11111000000000000000010011100011;   // beq zero zero L2, imm is -60
         196: INST_r = 32'h00198993;                           // KPP
         200: INST_r = 32'b11111110110110011101011011100011;   // bge s3, a3, JPP, imm is -10
         204: INST_r = 32'b11111000000000000000101011100011;   // beq zero, zero, L3, imm is -54
         208: INST_r = 32'h01412823;                           // Exit
         212: INST_r = 32'h01212623;
         216: INST_r = 32'h01312423;
         220: INST_r = 32'h01512223;
         224: INST_r = 32'h01612023;
         228: INST_r = 32'hfec10113;
         232: INST_r = 32'h00a54533;                           // xor a0, a0, a0
         default: INST_r = 32'h00000000;
      endcase
      end
   end

   assign INST = INST_r;

   
endmodule