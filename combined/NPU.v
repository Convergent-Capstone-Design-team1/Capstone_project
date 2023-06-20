module npu
#(
    parameter data_size = 32        ,       // we use 32-bit data for processing
    parameter mem_size = 50         ,       // memory size extendable
    parameter mul_size = 3          ,       // matrix multiplication = (n x mul_size) * (mul_size x m)
    parameter mat_size = 9
)
(
    input           clk             ,
    input           rst             ,
    input           en              ,
    input   [31:0]  mem_addr        ,       // initial values
    input   [31:0]  mem_init        ,   
    input   [7:0]   src1_addr       ,       // to multiply matrixes, get starting point from CPU.
    input   [7:0]   src2_addr       ,
    input   [7:0]   rd_addr         ,
    input           double_matr     ,
    
    output          ack             ,

    // PORTs due to shared memory system
    input           clk_50          ,
    input           MEMRead         ,       // we get these calculated datas from CPU.
    input           MEMWrite        ,
    input   [31:0]  ADDR            ,
    input   [31:0]  WD              ,

    output  [31:0]  RD
);
    ////// Shared memory part below //////
    reg         [data_size-1:0] mem_cell [mem_size-1:0];
    wire        [9:0]           word_addr = ADDR [11:2];

    always @ (posedge clk_50 or posedge rst) begin
        if(MEMWrite) begin
            mem_cell[word_addr] <= WD;      // write if MEMWrite
        end
        else if (MEMRead) begin
            RD_r <= mem_cell[word_addr];    // or, read if MEMRead
        end
        else begin
            RD_r <= 32'hz;                  // neither, output is Z.
        end
    end

    reg [31:0]  RD_r;
    assign RD = RD_r;

    ////// NPU operation part below //////
    reg [5:0]              i = 6'b0;            // counting integers for operation
    reg [5:0]              j = 6'b0;
    reg [5:0]              k = 6'b0;
    reg                    ack;

    reg [data_size-1:0] a1 = 32'b0;             // input datas for calculation
    reg [data_size-1:0] a2 = 32'b0;
    reg [data_size-1:0] a3 = 32'b0;
    reg [data_size-1:0] b1 = 32'b0;
    reg [data_size-1:0] b2 = 32'b0;
    reg [data_size-1:0] b3 = 32'b0;

    wire [data_size-1:0] c1;                    // multiplication output
    wire [data_size-1:0] c2;
    wire [data_size-1:0] c3;
    wire [data_size-1:0] c4;
    wire [data_size-1:0] c5;
    wire [data_size-1:0] c6;
    wire [data_size-1:0] c7;
    wire [data_size-1:0] c8;
    wire [data_size-1:0] c9;

    reg [mul_size-1:0] en_ab;                   // whether enable MAC or not.
    reg [mem_size-1:0] ack_cnt;                 // when does calculation end?

    generate                                    // observe inside the NPU memory
        genvar  idx;
        for (idx = 0; idx < 50; idx = idx+1) begin: inside_npu
            wire [31:0] tmp;
            assign tmp = mem_cell[idx];
        end
    endgenerate

    always@(posedge clk or posedge rst) begin

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
        end

        en_ab[0] <= (en && (i < (mul_size))) ? 1'b1 : 1'b0;     // activate MAC 1
        en_ab[1] <= (en && (en_ab[0])) ? 1'b1 : 1'b0;           // activate MAC 2,4
        en_ab[2] <= (en && (en_ab[1])) ? 1'b1 : 1'b0;           // activate MAC 3,5,7

        if(en) begin
            if(en_ab[0]) begin
                a1 <= mem_cell[5'd0 * mul_size + (i-1) + src1_addr];    // approaching data with memory addr, counter
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

        if((ack_cnt == (mul_size-1))) begin             // calculation ended! update the memory
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
        .clk(clk)       , 
        .rst(!en)       , 
        .a1(a1)         , 
        .a2(a2)         , 
        .a3(a3)         , 
        .b1(b1)         , 
        .b2(b2)         , 
        .b3(b3)         , 
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