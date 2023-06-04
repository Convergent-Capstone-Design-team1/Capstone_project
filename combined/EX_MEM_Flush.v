module EX_MEM_FLUSH
(
    input           flush           ,
    input           hit             ,
    input           npu_stall       ,
    input   [4:0]   ex_mem_ctrl     ,

    output  reg [4:0]   ex_mem_f_ctrl
);
    always @ (*) begin
        if (flush && !hit) begin
            ex_mem_f_ctrl = 5'b0;
        end
        else if (npu_stall && !hit) begin
            ex_mem_f_ctrl = {ex_mem_ctrl[4], 4'b0};
        end
        else begin
            ex_mem_f_ctrl = ex_mem_ctrl;
        end
    end
   
endmodule