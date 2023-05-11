`timescale 1ns / 100ps
module tb_NPU;

    parameter data_size = 32;

    reg                 clk;
    reg                 rst;
    reg                 en;
    reg [data_size-1:0] a1;
    reg [data_size-1:0] a2;
    reg [data_size-1:0] a3;
    reg [data_size-1:0] b1;
    reg [data_size-1:0] b2;
    reg [data_size-1:0] b3;
    wire                ack;

    always #2.5 clk = ~clk;

    NPU NPU
    (   
        //INPUT
        .clk(clk)           , 
        .rst(rst)           , 
        .en(en)             , 
        .in1()              , 
        .in2()              , 

        //OUTPUT
        .ack(ack)
    );

    initial 
    begin
        $dumpfile("test.vcd");
        $dumpvars(0, tb_NPU);
        
        rst = 1'b1;
        en = 1'b0;
        clk = 1'd1;
        #5;
        en = 1'd1;
        rst = 1'd0;

        #50;
        $finish;
    end

endmodule