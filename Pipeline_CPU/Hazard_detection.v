//lw 명령어는 Forwaridng Unit을 사용해도 어쩔 수 없이 1clk의 stall이 발생시켜야함.
//따라서 lw의 명령어는 MEMRead signal이 1이기 때문에 이를 사용해서 stall을 시켜주도록 구현

module HAZARD_DETECTION
(
    input           MEMRead         ,           //from EX stage MEMRead
    input   [4:0]   RD              ,           //from EX stage RD
    input   [4:0]   RS1             ,           //from ID stage RS1
    input   [4:0]   RS2             ,           //from ID stage RS2

    output          stall                            
);

    reg             stall_r;
    always @ (*) 
    begin
        stall_r = 1'b0;
        
        //lw 명령어 사용 && 현재 RS1 혹은 RS2가 이전 명령어의 RD와 같을 때 stall 
        if ((MEMRead == 1'b1) && {(RD == RS1) || (RD == RS2)}) begin
            stall_r = 1'b1;
        end 
    end

    assign stall = stall_r;

endmodule   