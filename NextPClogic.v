`timescale 1ns/1ps
//This module describe Next PC //////
module NextPClogic(NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, CNBZSig, Uncondbranch, BL);
       //Input and output
       input [63:0] CurrentPC, SignExtImm64;
       input Branch, ALUZero, Uncondbranch, CNBZSig, BL;
	   wire ZeroNot;
       output reg [63:0] NextPC;
	   assign ZeroNot = ~ALUZero;
	   //behavioral block
	   always@(*) begin
				if ((Branch&&ALUZero) || Uncondbranch || (CNBZSig&&ZeroNot) || BL)
					NextPC = CurrentPC + (SignExtImm64<<2);
				else
					NextPC = CurrentPC + 4;
			end
endmodule