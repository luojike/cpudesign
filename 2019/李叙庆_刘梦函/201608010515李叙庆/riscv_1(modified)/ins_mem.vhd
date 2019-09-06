library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ins_mem is
		port(
			addrbus: in std_logic_vector(31 downto 0);
			databus: inout std_logic_vector(31 downto 0)
			--read: in std_logic
			--write: in std_logic
			);
end entity;

architecture mem_behav of ins_mem is
		type memtype is array(natural range<>) of std_logic_vector(7 downto 0);
		signal memdata: memtype(1023 downto 0) := (
			0 => X"83",   
			1 => X"00",
			2 => X"00",
			3 => X"00", 
			
			4 => X"03",
			5 => X"41",
			6 => X"10",
			7 => X"00", --
			
			8 => X"b3",
			9 => X"81",
			10=> X"20",
			11=> X"00",
			
			12=> X"83",
			13=> X"10",
			14=> X"00",
			15=> X"00",
			others => X"11"
		);

begin
		do_read: process(addrbus)
				variable i: integer;
		begin
			i := to_integer(unsigned(addrbus));
			--if (read='1') then
				-- assume little-endian
				databus <= memdata(i+3) & memdata(i+2) & memdata(i+1) & memdata(i);
			--else
				--databus <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			--end if;
		end process do_read;
end;