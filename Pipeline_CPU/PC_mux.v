// BHT와 BTB를 통해 다음 주소를 구하는 여건을 맞췄다면
// 최종적으로 다음 주소를 선택해주는 모듈

module PC_MUX
(
    input           sel_mux         ,       //BHT의 taken, not taken 여부 출력 (T_NT)
    input   [31:0]  PC_4            ,
    input   [31:0]  target_address  ,

    output  [31:0]  next_pc
);
    //sel_mux가 1이라면 target address를
    //sel_mux가 0이라면 pc+4한 주소를 next_pc로 선택
    assign next_pc = sel_mux ? target_address : PC_4;
    
endmodule