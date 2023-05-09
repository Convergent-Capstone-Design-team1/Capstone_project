//BHT의 크기는 예측할 수 있는 분기 명령어의 수와 직접적으로 관련이 있다.
//또한 BHT는 각 분기 명령어의 예측 결과를 저장하므로, 각 엔트리는 분기 명령어의 주소와 예측 결과를 저장해야 함.

//BHT의 크기는 1024. 분기 명령어 주소와 예측 결과는 bht 레지스터 배열에 저장
//검색 결과는 index와 hit 와이어를 통해 생성. BHT를 갱신하는 동안 이전 예측 결과를 저장하는 c_state 레지스터 사용

module BHT
#(
    parameter           BHT_SIZE = 256      ,   // BHT 크기
    parameter           HISTORY_LENGTH = 2  ,   // 예측 결과 길이
    parameter   [1:0]   ST = 2'b11          ,
    parameter   [1:0]   wt = 2'b10          ,
    parameter   [1:0]   wn = 2'b01          ,
    parameter   [1:0]   SN = 2'b00
)
(
    input           clk                     ,
    input           rst_i                   ,
    input   [7:0]   bht_addr                ,
    input   [1:0]   bht_init                ,
    
    input           mem_is_taken            ,   // mem stage에서 가져온 hit
    input           PCSrc                   ,   
    input   [31:0]  b_pc                    ,
    input   [31:0]  mem_pc                  ,

    output          T_NT                    ,   // mux의 select 신호로 들어감, BTB에게 serach를 요구  
    output          miss_predict              
);  
    /******************* for simulation *************************/

    generate
        genvar  idx;
        for (idx = 0; idx < 256; idx = idx+1) begin: history_table
            wire [1:0] t_state;
            assign t_state = bht[idx];
        end
    endgenerate

    /********************** module start *************************/

    reg [HISTORY_LENGTH-1:0] bht [0:BHT_SIZE-1];            // 이전 상태를 저장하는 레지스터

    // BHT 갱신
    always @(posedge clk)
    begin                                                       // SN, wn 상태는 3clk 이후 결과를 알 수 있으므로 mem stage에서의 pc값을 가져옴
        if (rst_i) begin
            bht[bht_addr] <= bht_init;
        end
        else begin
            case (bht[mem_pc[9:2]])                            
                SN : begin                                        
                    if (PCSrc) begin                                // PCSrc가 1일 때 jump 
                        bht[mem_pc[9:2]] <= wn;                  // n으로 state를 이동
                    end     
                    else begin                                      
                        bht[mem_pc[9:2]] <= SN;                  //N으로 state 유지함
                    end
                end

                wn : begin
                    if (PCSrc) begin                                // PCSrc가 1일 때 jump
                        bht[mem_pc[9:2]] <= wt;                  // t으로 state를 이동
                    end     
                    else begin
                        bht[mem_pc[9:2]] <= SN;                  //N으로 state 떨어짐
                    end
                end

                wt : begin
                    if (bht[mem_pc[9:2]][1] != PCSrc) begin
                        bht[mem_pc[9:2]] <= wn;                     // miss 나면 아래 state로 내려줌    
                    end 
                    else if (mem_is_taken) begin                        // 
                        bht[mem_pc[9:2]] <= ST;
                    end
                end

                ST : begin
                    if (bht[mem_pc[9:2]][1] != PCSrc) begin              
                        bht[mem_pc[9:2]] <= wt;                     // miss 나면 아래 state로 내려줌
                    end
                    else if (mem_is_taken) begin
                        bht[mem_pc[9:2]] <= ST;
                    end
                end

                default : bht[mem_pc[9:2]] = 2'b0;
            endcase
        end
    end 

    reg miss_predict_r;
    always @ (mem_pc or PCSrc) begin
        miss_predict_r = 1'b0;
        if (bht[mem_pc[9:2]][1] != PCSrc) begin
            miss_predict_r = 1'b1;                              // 3clk이후 PCSrc가 1이면 의도하지 않은 점프 -> miss predict   
        end
    end
    assign miss_predict = miss_predict_r;

    // 예측 결과 출력
    assign T_NT = ((PCSrc && !mem_is_taken) || miss_predict) ? 1'b1 : bht[b_pc[9:2]][1];

endmodule
