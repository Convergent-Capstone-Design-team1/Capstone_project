module ID_EX_FLUSH
(
    input           flush           ,
    input   [5:0]   id_ex_ctrl      ,

    output  [5:0]   id_ex_f_ctrl
);

    assign id_ex_f_ctrl = flush ? 6'b0 : id_ex_ctrl;
    
endmodule