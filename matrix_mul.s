
.main :
    addi sp, sp -12 
    sw s1, 8(sp)        # int i;
    sw s2, 4(sp)        # int j;
    sw s3, 0(sp)        # int k;
    addi s1, zero, 0    # i = 0;
    addi s2, zero, 0    # j = 0;
    addi s3, zero, 0    # k = 0;
    addi a0, zero, 0    # A[][] start address
    addi a1, zero, 36   # B[][] start address
    addi a2, zero, 72   # C[][] start address
.L1 :    
    addi a3, zero, 3    # int l = 3;
    bge s1, a3, IPP     # i >= 3 -> i++    
    addi t0, a2, 0      # copy C[][] to t0
    addi t1, s2, 0      # copy j to t1
.L2 : 
    addi a5, zero, 3    # int n = 3;
    bqe t1, a5, JPP     # j >= 3 -> j++
    addi t3, zero, 0    # t2 = 0
    add t0, s1, t1      # t0 = C[i][j] address
    lw t3, 0(to)        # t3 = C[i][j] data
    addi t3, zero, 0    #  = 0
    sw t3. 0(t0)        
.L3 :
    addi a4, zero, 3    # int m = 3;
    addi t2, s3, 0      # copy k to t2
    bge t2, a4, KPP     # k >= 3 -> k++
    /**********************************/
    /*                                */
    /*            matrix mul          */
    /*                                */
    /**********************************/  

.IPP :
    addi s1, s1, 4
    beq zero, zero, L1
.JPP :
    addi t1, t1, 4
    beq zero, zero, L2
.KPP :
    addi t2, t2, 4
    beq zero, zero, L3    


sw t3, 0(t0)        # C[i][j] += A[i][k] * B[k][j]