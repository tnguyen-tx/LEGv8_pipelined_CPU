`timescale 1ns / 1ps
`define NOP 32'h8B1F03FF
/*
 * Module: InstructionMemory
 *
 * Implements read-only instruction memory
 * 
 */
module InstructionMemory(Data, Address);
   parameter T_rd = 20;
   parameter MemSize = 40;
   
   output [31:0] Data;
   input [63:0]  Address;
   reg [31:0] 	 Data;
   
   /*
    * ECEN 350 Processor Test Functions
    * Texas A&M University
    */
   
   always @ (Address) begin
      case(Address)

	/* Test Program 1:
	 * Program loads constants from the data memory. Uses these constants to test
	 * the following instructions: LDUR, ORR, AND, CBZ, ADD, SUB, STUR and B.
	 * 
	 * Assembly code for test:
	 * 
	 * 0: LDUR X9, [XZR, 0x0]    //Load 1 into x9
	 * 4: LDUR X10, [XZR, 0x8]   //Load a into x10
	 * 8: LDUR X11, [XZR, 0x10]  //Load 5 into x11
	 * C: LDUR X12, [XZR, 0x18]  //Load big constant into x12
	 * 10: LDUR X13, [XZR, 0x20]  //load a 0 into X13
	 * 
	 * 14: ORR X10, X10, X11  //Create mask of 0xf
	 * 18: AND X12, X12, X10  //Mask off low order bits of big constant
	 * 
	 * loop:
	 * 1C: CBZ X12, end  //while X12 is not 0
	 * 20: ADD X13, X13, X9  //Increment counter in X13
	 * 24: SUB X12, X12, X9  //Decrement remainder of big constant in X12
	 * 28: B loop  //Repeat till X12 is 0
	 * 2C: STUR X13, [XZR, 0x20]  //store back the counter value into the memory location 0x20
	 */
	 
	 // F D E M W 
	 //       F  D
	

	64'h000: Data = 32'hF84083EA; //LDUR x10, [xzr, 0x8]
	64'h004: Data = 32'hF84103EB; //LDUR x11, [xzr, 0x10]
	64'h008: Data = 32'hF84003E9; //LDUR X9, [XZR, 0x0]
	64'h00c: Data = 32'hF84183EC; //LDUR x12, [xzr, 0x18]
	64'h010: Data = 32'hAA0B014A; //ORR x10, x10, x11
	64'h014: Data = 32'hF84203ED; //LDUR X13, [xzr, 0x20]
	64'h018: Data = `NOP;
	64'h01c: Data = 32'h8A0A018C; //AND x12, x12, x10
	64'h020: Data = `NOP; //Data hazard
	64'h024: Data = `NOP;
	64'h028: Data = {8'b1011_0100, 19'd10,5'd12}; //loop: CBZ x12, end
	64'h02c: Data = `NOP; //Control hazard
	64'h030: Data = `NOP;
	64'h034: Data = `NOP; //Decision made in the Mem stage; so clock in 
	64'h038: Data = 32'h8B0901AD; //ADD x13, x13, x9
	64'h03c: Data = 32'hCB09018C; //SUB x12, x12, x9
	64'h040: Data = {6'b000101, 26'b11_1111_1111_1111_1111_1111_1010}; //B loop
	64'h044: Data = `NOP; //Control hazard
	64'h048: Data = `NOP;
	64'h04c: Data = `NOP;
	64'h050: Data = 32'hF80203ED; //end: STUR X13, [XZR, 0x20]
	64'h054: Data = 32'hF84203ED; //LDUR X13,[XZR, 0x20] One last load to place stored value on memdbus for test checking.
	64'h058: Data = `NOP; //Stall to wait for LDUR to be in the WB stage
	64'h05c: Data = `NOP;
	64'h060: Data = `NOP;
	64'h064: Data = `NOP;

	/* Add code for your tests here */
	/* Test Program 2: CBNZ 
	 * Program loads constants from the data memory. Uses these constants to test
	 * the following instructions: LDUR, ORR, AND, CBZ, ADD, SUB, STUR and B.
	 * 
	 * Assembly code for test:
	 * 
	 * 68: LDUR X9, [XZR, 0x0]    //Load 1 into x9
	 * 6c: LDUR X10, [XZR, 0x8]   //Load a into x10
	 * 70: NOP
	 * 74: CBNZ X9, label		//Jump if X9 !=0
	 * 78: NOP
	 * 7c: NOP
	 * 80: NOP
	 * 84: B exit  			//Branch to exit
	 * 88: NOP
	 * 8c: NOP
	 * 90: NOP
	 * 94: label: STUR X10, [XZR, 0x4]  //Store a to mem 
	 * 98: LDUR x10, [XZR, 0x4]  //load back
	 * 9c: NOP
	 * a0: NOP
	 * a4: NOP
	 * exit:
	 */
	
	63'h068: Data = 32'hF84003E9;
	63'h06c: Data = 32'hF84083EA;
	63'h070: Data = `NOP;
	63'h074: Data = 32'hB5000049;
	63'h078: Data = `NOP;
	63'h07c: Data = `NOP;
	63'h080: Data = `NOP;
	63'h084: Data = 32'h14000003;
	63'h088: Data = `NOP;
	63'h08c: Data = `NOP;
	63'h090: Data = `NOP;
	63'h094: Data = 32'hF80203EA;
	63'h098: Data = 32'hF84203EA;
	63'h09c: Data = `NOP;
	63'h0a0: Data = `NOP;
	63'h0a4: Data = `NOP;

