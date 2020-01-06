library iEEE ;
use IEEe.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity control is
port(
	--clk:in std_logic;
	opcode:in std_logic_vector(6 downto 0);
	Branch:out std_logic; 			--branch='0' -> pc+4
	MemRead:out std_logic;			--'1'=read data from datamemory
	MemtoReg:out std_logic;			--'1'=data from datamemory to register  0 alu
	ALUOp:out std_logic_vector(1 downto 0); 
	MemWrite:out std_logic;			--'1'=write into datamemory
	ALUSrc:out std_logic;		--'0'=register to alu  '1'=imm to alu
	RegWrite:out std_logic		--'1'=write into register 
	);
end control;

architecture con_bhv of control is

	signal pc:std_logic_vector(31 downto 0);
begin
	p1:process(opcode)
	begin
	--	if(rising_edge(clk)) then
			if(opcode="0110011")then  --R-type
				ALUSrc<='0';
				MemtoReg<='0';
				RegWrite<='1';
				MemRead<='0';
				MemWrite<='0';
				Branch<='0';
				ALUOp<="10";
			elsif(opcode="0000011") then  --I-type
				ALUSrc<='1';
				MemtoReg<='1';
				RegWrite<='1';
				MemRead<='1';
				MemWrite<='0';
				Branch<='0';
				ALUOp<="00";
			elsif(opcode="0100011") then --S-type
				ALUSrc<='1';
				MemtoReg<='X';
				RegWrite<='0';
				MemRead<='0';
				MemWrite<='1';
				Branch<='0';
				ALUOp<="00";
			elsif(opcode="1100111") then --SB-type
				ALUSrc<='0';
				MemtoReg<='X';
				RegWrite<='0';
				MemRead<='0';
				MemWrite<='0';
				Branch<='1';
				ALUOp<="01";
			
			--below is my add
			elsif(opcode="0010011") then  --I-type
				ALUSrc<='1';
				MemtoReg<='1';
				RegWrite<='1';
				MemRead<='0';
				MemWrite<='0';
				Branch<='0';
				ALUOp<="10";
			elsif(opcode="0110111") then --U-type
				ALUSrc<='1';
				MemtoReg<='0';
				RegWrite<='1';
				MemRead<='0';
				MemWrite<='0';
				Branch<='0';
				ALUOp<="11";
			elsif(opcode="0110111") then --UJ-type
				ALUSrc<='1';
				MemtoReg<='0';
				RegWrite<='0';
				MemRead<='0';
				MemWrite<='0';
				Branch<='1';
				ALUOp<="XX";
			else
				ALUSrc<='0';
				MemtoReg<='0';
				RegWrite<='0';
				MemRead<='0';
				MemWrite<='0';
				Branch<='0';
				ALUOp<="XX";
			end if;
	--	end if;
	end process;
end con_bhv;