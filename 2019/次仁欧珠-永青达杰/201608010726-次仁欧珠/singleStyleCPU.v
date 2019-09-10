//`include "controlUnit.v"
//`include "dataMemory.v"
//`include "ALU.v"
//`include "instructionMemory.v"
//`include "registerFile.v"
//`include "signZeroExtend.v"
//`include "PC.v"
`timescale 1ns / 1ps
 
module SingleCycleCPU(
    input clk, Reset,
	 output wire [6:0] opCode,
	 output wire [2:0] funct3,
	 output wire [4:0] shamt, rs, rt, rd,
	 output wire [31:0] Out1, Out2, curPC, Result,
	 //test
	 output wire [31:0] DMOut, DMOut2,I_ExtOut,
	 output wire zero
	 );
	 
	 wire [2:0] ALUOp;
	 wire [31:0] /*I_ExtOut, DMOut*/InstructionMemory, B_ExtOut;
	 wire [11:0] I_immediate, B_immediate;
	 wire /*zero,*/ PCWre, PCSrc, ALUSrcB, ALUM2Reg, RegWre, InsMemRW, DataMemRW, ExtSel, RegOut;
	 
	 // module ALU(ReadData1, ReadData2, inExt, ALUSrcB, ALUOp, zero, result);
	 ALU alu(Out1, Out2, I_ExtOut, opCode, shamt, ALUSrcB, ALUOp, /*zero,*/ Result);
	 // module BRANCH(ReadData1, ReadData2, opCode, funct3, zero);
	 BRANCH branch(Out1, Out2, opCode, funct3, zero);
	 //module LOAD(ReadData2, inExt, funct3, DataOut, DataIn, DataMemRW, InstructionMemory, opCode, curPC);
	 LOAD load(Out2, I_ExtOut, funct3, DMOut2, Out2, DataMemRW, InstructionMemory, opCode, curPC);
	 // module PC(clk, Reset, PCWre, PCSrc, immediate, Address);
	 PC pc(clk, Reset, PCWre, PCSrc, B_ExtOut, curPC);
	 // module controlUnit(opCode, funct3, zero, PCWre, ALUSrcB, ALUM2Reg, RegWre, InsMemRW, DataMemRW, ExtSel, PCSrc, RegOut, ALUOp);
	 controlUnit control(opCode, funct3, zero, PCWre, ALUSrcB, ALUM2Reg, RegWre, InsMemRW, DataMemRW, ExtSel, PCSrc, RegOut, ALUOp);
	 // module dataMemory(DAddr, DataIn, DataMemRW, DataOut, InstructionMemory, opCode, curPc);
	 dataMemory datamemory(Result, Out2, DataMemRW, DMOut, InstructionMemory, opCode, curPC);
	 /* module instructionMemory(
    input [31:0] pc,
    input InsMemRW,
	 input [5:0] op, 
	 input [4:0] rs, rt, rd,
	 output [15:0] immediate);*/
	 instructionMemory ins(curPC, InsMemRW, opCode, rs, rt, rd, funct3, shamt, I_immediate, B_immediate, InstructionMemory);
	 // module registerFile(clk, RegWre, RegOut, rs, rt, rd, ALUM2Reg, dataFromALU, dataFromRW, Data1, Data2);
	 registerFile registerfile(clk, RegWre, RegOut, rs, rt, rd, ALUM2Reg, Result, DMOut, Out1, Out2);
    // module signZeroExtend(I_immediate, ExtSel, out);
	 signZeroExtend ext(I_immediate, B_immediate, ExtSel, I_ExtOut, B_ExtOut);
 
 
endmodule
