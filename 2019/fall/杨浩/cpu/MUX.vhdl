library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity mux5 is
port(
A,B:in std_logic_vector(4 downto 0);
s:in std_logic; 
Z:out std_logic_vector(4 downto 0));
end mux5;
architecture Behavioral of mux5 is
begin
Z<=a when s='0'
else b;
end Behavioral;
