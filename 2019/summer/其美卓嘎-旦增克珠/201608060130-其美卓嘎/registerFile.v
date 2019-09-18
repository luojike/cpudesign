`timescale 1ns / 1ps
 
module registerFile(clk, RegWre, RegOut, rs, rt, rd, ALUM2Reg, dataFromALU, dataFromRW, Data1, Data2);
    input clk, RegOut, RegWre, ALUM2Reg;
	 input [4:0] rs, rt, rd;
	 input [31:0] dataFromALU, dataFromRW;
	 output [31:0] Data1, Data2;
	 
	 wire [4:0] writeReg;
	 wire [31:0] writeData;
	 assign writeReg = RegOut? rd : rt;
	 assign writeData = ALUM2Reg? dataFromRW : dataFromALU;
	 
	 reg [31:0] register[0:31];
	 integer i;
	 initial begin
	     for (i = 0; i < 32; i = i+1) register[i] <= 1;
	 end
	 
	 // output
	 assign Data1 = register[rs];
	 assign Data2 = register[rt];
	 
	 // Write Reg
	 always @(posedge clk) 
	 begin
	     if (RegWre && writeReg) register[writeReg] = writeData;  // ·ÀÖ¹Êý¾ÝÐ´Èë0ºÅ¼Ä´æÆ÷
	 end
 
endmodule
