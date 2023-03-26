module IF_ID
#(
    parameter  W = 64
)
(
    input           clk         ,
    input           rst         ,
    input           IF_IDWrite  ,
    input   [W-1:0] D           ,
    output  [W-1:0] Q
);

    REGISTER #(W) REG_IF_ID
    (
        .CLK(clk)           ,
        .RST(rst)           ,
        .EN(IF_IDWrite)     ,
        .D(D)               ,
        .Q(Q)
    );
    
endmodule