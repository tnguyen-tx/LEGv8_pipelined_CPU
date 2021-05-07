`timescale 1ns/1ps

module PipelinedProc(CLK, Reset_L, startPC, dMemOut, FetchedPC);
	input wire CLK;
	input wire Reset_L;
	input wire [63:0] startPC;
	reg [63:0] currentPC;
	wire [63:0] nextPC;
	output wire [63:0] dMemOut; //for testing results
	output wire [63:0] FetchedPC; //for testing results
	/* Declare internal nets here */
	
	//IF State
	wire [31:0] IMout;
	wire PCSrc;
	//IF-ID Reg State
	reg [63:0] IF_ID_currentPC;
	reg [31:0] IF_ID_IMout;
	reg [63:0] IF_ID_PC4; 
	//ID State
	wire ALUSrc;
	wire MemToReg;
	wire RegWrite;
	wire MemRead;
	wire MemWrite;
	wire Branch;
	wire Uncondbranch;
	wire CNBZSig;
	wire [1:0] ALUOp;
	wire BL;
	
	wire [63:0] BusA, BusB, BusW;
	wire [4:0] RA, RB, RW;
	wire [63:0] SExtenderOut;
	//ID- EX Reg 
	reg ID_EX_Branch;
	reg ID_EX_Uncondbranch; 
	reg ID_EX_MemWrite; 
	reg ID_EX_MemRead;
	reg ID_EX_CNBZSig;
	reg ID_EX_BL;
		//2EX state 
	reg ID_EX_ALUSrc;
	reg [1:0] ID_EX_ALUOp;
		//2WB state
	reg ID_EX_MemToReg;
	reg ID_EX_RegWrite; 
	reg [63:0] ID_EX_BusA, ID_EX_BusB, ID_EX_currentPC;
	reg [10:0] ID_EX_Instruction31_21;
	reg [4:0] ID_EX_Instruction4_0;
	reg [63:0] ID_EX_SExtenderOut;
	reg [63:0] ID_EX_PC4;
	//EX State
	wire [63:0] adder1_Out;
	wire [63:0] ALU_out;
	wire Zero;
	wire [63:0] ALU_in_B;
	wire [3:0] ALUCtrl;
	//EX-MEM reg
	reg EX_MEM_Branch;
	reg EX_MEM_Uncondbranch;
	reg EX_MEM_MemWrite; 
	reg EX_MEM_MemRead;
	reg EX_MEM_CNBZSig;
	reg EX_MEM_BL;
	reg EX_MEM_MemToReg;
	reg EX_MEM_RegWrite; 
	reg EX_MEM_Zero;
	reg [63:0] EX_MEM_BusB;
	reg [63:0] EX_MEM_adder1_Out;
	reg [63:0] EX_MEM_ALU_out;
	reg [4:0] EX_MEM_Instruction4_0;
	reg [63:0] EX_MEM_PC4;
	//MEM state
	wire AND1_Out, AND2_Out;
	wire ZeroNot;
	
	
	wire [63: 0] Mux_out;
	reg MEM_WB_MemToReg;
	reg MEM_WB_RegWrite;
	reg [63:0] MEM_WB_ReadData, MEM_WB_ALU_out, MEM_WB_PC4;
	reg MEM_WB_BL;
	reg [4:0] MEM_WB_Instruction4_0;
	
	
	//PC block
always@(negedge CLK)
begin
if(~Reset_L)
currentPC <= startPC;
else
currentPC <= nextPC;
end

/* Stage 1 - IF Connections */
assign FetchedPC = currentPC;
InstructionMemory IM(IMout, currentPC);

/* Stage 1/2 - IF/ID Registers */


always@(negedge CLK)
begin
IF_ID_currentPC <= currentPC;
IF_ID_IMout <= IMout;
IF_ID_PC4 <= currentPC + 4;
end

/* Stage 2 - ID Connections */

PipelinedControl PLctrl(.ALUSrc(ALUSrc), .MemToReg(MemToReg), .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .Uncondbranch(Uncondbranch), .CNBZSig(CNBZSig), .ALUOp(ALUOp), .BL(BL), .Opcode(IF_ID_IMout[31:21]));



assign RA = IF_ID_IMout[9:5];
assign RB = IF_ID_IMout[28]? IF_ID_IMout[4:0] : IF_ID_IMout[20:16];
assign RW = MEM_WB_BL ? 5'd30 : MEM_WB_Instruction4_0;
assign BusW = MEM_WB_BL? MEM_WB_PC4 : Mux_out;
RegisterFile RF(.BusA(BusA), .BusB(BusB), .BusW(BusW), .RA(RA), .RB(RB), .RW(RW), .RegWr(MEM_WB_RegWrite), .Clk(CLK));
SignExtender SE(.BusImm(SExtenderOut), .Imm32(IF_ID_IMout));

/* Stage 2/3 - ID/EX Registers */
		//2MEM state



always@(negedge CLK)
begin
/* Signals input to register */
//MEM state signals
ID_EX_Branch <= Branch;
ID_EX_Uncondbranch <= Uncondbranch;
ID_EX_MemWrite <= MemWrite; 
ID_EX_MemRead <= MemRead;
ID_EX_CNBZSig <= CNBZSig;
ID_EX_BL <= BL;
ID_EX_PC4 <= IF_ID_PC4;
//WB state signals
ID_EX_MemToReg <= MemToReg;
ID_EX_RegWrite <= RegWrite; 
//EX state signals 
ID_EX_ALUSrc <= ALUSrc;
ID_EX_ALUOp <= ALUOp;


/* Register File outputs to register */
ID_EX_BusA <= BusA; 
ID_EX_BusB <= BusB;
/* Individual Signals to ID_EX register */
ID_EX_currentPC <= IF_ID_currentPC;
ID_EX_Instruction31_21 <= IF_ID_IMout[31:21];
ID_EX_Instruction4_0 <= IF_ID_IMout[4:0];

//Outputs of Sign Extenders to pipeline ID_EX
ID_EX_SExtenderOut <= SExtenderOut;
end

/* Stage 3 - EX Connections */


assign adder1_Out = ID_EX_currentPC + (ID_EX_SExtenderOut <<2);
assign ALU_in_B = ID_EX_ALUSrc ? ID_EX_SExtenderOut : ID_EX_BusB;

ALUControl ALUC(.ALUCtrl(ALUCtrl), .ALUop(ID_EX_ALUOp), .Opcode(ID_EX_Instruction31_21));
ALU ALU1(.BusW(ALU_out), .Zero(Zero), .BusA(ID_EX_BusA), .BusB(ALU_in_B), .ALUCtrl(ALUCtrl));

/* Stage 3/4 - EX/MEM Registers */
//Signals from ID/EX pipeline (control unit)


always@(negedge CLK)
begin
//MEM state signals
EX_MEM_Branch <= ID_EX_Branch;
EX_MEM_Uncondbranch <= ID_EX_Uncondbranch;
EX_MEM_MemWrite <= ID_EX_MemWrite; 
EX_MEM_MemRead <= ID_EX_MemRead;
EX_MEM_CNBZSig <= ID_EX_CNBZSig;
EX_MEM_BL <= ID_EX_BL;
//WB state signals
EX_MEM_MemToReg <= ID_EX_MemToReg;
EX_MEM_RegWrite <= ID_EX_RegWrite; 
EX_MEM_PC4 <= ID_EX_PC4;
//Adder
EX_MEM_adder1_Out <= adder1_Out;
//ALU unit
EX_MEM_ALU_out <= ALU_out;
EX_MEM_Zero <= Zero;
//Indivuidual wires
EX_MEM_BusB <= ID_EX_BusB;
EX_MEM_Instruction4_0 <= ID_EX_Instruction4_0;
end

/* Stage 4 - MEM Connections */

wire [63:0] ReadData;

assign AND1_Out = EX_MEM_Branch&EX_MEM_Zero;
assign ZeroNot = ~Zero;
assign AND2_Out = ZeroNot&EX_MEM_CNBZSig;
assign PCSrc = AND1_Out^AND2_Out^EX_MEM_BL^EX_MEM_Uncondbranch;


assign nextPC = PCSrc? EX_MEM_adder1_Out : (currentPC+4);

DataMemory DM(.ReadData(ReadData), .Address(EX_MEM_ALU_out), .WriteData(EX_MEM_BusB), .MemoryRead(EX_MEM_MemRead), .MemoryWrite(EX_MEM_MemWrite), .Clock(CLK));

/* Stage 4/5 - MEM/WB Registers */


always@(negedge CLK)
begin
	//WB state signals
MEM_WB_MemToReg <= EX_MEM_MemToReg;
MEM_WB_RegWrite <= EX_MEM_RegWrite; 
MEM_WB_BL <= EX_MEM_BL;
MEM_WB_PC4 <= EX_MEM_PC4;
//Inputs from Data Memory
MEM_WB_ReadData <= ReadData;
MEM_WB_ALU_out <= EX_MEM_ALU_out;
MEM_WB_Instruction4_0 <= EX_MEM_Instruction4_0;
end

/* Stage 5 - WB Connections */

assign Mux_out = MEM_WB_MemToReg? MEM_WB_ReadData : MEM_WB_ALU_out;

assign dMemOut = MEM_WB_ReadData;

 
/* Instantiate and put modules here */
/* Stage 1 - IF Logic */
/* Stage 1/2 - IF/ID Pipeline Registers */
/* Stage 2 - ID Logic*/
/* Stage 2/3 - ID/EX Pipeline Registers */
/* Stage 3 - EX Logic  */
/* Stage 3/4 - EX/MEM Pipeline Registers */

/* Stage 4 - MEM Logic */
/* Stage 4/5 - MEM/WB Pipeline Registers */
/* Stage 5 - WB Logic */

endmodule
