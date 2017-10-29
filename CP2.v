`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This is the wrapper module for the AES encryption.
// This is designed as a black box to be dropped in as 
// Co-Processor Two in the Main module.
// The AES as is only accepts a single 128bit block of data at a time. 
// -This wrapper will accept data in length up to N bytes
// -Data will be broken into blocks, processed one block at a time
// 		then returned as a whole to the main processor. 
//////////////////////////////////////////////////////////////////////////////////




module CP2(
	input         clk, rst,
	input         wrEn_cpu,
	input  [ 5:0] addr_cpu,
	input  [31:0] wrData_cpu,
	output [31:0] rdData_cpu,

	input         wrEn_dma
	input  [20:0] addr_dma, 
	input  [31:0] wrData_dma,
	output [31:0] rdData_dma,

	output 		  INT
	);

	// CPU interface/status reg    // 31 , 30,      29,     28,   27-25, ..., 15:0
	// [0] status		           // INT, go, 128/256, encDec, clkMult,  0 , words of data
	// [1] start address
	// [2] KEY_0
	// [3] KEY_1
	// [4] KEY_2
	// [5] KEY_3
	// [6] KEY_4
	// [7] KEY_5
	// [8] KEY_6
	// [9] KEY_7
	reg [31:0] reg_cpu [9:0];

	// internal registers; 64kB; each set forms a block
	reg [31:0] r00 [0:3999];
	reg [31:0] r01 [0:3999];
	reg [31:0] r02 [0:3999];
	reg [31:0] r03 [0:3999];

	// no CPU output if AES is running : Write Only for Key
	assign rdData_cpu = (!go && (addr_cpu<2)) ? reg_cpu[addr_cpu] : 0 ; 
	assign INT        = reg_cpu[0][31];						// INT bit

	always @ (posedge clk, posedge rst)begin
		if(rst) begin
			integer i;
			for(i=0; i<10; i=i+1)begin
				reg_cpu[i] = 0;
			end
			for(i=0; i<4000; i=i+1)begin
				r00[i] = 0;
				r01[i] = 0;
				r02[i] = 0;
				r03[i] = 0;
			end
		end // END rst
		else begin
			if(wrEn_cpu) reg_cpu[addr_cpu] = wrData_cpu;
		end
	end


	always @ (posedge reg_cpu[0][30])begin
		

	end // END GO















endmodule