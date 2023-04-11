module EX_MEM
#(
    parameter  W = 140
)
(
    input           clk     ,
    input           rst     ,
    input           EN      ,
    input   [W-1:0] D       ,
    output  [W-1:0] Q
);

    REGISTER #(W) REG_EX_MEM
    (
        .CLK(clk)   ,
        .RST(rst)   ,
        .EN(EN)     ,
        .D(D)       ,
        .Q(Q)
    );

endmodule