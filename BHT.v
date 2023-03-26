//BHT의 크기는 예측할 수 있는 분기 명령어의 수와 직접적으로 관련이 있다.
//또한 BHT는 각 분기 명령어의 예측 결과를 저장하므로, 각 엔트리는 분기 명령어의 주소와 예측 결과를 저장해야 함.

//BHT의 크기는 1024. 분기 명령어 주소와 예측 결과는 history 레지스터 배열에 저장
//검색 결과는 index와 hit 와이어를 통해 생성. BHT를 갱신하는 동안 이전 예측 결과를 저장하는 prediction_r 레지스터 사용

module BHT
#(
    parameter       BHT_SIZE = 256          ,   // BHT 크기
    parameter       HISTORY_LENGTH = 2          // 예측 결과 길이
)
(
    input           clk                     ,
    input           rst                     ,
    input   [31:0]  pc                      ,
    input   [1:0]   prediction              ,
    
    output  [1:0]   result
);

    reg [HISTORY_LENGTH-1:0] history [0:BHT_SIZE-1];  // 분기 명령어 주소와 예측 결과를 저장하는 레지스터 배열
    reg [1:0] prediction_r;  // 이전 예측 결과를 저장하는 레지스터

    generate
    genvar  idx;
    for (idx = 0; idx < 256; idx = idx+1) begin: history_table
	    wire [7:0] tmp;
	    assign tmp = history[idx];
    end
    endgenerate

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i+1)
            history[i] = 2'b00;
    end

    wire hit;  // BHT에서 검색 결과

    // BHT에서 검색
    assign hit = (history[pc[9:2]] == prediction_r);

    // 예측 결과 출력
    assign result = prediction_r;

    // BHT 갱신
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prediction_r <= 2'b00;
        end 
        else begin
            history[pc[9:2]] <= {pc[1:0], prediction};
            prediction_r <= hit ? prediction_r : prediction;
        end
    end

endmodule
