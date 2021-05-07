//`timescale 1ns/1ps

//Define 
`define ADD 11'b10001011000
`define SUB 11'b11001011000
`define AND 11'b10001010000
`define ORR 11'b10101010000
`define LSL 11'b11010011011

module ALUControl(ALUCtrl, ALUop, Opcode);
     input [1:0] ALUop;
     input [10:0] Opcode;
     output reg [3:0] ALUCtrl;
     /* write your code here */
	 
	 //behavioral block
	 always@(*)
	 begin
		 case(ALUop)
			2'b00: begin 					//LDUR and STUR
					 ALUCtrl = 4'b0010;
					end
			2'b01: begin 					//CBZ
					 ALUCtrl = 4'b0111;
					end
			2'b10: begin 
					case(Opcode) 
						`ADD:  ALUCtrl = 4'b0010;		//ADD 
						`SUB:  ALUCtrl = 4'b0110;		//SUB
						`AND:  ALUCtrl = 4'b0000;		//AND
						`ORR:  ALUCtrl = 4'b0001;		//ORR
						`LSL:  ALUCtrl = 4'b0011;		//LSL
					endcase
					end
		 endcase
	 end	 
endmodule