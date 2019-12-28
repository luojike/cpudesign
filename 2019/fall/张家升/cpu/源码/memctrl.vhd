library ieee ;
use ieee.std_logic_1164.all ;

entity memctrl is
	port(
		--
		clrn : in std_logic ;
		--from 'fetch' moudle
		f_nBLE,f_nBHE: in std_logic ;
		f_nMREQ,f_nRD,f_nWR : in std_logic ;
		pc_in : in std_logic_vector(15 downto 0) ;
		ir_out : out std_logic_vector(15 downto 0) ;
		--from alu
		addr_in : in std_logic_vector(15 downto 0) ;
		--from 'readwrite' moudle
		rw_nBLE,rw_nBHE: in std_logic ;
		rw_nMREQ,rw_nRD,rw_nWR: in std_logic ;
		rtemp_in : in std_logic_vector(15 downto 0) ;
		rtemp_out : out std_logic_vector(15 downto 0) ;
		--select state
		T0: in std_logic ;
		T2: in std_logic ;
		--out 
		nMREQ,nBHE,nBLE,nWR,nRD : out std_logic ;
		MAR : out std_logic_vector(15 downto 0) ;
		MDR : inout std_logic_vector(15 downto 0)
	) ;
end memctrl ;

architecture behavior of memctrl is

begin
	process(clrn,T0,T2,pc_in,f_nMREQ,f_nRD,rw_nRD,rw_nWR)
	begin
		if(clrn = '1' and T0 = '1' and T2 = '0' and f_nRD = '0') then
			nMREQ <= '0' ;
			nRD <= '0' ;
			nWR <= '1' ;
			nBHE <= '0' ;
			nBLE <= '0' ;
		elsif(clrn = '1' and T0 = '0' and T2 = '1' and rw_nWR = '0') then
			nMREQ <= '0' ;
			nRD <= '1' ;
			nWR <= '0' ;
			nBHE <= '0' ;
			nBLE <= '0' ;
		elsif(clrn = '1' and T0 = '0' and T2 = '1' and rw_nRD = '0') then
			nMREQ <= '0' ;
			nRD <= '0' ;
			nWR <= '1' ;
			nBHE <= '0' ;
			nBLE <= '0' ;
		else
			nMREQ <= '1' ;
			nRD <= '1' ;
			nWR <= '1' ;
			nBHE <= '1' ;
			nBLE <= '1' ;
		end if ;
	end process ;
	
	process(clrn,T0,T2,pc_in,f_nMREQ,f_nRD,rw_nRD,rw_nWR) 
	begin
		if(clrn = '1' and T0 = '1' and T2 = '0' and f_nRD = '0') then
			MDR <= "ZZZZZZZZZZZZZZZZ";
			ir_out <= MDR ;
		elsif(clrn = '1' and T0 = '0' and T2 = '1' and rw_nWR = '0') then
			MDR <= rtemp_in ;
		elsif(clrn = '1' and T0 = '0' and T2 = '1' and rw_nRD = '0') then
			MDR <= "ZZZZZZZZZZZZZZZZ" ;
			rtemp_out <= MDR ;
		else
			MDR <= "ZZZZZZZZZZZZZZZZ" ;
		end if ;
	end process ;
	
	process(clrn,T0,T2,pc_in,f_nMREQ,f_nRD,rw_nRD,rw_nWR) 
	begin
		if(clrn = '1' and T0 = '1' and T2 = '0' and f_nRD = '0') then
			MAR <= pc_in ;
		elsif(clrn = '1' and T0 = '0' and T2 = '1' and rw_nWR = '0') then
			MAR <= addr_in ;
		elsif(clrn = '1' and T0 = '0' and T2 = '1' and rw_nRD = '0') then
			MAR <= addr_in ;
		else
			MAR <= "ZZZZZZZZZZZZZZZZ" ;
		end if ;
	end process ;
end behavior ;