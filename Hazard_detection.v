module HAZARD_DETECTION
(
    input           MEMRead         ,
    input   [4:0]   RD              ,
    input   [4:0]   RS1             ,
    input   [4:0]   RS2             ,
    
    output          stall                            
);

    reg             stall_r;
    always @ (*) 
    begin
        stall_r = 1'b0;
        
        //When Load instruction use
        if ((MEMRead == 1'b1) && {(RD == RS1) || (RD == RS2)}) begin
            stall_r = 1'b1;
        end 
    end

    assign stall = stall_r;

endmodule   