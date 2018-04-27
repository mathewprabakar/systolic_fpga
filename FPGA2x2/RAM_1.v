module numramModule_1(clk,en,we,addr,di,do);
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
	RAM[0] = 4'd0;
	RAM[1] = 4'd1;
	RAM[2] = 4'd3;
	RAM[3] = 4'd0;
	RAM[4] = 4'd2;
	RAM[5] = 4'd4;
	RAM[6] = 4'd0;
	RAM[7] = 4'd0;
	RAM[8] = 4'd0;
	RAM[9] = 4'd0;
	RAM[10] = 4'd0;
	RAM[11] = 4'd0;
	RAM[12] = 4'd0;
	RAM[13] = 4'd0;
	RAM[14] = 4'd0;
	RAM[15] = 4'd0;
	
end

always@(posedge clk) begin
	if(en) begin
		if(we)
			RAM[addr]<=di;
		do<=RAM[addr];
	end
end
endmodule