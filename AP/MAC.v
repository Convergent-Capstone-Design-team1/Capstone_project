`timescale 1ns / 100ps
module MAC
#(
  parameter data_size = 32
)
(
  input                   rst       ,
  input                   clk       ,
  input   [data_size-1:0] in_a      ,
  input   [data_size-1:0] in_b      ,

  output  [data_size-1:0] out_a     ,
  output  [data_size-1:0] out_b     ,
  output  [data_size-1:0] out_c     
);

  reg [data_size-1:0]   out_a_r;
  reg [data_size-1:0]   out_b_r;
  reg [2*data_size-1:0] out_c_r;
  
  always @(posedge clk or posedge rst)begin
    if(rst) begin
      out_a_r <= 0;
      out_b_r <= 0;
      out_c_r <= 0;
    end
    else begin
      out_a_r <= in_a;
      out_b_r <= in_b;
      out_c_r <= out_c + in_a * in_b;
    end
  end

  assign out_a = out_a_r;
  assign out_b = out_b_r;
  assign out_c = out_c_r[31:0];
 
endmodule