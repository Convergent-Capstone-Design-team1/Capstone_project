// We use shared memory system in NPU.v
// No longer use

// module DATA_MEM
// (
//   input           clk_50    ,
//   input           rst       ,
//   input           MEMRead   ,
//   input           MEMWrite  ,  
//   input   [31:0]  ADDR      ,
//   input   [31:0]  WD        ,
//   input   [31:0]  mem_addr  ,
//   input   [31:0]  mem_init  ,

//   output  [31:0]  RD        

// );

//   wire    [9:0]   word_addr;
//   reg     [31:0]  mem_cell [0:1023];

//   assign word_addr = ADDR [11:2];

//   generate
//     genvar  idx;
//     for (idx = 0; idx < 1024; idx = idx+1) begin: datamem
// 	    wire [31:0] tmp;
// 	    assign tmp = mem_cell[idx];
//     end
//   endgenerate

//   /* write */
//   always @ (posedge clk_50)
//   begin
//     if(MEMWrite) begin
//       mem_cell[word_addr] <= WD;
//     end
//     else if(rst) begin
//       mem_cell[mem_addr-1] <= mem_init;
//     end
//   end

//   /* read */
//   reg [31:0]  RD_r;
//   always @ (posedge clk_50 or posedge rst)
//   begin
//     if (rst) begin
//       RD_r <= 0;
//     end
//     else if (MEMRead) begin
//       RD_r <= mem_cell[word_addr];
//     end
//     else begin
//       RD_r <= 32'hz;
//     end
//   end

//   assign RD = RD_r;


// endmodule
