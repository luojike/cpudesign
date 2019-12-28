----------------------------------------------------------------------------------
-- 取指模块
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

entity fetch is
	port(
		clk : in std_logic ;
		t2,T4 : IN STD_LOGIC ;
		f_cs,clrn: in std_logic ;
		pc_update_alu: in std_logic ; 
		pc_new_alu: in std_logic_vector(15 downto 0) ;
		pc_update_writeback: in std_logic ; 
		pc_new_writeback: in std_logic_vector(15 downto 0) ;
		pc_out : out std_logic_vector(15 downto 0) ;
		ir_in : in std_logic_vector(15 downto 0) ;
		nrd,nMREQ,nwr : out std_logic ;
		nble,nbhe : out std_logic
			) ;
end fetch;

architecture Behavioral of fetch is
	signal pc:std_logic_vector(15 downto 0) ;
	signal ir:std_logic_vector(15 downto 0) ;
begin
	process(clrn,pc_update_alu,t2,t4,pc_new_alu,clk)
	begin
		if(clrn = '0') then
				pc <= "0000000000000000" ;
		elsif(t2 = '1' and pc_update_alu = '1') then  
				pc <= pc_new_alu ; 
		elsif(t4 = '1' and pc_update_writeback = '1' ) then
				pc <= pc_new_writeback ;
		end if ;
	end process ;
	
	process(clrn,f_cs)
	begin
		if(clrn = '0') then
			pc_out <= "0000000000000000" ;
		elsif(f_cs = '1') then
			pc_out <= pc ;
		end if ;
	end process ;
	
	process(clrn,f_cs)
	begin
	--存控制信号输出
	if(clrn = '0' or f_cs = '0') then
	nrd <= '1' ;
	nMREQ <= '1' ;
	nWR <= '1' ;
	nBHE <= '1' ;
	nBLE <= '1' ;
	elsif(clrn = '1' and f_cs = '1') then
	nrd <= '0' ;
	nMREQ <= '0' ;
	nWR <= '1' ;
	nBHE <= '0' ;
	nBLE <= '0' ;
	end if ;
	end process ;
end Behavioral;

