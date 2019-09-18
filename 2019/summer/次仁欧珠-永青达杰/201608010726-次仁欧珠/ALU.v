`timescale 1ns / 1ps
 
module ALU(ReadData1, ReadData2, inExt, opCode, shamt, ALUSrcB, ALUOp, /*zero,*/ result);
    input [31:0] ReadData1, ReadData2, inExt;
    input [6:0] opCode;
    input [4:0] shamt;
	 input ALUSrcB;
	 input [2:0] ALUOp;
	 //output zero;
	 output [31:0] result;
	 
	 //reg zero;
	 reg [31:0] result;
	 wire [31:0] B;
	 assign B = ALUSrcB? inExt : ReadData1;
	 
	 always @(ReadData1 or ReadData2 or inExt or ALUSrcB or ALUOp or B)
	     begin
		  if(opCode == 7'b0010011)begin
		      case(ALUOp)
				    // ADDI
					 3'b000: begin					 
						 result = ReadData2 + B;
						  //zero = (result == 0)? 1 : 0;
					 end
					 // SLLI
					 3'b001: begin
						result = ReadData2 << shamt;
						  //zero = (result == 0)? 1 : 0;
					 end
		      endcase
		   end
		   else if(opCode == 7'b0110011)begin
				case(ALUOp)
					// SLT
					 3'b010: begin
						result = (ReadData2 < ReadData1)? 1 : 0;
					end
				endcase
			end
			else if(!opCode)begin
				result = 0;
			end
		  end
endmodule
