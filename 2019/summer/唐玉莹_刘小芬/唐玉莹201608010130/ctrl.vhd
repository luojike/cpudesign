library iEEE ;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ctrl is
port(
	opcode:in std_logic_vector(6 downto 0);
	Branch:out std_logic; 
	MemRead:out std_logic;
	MemtoReg:out std_logic;	
	ALUOp:out std_logic_vector(1 downto 0); 
	MemWrite:out std_logic;	
	ALUSrc:out std_logic;
	RegWrite:out std_logic
	);
end ctrl;

architecture bhv of ctrl is

	signal pc:std_logic_vector(31 downto 0);
begin
	p1:process(opcode)
	begin
			if(opcode="0110011")then
				ALUSrc<='0';
				MemtoReg<='0';
				RegWrite<='1';
				MemRead<='0';
				MemWrite<='0';
				Branch<='0';
				ALUOp<="10";
			elsif(opcode="0000011") then
				ALUSrc<='1';
				MemtoReg<='1';
				RegWrite<='1';
				MemRead<='1';
				MemWrite<='0';
				Branch<='0';
				ALUOp<="00";
			elsif(opcode="0100011") then
				ALUSrc<='1';
				MemtoReg<='X';
				RegWrite<='0';
				MemRead<='0';
				MemWrite<='1';
				Branch<='0';
				ALUOp<="00";
			elsif(opcode="1100111") then
				ALUSrc<='0';
				MemtoReg<='X';
				RegWrite<='0';
				MemRead<='0';
				MemWrite<='0';
				Branch<='1';
				ALUOp<="01";

			elsif(opcode="0010011") then
				ALUSrc<='1';
				MemtoReg<='1';
				RegWrite<='1';
				MemRead<='0';
				MemWrite<='0';
				Branch<='0';
				ALUOp<="10";
			elsif(opcode="0110111") then
				ALUSrc<='1';
				MemtoReg<='0';
				RegWrite<='1';
				MemRead<='0';
				MemWrite<='0';
				Branch<='0';
				ALUOp<="11";
			elsif(opcode="0110111") then
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
	end process;
end bhv;