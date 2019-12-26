library IEEE;
use IEEE.STD_LOGIC_1164. ALL;
use ieee.std_logic_unsigned.all;
--Uncomment the following library declaration if using
--arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
--Uncomment the following library declaration if instantiating
--any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents all;

entity NPC is
port(
input:in std_logic_vector(31 downto 0);
offset:in std_logic_vector(31 downto 0);
pc:in std_logic_vector(31 downto 0);
nNPCcontrol:in std_logic_vector(1 downto 0);
ALUZero:in std_logic;
npcl:out std_logic_vector(31 downto 0));
end NPC;
architecture Behavioral of NPC is
signal beqj,offsetl:std_logic_vector(31 downto 0);
signal pcl:std_logic_vector(31 downto 0);
begin
pcl<=pc+4; 
offset1<=offset(29 downto 0)&"00";
beq<=pcl+offset1;
j<=pc1(31 downto 28 )&input(25 downto 0)&"00";
	npc1<=pcl when nNPCcontrol="00"
	else beq(31 downto 0) when nNPCcontrol="10" and ALUZero='1'
	else j(31 downto 0) when nNPCcontrol= "01'else pc1;
end Behavioral;
