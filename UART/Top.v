

module Top(CLK, BTNU, UART_TXD_IN, UART_RXD_OUT, LED, CA,CB,CC,CD,CE,CF,CG,DP,AN,BTNC,SW);//, RDATA, RVALID);

input wire CLK;
input wire UART_TXD_IN;
input wire BTNC;
input wire BTNU;
input [7:0] SW;

output wire UART_RXD_OUT;
output wire [7:0] LED;

output wire CA;
output wire CB;
output wire CC;
output wire CD;
output wire CE;
output wire CF;
output wire CG;
output wire DP;
output wire [7:0] AN;

parameter UNITS_X = 2;
parameter UNITS_Y = 2;

parameter M_X = 3;
parameter M_Y = 3;

parameter depth = (M_X + 1) * UNITS_X  -1 ;
parameter add_width = $clog2(depth);
parameter nbanks = $clog2(UNITS_Y+UNITS_Y);
parameter Bitwidth = 8;
parameter IP1_Width = Bitwidth * UNITS_X;

wire [7:0] RDATA;
wire RVALID;

wire [Bitwidth -1:0] Weights [(UNITS_X)-1:0];
wire [Bitwidth -1:0] Input   [(UNITS_Y)-1:0];

wire [7:0] TDATA;

reg [7:0] MEM;
reg [7:0] MET;
wire [7:0] RAM[3:0];

wire TBUSY;
wire TDONE;
reg TVALID = 1'd0;
reg [7:0] TEMP;

wire [3:0] TH;
wire [3:0] H;
wire [3:0] T;
wire [3:0] O;

wire [IP1_Width -1:0] OP1;
wire [Bitwidth -1:0] myop;

reg [add_width+nbanks-1:0] address = 8'd0;
reg [add_width+nbanks-1:0] r_address = 8'd0;
reg clr_sig;
reg inc_sig;
wire butout;

wire [UNITS_X + UNITS_Y - 1:0] decoded;
wire [UNITS_X + UNITS_Y - 1:0] r_decoded;
wire d_valid;


wire [Bitwidth -1:0] HOR [(UNITS_X*UNITS_Y)-1:0];
wire [Bitwidth -1:0] VER [(UNITS_X*UNITS_Y)-1:0];
wire [add_width+nbanks-1:0] mr_address;
wire [add_width+nbanks-1:0] wr_address;
reg myCLK = 0;

wire c1;
wire c2;
wire [1:0] c3;


localparam ST_IDLE=0, ST_SEND=1, ST_HOLD=2, ST_START=3, ST_BOUNCE=4;//, ST_HSBP=5, ST_VALID=6;
	reg [2:0] PS = ST_IDLE;
	reg [2:0] NS;
	
   //assign LED = MET;
   //assign LED[3:0] = r_address [3:0];
   assign LED[7:0] = address;
   assign TDATA = TEMP;
   
