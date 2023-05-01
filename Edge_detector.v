module EDGE_DETECTOR
(
    input  clk              ,
	input  rst              ,

    output rise_detected    ,
    output fall_detected
);

    reg clk_q;
    always @(posedge clk)
    begin
        if (rst)
            clk_q <= 1'b1;
        else
            clk_q <= clk;
    end

assign rise_detected = ~clk_q & clk;  // rising edge  (0 -> 1)
assign fall_detected = clk_q & ~clk;  // falling edge (1 -> 0)

endmodule
