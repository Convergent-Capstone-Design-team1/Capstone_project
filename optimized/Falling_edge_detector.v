module FALLING_EDGE_DETECTOR
(
    input  clk              ,
	input  rst              ,
    input  signal           ,

    output fall_detected
);

    reg clk_q = 1'b1;

    assign fall_detected = clk_q & ~clk;  // falling edge (1 -> 0)

endmodule