txuart mytx(.i_clk(CLK), .i_reset(0), .i_setup(32'h000364), .i_break(0), .i_wr(TVALID), .i_data(TDATA),
		.i_cts_n(0), .o_uart_tx(UART_RXD_OUT), .o_busy(TBUSY) );
	
rxuart myrx(.i_clk(CLK), .i_reset(0), .i_setup(32'h000364), .i_uart_rx(UART_TXD_IN), .o_wr(RVALID), .o_data(RDATA), .o_break(),
			.o_parity_err(), .o_frame_err(), .o_ck_uart());

/*
genvar k;
	for(k=0;k<UNITS_Y;k=k+1) begin
	v_rams_01_1 R(.clka(CLK), .clkb(CLK), .ena(decoded[k]), .enb(1), .wea(RVALID), .addra(address[add_width+nbanks-1:nbanks]), .addrb(mr_address), .dia(RDATA), .dob(Input[k]) );
end

	for(k=UNITS_Y;k<UNITS_X+UNITS_Y;k=k+1) begin
	v_rams_01_1 R(.clka(CLK), .clkb(CLK), .ena(decoded[k]), .enb(1), .wea(RVALID), .addra(address[add_width+nbanks-1:nbanks]), .addrb(mr_address), .dia(RDATA), .dob(Weights[k-UNITS_Y]) );
end
*/

genvar k;
	for(k=0;k<UNITS_Y;k=k+1) begin
	
blk_mem_gen_0 U (
  .clka(CLK),    // input wire clka
  .ena(decoded[k]),      // input wire ena
  .wea(RVALID),      // input wire [0 : 0] wea
  .addra(address[add_width+nbanks-1:nbanks]),  // input wire [3 : 0] addra
  .dina(RDATA-8'd48),    // input wire [15 : 0] dina
  .clkb(CLK),    // input wire clkb
  .enb(1),      // input wire enb
  .addrb(mr_address),  // input wire [3 : 0] addrb
  .doutb(Input[k])  // output wire [15 : 0] doutb
);

end

	for(k=UNITS_Y;k<UNITS_X + UNITS_Y;k=k+1) begin
	
blk_mem_gen_0 V (
  .clka(CLK),    // input wire clka
  .ena(decoded[k]),      // input wire ena
  .wea(RVALID),      // input wire [0 : 0] wea
  .addra(address[add_width+nbanks-1:nbanks]),  // input wire [3 : 0] addra
  .dina(RDATA-8'd48),    // input wire [15 : 0] dina
  .clkb(CLK),    // input wire clkb
  .enb(1),      // input wire enb
  .addrb(mr_address),  // input wire [3 : 0] addrb
  .doutb(Weights[k-UNITS_Y])  // output wire [15 : 0] doutb
);

end


/*			
blk_mem_gen_0 myram2 (
  .clka(CLK),    // input wire clka
  .ena(address[0]),      // input wire ena
  .wea(RVALID),      // input wire [0 : 0] wea
  .addra(address[7:1]),  // input wire [3 : 0] addra
  .dina(RDATA),    // input wire [15 : 0] dina
  .clkb(CLK),    // input wire clkb
  .enb(r_address[0]),      // input wire enb
  .addrb(r_address[7:1]),  // input wire [3 : 0] addrb
  .doutb(RAM)  // output wire [15 : 0] doutb
);
	*/		
   //BCD#(.bitwidth(8)) myBCD(.binary(RAM[r_address[nbanks-1:0]]), .Thousands(TH), .Hundreds(H), .Tens(T), .Ones(O));
   BCD#(.bitwidth(8)) myBCD(.binary(myop), .Thousands(TH), .Hundreds(H), .Tens(T), .Ones(O));
   
   	assign decoded = (1<<address[nbanks-1:0]);
	assign r_decoded = (1<<r_address[nbanks-1:0]);

sevenseg myseg(.clock(CLK), .reset(0),.in0(O), .in1(T), .in2(H), .in3(TH), .a(CA), .b(CB), .c(CC), .d(CD), .e(CE), .f(CF), .g(CG), .dp(DP), .an(AN) );

/*
DeBounce deb 
	(
	.clk(CLK), .n_reset(1), .button_in(BTNC),				// inputs
 	.DB_out(butout)													// output
	);
*/

   always@(posedge CLK) begin
	if(RVALID) begin
		MEM = RDATA;
		address = address + 1; 
		
		if(address > depth*(UNITS_X+UNITS_Y) )
			address = 0;
		else
			address = address;
			
		end
	else
		MEM = MEM;
   end
   
   always @(posedge CLK) begin
	PS <= NS;
end
  
    always@(posedge CLK) begin
	if(clr_sig)
		r_address = 8'd0;
	else if(inc_sig)
		r_address = r_address + 8'd1;
	else
		r_address = r_address;
	end
	
   always @(BTNC,PS,TBUSY,r_address) begin	
	
	NS = PS;
	TVALID = 1'b0;
	inc_sig = 1'b0;
	clr_sig = 1'b0;
	
	casex(PS)		
		//---------------------------------------------------------------------------------
		ST_IDLE: begin 
		clr_sig = 1'b1;
		
			if(BTNC)
			//if(RVALID) begin
				NS = ST_START;
			else
				NS = ST_IDLE;
		end
	
		ST_BOUNCE: begin 
			if(BTNC==1'b0)
				NS = ST_IDLE;
			else
				NS = ST_BOUNCE;
		end
			
		ST_START: begin 
			if(r_address > 8'd15)
				NS = ST_BOUNCE;
			else
				NS = ST_SEND;
		end
		
		ST_SEND: begin 

			TEMP = RAM[r_address[nbanks-1:0]];
			//TEMP = 8'h41;
			TVALID = 1'b1;
			NS = ST_HOLD;
		end

		ST_HOLD: begin 			
			if(TBUSY)
				NS = ST_HOLD;
			else begin
				NS = ST_START;
				inc_sig = 1'b1;
			end
		end		
	
		default: begin
			NS = ST_IDLE;
		end
	endcase		
end

always @ * myCLK = CLK && BTNU;

integer ID = 0;
integer y = 0;
ASM#(.UNITS_X(UNITS_X),.UNITS_Y(UNITS_Y)) my_asm(.CLK(myCLK), .RxD_data_in_ready(1), .c1(c1), .c2(c2), .c3(c3),.address_write(wr_address), .address_read(mr_address), .data_valid_out(d_valid));
/////////////////////////////////////////////////////////

	for(k=0;k<UNITS_X;k=k+1) begin
	//v_rams_01_1 T(.clka(CLK), .clkb(CLK), .ena(1), .enb(1), .wea(d_valid), .addra(UNITS_Y-1-wr_address), .dia(VER[(UNITS_Y-1)*UNITS_X+k]),.addrb(SW[7:4]), .dob(OP1[Bitwidth*(UNITS_X-k-1)+:Bitwidth]) );

	blk_mem_gen_0 V (
  .clka(CLK),    // input wire clka
  .ena(1),      // input wire ena
  .wea(d_valid),      // input wire [0 : 0] wea
  .addra(UNITS_Y-1-wr_address),  // input wire [3 : 0] addra
  .dina(VER[(UNITS_Y-1)*UNITS_X+k]),    // input wire [15 : 0] dina
  .clkb(CLK),    // input wire clkb
  .enb(1),      // input wire enb
  .addrb(SW[7:4]),  // input wire [3 : 0] addrb
  .doutb(OP1[Bitwidth*(UNITS_X-k-1)+:Bitwidth])  // output wire [15 : 0] doutb
);

	end

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
assign myop = OP1[Bitwidth*(UNITS_X-SW[3:0]-1)+:Bitwidth];
   
endmodule
/*
uart_rx my_rx
  #(.CLKS_PER_BIT(87))
  (
   input        .i_Clock(CLK),
   input        .i_Rx_Serial(UART_RXD_OUT),
   output       .o_Rx_DV(RVALID),
   output [7:0] .o_Rx_Byte(RDATA)
   );
   
   uart_tx my_tx 
  #(.CLKS_PER_BIT(87))
  (
   input       .i_Clock(CLK),
   input       .i_Tx_DV(TVALID),
   input [7:0] .i_Tx_Byte(TDATA), 
   output      .o_Tx_Active(TBUSY),
   output reg  .o_Tx_Serial(UART_TXD_IN),
   output      .o_Tx_Done(TDONE)
   );
   */