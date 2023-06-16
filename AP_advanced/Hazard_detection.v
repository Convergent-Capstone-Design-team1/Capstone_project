module HAZARD_DETECTION
(
    input           MEMRead         ,
    input   [4:0]   RD              ,
    input   [4:0]   RS1             ,
    input   [4:0]   RS2             ,
    input           mat_start       ,
    input           EN_NPU          ,
    input           mem_wr          ,
    input   [9:0]   critical_addr   ,   
    input   [9:0]   mem_is_writing  ,   // 데이터 메모리에 접근하는 주소
    
    output          stall           ,
    output          critical
);

    reg             stall_r;
    reg             critical;

    always @ (*) begin
        //When Load instruction use
        if (((MEMRead == 1'b1) && {(RD == RS1) || (RD == RS2)}) || mat_start) begin
            stall_r = 1'b1;
        end
        //matr 명령어가 fetch되는데 MemWrite control signal이 1이면서
        // 
        else if(EN_NPU && mem_wr && (critical_addr == mem_is_writing)) begin
            stall_r = 1'b1;
            critical = 1'b1;
        end
        else begin
            stall_r = 1'b0;
            critical = 1'b0;
        end
    end

    assign stall = stall_r;

endmodule   