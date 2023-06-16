// EX_MEM Register에 들어가는 control signal을 flush해주기 위한 모듈

module EX_MEM_FLUSH
(
    input           flush           ,
    input           hit             ,
    input   [4:0]   ex_mem_ctrl     ,

    output  [4:0]   ex_mem_f_ctrl
);

    // Flush flag가 1로 set이 되고 hit이 0으로 set => Flush
    // hit이 1이면 바로 Jump하기 때문에 control signal이 초기화 되면 안됨
    assign ex_mem_f_ctrl = (flush && !hit) ? 5'b0 : ex_mem_ctrl;
    
endmodule