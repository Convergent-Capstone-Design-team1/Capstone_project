module FALLING_EDGE_DETECTOR
(
    input  clk              ,
	input  rst              ,

    output fall_detected
);

    reg clk_q;
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            clk_q <= 1'b1;
        else
            clk_q <= clk;
    end

    assign fall_detected = clk_q & ~clk;  // falling edge (1 -> 0)

endmodule