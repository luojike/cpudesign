library ieee ;

use ieee.std_logic_1164.all ;

entity writeback is
	port(
		--basic
		clrn,writeback_cs : in std_logic ;
		--reg write-back
		rdata_out: out std_logic_vector(15 downto 0) ;
		raddr_out: out std_logic_vector(2 downto 0) ;
		rupdate_out : out std_logic ; --high is active
		rdata_in:in std_logic_vector(15 downto 0) ;
		raddr_in:in std_logic_vector(2 downto 0) ;
		--pc write-back
		pcnew_in : in std_logic_vector(15 downto 0) ;
		pcnew_out : out std_logic_vector(15 downto 0) ;
		pcupdate_out :out std_logic  ;
		cy_in,z_in : in std_logic ;
		--ir
		ir : in std_logic_vector(15 downto 0)
	) ;
end writeback ;

architecture behavior of writeback is

begin
	--just line it
	rdata_out <= rdata_in ;
	raddr_out <= raddr_in ;
	
	process(clrn,writeback_cs)
	begin
		if clrn = '0' then
			pcupdate_out <= '0' ;
			rupdate_out <=  '0' ;
		else
			if writeback_cs = '1' then
				case ir(15 downto 11) is
					--write back reg
					when "00000" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "00001" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "00010" =>
						rupdate_out <= '0' ;
						pcupdate_out <= '0' ;
					when "00011" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "01000" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "01001" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "01010" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "01011" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "01100" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "01101" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "01110" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "01111" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					--write back pc
					when "10100" =>
						rupdate_out <= '0' ;
						pcupdate_out <= '1' ;
					when "10101" =>
						rupdate_out <= '0' ;
						if(z_in = '1') then
							pcupdate_out <= '1' ;
						else
							pcupdate_out <= '0' ;
						end if ;
					when "10110" =>
						rupdate_out <= '0' ;
						if cy_in = '1' then
							pcupdate_out <= '1' ;
						else
							pcupdate_out <= '0' ;
						end if ;
					--write back reg
					when "10111" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "11000" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when "11001" =>
						rupdate_out <= '1' ;
						pcupdate_out <= '0' ;
					when others =>
						rupdate_out <= '0' ;
						pcupdate_out <= '0' ;
				end case ;
			else
				--when the cs has been 0 ,the update signal should be clrear 
				rupdate_out <= '0' ;
				pcupdate_out <= '0' ;
			end if ;
		end if ;
	end process ;
	
	process(clrn,ir,writeback_cs)
	begin
		if(clrn = '0') then
			pcnew_out <= "1111111111111111" ;
		elsif( clrn = '1' and writeback_cs = '1') then
			pcnew_out <= pcnew_in ;
		end if ;
	end process ;
end behavior ;