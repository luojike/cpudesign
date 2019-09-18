`timescale 1ns / 1ps
 
module dataMemory(DAddr, DataIn, DataMemRW, DataOut , InstructionMemory, opCode, curPC);
    input [31:0] DAddr, DataIn, InstructionMemory, curPC;
    input [6:0] opCode;
	 input DataMemRW;
	 output reg [31:0] DataOut;
	 reg [31:0] memory[0:31];
	 
	 
	 // read data
	 always @(DataMemRW) begin
	 if (DataMemRW == 0)  begin
			memory[curPC] = InstructionMemory;
			DataOut = memory[curPC];
		end
	 end
	 
	 
	 // write data
	 /*integer i;
	 initial begin
	     for (i = 0; i < 32; i = i+1) memory[i] <= 0;
	 end*/
	 always @(DataMemRW or DAddr or DataIn)
	     begin
		      if (DataMemRW) memory[DAddr] = DataIn;
		  end
 
endmodule
