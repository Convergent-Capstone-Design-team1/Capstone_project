`timescale  1ns / 100ps 
module tb_CPU();

	reg 	rst, clk;
	reg		start_switch;
	integer i;
	
  	TOPCPU CPU 
	(
		.clk(clk)						,
		.rst(rst)						,
		.start_switch(start_switch)
	);

	always #50 clk = ~clk;
	
	initial 
	begin
		$dumpfile("test.vcd");
		$dumpvars(0, tb_CPU);

		start_switch = 0;
		rst = 0;
		clk = 0;
		#150
		rst = 1;
		#500
		start_switch = 1;
		#50
		rst = 0;
		
		#55000
		rst = 1; 
		$finish;
	end

endmodule

