`timescale 1ns / 1ps

module LOAD(ReadData2, inExt, funct3, DataOut, DataIn, DataMemRW, InstructionMemory, opCode, curPC);
	input [31:0] ReadData2, inExt;
	input [6:0] opCode;
	input [2:0] funct3;
	input [31:0] DataIn, InstructionMemory, curPC;
	 input DataMemRW;
	output reg [31:0] DataOut;
	reg [31:0] memory[0:31];
	
	wire [31:0] DAddr;
	wire [15:0] Data;
	
	assign DAddr = ReadData2 + inExt;
	
	// read data
	 always @(DataMemRW) begin
	 if (DataMemRW == 0)  begin
			memory[curPC] = InstructionMemory;
		end
	 end
	
	
	always @(ReadData2 or inExt or DAddr or funct3)
		begin
		 if(opCode == 7'b0000011)
		 begin
			case(funct3)
				3'b001://LH
					begin
						DataOut = memory[DAddr];
						DataOut[31:16] = DataOut[15]? 16'hffff : 16'h0000;
					end
			endcase
		 end
		end
		
		
	always @(DataMemRW or DAddr or DataIn)
	     begin
		      if (DataMemRW) memory[DAddr] = DataIn;
		  end
		
endmodule
