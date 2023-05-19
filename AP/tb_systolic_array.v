`timescale 1ns / 100ps
module tb_systolic_array();

parameter data_size = 32;

reg clk;
reg rst;
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

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb_systolic_array);
    clk = 32'd1;
    rst = 32'd1;
    a1 = 32'd0; // all input values are 0 at initial.
    a2 = 32'd0;
    a3 = 32'd0;
    b1 = 32'd0;
    b2 = 32'd0;
    b3 = 32'd0;
    #5;  rst = 0;
    #5;  a1 = 32'd1; a2 = 32'd0; a3 = 32'd0; b1 = 32'd1; b2 = 32'd0; b3 = 32'd0;
    #10; a1 = 32'd2; a2 = 32'd4; a3 = 32'd0; b1 = 32'd4; b2 = 32'd2; b3 = 32'd0;
    #10; a1 = 32'd3; a2 = 32'd5; a3 = 32'd7; b1 = 32'd7; b2 = 32'd5; b3 = 32'd3;
    #10; a1 = 32'd0; a2 = 32'd6; a3 = 32'd8; b1 = 32'd0; b2 = 32'd8; b3 = 32'd6;
    #10; a1 = 32'd0; a2 = 32'd0; a3 = 32'd9; b1 = 32'd0; b2 = 32'd0; b3 = 32'd9;
    #10; a1 = 32'd0; a2 = 32'd0; a3 = 32'd0; b1 = 32'd0; b2 = 32'd0; b3 = 32'd0;
    #50;
    $finish;
end

    always #5 clk = ~clk;
    
endmodule