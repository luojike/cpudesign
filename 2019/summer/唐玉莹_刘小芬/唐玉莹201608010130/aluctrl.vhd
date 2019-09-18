library IEEE ;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity aluctrl is
port(
	aluop: in std_logic_vector(1 downto 0);
	funct7:std_logic_vector(6 downto 0);
	funct3:std_logic_vector(2 downto 0);
	aluctr:out std_logic_vector(4 downto 0)
	);
end aluctrl;

architecture behav of aluctrl is
begin
	aluctr<="00001" when aluop="10" and funct3="110" else   -- or,ori
			"00000" when aluop="10" and funct3="111" else   -- and,andi
			"00110" when aluop="10" and funct7="0100000" and funct3="000" else   -- subtract
			"00010" when aluop="10" and funct7="0000000" and funct3="000" else   -- add
																	--beq subtract  
			"00010" when aluop="00" else                          --load,store doubleword
			
			"11"& funct3 when aluop="01"  else                          --beq subtract
			"00011" when aluop="10" and funct3="100" else  --xor
			"00100" when aluop="10" and funct3="101" else  --srl,srli
			"00101" when aluop="10" and funct3="001" else  --sll,slli
			"00111" when aluop="10" and funct3="101" and funct7="0100000" else --srai,sra
			"01111" when aluop="11" else --LUI
			"ZZZZZ";
end behav; 