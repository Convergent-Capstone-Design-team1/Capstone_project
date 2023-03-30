module ID_EX
#(
    parameter  W = 154
)
(
    input           clk     ,
    input           rst     ,
    input           flush   ,
    input   [W-1:0] D       ,
    output  [W-1:0] Q
);

    REGISTER #(W) REG_ID_EX
    (
        .CLK(clk)   ,
        .RST(rst)   ,
        .EN(1'b0)   ,
        .D(D)       ,
        .Q(Q)
    );
    
endmodule

