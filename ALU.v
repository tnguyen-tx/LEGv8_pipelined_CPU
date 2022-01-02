`timescale 1ns/1ps

`define AND1 4'b0000
`define OR1 4'b0001
`define ADD1 4'b0010
`define LSL1 4'b0011
`define LSR1 4'b0100
`define SUB1 4'b0110
`define PassB1 4'b0111


module ALU(BusW, Zero , BusA , BusB , ALUCtrl);
    
	//Input and output declaration
    parameter n = 63;
	
    output reg [n:0] BusW;
    input   [n:0] BusA, BusB;
    input   [3:0] ALUCtrl;
    output  reg Zero;
    
	//Behavioral clock
    always @(ALUCtrl or BusA or BusB) begin
       	case(ALUCtrl)
            	`AND1: begin
                	BusW = BusA&BusB;
            	end
            	`OR1: begin
                	BusW = BusA|BusB;
            	end
		`ADD1: begin
                	BusW = BusA+BusB;
            	end
		`LSL1: begin
                	BusW = BusA<<BusB;
            	end
		`LSR1: begin
                	BusW = BusA>>BusB;
            	end
		`SUB1: begin
                	BusW = BusA-BusB;
            	end
		`PassB1: begin
                	BusW = BusB;
            	end	
        endcase
    end
	
	always@(*)
	begin 
	if (BusW == 64'b0)
		Zero = 1'b1; 
	else 
		Zero =1'b0;
	end
	
endmodule
