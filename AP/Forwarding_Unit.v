module FORWARDING_UNIT
(
    input           EX_MEM_RegWrite ,
    input           MEM_WB_RegWrite ,
    input   [4:0]   EX_MEM_RD       ,
    input   [4:0]   MEM_WB_RD       ,
    input   [4:0]   RS1             ,
    input   [4:0]   RS2             ,

    output  [1:0]   ForwardA        ,
    output  [1:0]   ForwardB   
);
    
    reg     [1:0]   ForwardA_r;
    reg     [1:0]   ForwardB_r;
    
    //ForwardA
    always @ (*) 
    begin
        
        //EX Hazard
        if (EX_MEM_RegWrite && (EX_MEM_RD != 5'd0) && (EX_MEM_RD == RS1)) begin
            ForwardA_r = 2'b10;
        end 
        //MEM Hazard   
        else if (MEM_WB_RegWrite && (MEM_WB_RD != 5'd0) && (MEM_WB_RD == RS1)) begin
            ForwardA_r = 2'b01;    
        end
        else begin
            ForwardA_r = 2'b00;
        end
    end

    //ForwardB
    always @ (*) 
    begin
        
        //EX Hazard
        if (EX_MEM_RegWrite && (EX_MEM_RD != 5'd0) && (EX_MEM_RD == RS2)) begin
            ForwardB_r = 2'b10;   
        end
        //MEM Hazard   
        else if (MEM_WB_RegWrite && (MEM_WB_RD != 5'd0) && (MEM_WB_RD == RS2)) begin
            ForwardB_r = 2'b01;
        end 
        else begin
            ForwardB_r = 2'b00;
        end
    end

    assign ForwardA = ForwardA_r;
    assign ForwardB = ForwardB_r;

endmodule