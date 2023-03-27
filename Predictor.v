module PREDICTOR
(   
    input   [6:0]   opcode          ,
    input   [1:0]   history         ,   // jump 여부
    input   [31:0]  pc              ,   // 현재 pc 값
    
    output          branch          ,
    output  [1:0]   taken           ,   // branch를 예측한 결과
    output  [31:0]  b_pc            
);
    
    // Predictor FSM
    
    // Output taken
    assign taken = history; //BTB로 감
    assign branch = (opcode == 7'b1100011) ? 1'b1 : 1'b0;
    assign b_pc = branch ? pc : 32'b0;

endmodule