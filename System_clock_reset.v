module SYSTEM_CLOCK_RESET
(
    input  pll_refclk_i     ,
    input  pll_rst_i        ,
    
	output pll_locked_o     ,
    output sys_clk_o        ,
	output sys_rst_o
);

reg rst_state_q;
reg [19:0] rst_delay_cnt_q;

wire sys_clk_w;
wire pll_locked_w;

pll u_pll
(
    .inclk0(pll_refclk_i)   , // 50 MHz
    .areset(pll_rst_i)      ,
    .c0 (sys_clk_w)         , // 50 MHz
    .locked(pll_locked_w)
);


// pll_locked_w ----> sys_rst_o
always @(posedge sys_clk_w)
begin
    if (~pll_locked_w)
        rst_state_q <= 1'd1; // assert reset immediately
    else
        rst_state_q <= (& rst_delay_cnt_q) ? 1'd0 : 1'd1; // deassert when the counter value is all-one.
end

always @(posedge sys_clk_w)
begin
    if (~pll_locked_w)
		//1초에 20번 toggle
        rst_delay_cnt_q <= 20'd0;
    else if ( & rst_delay_cnt_q ) // if all-one,
        rst_delay_cnt_q <= rst_delay_cnt_q;
    else
        rst_delay_cnt_q <= rst_delay_cnt_q + 20'd1;
end

assign pll_locked_o = pll_locked_w;
assign sys_clk_o = sys_clk_w;
assign sys_rst_o = rst_state_q;

endmodule
