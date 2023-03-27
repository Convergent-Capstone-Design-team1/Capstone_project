module PREDICTOR
#(
    parameter   [1:0]   T = 2'b11   ,
    parameter   [1:0]   t = 2'b10   ,
    parameter   [1:0]   n = 2'b01   ,
    parameter   [1:0]   N = 2'b00
)
(
    input           clk             ,
    input           rst             ,
    input   [6:0]   opcode          ,
    input           history         ,   // jump 여부
    input   [31:0]  pc              ,   // 현재 pc 값
    
    output          branch          ,
    output  [1:0]   taken           ,   // branch를 예측한 결과
    output  [31:0]  b_pc            
);
    
    // Predictor FSM
    reg [1:0] state_r;
    always @(posedge clk) begin
        if (rst) begin
            state_r <= N;
        end 
        else begin
            case (state_r)
                N : begin                // Strongly Not Taken
                    if (history) begin
                        state_r <= n;
                    end 
                    else begin
                        state_r <= N;
                    end
                end
                n : begin                // Weakly Not Taken
                    if (history) begin
                        state_r <= t;
                    end 
                    else begin
                        state_r <= N;
                    end
                end
                t : begin                // Weakly Taken
                    if (history) begin
                        state_r <= T;
                    end 
                    else begin
                        state_r <= n;
                    end
                end
                T : begin                // Strongly Taken
                    if (history) begin
                        state_r <= T;
                    end 
                    else begin
                        state_r <= t;
                    end
                end
            endcase
        end
    end

    // Output taken
    assign taken = state_r;
    assign branch = (opcode == 7'b1100011) ? 1'b1 : 1'b0;
    assign b_pc = branch ? pc : 32'b0;
endmodule