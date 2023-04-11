//Program Counter
module PC 
#(
    parameter  W = 32
)
(
    input           clk             ,
    input           rst             ,
    input           start_switch    ,
    
    input           PCWrite  	    ,
    input   [W-1:0] n_pc            ,

    output  [W-1:0] pc
);

    wire    pc_rst;
    assign  pc_rst = rst && start_switch; 
    
    REGISTER #(W) PC
    (
        .CLK(clk)           ,
        .RST(pc_rst)        ,
        .EN(PCWrite)     	,
        .D(n_pc)            ,
        .Q(pc)
    );

endmodule