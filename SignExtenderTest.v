`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: TAMU dot EDU
// Engineer: Thuy Nguyen
//
// Create Date:   15:12:10 03/02/2009
// Design Name:   SignExtenderTest
// Module Name:   E:/350/Lab6/FullAdd/SignExtenderTest.v
// Project Name:  SignExtenderTest_v
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SignExtenderTest_v
// 
////////////////////////////////////////////////////////////////////////////////

`define STRLEN 15
module SignExtenderTest_v;

   task passTest;
      input [1:0] actualOut, expectedOut;
      input [`STRLEN*8:0] testType;
      inout [7:0]         passed;
      
      if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
      else $display ("%s failed: %d should be %d", testType, actualOut, expectedOut);
   endtask
   
   task allPassed;
      input [7:0] passed;
      input [7:0] numTests;
      
      if(passed == numTests) $display ("All tests passed");
      else $display("Some tests failed");
   endtask

   // Inputs
   reg [31:0]     Imm32;
   reg [7:0]      passed;

   // Outputs
   wire [63:0]    BusImm;

   // Instantiate the Device Under Test (DUT)
   SignExtender dut (
		.BusImm(BusImm), 
		.Imm32(Imm32)
	        );
   initial begin
      // Initialize Inputs
      Imm32 = 8'h00000000;
      passed = 0;

      // Add stimulus here ----      Test 3 negative numbers and 2 types)
      #90; Imm32=32'b10010001000100000000000000101100; #10; passTest(BusImm, 64'b0000000000000000000000000000000000000000000000000000010000000000, "ADDI pos number", passed);
      #90; Imm32=32'b10010010001110000000000000011110; #10; passTest(BusImm, 64'b1111111111111111111111111111111111111111111111111111111000000000, "ANDI neg number", passed);
      #90; Imm32=32'b10110100101111000000000000000011; #10; passTest(BusImm, 64'b1111111111111111111111111111111111111111111111011110000000000000, "CBZ neg number", passed);
      #90; Imm32=32'b11111000010111111110000100001000; #10; passTest(BusImm, 64'b1111111111111111111111111111111111111111111111111111111111111110, "LDUR neg number", passed);
      allPassed(passed, 4);
   end
   
endmodule

