----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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
-------------------
---------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL ;
use IEEE.STD_LOGIC_UNSIGNED.ALL ;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
	port(
		--cs
		alu_cs,clrn:in std_logic ; -- alu_cs '1' is effective , clrn is '0' effective
		--
		ir,pc_in : in std_logic_vector(15 downto 0) ;
		----write back
		Raddr:in std_logic_vector(2 downto 0) ;
		Rdata:in std_logic_vector(15 downto 0) ;
		Rupdate:in std_logic ;
		----output
		ALUOUT :out std_logic_vector(15 downto 0) ;
		
		addr_out:out std_logic_vector(15 downto 0) ;
		Raddr_out:out std_logic_vector(2 downto 0) ;--output the raddr to the write-back moudle
		cy_out,z_out:out std_logic ;
		--pcupdate
		pcnew : out std_logic_vector(15 downto 0) ;
		pcupdate : out std_logic 
		) ;
end alu;

architecture Behavioral of alu is
	type regType is array(7 downto 0) of std_logic_vector(15 downto 0) ;
	--reg 
	signal regs : regType ;
	signal cy,z :std_logic ;
	--cal
begin
	--alu_ready
	process(clrn,alu_cs,ir)
		--ad1:10-8 ,ad2:2-0 ,ad3:7-0 , ad4:10-3
		variable ad1,ad2: integer ;
		variable ad3,ad4:std_logic_vector(7 downto 0) ;
		variable alu,ax,bx:std_logic_vector(16 downto 0) ;
		variable isPositive : std_logic ;
	begin
		if clrn = '0' then
			addr_out <="ZZZZZZZZZZZZZZZZ" ;
			ALUOUT <= "1010101010101010" ;
			cy <= '0' ;
			z <= '0' ;
		elsif alu_cs = '1'  and alu_cs'event then
			--get index or value
			ad1 := conv_integer(ir(10 downto 8)) ;
			ad2 := conv_integer(ir(2 downto 0)) ;
			ad3 := ir(7 downto 0) ;
			ad4 := ir(10 downto 3) ;
