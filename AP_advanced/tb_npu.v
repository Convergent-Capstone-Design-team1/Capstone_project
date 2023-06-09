`timescale 1ns / 100ps
module tb_npu();

parameter data_size = 32;

reg clk = 1;
reg rst = 1;
reg en = 0;
reg [data_size-1:0] a1;
reg [data_size-1:0] a2;
reg [data_size-1:0] a3;
reg [data_size-1:0] b1;
reg [data_size-1:0] b2;
reg [data_size-1:0] b3;
wire ack;

npu DUT_npu(.clk(clk), .rst(rst), .en(en), .in1(), .in2(), .ack(ack));
initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb_npu);
    clk = 32'd1;
    #5;
    en = 1'd1;
    rst = 1'd0;
    #115;
    $finish;
end

    always #5 clk = ~clk;
    
endmodule