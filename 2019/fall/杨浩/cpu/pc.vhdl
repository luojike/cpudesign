library IEEE;
use IEEE.STD LOGIC_1164. ALL;

-- Uncomment the following library declaration if using
--arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC STD.ALL;

--Uncomment the following library declaration if instantiating
--any Xilinx primitives in this code.
--library UNISIM; .
--use UNISIM.VComponents .all;

entity PC is
port(clk,clr:in std_logic;
	pc_in:in std_logic_vector(31 downto 0);
	pc_out:out std_logic_vector(31 downto 0));
end PC; 

architecture Behavioral of PC is

begin
process(clk,clr)begin
if clr='1' then
pc_out<=X"00000000";
else if clk'event  and clk='1' then
--shang sheng yan geng xin
pc_out<=pc_in;
end if;
end if;
end process;
end Behavioral;
