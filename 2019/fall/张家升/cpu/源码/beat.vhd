----------------------------------------------------------------------------------

--节拍模块
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity beat is
	port(
		clk,clrn : in std_logic ;
		T1,T2,T3,T4:out std_logic
	); 
end beat;
--高电平有效
architecture Behavioral of beat is
	signal beats : std_logic_vector(3 downto 0):="0000" ;
begin
	process(clk,clrn)
	begin
		if( clrn = '0' ) then
			beats <= "0000" ;
		elsif (clk = '1' and clk'event ) then
			beats(2)<=beats(3) ;
			beats(1)<=beats(2) ;
			beats(0)<=beats(1) ;
			if(beats = "0000") then
				beats(3) <= '1' ;
			else
				beats(3)<=beats(0) ;
			end if ;
		end if ;
	end process ;
	T1 <= beats(3) ;
	T2 <= beats(2) ;
	T3 <= beats(1) ;
	T4 <= beats(0) ;
end Behavioral;

