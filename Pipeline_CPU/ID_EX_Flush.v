// ID_EX Register에 들어가는 control signal을 flushgo주기 위한 모듈

module ID_EX_FLUSH
(
    input           flush           ,
    input           hit             ,
    input   [5:0]   id_ex_ctrl      ,

    output  [5:0]   id_ex_f_ctrl
);

    // Flush flag가 1로 set이 되고 hit이 0으로 set => Flush
    // hit이 1이면 바로 Jump하기 때문에 control signal이 초기화 되면 안됨
    assign id_ex_f_ctrl = (flush && !hit) ? 6'b0 : id_ex_ctrl;
    
endmodule