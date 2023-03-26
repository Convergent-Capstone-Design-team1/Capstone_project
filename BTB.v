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

  
  /******************* for simulation *************************/
  
  generate
    genvar  idx;
    for (idx = 0; idx < 64; idx = idx+1) begin: branch_target
	    wire [63:0] tmp;
	    assign tmp = btb[idx];
    end
  endgenerate

  integer i; 
  initial begin
      for (i = 0; i < 64; i = i+1)
        btb[i] = 64'b0;
  end

  /********************** module start *************************/
  reg [ENTRY_WIDTH-1:0] btb [NUM_ENTRIES-1:0];              // BTB 메모리
  reg [33:0]  next_pc_r = 34'b0;
  reg pend = 1'b0;
  reg [1:0] cnt = 2'b00;

  always @(*) begin
    if(branch) begin
      next_pc_r = target;                                   //104로 들어가게 해야함 
      if (btb[pc[9:2]][63:34] == pc[31:2]) begin            // 테이블에서 지금 pc를 발견함
        pend = 1'b0;
        if (taken == 2'b10 || taken == 2'b11) begin         // 분기를 예측한 경우
            next_pc_r = btb[pc[9:2]][31:0];                 // 분기 목적지 주소로 점프
          end
        btb[pc[9:2]] <= {pc[31:2], taken, target[31:0]};  // BTB 엔트리 업데이트
      end
      else begin
        pend = 1'b1;
      end
    end
    else if(pend) begin
      if(cnt == 2'b11) begin
        next_pc_r = target;
        pend = 1'b0;
        cnt = 2'b00;
      end
      else begin
        cnt = cnt + 1'b1;
      end
    end
  end
    
  assign next_pc = next_pc_r;

endmodule