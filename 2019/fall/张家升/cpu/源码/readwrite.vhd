----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Design Name: 
-- Module Name:    readwrite - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity readwrite is
	port(
	--basic
		readwrite_cs , clrn : in std_logic ;
		--rtemp in
		aluout_in: in std_logic_vector(15 downto 0) ;
		mdr_in :	in std_logic_vector(15 downto 0) ;
		--rtemp out
		rtemp_out : out std_logic_vector(15 downto 0) ;
		mdr_out : out std_logic_vector(15 downto 0) ;
		--ir
		ir: in std_logic_vector(15 downto 0) ;
		--read write control
		nMREQ,nRD,nWR : out std_logic ;
		nBHE,nBLE : out std_logic --high / low 8 bits is active
	) ;
end readwrite;

architecture Behavioral of readwrite is

signal rtemp : std_logic_vector(15 downto 0) ;
begin
	--read write
	process(clrn,readwrite_cs,ir,aluout_in,mdr_in)
	begin
		if clrn = '0' then
			nMREQ <= '1' ;
			nBHE <= '1' ;
			nBLE <= '1' ;
			nRD <= '1' ;
			nWR <= '1' ;
			--it is not necessary ,but ....
			mdr_out <= "ZZZZZZZZZZZZZZZZ" ;
			rtemp_out <= "ZZZZZZZZZZZZZZZZ" ;
		elsif readwrite_cs = '1' then
			case ir(15 downto 11) is
			--mvRM,write the aluout_in to memory
				when "00010" =>
					nMREQ <= '0' ;
					nBHE <= '0' ;
					nBLE <= '0' ;
					nRD <= '1' ;
					nWR <= '0' ;
					mdr_out <= aluout_in ;
				--mvMR,read the memory to the rtemp_out
					--i don't know if it will be ok
				when "00011" =>
					nMREQ <= '0' ;
					nBHE <= '0' ;
					nBLE <= '0' ;
					nRD <= '0' ;
					nWR <= '1' ;
					rtemp_out <= mdr_in ;
				--movMRR,read
				when "10111" =>
					nMREQ <= '0' ;
					nBHE <= '0' ;
					nBLE <= '0' ;
					nRD <= '0' ;
					nWR <= '1' ;
					rtemp_out <= mdr_in ;
				--movMRIX,read
				when "11000" =>
					nMREQ <= '0' ;
					nBHE <= '0' ;
					nBLE <= '0' ;
					nRD <= '0' ;
					nWR <= '1' ;
					rtemp_out <= mdr_in ;
				when others =>
					nMREQ <= '1' ;
					nBHE <= '1' ;
					nBLE <= '1' ;
					nRD <= '1' ;
					nWR <= '1' ;
					rtemp_out <= aluout_in ;
			end case ;
		end if ;
	end process ;
end Behavioral;

