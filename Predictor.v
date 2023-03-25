module PREDICTOR
#(
    parameter   [1:0]   T = 2'b11   ,
    parameter   [1:0]   t = 2'b10   ,
    parameter   [1:0]   n = 2'b01   ,
    parameter   [1:0]   N = 2'b00
)
(
    input           branch          ,   // branch 여부
    input   [31:0]  pc              ,   // 현재 pc 값
    output  [1:0]   taken               // branch를 예측한 결과
);

    // BTB
    wire    [31:0]  btb_tag;
    wire    [31:0]  btb_data;
    wire            btb_hit;

    //BHT
    wire    [7:0]   bht_index;
    wire    [1:0]   bht_data;
    
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
    
    // Predictor FSM
    reg [1:0] state_r;
    always @(posedge clk) begin
        if (reset) begin
            state_r <= 2'bN;
        end 
        else begin
            case (state_r)
                2'bN: begin                // Strongly Not Taken
                    if (branch) begin
                        state_r <= 2'bn;
                    end 
                    else begin
                        state_r <= 2'bN;
                    end
                end
                2'bn: begin                // Weakly Not Taken
                    if (branch) begin
                        state_r <= 2'bt;
                    end 
                    else begin
                        state_r <= 2'bN;
                    end
                end
                2'bt: begin                // Weakly Taken
                    if (branch) begin
                        state_r <= 2'bT;
                    end 
                    else begin
                        state_r <= 2'bn;
                    end
                end
                2'bT: begin                // Strongly Taken
                    if (branch) begin
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