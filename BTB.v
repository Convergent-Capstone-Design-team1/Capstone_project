//BTB는 64개의 엔트리, 각 엔트리는 64비트 너비, 상위 32비트는 이전 분기 명령어의 주소를, 하위 32비트는 해당 엔트리의 상태 비트
//상태 비트는 2비트 크기이며, not taken, weakly taken, strongly taken, reserved 중 하나임.
//항상 현재 명령어 주소(pc)와 일치하는 엔트리를 찾아 업데이트하며, 해당 주소 또는 +4한 값을 다음 명령어 주소(next_pc_r)로 반환함.

module BTB 
#(
  parameter NUM_ENTRIES = 64,   // BTB 엔트리 수
  parameter ENTRY_WIDTH = 64    // BTB 엔트리 너비 (주소와 상태 비트) 
)
(
  input           rst       ,   // 리셋 입력
  input           branch    ,
  input   [31:0]  pc        ,   // 현재 명령어 주소
  input   [1:0]   taken     ,   // 분기 예측 결과 (00: not taken, 01: weakly taken, 10: strongly taken, 11: reserved)
  input   [31:0]  target    ,   // 분기 목적지 주소
  output  [33:0]  next_pc       // 다음 명령어 주소
);

  reg [ENTRY_WIDTH-1:0] btb [NUM_ENTRIES-1:0]; // BTB 메모리

  integer i; // 반복문을 위한 변수
  initial begin
      for (i = 0; i < 64; i = i+1)
        btb[i] = 64'b0;
  end

  reg     [33:0]  next_pc_r;

  
  always @(*) begin
    if(branch) begin
      for (i = 0; i < NUM_ENTRIES; i = i + 1) begin
        if (btb[i][63:32] == pc[31:0]) begin // 현재 명령어 주소와 일치하는 엔트리를 찾으면
          if (taken == 2'b10 || taken == 2'b11) begin // 분기를 예측한 경우
            next_pc_r = btb[i][31:0]; // 분기 목적지 주소로 점프
          end

          btb[i] <= {target[31:0], taken}; // BTB 엔트리 업데이트
          i = i + NUM_ENTRIES; // 반복문 종료
        end
      end
    end
  end

  assign next_pc = next_pc_r;

endmodule