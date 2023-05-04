//Program Counter
module PC 
#(
    parameter  W = 32
)
(
    input           clk         ,
    input           rst         ,
    input           PCWrite  	,
    input   [W-1:0] n_pc        ,
    input           stall       ,
    input           mem_taken   ,
    input           branch      ,
    input           PCSrc       ,
    output  [W-1:0] pc          ,
    output          flush2      ,
    output          flush3
);

wire [31:0] next;
wire [31:0] nn_pc;
wire stalled;
wire mem_was_taken;
wire pc_stalled2;
wire delay_branch;
wire fc2;
wire fc3;

REGISTER #(W) pc_delay (.CLK(clk), .RST(rst), .EN(TRUE), .D(n_pc), .Q(nn_pc));
REGISTER prev_stall (.CLK(clk), .RST(rst), .EN(TRUE), .D(stall), .Q(stalled));
REGISTER mem_taken_stall (.CLK(clk), .RST(rst), .EN(TRUE), .D(mem_taken), .Q(mem_was_taken));
REGISTER jump_delay (.CLK(clk), .RST(rst), .EN(TRUE), .D(PCSrc), .Q(delay_branch));
REGISTER fc_delay (.CLK(clk), .RST(rst), .EN(TRUE), .D(fc2), .Q(fc3));


assign next = (branch && stalled && !mem_was_taken && (n_pc > 32'd16)) ? nn_pc : n_pc;
assign pc_stalled1 = ((nn_pc != pc) && (branch && stalled && !mem_was_taken && (n_pc > 32'd16))) ? 1'b1 : 1'b0;
assign pc_stalled2 = (nn_pc != pc);
assign fc2 = (n_pc == pc + 4) && pc_stalled2 && pc_stalled1 && delay_branch;
assign flush2 = fc2;
assign flush3 = fc3;

    REGISTER #(W) DUT_PC
    (
        .CLK(clk)           ,
        .RST(rst)           ,
        .EN(PCWrite)     	,
        .D(next)            ,
        .Q(pc)
    );

endmodule