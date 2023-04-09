module PIPELINE_CPU 
(
    input           CLOCK_50        ,
    input           RST_BUTTON      ,

    //output  [11:0]  LED             , 
    output			pll_locked	    ,
	output          heartbeat           
);

    wire            CLK;
    wire            RST;

    TOPCPU TOPCPU
    (   
        //INPUT
        .clk(CLK)                   ,
        .rst(RST)                  
    );

    CPU_CONTROL CPU_CONTROL
    (   
        //INPUT
        .pll_refclk_i(CLOCK_50)     ,
        .rst_button_i(RST_BUTTON)   ,
        
        //OUTPUT
        //.led_o()                    ,
        .clk_o(CLK)                 ,
        .rst_o(RST)                 ,
        .pll_locked_o(pll_locked)   ,
        .heartbeat_o(heartbeat)     
    );

endmodule