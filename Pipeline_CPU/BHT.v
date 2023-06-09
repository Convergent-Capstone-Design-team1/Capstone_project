//BHT의 크기는 예측할 수 있는 분기 명령어의 수와 직접적으로 관련이 있다.
//또한 BHT는 각 분기 명령어의 예측 결과를 저장하므로, 각 엔트리는 분기 명령어의 주소와 예측 결과를 저장

//BHT의 크기는 256. 분기 명령어 주소와 예측 결과는 bht 레지스터 배열에 저장
//검색 결과는 index와 hit 와이어를 통해 생성. BHT를 갱신하는 동안 이전 예측 결과를 저장하는 c_state 레지스터 사용

module BHT
#(
    parameter           BHT_SIZE = 256      ,   // BHT Size
    parameter           HISTORY_LENGTH = 2  ,   // Two-bit Branch prediction
    parameter   [1:0]   ST = 2'b11          ,   // Strong Taken
    parameter   [1:0]   wt = 2'b10          ,   // weakly taken
    parameter   [1:0]   wn = 2'b01          ,   // weakly not taken    
    parameter   [1:0]   SN = 2'b00              // Strong Not taken
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

    /***************************************************************/
    wire [1:0] t_state;
    generate
        genvar  idx;
        for (idx = 0; idx < 256; idx = idx+1) begin: history_table
            assign t_state = bht[idx];
        end
    endgenerate

    /***************************************************************/
    reg [HISTORY_LENGTH-1:0] bht [0:BHT_SIZE-1];                // 2차원 벡터를 이용한 BHT memory

    // BHT state machine
    always @(posedge clk)
    begin                                                       
        if (rst_i) begin                                        // BHT reset
            bht[bht_addr] <= bht_init;
        end
        else begin
            // branch 명령어의 결과는 3clk 이후에 결과를 알고 있으므로 mem stage에서의 pc값을 사용
            case (bht[mem_pc[9:2]])                                 
                
                // Not taken state에서는 3clk 이후에 결과가 나오는 PCSrc로만 분기 state 결정 가능 
                SN : begin                                      /*** Strong Not taken ***/
                    if (PCSrc) begin                            // PCSrc = 1 : decided to jump
                        bht[mem_pc[9:2]] <= wn;                 // SN -> wn : weakly not taken
                    end     
                    else begin                                      
                        bht[mem_pc[9:2]] <= SN;                 // SN 유지
                    end
                end

                wn : begin                                      /*** weakly not taken ***/
                    if (PCSrc) begin                            // PCSrc = 1 : decided to jump
                        bht[mem_pc[9:2]] <= wt;                 // wn -> wt : weakly taken
                    end     
                    else begin              
                        bht[mem_pc[9:2]] <= SN;                 // wn -> SN
                    end
                end

                //taken state에서는 mem state의 pc값에 대한 BHT memory의 state를 읽어와 
                //PCSrc와의 일치 여부로 분기 state 결정
                wt : begin                                      /*** weakly not taken ***/
                    if (bht[mem_pc[9:2]][1] != PCSrc) begin     // PCSrc와 분기 예측이 다름 
                        bht[mem_pc[9:2]] <= wn;                 // wt -> wn, prediction miss    
                    end 
                    else if (mem_is_taken) begin                 
                        bht[mem_pc[9:2]] <= ST;                 // wt -> ST
                    end
                end

                ST : begin                                      /*** Strong Not taken ***/
                    if (bht[mem_pc[9:2]][1] != PCSrc) begin     // PCSrc와 분기 예측이 다름       
                        bht[mem_pc[9:2]] <= wt;                 // ST -> wt, prediction mistake
                    end
                    else if (mem_is_taken) begin
                        bht[mem_pc[9:2]] <= ST;                 // ST 유지
                    end
                end

                default : bht[mem_pc[9:2]] = 2'b0;
            endcase
        end
    end 

    /* miss prediction decision */
    reg miss_predict_r;
    always @ (mem_pc or PCSrc) begin
        miss_predict_r = 1'b0;                                  // To prevent latch
        if (bht[mem_pc[9:2]][1] != PCSrc) begin                 // bht 상태와 PCSrc와 다름
            miss_predict_r = 1'b1;                              // -> miss predict   
        end
    end
    assign miss_predict = miss_predict_r;

    // 예측 결과 출력
    // ((PCSrc && !mem_is_taken) || miss_predict) 가 만족하면 우선적으로 jump
    // 그렇지 않으면 bht memory의 값을 통해 jump 결정
    assign T_NT = ((PCSrc && !mem_is_taken) || miss_predict) ? 1'b1 : bht[b_pc[9:2]][1];

endmodule
