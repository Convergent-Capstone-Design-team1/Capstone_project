`timescale 1ns / 100ps
module npu(clk, rst, en, in1, in2, ack);
parameter data_size = 32;
parameter mem_size = 24;
parameter mul_size = 3;

input clk;
input rst;
input en;
input [31:0] in1;
input [31:0] in2;
output ack;

reg [mem_size-1:0] row_data[data_size-1:0];     // for문으로 각 24개씩 32'b data를 초기화하며 넣어줌
reg [mem_size-1:0] col_data[data_size-1:0];
reg [5:0] i = 6'b0;


// this is temporary area - initial data is 1 to 9 for both memory.
initial begin
    for(i = 0; i < 6'd32; i = i + 1) begin
        row_data[i] = 0;
        col_data[i] = 0;
    end
    i = 6'b0;
    for(i = 0; i < 4'd9; i = i + 1) begin
        row_data[i] = i + 1;
        col_data[i] = i + 1;
    end
end
//

reg [data_size-1:0] a1 = 32'b0;
reg [data_size-1:0] a2 = 32'b0;
reg [data_size-1:0] a3 = 32'b0;
reg [data_size-1:0] b1 = 32'b0;
reg [data_size-1:0] b2 = 32'b0;
reg [data_size-1:0] b3 = 32'b0;

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

always@(posedge clk or posedge rst) begin
    if(!en) begin
        /*
        for(i = 0; i < 6'd32; i = i + 1) begin      // 초기값을 메모리에 써주는 부분. 지금은 initial씀.
            row_data[i] <= 0;
            col_data[i] <= 0;
        end
        */
        ack_cnt <= 0;
        i <= 6'd0;
    end
    else begin
        if(en_ab[0]) begin
            a1 <= row_data[5'd0 * mul_size + (i-1)];
            b1 <= col_data[(i-1) * mul_size + 5'd0];
        end
        else begin
            a1 <= 32'd0;
            b1 <= 32'd0;
        end
        if(en_ab[1]) begin
            a2 <= row_data[5'd1 * mul_size + (i-2)];
            b2 <= col_data[(i-2) * mul_size + 5'd1];
        end
        else begin
            a2 <= 32'd0;
            b2 <= 32'd0;
        end
        if(en_ab[2]) begin
            a3 <= row_data[5'd2 * mul_size + (i-3)];
            b3 <= col_data[(i-3) * mul_size + 5'd2];
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

    en_ab[0] <= ((i < (mul_size))) ? 1'b1 : 1'b0;
    en_ab[1] <= (!rst && (en_ab[0])) ? 1'b1 : 1'b0;
    en_ab[2] <= (!rst && (en_ab[1])) ? 1'b1 : 1'b0;

end

assign ack = (mul_size == ack_cnt) ? 1'b1 : 1'b0;

systolic_array dut1(
    .clk(clk), 
    .rst(rst), 
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
    .c9(c9));

endmodule