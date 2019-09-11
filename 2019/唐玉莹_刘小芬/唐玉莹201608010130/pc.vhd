library iEEE ;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use iEEE.numeric_std.all;

entity pc is
	port(
		clk:in std_logic ;
		rst:in std_logic ;
		stop:in std_logic ;
		imm:in std_logic_vector(31 downto 0) ;
		pc_src:in std_logic ;
		pc_out:out std_logic_vector(31 downto 0) 
	);
end pc;

architecture bhv of pc is
	signal pc_now: std_logic_vector(31 downto 0) :=X"00000000";
	signal pc_next:std_logic_vector(31 downto 0) ;
begin	   
	seq0: process(clk,stop)
	begin
		if rising_edge(clk) and stop='0'  then
			if rst='1' then
				pc_next <= X"00000000";
			elsif pc_src='1' then
				pc_next <= std_logic_vector( unsigned(pc_now) + unsigned(imm));
			else
				pc_next <= std_logic_vector( unsigned(pc_now) + 4);
			end if;
			pc_out<=pc_now;
			pc_now <= pc_next; 	
		end if;
	end process;
end bhv;