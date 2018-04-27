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

module tb_Top;
parameter Bitwidth = 16;
parameter UNITS_X = 2;
parameter UNITS_Y = 2;
parameter M_X = 3;
parameter M_Y = 3;
parameter IP1_Width = Bitwidth * UNITS_X;
parameter IP2_Width = Bitwidth * UNITS_Y;

	wire [IP1_Width-1:0] OP1;
	wire [IP2_Width-1:0] OP2;
	
	integer counter = -1;
	integer t;
	reg [Bitwidth-1:0] temp = 0;
	
	reg clk;
	always #5 clk <= ~clk;

	reg [IP1_Width-1:0] IP1 = 0;
	reg [IP2_Width-1:0] IP2 = 0;
	reg READY =0;

	// DUT instantiation
	//Top#(.Bitwidth(Bitwidth),.UNITS_X(UNITS_X),.UNITS_Y(UNITS_Y)) uut (.CLK(clk), .READY(READY), .IP1(IP1), .IP2(IP2), .OP1(OP1),.OP2(OP2));
      Top#(.Bitwidth(Bitwidth),.UNITS_X(UNITS_X),.UNITS_Y(UNITS_Y)) uut (.CLK(clk), .READY(READY), .SW(8'h00) );//, LED, CA,CB,CC,CD,CE,CF,CG,DP,AN);
integer fileop;

	//Initializing Variables
	initial
	begin
		clk = 0;
		fileop = $fopen("Input.txt","r");

	end
	
	always @(posedge clk) begin
		counter = counter+1;
		end
	
	always @(posedge clk) begin
		if(counter > 10) begin
			READY = 1'b1;
			
		if (!$feof(fileop)) 
		begin
		temp = 0;
			for(t=0;t<UNITS_X;t=t+1) begin
				$fscanf(fileop,"%d",temp);
				IP2[Bitwidth*(UNITS_X-t-1)+:Bitwidth]=temp;
			end	
		temp = 0;
			for(t=0;t<UNITS_Y;t=t+1) begin
				$fscanf(fileop,"%d",temp);
				IP1[Bitwidth*(UNITS_Y-t-1)+:Bitwidth]=temp;
			end	
		end
		
		else begin
			IP1 = {IP1_Width{1'b0}};
			IP2 = {IP2_Width{1'b0}};
			if(counter>50)
			$stop;
		end
		
		end
	end	
	
endmodule