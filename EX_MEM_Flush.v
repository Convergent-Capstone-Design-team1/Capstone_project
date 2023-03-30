module EX_MEM_FLUSH
(
    input           flush           ,
    input           hit             ,
    input   [4:0]   ex_mem_ctrl     ,

    output  [4:0]   ex_mem_f_ctrl
);

    assign ex_mem_f_ctrl = (flush && !hit) ? 5'b0 : ex_mem_ctrl;
    
endmodule