`timescale 1ns / 1ps
//-----------------------------------------------------
// Engineer: Mathew Prabakar
// Overview
//  A testbench to test 16QAM demodulator
//	16QAM data into Symbols.
// Design Name:   tb_HW3
// File Name:     tb_HW3.v
//
// Stimuli: 
//		inphase: the I input signal from the IQ demodulator
//		quad: the Q input signal from the IQ demodulator
// Monitor: 
//		symbol: The decoded output symbol
//
// History:       22 Jan. 2018, Mathew Prabakar, File Created
//
//-----------------------------------------------------

module tb_asm;
	integer counter = -1;
	integer t;
	
	reg clk;
	always #5 clk <= ~clk;

	// DUT instantiation
	ASM uut(.CLK(clk), .RxD_data_in_ready(1));//, .c1, c2, c3, data_valid_out);
	
	//Initializing Variables
	initial
	begin
		clk = 0;
	end
	
	always @(posedge clk) begin
		counter = counter+1;
		end
	
	always @(posedge counter) begin
			if(counter>45)
			$stop;
		end	
	
endmodule