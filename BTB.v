//BTB는 64개의 엔트리, 각 엔트리는 64비트 너비, 상위 32비트는 이전 분기 명령어의 주소를, 하위 32비트는 해당 엔트리의 상태 비트
//상태 비트는 2비트 크기이며, not is_taken, weakly is_taken, strongly is_taken, reserved 중 하나임.
//항상 현재 명령어 주소(pc)와 일치하는 엔트리를 찾아 업데이트하며, 해당 주소 또는 +4한 값을 다음 명령어 주소(next_pc_r)로 반환함.

module BTB 
#(
  parameter NUM_ENTRIES = 64  ,   // BTB 엔트리 수
  parameter ENTRY_WIDTH = 64      // BTB 엔트리 너비 (주소와 상태 비트) 
)
(
  input           is_branch   ,   // branch 명령어인지?
  input   [31:0]  pc          ,   // 현재 명령어 주소
  input   [31:0]  mem_pc      ,   // mem stage의 pc값 
  input   [31:0]  target      ,   // 분기 목적지 주소
  input   [1:0]   state       ,   // BHT state
  input           is_taken    ,   // 앞에서 결정하기를, 점프를 해야 한다. 그럼 테이블에 있는지 찾아보자.
  input           b_valid     ,
  input           PCSrc       ,
  input           miss_predict,
  
  output          hit         ,
  output  [31:0]  next_pc         // 다음 명령어 주소
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
  reg hit_r;

  always @ (*) begin
    hit_r = 0;
    if (~b_valid && is_taken && PCSrc) begin
      next_pc_r = target;
      btb[mem_pc[9:2]] = {mem_pc, target};
    end
    else if(miss_predict) begin
      next_pc_r = mem_pc + 32'd4;
    end
    else if(is_branch && !PCSrc) begin
      if ((btb[pc[9:2]][63:32] == pc[31:0])) begin          // 테이블에서 지금 pc를 발견함. 이 주소로 갈까요?
        if (is_taken) begin                                 // 앞에서 말하기를, 점프 해야하는 경우
          next_pc_r = btb[pc[9:2]][31:0];                   // 저장되어있던, 분기 목적지 주소로 세팅해줌
          hit_r = 1;
        end
        else begin                                          // 만약 찾았더라도 점프 하지 말라고 지시받았으면, 그대로 가라.
          next_pc_r = next_pc_r;
        end
      end
    end
  end

  assign next_pc = next_pc_r;
  assign hit = hit_r;
  
endmodule