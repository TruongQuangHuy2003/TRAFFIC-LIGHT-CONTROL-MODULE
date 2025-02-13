`timescale 1ns/1ps
module test_bench;
	reg clk;
    	reg rst_n;
	reg [3:0] time_slot;
	reg sensor_car;
	reg sensor_pedestrian;
	reg emergency;
	wire [2:0] light_NS;
	wire [2:0] light_EW;
	wire pedestrian_signal;

	top dut(.*);

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	task verify;
		input [2:0] exp_light_NS;
		input [2:0] exp_light_EW;
		input exp_pedestrian_signal;
		begin
			$display("At time: %t, rst_n = 1'b%b, time_slot = 4'h%h, sensor_car = 1'b%b,  sensor_pedestrian = 1'b%b, emergency = 1'b%b", $time, rst_n, time_slot, sensor_car, sensor_pedestrian, emergency);
			if( light_NS == exp_light_NS && light_EW === exp_light_EW && pedestrian_signal == exp_pedestrian_signal) begin
				$display("------------------------------------------------------------------------------------------------------------------------");
				$display("PASSED: Expected Light_NS = 3'b%b, Got Light_NS = 3'b%b, Expected Ligh_EW = 3'b%b, Got Light_EW = 3'b%b, Expected pedestrian_signal = 1'b%b, Got pedestrian_signal = 1'b%b", exp_light_NS, light_NS, exp_light_EW, light_EW, exp_pedestrian_signal, pedestrian_signal);
				$display("------------------------------------------------------------------------------------------------------------------------");
			end else begin
				$display("------------------------------------------------------------------------------------------------------------------------");
				$display("FAILED: Expected Light_NS = 3'b%b, Got Light_NS = 3'b%b, Expected Ligh_EW = 3'b%b, Got Light_EW = 3'b%b, Expected pedestrian_signal = 1'b%b, Got pedestrian_signal = 1'b%b", exp_light_NS, light_NS, exp_light_EW, light_EW, exp_pedestrian_signal, pedestrian_signal);
				$display("------------------------------------------------------------------------------------------------------------------------");
			end
		end
	endtask

	initial begin
		$dumpfile("test_bench.vcd");
		$dumpvars(0, test_bench);
	
		$display("---------------------------------------------------------------------------------------------------------------------------------");	
		$display("------------------------------------TESTBENCH FOR TRAFFIC LIGHT CONTROL MODULE---------------------------------------------------");	
		$display("---------------------------------------------------------------------------------------------------------------------------------");

		rst_n = 0;
		time_slot = 3'b100;
		sensor_car = 1;
		sensor_pedestrian = 1;
		emergency = 1;
		@(posedge clk);
		verify(3'b100, 3'b100, 0);

		rst_n = 1;
		time_slot = 3'b100;
		sensor_car = 1;
		sensor_pedestrian = 0;
		emergency = 1;
		repeat(time_slot) @(posedge clk);
		verify(3'b100, 3'b100, 0);

		sensor_car = 0;
		sensor_pedestrian = 1; 
		emergency = 0;
		repeat (time_slot)@(posedge clk);
		verify(3'b100, 3'b100, 1);

		sensor_car = 1;
		sensor_pedestrian = 0;
		repeat (time_slot) @(posedge clk);
		verify(3'b001, 3'b100, 0);
		repeat(time_slot+1) @(posedge clk);
		verify(3'b010, 3'b100, 0);
		repeat(3) @(posedge clk);
		verify(3'b100, 3'b001, 0);
		repeat(time_slot+1) @(posedge clk);
		verify(3'b100, 3'b010, 0);
		
		#100;
		$finish;
	end
endmodule

