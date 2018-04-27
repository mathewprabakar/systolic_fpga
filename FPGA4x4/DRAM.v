module v_rams_01_1 (clka, clkb, ena, enb, wea, addra, addrb, dia, doa, dob);
parameter Output_width = 16;
parameter Address_width = 4;
parameter Length = 16;

	input clka, clkb;
	input wea;
	input ena, enb;
	input [Address_width-1:0] addra, addrb;
	input [15:0] dia;
	output [Output_width-1:0] doa, dob;
	reg [Output_width-1:0] RAM [Length-1:0];
	reg [Output_width-1:0] doa, dob;
	
	always @(posedge clka)
	begin
		if (ena)
		begin
			if (wea)
				RAM[addra]<=dia;
			doa <= RAM[addra];
		end
	end
		
	always @(posedge clkb)
	begin
		if (enb)
		begin
			dob <= RAM[addrb];
		end
	end
	
endmodule