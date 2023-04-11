`timescale  1ns / 100ps 
module tb_CPU();

	reg 	rst, clk;
	//reg		rst_switch;
	reg		start_switch;

	integer i;
	
  	TOPCPU CPU 
	(
		.clk(clk)	,
		.rst(rst)	
	);

	always #50 clk = ~clk;
	
	initial 
	begin
		$dumpfile("test.vcd");
		$dumpvars(0, tb_CPU);

		rst = 0;
		clk = 0;
		#150
		rst = 1;
		#50
		rst = 0;
		
		#55000
		rst = 1; 
		$finish;
	end

endmodule

