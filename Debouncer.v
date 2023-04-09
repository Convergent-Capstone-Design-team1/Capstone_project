module DEBOUNCER
#(
    // Clock : 50MHz => 1초에 20번 toggle
    parameter DELAYCNT_WIDTH = 20
)
(
    // Clock
    input        clk                ,
    input        button             ,

    // Debounced Signal (Output)
    output       debounced_signal
);

    reg         state_q;
    reg [DELAYCNT_WIDTH-1:0] input_delay_cnt_q;

    wire update_w;

    // rst_btn_n_i ----> rst_input_valid
    always @(posedge clk)
    begin
        if (update_w)begin
            // if all-one, update the state
            state_q <= button;
        end
        else begin
            state_q <= state_q;
        end
    end
    assign update_w = (& input_delay_cnt_q) ? 1'b1 : 1'b0;

    always @(posedge clk)
    begin
        if (state_q == button) begin
            input_delay_cnt_q <= {DELAYCNT_WIDTH{1'd0}};
        end
        else // if the input value is changed, 
        begin
            input_delay_cnt_q <= input_delay_cnt_q + 20'd1;
        end
    end

    assign debounced_signal = state_q;

endmodule
