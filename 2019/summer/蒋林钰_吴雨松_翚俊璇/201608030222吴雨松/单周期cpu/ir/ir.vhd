library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity ir is
	port(
	ldir,clk: in std_logic;
	input: in std_logic_vector(31 downto 0);
	output: out std_logic_vector(31 downto 0);
	count:out std_logic
	);
end ir;
architecture behav of ir is
    signal ld:std_logic:='0';
begin
	process(clk)
	begin
		if(clk'event and clk='1') then
		    if(ldir='0') then
		    case ld is
			when '0'=>
			ld<='1';
			count<='1';
			when '1'=>
			ld<='0';
			count<='0';
			end case;
			if(ld='1') then
		    output<=input;
		    end if;
		    else
		    output<=input;
		    count<='0';
		    end if;
		end if;
	end process;
end behav; 





		