library IEEE;
use IEEE.STD_LOGIC_1164. ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--Uncomment the following library declaration if using
--arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC STD.ALL;
--Uncomment the following library declaration if instantiating
--any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity rf is
port(clk,we:in std_logic;
ra,rb,rw:in std_logic_vector(4 downto 0);
rd:in std_logic_vector(31 downto 0);
qa,qb:out std_logic_vector(31 downto 0);
jdb1,jdb2,jdb3,jdb4:out std_logic_vector(31 downto 0));
end rf;

architecture Behavioral of rf is
type JCQwj is array(31 downto 0) of std_logic_vector(31 downto 0);
signal mem:JCQwj; .
begin
process (clk)begin
if clk'event and clk='1' then
if we='1' then
mem(conv_integer(rw))<=rd;
end if;
end if;
end process;
process (clk)begin
if(conv_integer(ra)=0)then
qa<=x"00000000";
else qa<=mem(conv_integer(ra));
end if;
if(conv_integer(rb)=0)then
qb<=x"00000000";
else qb<=mem(conv_integer(rb)); .
end if;

jdb1<=mem(conv_integer("10010"));
jdb2<=mem(conv_integer("01000"));
jdb3<=mem(conv_integer("10000"));
jdb4<=mem(conv_integer("10001"));
end process;
end Behavioral;
