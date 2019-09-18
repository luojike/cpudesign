`timescale 1ns / 1ps
 
module controlUnit(opCode, funct3, zero, PCWre, ALUSrcB, ALUM2Reg, RegWre, InsMemRW, DataMemRW, ExtSel, PCSrc, RegOut, ALUOp);
    input [6:0] opCode;
    input [2:0] funct3;
	 input zero;
	 output PCWre, ALUSrcB, ALUM2Reg, RegWre, InsMemRW, DataMemRW, ExtSel, PCSrc, RegOut;
	 output [2:0] ALUOp;
	 
	 assign PCWre = (opCode == 7'b1111111)? 0 : 1;
	 assign ALUSrcB = (opCode == 7'b0010011 || opCode == 7'b0100011 || opCode == 7'b0000011)? 1 : 0;
	 assign ALUM2Reg = (opCode == 7'b0000011)? 1 : 0;
	 assign RegWre = (opCode == 7'b0110011 || opCode == 7'b0010011 ||opCode == 7'b0000011)? 1 : 0;
	 assign InsMemRW = 0;
	 assign DataMemRW = (opCode == 7'b0100011)? 1 : 0;
	 assign ExtSel = (opCode == 7'b0010011 || opCode == 7'b0100011 || opCode == 7'b0000011 || opCode== 7'b1100011)? 1 : 0;
	 assign PCSrc = (opCode == 7'b1100011 && zero == 1)? 1 : 0;
	 assign RegOut = (opCode == 7'b0001111)? 0 : 1;
	 assign ALUOp[2] = funct3[2];
	 assign ALUOp[1] = funct3[1];
	 assign ALUOp[0] = funct3[0];
	 
endmodule
