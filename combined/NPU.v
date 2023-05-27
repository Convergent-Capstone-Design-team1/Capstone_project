module npu
#(
    parameter data_size = 32        ,
    parameter mem_size = 28         ,
    parameter mul_size = 3          ,
    parameter mat_size = 9
)
(
    input           clk             ,
    input           rst             ,
    input           en              ,
    input           get_wr          ,
    input   [31:0]  get_data        ,
    input   [31:0]  get_addr        ,
    input   [31:0]  mem_addr        ,
    input   [31:0]  mem_init        ,

    output          pass_we         ,
    output          ack             ,
    output  [31:0]  modified_addr   ,
    output  [31:0]  modified_data
);

reg [(mem_size*2)-1:0] npu_mem[data_size-1:0];     // for문으로 각 24개씩 32'b data를 초기화하며 넣어줌
reg [5:0]              i = 6'b0;
reg [5:0]              j = 6'b0;
reg [5:0]              k = 6'b0;
reg                    flag = 0;
reg [31:0]             modified_addr = 0;
reg [31:0]             modified_data = 0;

reg [data_size-1:0] a1 = 32'b0;
reg [data_size-1:0] a2 = 32'b0;
reg [data_size-1:0] a3 = 32'b0;
reg [data_size-1:0] b1 = 32'b0;
reg [data_size-1:0] b2 = 32'b0;
reg [data_size-1:0] b3 = 32'b0;

reg [data_size-1:0] matA = 32'b0;
reg [data_size-1:0] matB = 32'b0;
reg [data_size-1:0] matC = 32'b0;

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

generate
    genvar  idx;
    for (idx = 0; idx < 27; idx = idx+1) begin: inside_npu
	    wire [31:0] tmp;
	    assign tmp = npu_mem[idx];
    end
endgenerate

always@(posedge rst) begin
    a1 <= 32'b0;
    a2 <= 32'b0;
    a3 <= 32'b0;
    b1 <= 32'b0;
    b2 <= 32'b0;
    b3 <= 32'b0;
    i  <= 6'b0;
end

always@(posedge clk) begin

    if(rst) begin
        npu_mem[mem_addr-1] <= mem_init;
    end

    en_ab[0] <= (en && (i < (mul_size + 3)) && (3 <= i)) ? 1'b1 : 1'b0;
    en_ab[1] <= (en && (en_ab[0])) ? 1'b1 : 1'b0;
    en_ab[2] <= (en && (en_ab[1])) ? 1'b1 : 1'b0;
    //en_ab[mul_size-1:1] <= (en && (en_ab[mul_size-2:0])) ? 1'b1 : 1'b0;

    if(!en && get_wr && (get_addr >= 0)) begin
        npu_mem[mem_addr] <= get_data;
    end

    if(en) begin

        if(i==0) begin
            matA <= (get_data / 4);
        end
        else if(i==1) begin
            matB <= (get_data / 4);
        end
        else if(i==2) begin
            matC <= (get_data / 4);
        end

        if(en_ab[0]) begin
            a1 <= npu_mem[5'd0 * mul_size + (i-4) + matA];
            b1 <= npu_mem[(i-4) * mul_size + 5'd0 + matB];
        end
        else begin
            a1 <= 32'd0;
            b1 <= 32'd0;
        end
        if(en_ab[1]) begin
            a2 <= npu_mem[5'd1 * mul_size + (i-5) + matA];
            b2 <= npu_mem[(i-5) * mul_size + 5'd1 + matB];
        end
        else begin
            a2 <= 32'd0;
            b2 <= 32'd0;
        end
        if(en_ab[2]) begin
            a3 <= npu_mem[5'd2 * mul_size + (i-6) + matA];
            b3 <= npu_mem[(i-6) * mul_size + 5'd2 + matB];
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
    if(ack) begin
        for(j = 0; j < mat_size; j = j + 1) begin
            npu_mem[mat_size*2 + j] <= 0;
        end
    end
    else begin
        npu_mem[mat_size*2 + 0] <= c1;
        npu_mem[mat_size*2 + 1] <= c2;
        npu_mem[mat_size*2 + 2] <= c3;
        npu_mem[mat_size*2 + 3] <= c4;
        npu_mem[mat_size*2 + 4] <= c5;
        npu_mem[mat_size*2 + 5] <= c6;
        npu_mem[mat_size*2 + 6] <= c7;
        npu_mem[mat_size*2 + 7] <= c8;
        npu_mem[mat_size*2 + 8] <= c9;
    end
    if(!flag && (mul_size == ack_cnt)) begin
        flag <= 1;
    end
    else if(flag && (k < mat_size)) begin
        modified_addr <= (matC + k) * 4;
        modified_data <= npu_mem[mat_size*2 + k];
        k <= k + 1;
    end
    else begin
        k <= 0;
        flag <= 0;
        modified_addr <= 0;
        modified_data <= 0;
    end
end

wire ack;
assign ack = (k == mat_size) ? 1'b1 : 1'b0;
assign pass_we = k && flag;

SYSTOLIC_ARRAY dut1
(
    .clk(clk), 
    .rst(!en), 
    .a1(a1), 
    .a2(a2), 
    .a3(a3), 
    .b1(b1), 
    .b2(b2), 
    .b3(b3), 
    .c1(c1), 
    .c2(c2), 
    .c3(c3), 
    .c4(c4), 
    .c5(c5), 
    .c6(c6), 
    .c7(c7), 
    .c8(c8), 
    .c9(c9)
);

endmodule