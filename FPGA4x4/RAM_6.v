module numramModule_6(clk,en,we,addr,di,do);
parameter Output_width = 16;
parameter Address_width = 4;
parameter Length = 16;
input clk;
input we;
input en;
input[Address_width-1:0]addr;
input[15:0]di;

output[Output_width-1:0]do;

reg[Output_width-1:0] RAM[Length-1:0];
reg[Output_width-1:0] do;

initial begin
	RAM[0] =  16'd0;
	RAM[1] =  16'd1;
	RAM[2] =  16'd4;
	RAM[3] =  16'd7;
	RAM[4] =  16'd2;
	RAM[5] =  16'd5;
	RAM[6] =  16'd8;
	RAM[7] =  16'd3;
	RAM[8] =  16'd6;
	RAM[9] =  16'd9;
	RAM[10] = 16'd0;
	RAM[11] = 16'd0;
	RAM[12] = 16'd0;
	RAM[13] = 16'd0;
	RAM[14] = 16'd0;
	RAM[15] = 16'd0;
	
end

always@(posedge clk) begin
	if(en) begin
		if(we)
			RAM[addr]<=di;
		do<=RAM[addr];
	end
end
endmodule