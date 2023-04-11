module PREDICTOR
(   
    input   [6:0]   opcode          ,
    input   [31:0]  pc              ,   // 현재 pc 값
    
    output          is_branch       ,  
    output  [31:0]  b_pc            
);
    
    // Predictor FSM
    
    // Output taken
    assign is_branch = (opcode == 7'b1100011) ? 1'b1 : 1'b0;       // 출력해줌. 이번 명령어는 branch이다!
    assign b_pc = is_branch ? pc : 32'b0;                          // hashing에 맞게 pc를 변형시킴.

endmodule