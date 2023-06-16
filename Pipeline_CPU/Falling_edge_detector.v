// Register file과 Data mem에서 위상이 반전된 clk을 사용하기 위한 Falling edge detector
// 기존 clk에서 falling edge일 때 1로 set하고 아닐 때 0으로 set해 위상 반전을 구현

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