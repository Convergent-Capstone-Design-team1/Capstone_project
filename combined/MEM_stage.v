module MEM_STAGE
// we'll use memory located in the NPU. so, MEMstage is simplified.
(
    input   [2:0]   MEM_control         ,
    input           zero                ,

    output          branch              ,
    output          memrd               ,
    output          memwr               
);

    assign branch = MEM_control[0] & zero;
    assign memrd = MEM_control[2];
    assign memwr = MEM_control[1];

endmodule