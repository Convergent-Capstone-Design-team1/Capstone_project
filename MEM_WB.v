module MEM_WB
#(
    parameter  W = 71
)
(
    input           clk     ,
    input           rst     ,
    input   [W-1:0] D       ,
    output  [W-1:0] Q
);

    REGISTER #(W) REG_MEM_WB
    (
        .CLK(clk)   ,
        .RST(rst)   ,
        .EN(1'b0)   ,
        .D(D)       ,
        .Q(Q)
    );
    
endmodule