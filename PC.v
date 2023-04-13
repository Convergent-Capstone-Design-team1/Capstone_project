//Program Counter
module PC 
#(
    parameter  W = 32
)
(
    input           clk             ,
    input           rst             ,
  
    input           PCWrite  	    ,
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