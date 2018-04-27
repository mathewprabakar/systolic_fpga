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
//module Top(CLK, READY, IP1, IP2, OP1,OP2);
module Top(CLK, BTNC, SW, LED, CA,CB,CC,CD,CE,CF,CG,DP,AN);
parameter UNITS_X = 4;
parameter UNITS_Y = 4;
parameter Bitwidth = 16;
localparam IP1_Width = Bitwidth * UNITS_X;
localparam IP2_Width = Bitwidth * UNITS_Y;

input CLK;
input [7:0] SW;
output [4:0] LED;

output CA;
output CB;
output CC;
output CD;
output CE;
output CF;
output CG;
output DP;
output [3:0] AN;

input wire BTNC;
wire READY = BTNC ;

wire [IP1_Width -1:0] IP1 ;
wire [IP1_Width -1:0] IP2 ;

wire [IP1_Width -1:0] OP1;
wire [IP1_Width -1:0] OP2;
///////////////////////////////////////////////////////////

wire [Bitwidth -1:0] Weights [(UNITS_X)-1:0];
wire [Bitwidth -1:0] Input   [(UNITS_Y)-1:0];

wire [Bitwidth -1:0] DISP [(UNITS_X)-1:0];
wire [Bitwidth -1:0] myop;

wire c1;
wire c2;
wire [1:0] c3;

reg [Bitwidth-1:0] RESULT [(UNITS_X*UNITS_Y)-1:0];

wire [3:0] TH;
wire [3:0] H;
wire [3:0] T;
wire [3:0] O;

//reg ready_sig = 0;
//reg [3:0] ready_counter = 0;
reg myCLK = 0;
wire d_valid;
wire [7:0] address;
wire [7:0] counter;
wire [3:0] outp;
//reg [7:0] temp = 0;

wire [Bitwidth -1:0] HOR [(UNITS_X*UNITS_Y)-1:0];
wire [Bitwidth -1:0] VER [(UNITS_X*UNITS_Y)-1:0];
//////////////////////////////////////////////////////////
always @ * myCLK = CLK && READY;
// always @(posedge CLK) begin
	// if(ready_counter>5)
		// ready_sig = 1'b1;
	// else begin
		// ready_counter = ready_counter + 1 ;
		// ready_sig = 1'b0;
	// end
// end
//////////////////////////////////////////////////////////

integer ID = 0;
integer y = 0;
ASM#(.UNITS_X(UNITS_X),.UNITS_Y(UNITS_Y)) my_asm(.CLK(myCLK), .RxD_data_in_ready(1), .c1(c1), .c2(c2), .c3(c3),.address_write(address), .address_read(counter), .data_valid_out(d_valid));
/////////////////////////////////////////////////////////

genvar i,j;

generate
  for (i=0; i < UNITS_X; i=i+1) begin 
	for (j=0; j < UNITS_Y; j=j+1) begin 
     
	 //ID = i*UNITS_X+j;
	 
	 if( (i==0) && (j==0) )
		Tile#(.Bitwidth(Bitwidth)) U (.CLK(myCLK), .IP1(Weights[j]), .IP2(Input[i]), .c1(c1), .c2(c2), .c3(c3), .OP1(VER[i*UNITS_X+j]),.OP2(HOR[i*UNITS_X+j]) );
	 else if (i==0)
		Tile#(.Bitwidth(Bitwidth)) U (.CLK(myCLK), .IP1(Weights[j]), .IP2(HOR[i*UNITS_X+j-1]), .c1(c1), .c2(c2), .c3(c3), .OP1(VER[i*UNITS_X+j]),.OP2(HOR[i*UNITS_X+j]) );
	 else if (j==0)
		Tile#(.Bitwidth(Bitwidth)) U (.CLK(myCLK), .IP1(VER[(i-1)*UNITS_X+j]), .IP2(Input[i]), .c1(c1), .c2(c2), .c3(c3), .OP1(VER[i*UNITS_X+j]),.OP2(HOR[i*UNITS_X+j]) );
	 else
		Tile#(.Bitwidth(Bitwidth)) U (.CLK(myCLK), .IP1(VER[(i-1)*UNITS_X+j]), .IP2(HOR[i*UNITS_X+j-1]), .c1(c1), .c2(c2), .c3(c3), .OP1(VER[i*UNITS_X+j]),.OP2(HOR[i*UNITS_X+j]) );
	 
	end
  end
endgenerate

/////////////////////////////////////////////////////////

numramModule_1 ip1(.clk(CLK),.en(1),.we(0),.addr(counter),.do(Input[0]));
numramModule_2 ip2(.clk(CLK),.en(1),.we(0),.addr(counter),.do(Input[1]));

numramModule_3 ip3(.clk(CLK),.en(1),.we(0),.addr(counter),.do(Input[2]));
numramModule_4 ip4(.clk(CLK),.en(1),.we(0),.addr(counter),.do(Input[3]));

numramModule_5 wt1(.clk(CLK),.en(1),.we(0),.addr(counter),.do(Weights[0]));
numramModule_6 wt2(.clk(CLK),.en(1),.we(0),.addr(counter),.do(Weights[1]));

