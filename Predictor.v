module PREDICTOR
#(
    parameter   [1:0]   T = 2'b11   ,
    parameter   [1:0]   t = 2'b10   ,
    parameter   [1:0]   n = 2'b01   ,
    parameter   [1:0]   N = 2'b00
)
(
<<<<<<< HEAD
    input           branch          ,   // branch 여부
    input   [31:0]  pc              ,   // 현재 pc 값
    output  [1:0]   taken               // branch를 예측한 결과
);

    BTB BTB
    (
        .pc(pc)                     ,
        .tag(btb_tag)               ,
        .data(btb_data)             ,
        .hit(btb_hit)
    );

    BHT BHT
    (
        .pc(pc)                     ,
        .index(bht_index)           ,
        .data(bht_data)
    );
=======
    input   [1:0]   branch          ,   // branch 여부
    input   [31:0]  pc              ,   // 현재 pc 값
    output  [1:0]   taken               // branch를 예측한 결과
);
>>>>>>> e5d2f7703514f542fa867f26a98e4249739f5857
    
    // Predictor FSM
    reg [1:0] state_r;
    always @(posedge clk) begin
        if (reset) begin
            state_r <= 2'bN;
        end 
        else begin
            case (state_r)
                N : begin                // Strongly Not Taken
<<<<<<< HEAD
                    if (branch) begin
=======
                    if (branch[1]) begin
>>>>>>> e5d2f7703514f542fa867f26a98e4249739f5857
                        state_r <= 2'bn;
                    end 
                    else begin
                        state_r <= 2'bN;
                    end
                end
                n : begin                // Weakly Not Taken
<<<<<<< HEAD
                    if (branch) begin
=======
                    if (branch[1]) begin
>>>>>>> e5d2f7703514f542fa867f26a98e4249739f5857
                        state_r <= 2'bt;
                    end 
                    else begin
                        state_r <= 2'bN;
                    end
                end
                t : begin                // Weakly Taken
<<<<<<< HEAD
                    if (branch) begin
=======
                    if (branch[1]) begin
>>>>>>> e5d2f7703514f542fa867f26a98e4249739f5857
                        state_r <= 2'bT;
                    end 
                    else begin
                        state_r <= 2'bn;
                    end
                end
                T : begin                // Strongly Taken
<<<<<<< HEAD
                    if (branch) begin
=======
                    if (branch[1]) begin
>>>>>>> e5d2f7703514f542fa867f26a98e4249739f5857
                        state_r <= 2'bT;
                    end 
                    else begin
                        state_r <= 2'bt;
                    end
                end
            endcase
        end
    end

    // Output taken
    assign taken = state_r;

    endmodule