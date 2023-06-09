module WB_STAGE
(
    input           WB              ,
    input   [31:0]  R_DATA          ,
    input   [31:0]  result          ,

    output  [31:0]  WB_OUTPUT
);
    
    assign WB_OUTPUT = WB ? R_DATA : result;

endmodule