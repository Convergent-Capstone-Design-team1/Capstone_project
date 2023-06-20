`timescale 1ns / 100ps
module SYSTOLIC_ARRAY
#(
    parameter data_size = 32
)
(
    input                   clk     ,
    input                   rst     ,
    input   [data_size-1:0] a1      ,
    input   [data_size-1:0] a2      ,
    input   [data_size-1:0] a3      ,
    input   [data_size-1:0] b1      ,
    input   [data_size-1:0] b2      ,
    input   [data_size-1:0] b3      ,

    output  [data_size-1:0] c1      ,
    output  [data_size-1:0] c2      ,
    output  [data_size-1:0] c3      ,
    output  [data_size-1:0] c4      ,
    output  [data_size-1:0] c5      ,
    output  [data_size-1:0] c6      ,
    output  [data_size-1:0] c7      ,
    output  [data_size-1:0] c8      ,
    output  [data_size-1:0] c9
);

    wire    [data_size-1:0] a12;
    wire    [data_size-1:0] a23;
    wire    [data_size-1:0] a45;
    wire    [data_size-1:0] a56;
    wire    [data_size-1:0] a78;
    wire    [data_size-1:0] a89;

    wire    [data_size-1:0] b14;
    wire    [data_size-1:0] b25;
    wire    [data_size-1:0] b36;
    wire    [data_size-1:0] b47;
    wire    [data_size-1:0] b58;
    wire    [data_size-1:0] b69;

    /* connect MACs with wires, place
        1   2   3
        4   5   6
        7   8   9
    */

    MAC MAC1
    (
        //INPUT
        .clk(clk)           , 
        .rst(rst)           , 
        .in_a(a1)           , 
        .in_b(b1)           , 

        //OUTPUT
        .out_a(a12)         , 
        .out_b(b14)         , 
        .out_c(c1)
    );

    MAC MAC2
    (
        //INPUT
        .clk(clk)           , 
        .rst(rst)           ,           
        .in_a(a12)          , 
        .in_b(b2)           , 

        //OUTPUT
        .out_a(a23)         , 
        .out_b(b25)         , 
        .out_c(c2)
    );

    MAC MAC3
    (
        //INPUT
        .clk(clk)           , 
        .rst(rst)           , 
        .in_a(a23)          , 
        .in_b(b3)           , 

        //OUTPUT
        .out_a()            , 
        .out_b(b36)         , 
        .out_c(c3)
    );

    MAC MAC4 
    (
        //INPUT
        .clk(clk)           , 
        .rst(rst)           , 
        .in_a(a2)           , 
        .in_b(b14)          , 

        //OUTPUT
        .out_a(a45)         , 
        .out_b(b47)         , 
        .out_c(c4)
    );

    MAC MAC5 
    (
        //INPUT
        .clk(clk)           , 
        .rst(rst)           , 
        .in_a(a45)          , 
        .in_b(b25)          , 

        //OUTPUT
        .out_a(a56)         , 
        .out_b(b58)         , 
        .out_c(c5)
    );
    
    MAC MAC6
    (
        //INPUT
        .clk(clk)           , 
        .rst(rst)           , 
        .in_a(a56)          , 
        .in_b(b36)          ,   

        //OUTPUT
        .out_a()            , 
        .out_b(b69)         , 
        .out_c(c6)
    );

    MAC MAC7
    (
        //INPUT
        .clk(clk)           , 
        .rst(rst)           , 
        .in_a(a3)           , 
        .in_b(b47)          , 

        //OUTPUT
        .out_a(a78)         , 
        .out_b()            , 
        .out_c(c7)
    );

    MAC MAC8 
    (
        //INPUT
        .clk(clk)           , 
        .rst(rst)           , 
        .in_a(a78)          , 
        .in_b(b58)          , 

        //OUTPUT
        .out_a(a89)         , 
        .out_b()            , 
        .out_c(c8)
    );

    MAC MAC9 
    (
        //INPUT
        .clk(clk)           , 
        .rst(rst)           , 
        .in_a(a89)          , 
        .in_b(b69)          , 

        //OUTPUT
        .out_a()            , 
        .out_b()            ,    
        .out_c(c9)
    );

endmodule