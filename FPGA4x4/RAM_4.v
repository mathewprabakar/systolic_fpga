module numramModule_4(clk,en,we,addr,di,do);
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
	RAM[1] =  16'd0;
	RAM[2] =  16'd0;
	RAM[3] =  16'd9;
	RAM[4] =  16'd13;
	RAM[5] =  16'd0;
	RAM[6] =  16'd10;
	RAM[7] =  16'd14;
	RAM[8] =  16'd0;
	RAM[9] =  16'd11;
	RAM[10] = 16'd15;
	RAM[11] = 16'd0;
	RAM[12] = 16'd12;
	RAM[13] = 16'd16;
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