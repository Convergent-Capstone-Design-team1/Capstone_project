// Branch 명령어인지 아닌지 판단해주는 모듈로
// Branch 명령어일 때의 PC값을 BHT와 BTB에 보내주고 그렇지 않으면 0으로 전송

module PREDICTOR
(   
    input   [6:0]   opcode          ,
    input   [31:0]  pc              ,   // 현재 pc 값
    
    output          is_branch       ,  
    output  [31:0]  b_pc            
);
    
    assign is_branch = (opcode == 7'b1100011) ? 1'b1 : 1'b0;       // branch 명령어 구분
    assign b_pc = is_branch ? pc : 32'b0;                          // branch 명령어 일 때만 BHT와 BTB에 pc값을 전달

endmodule