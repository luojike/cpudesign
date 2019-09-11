library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timee is
port(
	clk_in:in std_logic;
	clk_out:out std_logic_vector(4 downto 0)
	);
end timee;

architecture bhv of timee is
signal temp:std_logic_vector(4 downto 0):="10000";
begin
	t0:process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if temp="10000" then
				temp<="00001";
			else
				temp <= temp(3 downto 0) & '0';
			end if;
		end if;
	end process;
	clk_out <= temp;
end bhv;
