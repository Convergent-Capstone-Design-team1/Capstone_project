module PC_MUX
(
    input           sel_mux         ,
    input   [31:0]  PC_4            ,
    input   [31:0]  target_address  ,

    output  [31:0]  next_pc
);

    assign next_pc = sel_mux ? target_address : PC_4;
    
endmodule