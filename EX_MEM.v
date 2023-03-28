module EX_MEM
#(
    parameter  W = 107
)
(
    input           clk     ,
    input           rst     ,
    //input           flush   ,
    input   [W-1:0] D       ,
    output  [W-1:0] Q
);

    REGISTER #(W) REG_EX_MEM
    (
        .CLK(clk)   ,
        .RST(rst)   ,
        .EN(1'b0)  ,
        .D(D)       ,
        .Q(Q)
    );

endmodule