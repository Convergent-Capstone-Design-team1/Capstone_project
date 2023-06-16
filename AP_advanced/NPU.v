module npu
#(
    parameter data_size = 32        ,
    parameter mem_size = 28         ,       // memory size extendable
    parameter mul_size = 3          ,
    parameter mat_size = 9
)
(
    input           clk             ,
    input           rst             ,
    input           en              ,
    input   [31:0]  mem_addr        ,
    input   [31:0]  mem_init        ,
    input   [7:0]   src1_addr       ,
    input   [7:0]   src2_addr       ,
    input   [7:0]   rd_addr         ,
    input           double_matr     ,
    
    output          ack             ,

    // PORTs due to shared memory system
    input           clk_50          ,
    input           MEMRead         ,
    input           MEMWrite        ,
    input   [31:0]  ADDR            ,
    input   [31:0]  WD              ,

    output  [31:0]  RD
);  
    ////// Shared memory part below //////
    reg         [data_size-1:0] mem_cell [mem_size-1:0];
    wire        [9:0]           word_addr = ADDR [11:2];

    generate
        genvar  idx;
        for (idx = 0; idx < 27; idx = idx+1) begin: inside_npu
            wire [31:0] tmp;
            assign tmp = mem_cell[idx];
        end
    endgenerate

    /* write */
    always @ (posedge clk_50) begin
        if(MEMWrite) begin
            mem_cell[word_addr] <= WD;
        end
        else if(rst) begin
            mem_cell[mem_addr-1] <= mem_init;
        end
    end

    /* read */
    reg [31:0]  RD_r;
    always @ (posedge clk_50 or posedge rst) begin
        if (rst) begin
            RD_r <= 0;
        end
        else if (MEMRead) begin
            RD_r <= mem_cell[word_addr];
        end
        else begin
            RD_r <= 32'hz;
        end
    end

    assign RD = RD_r;

    ////// NPU operation part below //////
    reg [5:0]              i;
    reg [5:0]              j;
    reg [5:0]              k;
    reg                    ack;

    reg [data_size-1:0] a1;
    reg [data_size-1:0] a2;
    reg [data_size-1:0] a3;
    reg [data_size-1:0] b1;
    reg [data_size-1:0] b2;
    reg [data_size-1:0] b3;

    wire [data_size-1:0] c1;
    wire [data_size-1:0] c2;
    wire [data_size-1:0] c3;
    wire [data_size-1:0] c4;
    wire [data_size-1:0] c5;
    wire [data_size-1:0] c6;
    wire [data_size-1:0] c7;
    wire [data_size-1:0] c8;
    wire [data_size-1:0] c9;

    reg [mul_size-1:0] en_ab;
    reg [mem_size-1:0] ack_cnt;

    always@(posedge clk or posedge rst) 
    begin
        en_ab[0] <= (en && (i < (mul_size))) ? 1'b1 : 1'b0;
        en_ab[1] <= (en && (en_ab[0])) ? 1'b1 : 1'b0;
        en_ab[2] <= (en && (en_ab[1])) ? 1'b1 : 1'b0;

        if(rst) begin
            mem_cell[mem_addr-1] <= mem_init;
            RD_r <= 0;
            a1 <= 32'b0;
            a2 <= 32'b0;
            a3 <= 32'b0;
            b1 <= 32'b0;
            b2 <= 32'b0;
            b3 <= 32'b0;
            i  <= 6'b0;
            j  <= 6'b0;
            k  <= 6'b0;
        end
        else if(en) begin
            if(en_ab[0]) begin
                a1 <= mem_cell[5'd0 * mul_size + (i-1) + src1_addr];
                b1 <= mem_cell[(i-1) * mul_size + 5'd0 + src2_addr];
            end
            else begin
                a1 <= 32'd0;
                b1 <= 32'd0;
            end
            if(en_ab[1]) begin
                a2 <= mem_cell[5'd1 * mul_size + (i-2) + src1_addr];
                b2 <= mem_cell[(i-2) * mul_size + 5'd1 + src2_addr];
            end
            else begin
                a2 <= 32'd0;
                b2 <= 32'd0;
            end
            if(en_ab[2]) begin
                a3 <= mem_cell[5'd2 * mul_size + (i-3) + src1_addr];
                b3 <= mem_cell[(i-3) * mul_size + 5'd2 + src2_addr];
            end
            else begin
                a3 <= 32'd0;
                b3 <= 32'd0;
            end
            if(c9) begin
                ack_cnt <= ack_cnt + 1'b1;
            end
            i <= i + 1'b1;
        end
        else begin
            ack_cnt <= 0;
            i <= 6'd0;
        end

    end

    always@(posedge clk or posedge rst) 
    begin
        if((ack_cnt == (mul_size-1))) begin
            mem_cell[rd_addr + 0] <= c1;
            mem_cell[rd_addr + 1] <= c2;
            mem_cell[rd_addr + 2] <= c3;
            mem_cell[rd_addr + 3] <= c4;
            mem_cell[rd_addr + 4] <= c5;
            mem_cell[rd_addr + 5] <= c6;
            mem_cell[rd_addr + 6] <= c7;
            mem_cell[rd_addr + 7] <= c8;
            mem_cell[rd_addr + 8] <= c9;
            ack <= 1'b1;
        end
        else begin
            ack <= 0;
        end
    end

    SYSTOLIC_ARRAY dut1
    (   
        //INPUT
        .clk(clk)       , 
        .rst(!en)       , 
        .a1(a1)         , 
        .a2(a2)         , 
        .a3(a3)         , 
        .b1(b1)         , 
        .b2(b2)         , 
        .b3(b3)         , 

        //OUTPUT
        .c1(c1)         , 
        .c2(c2)         , 
        .c3(c3)         , 
        .c4(c4)         ,       
        .c5(c5)         , 
        .c6(c6)         , 
        .c7(c7)         , 
        .c8(c8)         , 
        .c9(c9)
    );

endmodule