library iEEE ;
use IEEe.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
entity alu_control is
port(
	aluop: in std_logic_vector(1 downto 0);
	funct7:std_logic_vector(6 downto 0);
	funct3:std_logic_vector(2 downto 0);
	aluctr:out std_logic_vector(3 downto 0)
	);
end;
architecture behav of alu_control is
begin
	aluctr<="0001" when aluop="10"                     
  and funct3="110" else   
			"0000" when aluop="10" and funct3="111" else  
			"0110" when aluop="10" and funct7="0100000" and funct3="000" else   
			"0010" when aluop="10" and funct7="0000000" and funct3="000" else  
			"0110" when aluop="01" else                         
			"0010" when aluop="00" else                          
			"0011" when aluop="10" and funct3="100" else 
			"0100" when aluop="10" and funct3="101" else 
			"0101" when aluop="10" and funct3="001" else  
			"0111" when aluop="10" and funct3="101" and funct7="0100000" else
			"1111" when aluop="11" else --LUI
			"ZZZZ";
end behav;