--------------------------alu_ready-------------------------------------------------
			case ir(15 downto 11) is
				--mvRR Ri, Rj
				when "00000" =>
					ALUOUT <= regs(ad2) ;
					Raddr_out <= ir(10 downto 8) ;
				--mvIR
				when "00001" =>
					ALUOUT(7 downto 0) <= ad3 ;
					ALUOUT(15 downto 8) <= "00000000" ;
					Raddr_out <= ir(10 downto 8) ;
				--mvRM M,Ri
				when "00010" =>
					ALUOUT <= regs(ad2) ;
					addr_out(7 downto 0) <= ad4 ;
					addr_out(15 downto 8) <= regs(7)(7 downto 0) ;
				--mvMR R,M
				when "00011" =>
					--just for invoke the alu_calculate process,is it ok?
					addr_out(7 downto 0) <= ad3 ;
					addr_out(15 downto 8) <= regs(7)(7 downto 0) ;
					--addr_out <= "0101010101010101" ;
					Raddr_out <= ir(10 downto 8) ;
				--ADC
					--ADCRR
				when "01000" => 
					ax := '0'&regs(ad1) ;
					bx := '0'&regs(ad2) ;
					alu := ax +bx +cy ;
					ALUOUT <= alu(15 downto 0) ;
					--ALUOUT <= "1111111111111111" ;
					cy <= alu(16) ;
					if(conv_integer(alu) = 0) then
						z<= '1' ;
					else
						z <= '0' ;
					end if ;
					Raddr_out <= ir(10 downto 8) ;
					--ADCIR
				when "01001" =>
					ax := '0'&regs(ad1) ;
					bx(7 downto 0) := ad3 ;
					bx(16 downto 8) := "000000000" ;
					alu := ax + bx + cy ;
					ALUOUT <= alu(15 downto 0) ;
					cy <= alu(16) ;
					if(conv_integer(alu) = 0) then
						z<= '1' ;
					else
						z <= '0' ;
					end if ;
					Raddr_out <= ir(10 downto 8) ;
				--SBB
					--SBBRR
				when "01010" =>
					ax := '0'&regs(ad1) ;
					bx := '0'&regs(ad2) ;
					alu := ax - bx - cy ;
					ALUOUT <= alu(15 downto 0) ;
					cy <= alu(16) ;
					if(conv_integer(alu) = 0) then
						z<= '1' ;
					else
						z <= '0' ;
					end if ;
					Raddr_out <= ir(10 downto 8) ;
						--SBBRI
				when "01011" =>
					ax := '0'&regs(ad1) ;
					bx(7 downto 0) := ad3 ;
					bx(16 downto 8) := "000000000" ;
					alu := ax - bx - cy ;
					ALUOUT <= alu(15 downto 0) ;
					cy <= alu(16) ;
					if(conv_integer(alu) = 0) then
						z<= '1' ;
					else
						z <= '0' ;
					end if ;
					Raddr_out <= ir(10 downto 8) ;
				--AND
					--ANDRR
				when "01100" =>
					ax := '0'&regs(ad1) ;
					bx := '0'&regs(ad2) ;
					alu := ax and bx ;
					ALUOUT <= alu(15 downto 0) ;
					cy <= alu(16) ;
					if(conv_integer(alu) = 0) then
						z<= '1' ;
					else
						z <= '0' ;
					end if ;
					Raddr_out <= ir(10 downto 8) ;
					--ANDRI
				when "01101" =>
					ax := '0'&regs(ad1) ;
					bx(7 downto 0) := ad3 ;
					bx(16 downto 8) := "000000000" ;
					alu := ax and bx  ;
					ALUOUT <= alu(15 downto 0) ;
					cy <= alu(16) ;
					if(conv_integer(alu) = 0) then
						z<= '1' ;
					else
						z <= '0' ;
					end if ;
					Raddr_out <= ir(10 downto 8) ;
				--OR
					--ORRR
				when "01110" =>
					ax := '0'&regs(ad1) ;
					bx(7 downto 0) := ad3 ;
					bx(16 downto 8) := "000000000" ;
					alu := ax or bx ;
					ALUOUT <= alu(15 downto 0) ;
					cy <= alu(16) ;
					if(conv_integer(alu) = 0) then
						z<= '1' ;
					else
						z <= '0' ;
					end if ;
					Raddr_out <= ir(10 downto 8) ;
					--ORRI
				when "01111" =>
					ax := '0'&regs(ad1) ;
					bx(7 downto 0) := ad3 ;
					bx(16 downto 8) := "000000000" ;
					alu := ax or bx  ;
					ALUOUT <= alu(15 downto 0) ;
					cy <= alu(16) ;
					if(conv_integer(alu) = 0) then
						z<= '1' ;
					else
						z <= '0' ;
					end if ;
					Raddr_out <= ir(10 downto 8) ;
				--CLC
				when "10000" =>
					cy <= '0' ;
				--STC
				when "10001" =>
					cy <= '1' ;
				--JMP
				when "10100" =>
					
					ALUOUT(7 downto 0) <= ad3 ;
					ALUOUT(15 downto 8) <= "00000000" ;
				----------JZ,JC ,in alu we just calculate it and ouput it from aluout to pc_new or write-back
				----------and decided if write back pc at write-back moudle
				--JZ
				when "10101" =>
					isPositive := '1' ;
					if ad3(7) = '1' then
						ad3 := not ad3 + '1' ;
						isPositive := '0' ;
					end if ;
					ax(15 downto 0) := pc_in ;
					bx(7 downto 0) := ad3 ;
					bx(15 downto 8) := "00000000" ;
					if isPositive = '1' then
					alu := ax +bx + '1';
					else 
					alu:= ax - bx + '1' ;
					end if ;
					ALUOUT <= alu(15 downto 0) ;
				--JC
				when "10110" =>
					isPositive := '1' ;
					if ad3(7) = '1' then
						ad3 := not ad3 + '1' ;
						isPositive := '0' ;
					end if ;
					ax(15 downto 0) := pc_in ;
					bx(7 downto 0) := ad3 ;
					bx(15 downto 8) := "00000000" ;
					if isPositive = '1' then
					alu := ax + bx + '1' ;
					else
					alu := ax - bx + '1' ;
					end if ;
					ALUOUT <= alu(15 downto 0) ;
				--------extend
				--movMRR
				when "10111" =>
					addr_out <= regs(ad2) ;
					Raddr_out <= ir(10 downto 8) ;
				--movMRIX
				when "11000" =>
					ax := '0'&regs(6) ;
					bx(7 downto 0) := ad3 ;
					bx(16 downto 8) := "000000000" ;
					alu := ax +bx ;
					addr_out <= alu(15 downto 0) ;
					Raddr_out <= ir(10 downto 8) ;
				--LR
				when "11001" =>
					ALUOUT(7 downto 0) <= regs(ad1)(15 downto 8) ;
					ALUOUT(15 downto 8) <= regs(ad1)(7 downto 0) ;
					Raddr_out <= ir(10 downto 8) ;
				when others =>
			end case ;
---------------------------end alu_ready------------------------------------------------
		end if ;
	end process ;
	
-----------out put-----------	
		cy_out <= cy ;
		z_out <= z ;
------------write_back------
	process(Rupdate,Raddr,Rdata)
	begin
		if(Rupdate = '1') then
			regs(conv_integer(Raddr)) <= Rdata ;
		end if ;
	end process ;
---to update pc
	process(clrn,alu_cs)
	begin
	if(clrn = '0') then
		pcupdate <= '0' ; 
	elsif(alu_cs = '1') then
		pcnew <= pc_in + "0000000000000001" ;
		pcupdate<= '1' ;
	else
		pcupdate <= '0' ;
	end if ;
	end process ;
end Behavioral;

