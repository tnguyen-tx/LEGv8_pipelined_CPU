`timescale 1ns / 1ps

module RegisterFile(BusA, BusB, BusW, RA, RB, RW, RegWr, Clk);
//declare output and input
    output reg [63:0] BusA;
    output reg [63:0] BusB;
    input [63:0] BusW;
    input [4:0] RW;
	input [4:0] RA;
	input [4:0] RB;
    input RegWr;
    input Clk;
    reg [63:0] registers [31:0];
	
	//behavioral blocks
	always@(*) //BlockA
	begin
	if (RA==5'b11111)				//if read X31 then output 0
		#2 assign BusA = 64'b0;
	else 
		#2 assign BusA = registers[RA];	//otherwise read register RA
	end
	
	always@(*)//Block B
	begin
	if (RB==5'b11111)					//if read X31 then output 0
		#2 assign BusB = 64'b0;
	else 
		#2 assign BusB = registers[RB];	//otherwise read register RB
	end
	
	always @ (posedge Clk) begin		//change the value of register RW 
		if((RegWr))
				registers[RW] <= #3 BusW;
		end
endmodule
