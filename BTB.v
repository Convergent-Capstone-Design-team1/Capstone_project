//BTB는 64개의 엔트리, 각 엔트리는 64비트 너비, 상위 32비트는 이전 분기 명령어의 주소를, 하위 32비트는 해당 엔트리의 상태 비트
//상태 비트는 2비트 크기이며, not is_taken, weakly is_taken, strongly is_taken, reserved 중 하나임.
//항상 현재 명령어 주소(pc)와 일치하는 엔트리를 찾아 업데이트하며, 해당 주소 또는 +4한 값을 다음 명령어 주소(next_pc_r)로 반환함.

module BTB 
#(
  parameter NUM_ENTRIES = 256  ,   // BTB 엔트리 수
  parameter ENTRY_WIDTH = 40      // BTB 엔트리 너비 (주소와 상태 비트) 
)
(
  input           clk         ,
  input           rst_i       ,
  input   [7:0]   btb_addr    ,
  input   [39:0]  btb_init    ,

  input           is_branch   ,   // branch 명령어인지?
  input   [31:0]  pc          ,   // 현재 명령어 주소
  input   [31:0]  mem_pc      ,   // mem stage의 pc값 
  input   [31:0]  target      ,   // 분기 목적지 주소
  input           is_taken    ,   // 앞에서 결정하기를, 점프를 해야 한다. 그럼 테이블에 있는지 찾아보자.
  input           PCSrc       ,
  input           miss_predict,
  
  output          hit         ,
  output  [31:0]  next_pc         // 다음 명령어 주소
);

  generate
    genvar 		 idx;
    for(idx = 0; idx < 256; idx = idx+1) begin: btb_target
	    wire [39:0] tmp;
	    assign tmp = btb[idx];
    end
  endgenerate

  reg [ENTRY_WIDTH-1:0] btb [NUM_ENTRIES-1:0];
  reg   [31:0]  next_pc_r;
  reg           hit_r;
  
  always @ (posedge clk)
  begin
    if (rst_i) begin
      btb[btb_addr] <= btb_init;
    end
    else 
    if (is_taken && PCSrc) begin                
      btb[mem_pc[9:2]] <= {mem_pc[9:2], target};
    end
  end

  always @ (miss_predict or is_branch or PCSrc or is_taken or pc or mem_pc or target)
  begin
    hit_r = 1'b0;
    next_pc_r = 32'b0;
    if (is_taken && PCSrc) begin                
      next_pc_r = target;
    end
    else
    if(miss_predict) begin
      next_pc_r = mem_pc + 32'd4;
    end
    else if(is_branch && !PCSrc) begin
      if (is_taken) begin                                     // 앞에서 말하기를, 점프 해야하는 경우
        next_pc_r = btb[pc[9:2]][31:0]; 
        hit_r = 1'b1;                               // 저장되어있던, 분기 목적지 주소로 세팅해줌
      end
    end
     else begin
      next_pc_r = 32'b0;
    end 
  end

  reg [9:0] cnt;
  reg [9:0] h_cnt;
  always @ (posedge clk) begin
    if (rst_i) 
      cnt <= 10'b0;
    else if (is_branch)
      cnt <= cnt + 10'b1;
  end

  always @ (posedge clk) begin
    if (rst_i) 
      h_cnt <= 10'b0;
    else if (hit_r)
      h_cnt <= h_cnt + 10'b1;
  end

  assign hit = hit_r;
  assign next_pc = next_pc_r;

endmodule