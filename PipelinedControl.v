`timescale 1ns/1ps
//this module describes the gate-level model of a half-adder in Verilog

module PipelinedControl(ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Uncondbranch, CNBZSig, ALUOp, BL, Opcode);
//Input and output declaration
input [10:0] Opcode;
output reg ALUSrc;
output reg MemToReg;
output reg RegWrite;
output reg MemRead;
output reg MemWrite;
output reg Branch;
output reg Uncondbranch;
output reg CNBZSig;
output reg BL;
output reg [1:0] ALUOp;
/* Write Module Here */

always@(*)
begin
	casex(Opcode)
	11'b000101xxxxx: //Unconditional Branch 
	begin
		ALUSrc = 1'b1;
		MemToReg = 1'b0;
		RegWrite = 1'b1;
		MemRead = 1'b0;
		MemWrite = 1'b0;
		Branch = 1'b0;
		ALUOp = 2'b10;
		Uncondbranch = 1'b1;
		CNBZSig = 1'b0;
		BL =1'b0;
	end	
	11'b10110101xxx: //CBNZ
	begin
		ALUSrc = 1'b1;
		MemToReg = 1'b0;
		RegWrite = 1'b1;
		MemRead = 1'b0;
		MemWrite = 1'b0;
		Branch = 1'b0;
		ALUOp = 2'b10;
		Uncondbranch = 1'b0;
		CNBZSig = 1'b1;
		BL=1'b0;
	end	
	11'b11010011011: //LSL
		begin
		ALUSrc = 1'b1;
		MemToReg = 1'b0;
		RegWrite = 1'b1;
		MemRead = 1'b0;
		MemWrite = 1'b0;
		Branch = 1'b0;
		ALUOp = 2'b10;
		Uncondbranch = 1'b0;
		CNBZSig = 1'b0;
		BL=1'b0;
		end
	
	11'b1xx0101x000: //R-Type
		begin
		ALUSrc = 1'b0;
		MemToReg = 1'b0;
		RegWrite = 1'b1;
		MemRead = 1'b0;
		MemWrite = 1'b0;
		Branch = 1'b0;
		ALUOp = 2'b10;
		Uncondbranch = 1'b0;
		CNBZSig = 1'b0;
		BL =1'b0;
		end
	11'b11111000000: //STUR
		begin
		ALUSrc = 1'b1;
		MemToReg = 1'bx;
		RegWrite = 1'b0;
		MemRead = 1'b0;
		MemWrite = 1'b1;
		Branch = 1'b0;
		ALUOp = 2'b00;
		Uncondbranch = 1'b0;
		CNBZSig = 1'b0;
		BL=1'b0;
		end
	11'b11111000010: //LDUR
		begin
		ALUSrc = 1'b1;
		MemToReg = 1'b1;
		RegWrite = 1'b1;
		MemRead = 1'b1;
		MemWrite = 1'b0;
		Branch = 1'b0;
		ALUOp = 2'b00;
		Uncondbranch = 1'b0;
		CNBZSig = 1'b0;
		BL=1'b0;
		end
	11'b10110100xxx: //CBZ
		begin
		ALUSrc = 1'b0;
		MemToReg = 1'bx;
		RegWrite = 1'b0;
		MemRead = 1'b0;
		MemWrite = 1'b0;
		Branch = 1'b1;
		ALUOp = 2'b01;
		Uncondbranch = 1'b0;
		CNBZSig = 1'b0;
		BL =1'b0;
		end	
	
	11'b100101xxxxx: //Branchlink	
		begin
		ALUSrc = 1'b0;
		MemToReg = 1'b0;
		RegWrite =1'b1;
		MemRead =1'b0;
		MemWrite =1'b0;
		Branch =1'b0;
		Uncondbranch =1'b1;
		ALUOp = 2'bxx;
		CNBZSig = 1'b0;
		Uncondbranch = 1'b0;
		BL = 1'b1;
        end
		
	default: 
		begin
		ALUSrc = 1'b0;
		MemToReg = 1'b0;
		RegWrite = 1'b0;
		MemRead = 1'b0;
		MemWrite = 1'b0;
		Branch = 1'b0;
		ALUOp = 2'b10;
		CNBZSig = 1'b0;
		Uncondbranch = 1'b0;
		BL = 1'b0;
		end
	endcase
end
endmodule
