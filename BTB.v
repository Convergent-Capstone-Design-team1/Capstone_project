//BTB는 64개의 엔트리, 각 엔트리는 64비트 너비, 상위 32비트는 이전 분기 명령어의 주소를, 하위 32비트는 해당 엔트리의 상태 비트
//상태 비트는 2비트 크기이며, not taken, weakly taken, strongly taken, reserved 중 하나임.
//항상 현재 명령어 주소(pc)와 일치하는 엔트리를 찾아 업데이트하며, 해당 주소 또는 +4한 값을 다음 명령어 주소(next_pc_r)로 반환함.

module BTB 
#(
  parameter NUM_ENTRIES = 64,   // BTB 엔트리 수
  parameter ENTRY_WIDTH = 64    // BTB 엔트리 너비 (주소와 상태 비트) 
)
(
  input           clk       ,
  input           rst       ,   // 리셋 입력
  input           branch    ,   // BRANCH가 아니면 테이블에 쓰지 마라.
  input   [31:0]  pc        ,   // 현재 명령어 주소
  input           taken     ,   // 앞에서 결정하기를, 점프를 해야 한다. 그럼 테이블에 있는지 찾아보자.
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
      for (i = 0; i < 64; i = i+1) begin
        btb[i] = 64'b0;
      end
  end

  /********************** module start *************************/
  reg [ENTRY_WIDTH-1:0] btb [NUM_ENTRIES-1:0];              // BTB 메모리
  reg [1:0]           valid [NUM_ENTRIES-1:0];
  reg [31:0]                next_pc_r = 32'b0;
  reg [31:0]                pend_pc_1 = 32'b0;
  reg [31:0]                pend_pc_2 = 32'b0;
  reg [31:0]                pend_pc_3 = 32'b0;
  reg                                    pend;
  reg [31:0]                       check_addr;
  reg [31:0]                     check_target;
  reg [31:0]                       addr_input;

  always @(posedge clk) begin
    pend_pc_1 <= pc[31:0];
    pend_pc_2 <= pend_pc_1;
    pend_pc_3 <= pend_pc_2;

    if(pend && (pend_pc_3 != 0)) begin
      btb[pend_pc_3[9:2]] = {pend_pc_3, target};
      {check_addr, check_target} = btb[pend_pc_3[9:2]];
      pend = 1'b0;
    end

  end

  always @(*) begin

    if(rst) begin
      pend_pc_1 <= 32'b0;
      pend_pc_2 <= 32'b0;
      pend_pc_3 <= 32'b0;
      pend = 1'b0;
    end

    if(taken) begin
      next_pc_r = target;
    end

    else if(branch) begin
      addr_input = btb[pc[9:2]][63:32];
      if (btb[pc[9:2]][63:32] == pc[31:0]) begin            // 테이블에서 지금 pc를 발견함. 이 주소로 갈까요?
        if (taken) begin                                    // 앞에서 말하기를, 점프 해야하는 경우
          next_pc_r = btb[pc[9:2]][31:0];                   // 저장되어있던, 분기 목적지 주소로 세팅해줌
        end
        else begin                                          // 만약 찾았더라도 점프 하지 말라고 지시받았으면, 그대로 가라.
          next_pc_r = next_pc_r;
        end
      end
      else begin                                            // branch인데 테이블에 명령어가 없는 경우, 써줘야함
        pend = 1'b1;
      end
    end
  end

  assign next_pc = next_pc_r;
  
endmodule