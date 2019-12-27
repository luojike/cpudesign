library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity timer is 
	port(reset,clk : in std_logic;
		 ir : in std_logic_vector(15 downto 0);
		 s  : buffer std_logic);
end timer;
architecture bhv of timer is
begin
	process(reset,clk)
	begin
	if reset='0' then 
	s<='0';
	elsif clk'event and clk='1' then
	  if s='0' and ir="0101000000000000" then 
	  	s<='0';
	  else 
	    s<=not s;
	  end if ;
	end if;
	end process;
end bhv;