

module Top(CLK, UART_TXD_IN, UART_RXD_OUT, LED, CA,CB,CC,CD,CE,CF,CG,DP,AN,BTNC);

input wire CLK;
input wire UART_TXD_IN;
input wire BTNC;
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

parameter M_X = 2;
parameter M_Y = 2;

parameter depth = (M_X + 1) * UNITS_X  -1 ;
parameter add_width = $clog2(depth);
parameter nbanks = $clog2(UNITS_Y+UNITS_Y);

wire [7:0] TDATA;
wire [7:0] RDATA;
wire RVALID;

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

wire [3:0] BCD_R [4:0];
assign BCD_R[4] = 4'h20;

reg [add_width+nbanks-1:0] address = 8'd0;
reg [add_width+nbanks-1:0] r_address = 8'd0;
reg [2:0] smallcounter = 3'd0;
reg clr_sig;
reg inc_sig;
reg sub_sig;
reg b_inc;
reg b_clr;
wire butout;

wire [UNITS_X + UNITS_Y - 1:0] decoded;
wire [UNITS_X + UNITS_Y - 1:0] r_decoded;

localparam ST_IDLE=0, ST_SEND=1, ST_HOLD=2, ST_START=3, ST_BOUNCE=4, ST_TRANS=5;//, ST_VALID=6;
	reg [2:0] PS = ST_IDLE;
	reg [2:0] NS;
	
   //assign LED = MET;
   assign LED[3:0] = r_address [3:0];
   assign LED[7:4] = address [4:0];
   assign TDATA = TEMP;
   
txuart mytx(.i_clk(CLK), .i_reset(0), .i_setup(32'h000364), .i_break(0), .i_wr(TVALID), .i_data(TDATA),
		.i_cts_n(0), .o_uart_tx(UART_RXD_OUT), .o_busy(TBUSY) );
	
rxuart myrx(.i_clk(CLK), .i_reset(0), .i_setup(32'h000364), .i_uart_rx(UART_TXD_IN), .o_wr(RVALID), .o_data(RDATA), .o_break(),
			.o_parity_err(), .o_frame_err(), .o_ck_uart());

genvar k;
	for(k=0;k<UNITS_X + UNITS_Y;k=k+1) begin
	
blk_mem_gen_0 U (
  .clka(CLK),    // input wire clka
  .ena(decoded[k]),      // input wire ena
  .wea(RVALID),      // input wire [0 : 0] wea
  .addra(address[add_width+nbanks-1:nbanks]),  // input wire [3 : 0] addra
  .dina(RDATA),    // input wire [15 : 0] dina
  .clkb(CLK),    // input wire clkb
  .enb(r_decoded[k]),      // input wire enb
  .addrb(r_address[add_width+nbanks-1:nbanks]),  // input wire [3 : 0] addrb
  .doutb(RAM[k])  // output wire [15 : 0] doutb
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
   BCD#(.bitwidth(8)) myBCD(.binary(RAM[r_address[nbanks-1:0]]-8'd48), .Thousands(BCD_R[0]), .Hundreds(BCD_R[1]), .Tens(BCD_R[2]), .Ones(BCD_R[3]));
   
   	assign decoded = (1<<address[nbanks-1:0]);
	assign r_decoded = (1<<r_address[nbanks-1:0]);

sevenseg myseg(.clock(CLK), .reset(0),.in0(BCD_R[3]), .in1(BCD_R[2]), .in2(BCD_R[1]), .in3(BCD_R[0]), .a(CA), .b(CB), .c(CC), .d(CD), .e(CE), .f(CF), .g(CG), .dp(DP), .an(AN) );

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
		
		if(address > 15)
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
	else if(sub_sig)
		r_address = r_address - 8'd1;
	else
		r_address = r_address;
	end
	
	always@(posedge CLK) begin
		if(b_clr)
			smallcounter = 3'd0;
		else if(b_inc)
			smallcounter = smallcounter +3'd1;
		else
			smallcounter = smallcounter;
	end
	
   always @(BTNC,PS,TBUSY,r_address) begin	
	
	NS = PS;
	TVALID = 1'b0;
	inc_sig = 1'b0;
	clr_sig = 1'b0;
	sub_sig = 1'b0;
	b_inc = 1'b0;
	b_clr = 1'b0;
	
	casex(PS)		
		//---------------------------------------------------------------------------------
		ST_IDLE: begin 
		clr_sig = 1'b1;
		b_clr = 1'b1;
		
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
				NS = ST_TRANS;
		end
		ST_TRANS: begin
			if(smallcounter == 3'd5) begin
				NS = ST_START;
				inc_sig = 1'b1;
				b_clr = 1'b1;
				end
			else if(smallcounter == 3'd3) begin
				NS = ST_SEND;
				end
			else if(BCD_R[smallcounter] == 4'd0)begin
				NS = ST_TRANS;
				b_inc = 1'b1;
				end
			else
				NS = ST_SEND;
				
		end
		
		ST_SEND: begin 

			//TEMP = RAM[r_address[nbanks-1:0]];
			TEMP = BCD_R[smallcounter] + 8'd48;
			//TEMP = 8'h41;
			TVALID = 1'b1;
			NS = ST_HOLD;
		end

		ST_HOLD: begin 			
			if(TBUSY)
				NS = ST_HOLD;
			else begin
				NS = ST_TRANS;
				b_inc = 1'b1;
			end
		end		
	
		default: begin
			NS = ST_IDLE;
		end
	endcase		
end

   
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