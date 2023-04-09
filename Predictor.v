module PREDICTOR
#(   
    parameter   [1:0]   ST = 2'b11          ,
    parameter   [1:0]   wt = 2'b10          ,
    parameter   [1:0]   wn = 2'b01          ,
    parameter   [1:0]   SN = 2'b00
)
(   
    input           clk             ,
    input           PCSrc           ,
    input           is_taken        ,
    //input   [1:0]   state           ,

    input   [6:0]   opcode          ,
    input   [31:0]  pc              ,   // 현재 pc 값
    
    output          is_branch       , 
    output  [31:0]  b_pc            
);
   /* 
    // Predictor FSM
    always @(posedge clk)
    begin                                                       // SN, wn 상태는 3clk 이후 결과를 알 수 있으므로 mem stage에서의 pc값을 가져옴
        //miss_predict_r = 1'b0;
        case (history[mem_pc[9:2]])                            
            SN : begin                                        
                if (PCSrc) begin                                // PCSrc가 1일 때 jump 
                    history[mem_pc[9:2]] = wn;                  // n으로 state를 이동
                end     
                else begin                                      
                    history[mem_pc[9:2]] = SN;                  //N으로 state 유지함
                end
            end

            wn : begin
                //valid[mem_pc[9:2]] = 1'b1;
                if (PCSrc) begin                                // PCSrc가 1일 때 jump
                    history[mem_pc[9:2]] = wt;                  // t으로 state를 이동
                end     
                else begin
                    history[mem_pc[9:2]] = SN;                  //N으로 state 떨어짐
                end
            end

            wt : begin
                if (history[mem_pc[9:2]][1] != PCSrc) begin
                    //miss_predict_r = 1'b1;                              // 3clk이후 PCSrc가 1이면 의도하지 않은 점프 -> miss predict 
                    history[mem_pc[9:2]] = wn;                     // miss 나면 아래 state로 내려줌    
                end 
                else if (is_taken) begin                        // 
                    history[b_pc[9:2]] = ST;
                end
            end

            ST : begin
                if (history[mem_pc[9:2]][1] != PCSrc) begin
                    //miss_predict_r = 1'b1;                              // 3clk이후 PCSrc가 1이면 의도하지 않은 점프 -> miss predict                  
                    history[mem_pc[9:2]] = wt;                     // miss 나면 아래 state로 내려줌
                end
                else if (is_taken) begin
                    history[b_pc[9:2]] = ST;
                end
            end
        endcase
    end 
    */
    // Output taken
    assign is_branch = (opcode == 7'b1100011) ? 1'b1 : 1'b0;       // 출력해줌. 이번 명령어는 branch이다!
    assign b_pc = is_branch ? pc : 32'b0;                          // hashing에 맞게 pc를 변형시킴.

endmodule