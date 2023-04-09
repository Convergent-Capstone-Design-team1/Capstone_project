`timescale  1ps / 100fs 
module tb_Vr_CPU();

	reg rst, clk;
	integer i;
	
  	Vr_TopCPU U0 (rst, clk);

	always #50 clk = ~clk;

	initial begin
		
		$dumpfile("test.vcd");
		$dumpvars(0, tb_Vr_CPU);

		rst = 1;
		clk = 0;
		#100
		rst = 0;
		
		#200000
		rst = 1; 
		$finish;
	end
endmodule

