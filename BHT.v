//BHT의 크기는 예측할 수 있는 분기 명령어의 수와 직접적으로 관련이 있다.
//또한 BHT는 각 분기 명령어의 예측 결과를 저장하므로, 각 엔트리는 분기 명령어의 주소와 예측 결과를 저장해야 함.

//BHT의 크기는 1024. 분기 명령어 주소와 예측 결과는 history 레지스터 배열에 저장
//검색 결과는 index와 hit 와이어를 통해 생성. BHT를 갱신하는 동안 이전 예측 결과를 저장하는 c_state 레지스터 사용

module BHT
#(
    parameter           BHT_SIZE = 256          ,   // BHT 크기
    parameter           HISTORY_LENGTH = 2      ,   // 예측 결과 길이
    parameter   [1:0]   T = 2'b11               ,
    parameter   [1:0]   t = 2'b10               ,
    parameter   [1:0]   n = 2'b01               ,
    parameter   [1:0]   N = 2'b00
)
(
    input           clk                     ,
    input           rst                     ,
    input           hit                     ,
    input           jump                    ,   // PCSrc (MEMstage의 output에서 받아옴) = 나중에 보니까 점프 했더라
    input           is_branch               ,   // 명령어가 branch인지를 입력받음
    input   [31:0]  b_pc                    ,
    input           mem_is_taken            ,
    input   [31:0]  mem_pc                  ,

    output          T_NT                    ,   // mux의 select 신호로 들어감, BTB에게 serach를 요구
    output  [1:0]   state
);  
    /******************* for simulation *************************/

    generate
        genvar  idx;
        for (idx = 0; idx < 256; idx = idx+1) begin: history_table
            wire [1:0] tmp;
            assign tmp = history[idx];
        end
    endgenerate

    generate
        genvar  idz;
        for (idz = 0; idz < 256; idz = idz+1) begin: valid_table
            wire temp;
            assign temp = valid[idz];
        end
    endgenerate

    integer i;
    /* initial begin
        for (i = 0; i < 256; i = i+1) begin
            history[i] = 2'b00;
            valid[i] = 1'b0;
        end
    end */

    /********************** module start *************************/

    reg [HISTORY_LENGTH-1:0] history [0:BHT_SIZE-1];            // 이전 상태를 저장하는 레지스터
    reg                        valid [0:BHT_SIZE-1];            // 해당 데이터의 valid
    reg [31:0]                             prev_pc1;
    reg [31:0]                             prev_pc2;
    reg [31:0]                             prev_pc3;
    reg [31:0]                             prev_pc4;
    reg [31:0]                             pcin;
    reg [1:0]                                nstate;
    wire [1:0]                               changed_st;
    wire [31:0]                               changed_pc;
    reg [1:0]                               casein;

    // BHT 갱신

    always @ (*) begin
        pcin <= prev_pc3;
        casein <= history[prev_pc3[9:2]];
        case (history[prev_pc3[9:2]])                   //BHT 내부의 검색단계
            N : begin
                if (jump) begin                         //valid하며, history[1]의 값(jump)했을 경우
                    nstate <= n;                        //n으로 state를 이동시킴
                end     
                else begin                              //valid하며, jump하지 않은 경우
                    nstate <= N;                        //N으로 state 유지함
                end
            end

            n : begin
                if (jump) begin
                    nstate <= t;
                end     
                else begin
                    nstate <= N;
                end
            end

            t : begin
                if (jump) begin
                    nstate <= T;
                end     
                else begin
                    nstate <= n;
                end
            end

            T : begin
                if (jump) begin
                    nstate <= T;
                end     
                else begin
                    nstate <= t;
                end
            end
        endcase
    end

    always @ (posedge clk or posedge rst) begin

        if (rst) begin
            for (i = 0; i < 256; i = i + 1) begin
                history[i] = 2'b00;
                valid[i] = 1'b0;
            end
            nstate <= n;
            prev_pc1 <= 32'b0;
            prev_pc2 <= 32'b0;
            prev_pc3 <= 32'b0;
            prev_pc4 <= 32'b0;
        end

        else begin
            
            history[prev_pc3[9:2]] <= nstate;
        end

        prev_pc1 <= b_pc;
        prev_pc2 <= prev_pc1;
        prev_pc3 <= prev_pc2;
        prev_pc4 <= prev_pc3;
    end

    // 예측 결과 출력  

    assign T_NT = ((jump && !hit && !mem_is_taken)) ? 1'b1 : history[b_pc[9:2]][1];
    assign state = history[b_pc[9:2]];
    assign changed_pc = prev_pc4;
    assign changed_st = history[prev_pc4[9:2]];

endmodule