numramModule_7 wt3(.clk(CLK),.en(1),.we(0),.addr(counter),.do(Weights[2]));
numramModule_8 wt4(.clk(CLK),.en(1),.we(0),.addr(counter),.do(Weights[3]));

//numramModule_1(.clk(CLK),.en(1),.we(0),.addr(address),.di(VER[(UNITS_Y-1)*UNITS_X+0]),.do(DISP[0]) );
//numramModule_1(.clk(CLK),.en(1),.we(0),.addr(address),.di(VER[(UNITS_Y-1)*UNITS_X+1]),.do(DISP[1]) );

genvar k;
	for(k=0;k<UNITS_X;k=k+1) begin
	v_rams_01_1 R(.clka(CLK), .clkb(CLK), .ena(1), .enb(1), .wea(d_valid), .addra(UNITS_Y-1-address), .addrb(SW[7:4]), .dia(VER[(UNITS_Y-1)*UNITS_X+k])/*, .doa()*/, .dob(OP1[Bitwidth*(UNITS_X-k-1)+:Bitwidth]) );
end

//v_rams_01_1 ram1(.clka(CLK), .clkb(CLK), .ena(1), .enb(1), .wea(d_valid), .addra(UNITS_Y-1-address), .addrb(SW[7:4]), .dia(VER[(UNITS_Y-1)*UNITS_X+0])/*, .doa()*/, .dob(OP1[Bitwidth*(UNITS_X-0-1)+:Bitwidth]) );
//v_rams_01_1 ram2(.clka(CLK), .clkb(CLK), .ena(1), .enb(1), .wea(d_valid), .addra(UNITS_Y-1-address), .addrb(SW[7:4]), .dia(VER[(UNITS_Y-1)*UNITS_X+1])/*, .doa()*/, .dob(OP1[Bitwidth*(UNITS_X-1-1)+:Bitwidth]) );

/*
genvar k;
	for(k=0;k<UNITS_X;k=k+1) begin		
		//assign Weights[k]=IP1[Bitwidth*(UNITS_X-k-1)+:Bitwidth];
		//assign Input[k]  =IP2[Bitwidth*(UNITS_X-k-1)+:Bitwidth];

		//assign OP1[Bitwidth*(UNITS_X-k-1)+:Bitwidth]=VER[(UNITS_Y-1)*UNITS_X+k];
		assign OP2[Bitwidth*(UNITS_X-k-1)+:Bitwidth]=HOR[(UNITS_X-1)+UNITS_X*k];
	end

	//assign Result = {VER[2],VER[3]};

//////////////////////////////////////////////////////////
//Tile T1(.CLK(CLK), .IP1(Weights[0]), .IP2(Input[0]), .c1(c1), .c2(c2), .OP1(VER[0]),.OP2(HOR[0]) );
//Tile T2(.CLK(CLK), .IP1(Weights[1]), .IP2(HOR[0]), .c1(c1), .c2(c2), .OP1(VER[1]),.OP2(HOR[1]) );
//Tile T3(.CLK(CLK), .IP1(VER[0]), .IP2(Input[1]), .c1(c1), .c2(c2), .OP1(VER[2]),.OP2(HOR[2]) );
//Tile T4(.CLK(CLK), .IP1(VER[1]), .IP2(HOR[2]), .c1(c1), .c2(c2), .OP1(VER[3]),.OP2(HOR[3]) );
//////////////////////////////////////////////////////////
		
always @(posedge CLK) begin		
	if(d_valid) begin
	//temp = address*UNITS_X;

		for(y=0;y<UNITS_X;y=y+1) begin
		RESULT[ (UNITS_Y-1-address)*UNITS_X +y] = VER[(UNITS_Y-1)*UNITS_X+y];
		end
		
		//RESULT[ (UNITS_Y-1-address)*UNITS_X +0] = VER[(UNITS_Y-1)*UNITS_X+0];
		//RESULT[ (UNITS_Y-1-address)*UNITS_X +1] = VER[(UNITS_Y-1)*UNITS_X+1];
		//RESULT[ (UNITS_Y-1-address)*UNITS_X +2] = VER[(UNITS_Y-1)*UNITS_X+2];
		//RESULT[ (UNITS_Y-1-address)*UNITS_X +3] = VER[(UNITS_Y-1)*UNITS_X+3];
	end
		
end
*/

//numramModule#(.Output_width(4)) myram(.clk(CLK),.en(1),.we(0),.addr(SW[3:0]),.do(outp));

assign myop = OP1[Bitwidth*(UNITS_X-SW[3:0]-1)+:Bitwidth];
BCD myBCD(.binary(myop), .Thousands(TH), .Hundreds(H), .Tens(T), .Ones(O));

sevenseg myseg(.clock(CLK), .reset(0),.in0(O), .in1(T), .in2(H), .in3(TH), .a(CA), .b(CB), .c(CC), .d(CD), .e(CE), .f(CF), .g(CG), .dp(DP), .an(AN) );
 
    //reg[3:0] counter = 4'd0;
	integer hit;
	assign LED[0] = hit[28];
    //assign LED[0] = outp[0];
	/*assign LED[1] = outp[1];
	assign LED[2] = outp[2];
	assign LED[3] = outp[3];
	assign LED[4] = hit[28];*/
    always @ (posedge CLK) begin
		hit = hit + 1;
		end   
    
endmodule

