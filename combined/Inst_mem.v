module INST_MEM
(  
   input             clk_50   ,
   input    [31:0]   ADDR     ,
   output   [31:0]   INST
);
  
   //bge 3개, beq 3개
   reg    [31:0]   INST_r;
   always @ (posedge clk_50)
   begin
      INST_r = 32'b0;
      
      case(ADDR)
         0: INST_r = 32'h00000013;        //         addi x0, x0, 0
         4: INST_r = 32'h00000013;        //         addi x0, x0, 0
         8: INST_r = 32'h00000013;        //         addi x0, x0, 0
         12: INST_r = 32'h00000013;       //         addi x0, x0, 0
         16: INST_r = 32'h00000013;       //         addi x0, x0, 0
         20: INST_r = 32'hff810113;       //         addi sp, sp, -8   #save s4, s4 on stack *
         24: INST_r = 32'h01412223;       //         sw s4, 4(sp)      #int j *
         28: INST_r = 32'h01312023;       //         sw s3, 0(sp)      #int i *
         32: INST_r = 32'h00000993;       //         addi s3, zero, 4  #i = 0
         36: INST_r = 32'h00000a13;       //         addi s4, zero, 0  #j = 0
         40: INST_r = 32'h02000793;       //         addi a5, zero, 32     # A[][] start address
         44: INST_r = 32'h05000813;       //         addi a6, zero, 80    # B[][] start address
         48: INST_r = 32'h0A000893;       //         addi a7, zero, 164    # C[][] start address
         52: INST_r = 32'h00f818b3;       //         matr a7, a5, a6   # A X B = C
         56: INST_r = 32'h010897B3;       // double  matr a7, a5, a6   # A X B = C        
         60: INST_r = 32'h00000513;       //Loop 1:  addi a0, s1, 0   #download base addr of arry[] at a0 -> 0
         64: INST_r = 32'h02400613;       //         addi a2, s2, 40     #download size of arry[](=n) at a2 -> 10 * 4  //028  02c 190
         //68: INST_r = 32'h00F002B3;       //  case 1 add t0, zero, a5     #sorting MatA
         68: INST_r = 32'h011002B3;       //  case 2 add t0, zero, a7     #sorting MatC
         72: INST_r = 32'h04c9d863;       //         bge s3, a2, Exit   #j is bigger than n or equal
         76: INST_r = 32'h00000e33;       //         add t3, zero, zero #tmp reset
         80: INST_r = 32'hFFC60E13;       //         addi t3, a2, -4       <original : sub t3, a2, s3     #tmp resigter t3 = n-i>
         84: INST_r = 32'h000a0f13;       //         addi t5, s4, 0     #copy of j
         88: INST_r = 32'h03cf5863;       //Loop 2:  bge t5, t3, Exit1 #j is bigger than n-i or equal
         92: INST_r = 32'h0002a503;       //         lw a0, 0(t0)      #t1 = arr[j] data
         96: INST_r = 32'h0042a583;       //         lw a1, 4(t0)      #t2 = arr[j+1] data
         100: INST_r = 32'h00428293;       //         addi t0, t0, 4    #t0 = arr[j+1] address
         104: INST_r = 32'h02a5d463;      //         bge a1, a0, Exit2 #arry[j+1] data is bigger than arry[j] or equal
         108: INST_r = 32'h00050f93;      //         addi t6, a0, 0     #swap, t6 is tmp register
         112: INST_r = 32'h00058513;      //         addi a0, a1, 0
         116: INST_r = 32'h000f8593;      //         addi a1, t6, 0
         120: INST_r = 32'hfea2ae23;      //         sw a0, -4(t0)     #save memory
         124: INST_r = 32'h00b2a023;      //         sw a1, 0(t0)
         128: INST_r = 32'h004f0f13;      //         addi t5, t5, 4    #j++
         132: INST_r = 32'hfc000ae3;      //         beq zero, zero, Loop2
         136: INST_r = 32'h00498993;      //Exit1 :  addi s3, s3, 4           // i++
         140: INST_r = 32'hfa0008e3;      //         beq zero, zero, Loop1
         144: INST_r = 32'h004f0f13;      //Exit2:   addi t5, t5, 4           // j++
         148: INST_r = 32'hfc0002e3;      //         beq zero, zero, Loop2
         152: INST_r = 32'h00013983;      ///Exit :  lw s3, 0(sp)
         156: INST_r = 32'h00413a03;      //         lw s4, 4(sp)
         160: INST_r = 32'h00810113;      //         addi sp, sp, 8
         164: INST_r = 32'h00a54533;      //         xor a0, a0, a0
         default: INST_r = 32'h00000000;
      endcase

   /******************************************************************************************************/ 
   //                               matrix multiplication for CPU below
   /******************************************************************************************************/ 
   /*
      case(ADDR)
         0: INST_r = 32'h00000013;        //       addi x0, x0, 0
         4: INST_r = 32'h00000013;        //       addi x0, x0, 0
         8: INST_r = 32'h00000013;        //       addi x0, x0, 0
         12: INST_r = 32'h00000013;       //       addi x0, x0, 0
         16: INST_r = 32'h00000013;       //       addi x0, x0, 0
         20: INST_r = 32'hff410113;       //       addi sp, sp -12
         24: INST_r = 32'h00912423;       //       sw s1, 8(sp)         # int i;
         28: INST_r = 32'h01212223;       //       sw s2, 4(sp)         # int j;
         32: INST_r = 32'h01312023;       //       sw s3, 0(sp)         # int k;
         36: INST_r = 32'h00000493;       //       addi s1, zero, 0     # i = 0;
         40: INST_r = 32'h00000913;       //       addi s2, zero, 0     # j = 0;
         44: INST_r = 32'h00000993;       //       addi s3, zero, 0     # k = 0;
         48: INST_r = 32'h00000513;       //       addi a0, zero, 0     # A[][] start address
         52: INST_r = 32'h02400593;       //       addi a1, zero, 36    # B[][] start address
         56: INST_r = 32'h04800613;       //       addi a2, zero, 72    # C[][] start address
         60: INST_r = 32'h00300693;       //       addi a3, zero, 3     #  3;
         64: INST_r = 32'h00090713;       // L1:   addi a4, s2, 0       # copy j to a4
         68: INST_r = 32'h08d4d263;       //       bge s1, a3, Exit     # i >= 3 -> i++ 
         72: INST_r = 32'h00048293;       // L2:   addi t0, s1, 0       # copy i to t0
         76: INST_r = 32'h06d75263;       //       bge a4, a3, IPP      # j >= 3 -> j++
         80: INST_r = 32'h02d282b3;       //       mul t0, t0, a3       # i = 3*i,  here is MULT
         84: INST_r = 32'h00e28333;       //       add t1, t0, a4       # t1 = 3*i + j
         88: INST_r = 32'h00231313;       //       slli t1, t1, 2     	# word =* 4
         92: INST_r = 32'h00c30333;       //       add t1, t1, a2       # C[i][j]s addr
         96: INST_r = 32'h00032023;       //       sw zero, 0(t1)       # sotre 0 for init   
         100: INST_r = 32'h00098793;      //       addi a5, s3, 0       # copy k to a5 
         104: INST_r = 32'h04d7d863;      // L3:   bge a5, a3, JPP     	# k >= 3 -> k++
         108: INST_r = 32'h00f283b3;      //       add t2, t0, a5    	# t2 = 3*i + k
         112: INST_r = 32'h00239393;      //       slli t2, t2, 2       # word *= 4
         116: INST_r = 32'h00a383b3;      //       add t2, t2, a0    	# A[i][k]s addr 
         120: INST_r = 32'h0003aa83;      //       lw s5, 0(t2)      	# s5 = A[i][k]                   //stall
         124: INST_r = 32'h02f68e33;      //       mul t3, a3, a5    	# t3 = 3*k, here is MULT   00a383b3;      //       add t2, t2, a0    	# A[i][k]s addr
         128: INST_r = 32'h00ee0e33;      //       add t3, t3, a4    	# t3 = 3*k + j
         132: INST_r = 32'h002e1e13;      //       slli t3, t3, 2    	# word *= 4  
         136: INST_r = 32'h00be0e33;      //       add t3, t3, a1    	# B[k][j]s addr                   //stall
         140: INST_r = 32'h000e2b03;      //       lw s6, 0(t3)      	# s6 = B[k][j]
         144: INST_r = 32'h00e28eb3;      //       add t4, t0, a4    	# t4 = 3*i+j     
         148: INST_r = 32'h002e9e93;      //       slli t4, t4, 2    	# word *= 4
         152: INST_r = 32'h00ce8eb3;      //       add t4, t4, a2    	# C[i][j]s addr
         156: INST_r = 32'h036a8f33;      //       mul t5, s5, s6    	# mult two matrixes, here is MULT   
         160: INST_r = 32'h000eaf83;      //       lw t6, 0(t4)      	# get existing value there
         164: INST_r = 32'h01ff0f33;      //       add t5, t5, t6    	# and add calculated + existing
         168: INST_r = 32'h01eea023;      //       sw t5, 0(t4)      	# add values to array C
         172: INST_r = 32'h00000a63;      //       beq zero, zero, KPP  # k++
         176: INST_r = 32'h00148493;      // IPP:  addi s1, s1, 1
         180: INST_r = 32'hf80006e3;      //       beq zero, zero, L1
         184: INST_r = 32'h00170713;      // JPP:  addi a4, a4, 1
         188: INST_r = 32'hf80006e3;      //       beq zero, zero, L2
         192: INST_r = 32'h00178793;      // KPP:  addi a5, a5, 1
         196: INST_r = 32'hfa0002e3;      //       beq zero, zero, L3
         200: INST_r = 32'h01412823;      // Exit: sw s4, 16(sp)        #restore stacks
         204: INST_r = 32'h01212623;      //       sw s2, 12(sp)
         208: INST_r = 32'h01312423;      //       sw s3, 8(sp) 
         212: INST_r = 32'h01512223;      //       sw s5, 4(sp)   
         216: INST_r = 32'h01612023;      //       sw s6, 0(sp)    
         220: INST_r = 32'hfec10113;      //       addi sp, sp, -20
         224: INST_r = 32'h00a54533;      //       xor a0, a0, a0
         default: INST_r = 32'h00000000;
      endcase
   */

   end

   assign INST = INST_r;

   
endmodule