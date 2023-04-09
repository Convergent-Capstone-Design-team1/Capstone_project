module EDGE_DETECTOR
(
    input  clk              ,
	input  rst              ,
    input  signal           ,

    output rise_detected    ,
    output fall_detected
);

    reg signal_q;                               // 1-clk delayed signal
    reg clk_q;
    always @(posedge clk)
    begin
        if (rst)
            signal_q <= 1'd1;
            clk_q <= 1'b1;
        else
            signal_q <= signal;
            clk_q <= clk;
    end

assign rise_detected = ~signal_q & signal;  // rising edge  (0 -> 1)
assign fall_detected = clk_q & ~clk;  // falling edge (1 -> 0)

endmodule
