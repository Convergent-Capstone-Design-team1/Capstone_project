module INST_MEM
(
   input             clk_50   ,
   input             rst      ,
   input    [31:0]   ADDR     ,
   output   [31:0]   INST
);
  
   //bge 3개, beq 3개
   reg    [31:0]   INST_r;
   always @ (posedge clk_50)
   begin
      if (rst) begin
         INST_r <= 1'b0;
      end
      else begin
         case(ADDR)
         0: INST_r = 32'h00000013;        //        addi x0, x0, 0
         4: INST_r = 32'h00000013;        //          addi x0, x0, 0
         8: INST_r = 32'h00000013;        //        addi x0, x0, 0
         12: INST_r = 32'h00000013;       //          addi x0, x0, 0
         16: INST_r = 32'h00000013;       //        addi x0, x0, 0
         20: INST_r = 32'hff810113;       //         addi sp, sp, -8   #save s4, s4 on stack *
         24: INST_r = 32'h01412223;       //         sw s4, 4(sp)      #int j *
         28: INST_r = 32'h01312023;       //         sw s3, 0(sp)      #int i *
         32: INST_r = 32'h00400993;       //         addi s3, zero, 4  #i = 1
         36: INST_r = 32'h00000a13;       //         addi s4, zero, 0  #j = 0
         40: INST_r = 32'h00000513;       //Loop 1:  addi a0, s1, 0   #download base addr of arry[] at a0 -> 0
         44: INST_r = 32'h02800613;       //         addi a2, s2, 40     #download size of arry[](=n) at a2 -> 10 * 4  //028  02c 190
         48: INST_r = 32'h00050293;       //         addi t0, a0, 0     #copy of a0
         52: INST_r = 32'h04c9d863;       //         bge s3, a2, Exit   #j is bigger than n or equal
         56: INST_r = 32'h00000e33;       //         add t3, zero, zero #tmp reset
         60: INST_r = 32'h41360e33;       //         sub t3, a2, s3     #tmp resigter t3 = n-i
         64: INST_r = 32'h000a0f13;       //         addi t5, s4, 0     #copy of j
         68: INST_r = 32'h03cf5863;       //Loop 2: bge t5, t3, Exit1 #j is bigger than n-i or equal
         72: INST_r = 32'h0002a503;       //         lw a0, 0(t0)      #t1 = arr[j] data
         76: INST_r = 32'h0042a583;       //         lw a1, 4(t0)      #t2 = arr[j+1] data
         80: INST_r = 32'h00428293;       //         addi t0, t0, 4    #t0 = arr[j+1] address
         84: INST_r = 32'h02a5d463;       //         bge a1, a0, Exit2 #arry[j+1] data is bigger than arry[j] or equal
         88: INST_r = 32'h00050f93;       //         addi t6, a0, 0     #swap, t6 is tmp register
         92: INST_r = 32'h00058513;       //         addi a0, a1, 0
         96: INST_r = 32'h000f8593;       //         addi a1, t6, 0
         100: INST_r = 32'hfea2ae23;      //         sw a0, -4(t0)     #save memory
         104: INST_r = 32'h00b2a023;      //         sw a1, 0(t0)
         108: INST_r = 32'h004f0f13;      //         addi t5, t5, 4    #j++
         112: INST_r = 32'hfc000ae3;      //         beq zero, zero, Loop2
         116: INST_r = 32'h00498993;      //Exit1 : addi s3, s3, 4           // i++
         120: INST_r = 32'hfa0008e3;      //         beq zero, zero, Loop1
         124: INST_r = 32'h004f0f13;      //Exit2:  addi t5, t5, 4           // j++
         128: INST_r = 32'hfc0002e3;      //         beq zero, zero, Loop2
         132: INST_r = 32'h00013983;      ///Exit : lw s3, 0(sp)
         136: INST_r = 32'h00413a03;      //         lw s4, 4(sp)
         140: INST_r = 32'h00810113;      //         addi sp, sp, 8
         144: INST_r = 32'h00a54533;      //        xor a0, a0, a0
         default: INST_r = 32'h00000000;
      endcase
         /*
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
      */
      end
   end

   assign INST = INST_r;

   
endmodule