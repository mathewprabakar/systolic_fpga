`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Carrier Frequency, Inc.
// Engineer: 		Mathew Prabakar
// 
// Create Date:    20:03:42 05/31/2011 
// Design Name: 
// Module Name:    Serial_GPS 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module Tile(CLK, IP1, IP2, c1, c2, c3, OP1,OP2);

parameter Bitwidth = 16;

input CLK;
input c1;
input c2;
input [1:0] c3;

input [Bitwidth-1:0] IP1;
input [Bitwidth-1:0] IP2;

output [Bitwidth-1:0] OP1;
output [Bitwidth-1:0] OP2;
///////////////////////////////////////////////////////////

reg [Bitwidth-1:0] IP1_reg = 0;
reg [Bitwidth-1:0] IP2_reg = 0;

reg [Bitwidth-1:0] OP1_reg = 0;
reg [Bitwidth-1:0] OP2_reg = 0;

reg [Bitwidth-1:0] OP1_sig;
reg [Bitwidth-1:0] OP2_sig;
reg [Bitwidth-1:0] c_sig = 0;

reg [Bitwidth-1:0] OPALU_sig = 0;
reg [Bitwidth-1:0] OPALU_reg = 0;

///////////////////////////////////////////////////////////
always @(posedge CLK) begin
	IP1_reg <= IP1;
	IP2_reg <= IP2;
	
	OP1_reg <= IP1;
	OP2_reg <= IP2;

	OPALU_reg = (IP1_reg * IP2_reg) + c_sig;
end

always @(*) begin
	
	if(c1)
		OP1_sig = OPALU_reg;
	else
		OP1_sig = OP1_reg; 
		
	if(c2)
		OP2_sig = OPALU_reg;
	else
		OP2_sig = OP2_reg;
		
	case(c3)
		2'b00:c_sig = {Bitwidth{1'd0}};
		2'b01:c_sig = IP1_reg;
		2'b10:c_sig = IP2_reg;
		2'b11:c_sig = OPALU_reg;
		default: begin
			c_sig = {Bitwidth{1'd0}};
		end
	endcase
	
end

assign OP1 = OP1_sig;
assign OP2 = OP2_sig;

endmodule

