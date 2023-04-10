//BHT의 크기는 예측할 수 있는 분기 명령어의 수와 직접적으로 관련이 있다.
//또한 BHT는 각 분기 명령어의 예측 결과를 저장하므로, 각 엔트리는 분기 명령어의 주소와 예측 결과를 저장해야 함.

//BHT의 크기는 1024. 분기 명령어 주소와 예측 결과는 history 레지스터 배열에 저장
//검색 결과는 index와 hit 와이어를 통해 생성. BHT를 갱신하는 동안 이전 예측 결과를 저장하는 c_state 레지스터 사용

module BHT
#(
    parameter           BHT_SIZE = 256      ,   // BHT 크기
    parameter           HISTORY_LENGTH = 2  ,   // 예측 결과 길이
    parameter   [1:0]   ST = 2'b11           ,
    parameter   [1:0]   wt = 2'b10           ,
    parameter   [1:0]   wn = 2'b01           ,
    parameter   [1:0]   SN = 2'b00
)
(
    input           clk                     ,
    input           rst                     ,
    input           is_taken                ,   // BTB의 hit
    input           mem_is_taken            ,   // mem stage에서 가져온 hit
    input           PCSrc                   ,   
    input           ex_is_branch            ,
    input   [31:0]  b_pc                    ,
    input   [31:0]  mem_pc                  ,

    output          T_NT                    ,   // mux의 select 신호로 들어감, BTB에게 serach를 요구
    output          miss_predict            ,
    output  [1:0]   state                 
);  
    /******************* for simulation *************************/

    reg [8:0] i = 9'b0;

    /********************** module start *************************/

    reg [HISTORY_LENGTH-1:0] history [0:BHT_SIZE-1];            // 이전 상태를 저장하는 레지스터
    reg                        valid [0:BHT_SIZE-1];            // 해당 데이터의 valid
    reg miss_predict_r;
    
    // BHT 갱신
    always @(posedge clk or posedge rst)
    begin                                                       // SN, wn 상태는 3clk 이후 결과를 알 수 있으므로 mem stage에서의 pc값을 가져옴
        if(rst) begin
            for (i = 0; i < 256; i = i+1) begin
                history[i] = 2'b00;
            end
        end
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
                else begin
                    i = 0;
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
                else begin
                    i = 0;
                end
            end
        endcase
    end 

    always @ (mem_pc or PCSrc) begin
        miss_predict_r = 1'b0;
        if (history[mem_pc[9:2]][1] != PCSrc) begin
            miss_predict_r = 1'b1;                              // 3clk이후 PCSrc가 1이면 의도하지 않은 점프 -> miss predict   
        end
        else begin
            miss_predict_r = 1'b0;
        end
    end

    // 예측 결과 출력
    assign miss_predict = miss_predict_r;
    assign T_NT = ((PCSrc && !is_taken && !mem_is_taken) || miss_predict) ? 1'b1 : (history[b_pc[9:2]][1] && ex_is_branch) ? 1'b0 : history[b_pc[9:2]][1];
    assign state = history[b_pc[9:2]];

endmodule