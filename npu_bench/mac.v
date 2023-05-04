`timescale 1ns / 100ps
module mac(clk, rst, in_a, in_b, out_a, out_b, out_c);

parameter data_size = 32;

input rst;
input clk;
input [data_size-1:0] in_a;
input [data_size-1:0] in_b;
output [data_size-1:0] out_c;
output reg [data_size-1:0] out_a;
output reg [data_size-1:0] out_b;

reg [2*data_size-1:0] out_c_r;

always @(posedge clk or posedge rst)begin
  if(rst) begin
    out_a <= 0;
    out_b <= 0;
    out_c_r <= 0;
  end
  else begin
    out_a <= in_a;
    out_b <= in_b;
    out_c_r <= out_c + in_a * in_b;
  end
end

assign out_c = out_c_r[31:0];
 
endmodule