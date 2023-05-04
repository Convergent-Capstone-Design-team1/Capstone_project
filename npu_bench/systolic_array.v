`timescale 1ns / 100ps
module systolic_array(clk, rst, a1, a2, a3, b1, b2, b3, c1, c2, c3, c4, c5, c6, c7, c8, c9);

parameter data_size = 32;

input clk;
input rst;
input [data_size-1:0] a1;
input [data_size-1:0] a2;
input [data_size-1:0] a3;
input [data_size-1:0] b1;
input [data_size-1:0] b2;
input [data_size-1:0] b3;

output [data_size-1:0] c1;
output [data_size-1:0] c2;
output [data_size-1:0] c3;
output [data_size-1:0] c4;
output [data_size-1:0] c5;
output [data_size-1:0] c6;
output [data_size-1:0] c7;
output [data_size-1:0] c8;
output [data_size-1:0] c9;

wire [data_size-1:0] a12;
wire [data_size-1:0] a23;
wire [data_size-1:0] a45;
wire [data_size-1:0] a56;
wire [data_size-1:0] a78;
wire [data_size-1:0] a89;

wire [data_size-1:0] b14;
wire [data_size-1:0] b25;
wire [data_size-1:0] b36;
wire [data_size-1:0] b47;
wire [data_size-1:0] b58;
wire [data_size-1:0] b69;

mac dut_mac1 (.clk(clk), .rst(rst), .in_a(a1), .in_b(b1), .out_a(a12), .out_b(b14), .out_c(c1));
mac dut_mac2 (.clk(clk), .rst(rst), .in_a(a12), .in_b(b2), .out_a(a23), .out_b(b25), .out_c(c2));
mac dut_mac3 (.clk(clk), .rst(rst), .in_a(a23), .in_b(b3), .out_a(), .out_b(b36), .out_c(c3));
mac dut_mac4 (.clk(clk), .rst(rst), .in_a(a2), .in_b(b14), .out_a(a45), .out_b(b47), .out_c(c4));
mac dut_mac5 (.clk(clk), .rst(rst), .in_a(a45), .in_b(b25), .out_a(a56), .out_b(b58), .out_c(c5));
mac dut_mac6 (.clk(clk), .rst(rst), .in_a(a56), .in_b(b36), .out_a(), .out_b(b69), .out_c(c6));
mac dut_mac7 (.clk(clk), .rst(rst), .in_a(a3), .in_b(b47), .out_a(a78), .out_b(), .out_c(c7));
mac dut_mac8 (.clk(clk), .rst(rst), .in_a(a78), .in_b(b58), .out_a(a89), .out_b(), .out_c(c8));
mac dut_mac9 (.clk(clk), .rst(rst), .in_a(a89), .in_b(b69), .out_a(), .out_b(), .out_c(c9));

endmodule