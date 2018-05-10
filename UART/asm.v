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
module ASM(CLK, RxD_data_in_ready, c1, c2, c3, address_read, address_write, data_valid_out);
input CLK;
input RxD_data_in_ready;

output wire c1;
output wire c2;
output wire [1:0] c3;
output wire data_valid_out;
output wire [7:0] address_write;
output wire [7:0] address_read;

//=========================================================================================
//------- Create the mechanism to grab the serial data and parse it -----------------------
//=========================================================================================

// State Machine Variables
localparam ST_IDLE=0, ST_EXE=1, ST_STORE=2;
parameter UNITS_X = 2;
parameter UNITS_Y = 2;
parameter M_X = 3;
parameter M_Y = 3;
//localparam tend = M_X*M_Y + M_Y*(UNITS_X-1) + UNITS_X-1 + UNITS_Y-1 ;
localparam tend = (M_X + 1) * UNITS_X  + UNITS_Y - 2 ;

reg [2:0] PS=ST_IDLE;	//this is a register
reg [2:0] NS;	//this is the combinational output line driving the register.

// Data registers
reg data_valid_reg;

// Signals that will drive the Data registers
reg data_valid_sig;

// Internal Counter
integer counter = 0;
reg inc_index;	//increment flag
reg clr_index;	//clear flag

reg inc_add;	//increment flag
reg clr_add;	//clear flag

reg c1_sig;
reg c2_sig;
reg [1:0] c3_sig;

reg c1_reg = 1'b0;
reg c2_reg = 1'b0;
reg [1:0] c3_reg = 2'b0;

reg [7:0] address_sig = 0;

// Create a register block for the state variable
always @(posedge CLK) begin
	PS <= NS;
end

// Create a counter for the indexing of the output variable
always @(posedge CLK) begin
	if(clr_index)
		counter = 0;
	else if(inc_index)
		counter = counter + 1;
	else
		counter = counter;
end

always @(posedge CLK) begin
	if(clr_add)
		address_sig = 0;
	else if(inc_add)
		address_sig = address_sig + 1;
	else
		address_sig = address_sig;
end

// Create a register block for the outputs
always @(posedge CLK) begin
	data_valid_reg <= data_valid_sig;
	c1_reg = c1_sig;
	c2_reg = c2_sig;
	c3_reg = c3_sig;
end

// CREATE THE MECHNISM THAT PARSES THE SERIAL DATA
always @(RxD_data_in_ready, counter, PS, address_sig) begin	
	//set the default conditions
	data_valid_sig = 1'b0;
	inc_index = 1'b0;
	clr_index = 1'b0;
	inc_add = 1'b0;
	clr_add = 1'b0;
	c1_sig=1'b0;
	c2_sig=1'b0;
	c3_sig=2'b11;
			
	NS = PS;
	
	//the state machine combinational logic
	casex(PS)		
		//---------------------------------------------------------------------------------
		// 4'b1xxx: begin	//data is not valid, so we are just going to wait.
			// NS = PS;
		// end
		//---------------------------------------------------------------------------------
		ST_IDLE: begin 
			clr_index = 1'b1;
			if(RxD_data_in_ready==1)
				NS = ST_EXE;
			else
				NS = ST_IDLE;
		end
		//---------------------------------------------------------------------------------
		ST_EXE: begin
			inc_index = 1'b1;
			if(counter<tend)
			//if(counter<18)
				NS=ST_EXE;
			else begin
				NS=ST_STORE;
			c1_sig=1'b1;
			clr_index = 1'b1;
			end
		end
		//---------------------------------------------------------------------------------
		
		ST_STORE: begin
		data_valid_sig = 1'b1;
			inc_add = 1'b1;
			if(address_sig>=UNITS_Y-1) begin
				NS=ST_IDLE;
				clr_add = 1'b1;
				c3_sig = 2'b00;
				end
			else
				NS=ST_STORE;
		end	
		default: begin
			NS = ST_IDLE;
		end
	endcase		
end

//assign the outputs
assign data_valid_out = data_valid_sig;
assign c1 = c1_reg;
assign c2 = c2_reg;
assign c3 = c3_reg;
assign address_write = address_sig;
assign address_read = counter;

endmodule

/*
if(RxD_data_in==10)begin //LF: Line Feed, end of message, go to idle state					
				NS = ST_IDLE;
			end
			else begin	//valid data on the RxD_data_in line
				NS = ST_PARSE;				//stay in the current state
				if(CHAR_CNT>=6 && CHAR_CNT<=9)begin
					inc_index = 1'b1;
					time_sig[(12-index_counter) +: 4] = RxD_data_in-48;	//this is the time data.
				end
				else if(CHAR_CNT==10)begin
					clr_index = 1'b1;
					time_sig[(12-index_counter) +: 4] = RxD_data_in-48;	//this is the time data.
					data_valid_sig = 1'b1;
				end
				else begin //nothing important...just wait						
					data_valid_sig = 1'b0;
					inc_index = 1'b0;
					clr_index = 1'b0;					
				end
			end
			*/