module ID_EX
#(
    parameter  W = 154
)
(
    input           clk     ,
    input           rst     ,
    input           EN      ,
    input           flush   ,
    input   [W-1:0] D       ,
    output  [W-1:0] Q
);

    REGISTER #(W) REG_ID_EX
    (
        .CLK(clk)   ,
        .RST(rst)   ,
        .EN(EN)     ,
        .D(D)       ,
        .Q(Q)
    );
    
endmodule