////////Test Branch and Link /////////
	/* Test Program 3:
	 * Program loads constants from the data memory. Uses these constants to test
	 * the following instructions: LDUR, ORR, AND, CBZ, ADD, SUB, STUR and B.
	 * 
	 * Assembly code for test:
	 * 
	 * a8: LDUR X9, [XZR, 0x0]    		//Load 1 into x9
	 * ac: LDUR X10, [XZR, 0x8]   		//Load a into x10
	 * b0: BL label						//Jump to the label
	 * b4 NOP
	 * b8 NOP
	 * bc NOP
	 * c0: STUR X9, [XZR, 40]  		 //Store 1 to memory
	 * c4: label: ADD X10, X10, X30  //X10 = (PC+4) + a   //0x58+0xA = 0x62
	 * c8: STUR X10, [XZR, 40]  	//Store (PC+4) + a to mem 
	 * cc: LDUR X10, [XZR, 40]
	 * d0 NOP
	 * d4 NOP
	 * d8 NOP
	 */
	
	63'h0a8: Data = 32'hF84003E9; //LDUR X9, [XZR, 0x0]
	63'h0ac: Data = 32'hF84083EA; //LDUR X10, [XZR, 0x8]
	63'h0b0: Data = 32'h94000005; //BL label
	63'h0b4: Data = `NOP;
	63'h0b8: Data = `NOP;
	63'h0bc: Data = `NOP;
	63'h0c0: Data = 32'hF80283E9; //STUR X9, [XZR, 40]
	63'h0c4: Data = 32'h8B0A03CA; //label: ADD X10, X10, X30
	63'h0c8: Data = `NOP;
	63'h0cc: Data = `NOP;
	63'h0d0: Data = 32'hF80283EA; //STUR X10, [XZR, 40] 
	63'h0d4: Data = 32'hF84283EA; //LDUR X10, [XZR, 40]
	63'h0d8: Data = `NOP;
	63'h0dc: Data = `NOP;
	63'h0e0: Data = `NOP;

	/////////////Test LSL//////////////////
	/* Test Program 3:
	 * Program loads constants from the data memory. Uses these constants to test
	 * the following instructions: LDUR, ORR, AND, CBZ, ADD, SUB, STUR and B.
	 * 
	 * Assembly code for test:
	 * 
	 * dc: LDUR X9, [XZR, 0x0]    		//Load 1 into x9
		Data = `NOP;
		Data = `NOP;
		Data = `NOP;
	 * e0: LSL X9, X9, #2	
		Data = `NOP;
		Data = `NOP;
		Data = `NOP;
	 * e4: STUR X9, [XZR, 48]  		//Store 1 to memory
	  e8: LDUR X9, [XZR, 48]
	   Data = `NOP;
	  Data = `NOP;
	  Data = `NOP;
	*/
	
	
	63'h0e4: Data = 32'hF84003E9;  //LDUR X9, [XZR, 0x0]
	63'h0e8: Data = `NOP;
	63'h0ec: Data = `NOP;
	63'h0f0: Data = `NOP;
	63'h0f4: Data = 32'hD3600929; //LSL X9, X9, #2
	63'h0f8: Data = `NOP;
	63'h0fc: Data = `NOP;
	63'h100: Data = `NOP;
	63'h104: Data = 32'hF80303E9; //STUR X9, [XZR, 48]
	63'h108: Data = 32'hF84303E9; //Load to check
	63'h10c: Data = `NOP;
	63'h110: Data = `NOP;
	63'h114: Data = `NOP;
	
	/////////////////////////////////
	
			
	default: Data = 32'hXXXXXXXX;
      endcase
   end
endmodule
