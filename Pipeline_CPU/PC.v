// Program Counter 구현
// PCWrite (stall)을 EN으로 넣어줌으로써
// Q값을 다시 Q로 집어넣어 stall을 구현하도록 함
module PC 
#(
    parameter  W = 32
)
(
    input           clk             ,
    input           rst             ,
  
    input           PCWrite  	    ,       //stall signal
    input   [W-1:0] n_pc            ,

    output  [W-1:0] pc
);
   
    REGISTER #(W) PC
    (
        .CLK(clk)           ,
        .RST(rst)           ,
        .EN(PCWrite)     	,
        .D(n_pc)            ,
        .Q(pc)
    );

endmodule