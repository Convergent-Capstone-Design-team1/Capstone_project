module ID_EX_FLUSH
(
    input           flush           ,
    input           npu_stall       ,
    input           hit             ,
    input   [5:0]   id_ex_ctrl      ,

    output  reg [5:0]   id_ex_f_ctrl
);

    always @ (*) begin
        if (flush && !hit) begin
            id_ex_f_ctrl = 6'b0;
        end
        else if (npu_stall && !hit) begin
            id_ex_f_ctrl = {2'b0, id_ex_ctrl[3], 3'b0};
        end
        else begin
            id_ex_f_ctrl = id_ex_ctrl;
        end
    end

    //assign id_ex_f_ctrl = (flush && !hit) ? 6'b0 : id_ex_ctrl;
    
endmodule