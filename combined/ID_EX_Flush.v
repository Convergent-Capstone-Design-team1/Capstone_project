module ID_EX_FLUSH
(
    input           flush           ,
    input           hit             ,
    input   [5:0]   id_ex_ctrl      ,
    input           EN_NPU          ,
    input           ack             ,

    output  [5:0]   id_ex_f_ctrl
);

    // 그냥 EN_NPU일때 -> 첫 matr 명령어에서 72 -> 0 초기화 되는 거 막음 
    // (ack && !EN_NPU) 일 때 -> 두 번째 matr 명령어에서 72 -> 0으로 초기화 되는 거 막음 
    //    ㄴ> 이런 조건을 넣은 이유는 6/10 4:30 am에 보낸 카톡 사진 확인
    assign id_ex_f_ctrl = ((flush && !hit) || EN_NPU || (ack && !EN_NPU)) ? 6'b0 : id_ex_ctrl;
    
endmodule