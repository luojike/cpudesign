library IEEE;
use IEEE.STD_LOGIC_1164. ALL;
--Uncomment the following library declaration if using
--arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC STD.ALL;
--Uncomment the following library declaration if instantiating
--anyXilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents all;
entity CU is
port(
op:in std_ logic_ vector(5 downto 0);
func:in std_ logic_ vector(5 downto 0);
RegDst,RegWrite,ALUSrc,MemtoReg, MemWrite,SEControl:out std_ logic;
NPCControl:out std_logic_vector(1 downto 0);
ALUControl:out std_logic_vector(2 downto 0));
end CU;

architecture Behavioral of CU is
signal add,and l,addi,beq,j,sw,lw:std_logic;
begin
process(op,func) begin
if(op="000000" and func="100000")
add<='1';and1<=';addi<='0';beq<='0';j<='0';sw<='0';lw<='0';
elsif(op="000000" and func="100100")
add<='0';and1<='1';addi<='0';beq<='0';j<=';sw<='0';lw<='0';
elsif(op="001000") then add<='0';and1<='0';addi<='1';beq<='0';j<='0';sw<='0';lw<='0';
elsif(op="000100") then add<='0';and1<='0';addi<='0';beq<='1';j<='0';sw<='0';lw<='0';
elsif(op="000010") then add<='0';and1<='0';addi<='0';beq<='0';j<='1';sw<='0';lw<='0';
elsif(op="101011") then add<='0';and1<='0';addi<='0';beq<='0';j<='0';sw<='1';lw<='0';
elsif(op="100011") then add<='0',and1<='0';addi<='0';beq<='0';j<='0';sw<='0';lw<='1';
else NULL;
end if; 
end process;
RegDst<= =addi or lw;
RegWrite<=(add or and1 or addi or Iw) and (not beq);
ALUSrc<=addi or sw or Iw;
MemtoReg<=lw;
MemWrite<=sw;
SEControl<=sw or lw;
NPCControl(1)<=beq;
NPCControl(0)<=j;
ALUControl(2)<='0';
ALUControl(1)<=andl;
ALUControl(0)<=and1 or beq;
end Behavioral;
