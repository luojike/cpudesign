library iEEE ;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity imm is
port(
	ins:in std_logic_vector(31 downto 0);
	imm_out:out std_logic_vector(31 downto 0)
	);
end imm;

architecture bhv of imm is

signal opcode:std_logic_vector(6 downto 0):=ins(6 downto 0);
signal funct3:std_logic_vector(2 downto 0):=ins(14 downto 12);
signal funct7:std_logic_vector(6 downto 0):=ins(31 downto 25);

begin
	imm:process(ins)
	begin
		if(opcode="0010011") then
			if(funct3="000"or funct3="111"or funct3="110"or funct3="100") then 
				imm_out(11 downto 0) <= ins(31 downto 20);
				imm_out(31 downto 21)<= (others=>ins(31)); 
			elsif((funct3="011"and funct7="0000000") or
					(funct3="101"and (funct7="0000000"or funct7="0100000"))) then
				imm_out<=  "0000000" & ins(24 downto 0);
			end if;
		elsif(opcode="0110111" or opcode="0010111") then
			imm_out<=ins(31 downto 12) & X"000";
		elsif (opcode="1100111") then 
			imm_out(11 downto 0) <= ins(31 downto 20);
			imm_out(31 downto 21)<= (others=>ins(31));
		elsif (opcode="1101111") then
			imm_out(20 downto 0) <= ins(31) & ins(19 downto 12) & ins(20) & ins(30 downto 21) & '0';
			imm_out(31 downto 21)<=(others=>ins(31));
		elsif (opcode="1100011") then 
			imm_out(13 downto 0) <= ins(31) & ins(7) & ins(30 downto 25) & ins(11 downto 8) & "00";
			imm_out(31 downto 14)<= (others=>ins(31));
		elsif(opcode="0000011") then 
			imm_out <= X"00000" & ins(31 downto 20);
		elsif(opcode="0100011") then 
			imm_out <= X"00000"  & ins(31 downto 25) & ins(11 downto 7);
		else 
			imm_out <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		end if;
	end process;
end bhv;