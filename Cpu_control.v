module CPU_CONTROL
(
    // Reference Clock
    input           pll_refclk_i                ,   //from CLOCK_50 pin
    input           rst_button_i                ,
    input			rst_switch_i			    , 
	input			start_switch_i				,
    //input  [2:0]    user_button_n_i             ,

	// User Interface (Push Buttons and LEDs)
    //output [7:0]    led_o                       ,

    // CPU Clock & Reset
    output          clk_o                       ,
    output          rst_o                       ,
    output          pll_locked_o                ,
    output          heartbeat_o                 ,

    output    	 	rst_switch_o				,
    output 			start_switch_o     

    // BIST
    //output          bist_start_o                ,
    //input  [2:0]    bist_status_i
);

    reg     [31:0]  clock_cnt_q;
    reg             heartbeat_q;

    wire            rst_debounced;
    wire    [2:0]   user_debounced;

    (* noprune *) reg [7:0] user_led_q;

    // rst_button_i ----> rst_debounced
    DEBOUNCER RESET_BUTTON
    (   
        //INPUT
        .clk(pll_refclk_i)                      ,   // Clock_50 pin
        .button(rst_button_i)                   ,   // Reset button signal

        //OUTPUT
        .debounced_signal(rst_debounced)            // Debounced signa
    );

    
    SYSTEM_CLOCK_RESET SYSTEM_CLOCK_RESET
    (   
        //INPUT
        .pll_refclk_i (pll_refclk_i)            ,
        .pll_rst_i    (~rst_debounced)          ,

        //OUTPUT
        .pll_locked_o (pll_locked_o)            ,
        .sys_clk_o    (clk_o)                   ,
        .sys_rst_o    (rst_o)
    );

    always @(posedge clk_o)
    begin
        if (rst_o)
        begin
            clock_cnt_q <= 32'd0;
            heartbeat_q <= 1'd0;
        end
        else if (clock_cnt_q == 32'd10_000_000) // 0.2 s
        begin
            clock_cnt_q <= 32'd0;
            heartbeat_q <= ~heartbeat_q; // toggle
        end
        else
        begin
            clock_cnt_q <= clock_cnt_q + 1;
            heartbeat_q <= heartbeat_q;
        end
    end
    assign heartbeat_o = heartbeat_q;

    assign rst_switch_o = rst_switch_i;
	assign start_switch_o = start_switch_i;

endmodule
