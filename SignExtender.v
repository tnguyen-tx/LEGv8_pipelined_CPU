`timescale 1ns/1ps
module SignExtender(BusImm, Imm32); 
  output reg [63:0] BusImm; 
  input [31:0] Imm32; 

  reg extBit; 
  always@(*)
  begin  
	if (Imm32[31:24] == 8'b10110100 || Imm32[31:24] == 8'b10110101) //CB-type
		begin
		  extBit <= Imm32[23]; 
		   BusImm <= {{45{extBit}}, Imm32[23:5]};
		end  
	else if (Imm32[31:26] == 6'b000101 || Imm32[31:26] == 6'b100101) //B-type
		begin
		   extBit <= Imm32[25]; 
		   BusImm <= {{38{extBit}}, Imm32[25:0]};
		end 
	else if (Imm32[31:21]==11'b11111000000 || Imm32[31:21] == 11'b11111000010) //D-type
		begin
		   extBit <= Imm32[20]; 
		   BusImm <= {{55{extBit}}, Imm32[20:12]};
		end 
	else if (Imm32[31:21]== 11'b11010011011) 	//R-type for LSL
		begin
		   BusImm <= {26'b0, Imm32[15:10]};
		end
	else if (Imm32[31:22] == 10'b??)
		begin
		   extBit <= Imm32[21]; 
		   BusImm <= {{53{extBit}}, Imm32[21:10]};
		end
	else
	BusImm=32'b0;
	end
endmodule