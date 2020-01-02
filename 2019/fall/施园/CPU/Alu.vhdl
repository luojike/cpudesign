library iEEE ;
use IEEe.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_ARITH.all;
entity alu is
port(
		clk:in std_logic;
		data1:in std_logic_vector(31 downto 0);
		data2:in std_logic_vector(31 downto 0);
		alu_ctr:in std_logic_vector( 3 downto 0 );
		alu_res:out std_logic_vector( 31 downto 0 );
		zero:out std_logic
		);
end alu;
architecture alu_behav of alu is
signal res:std_logic_vector(31 downto 0); 
begin
	result:process(data1,data2,alu_ctr)
		begin
		case alu_ctr is
			when "0010" =>  res <= std_logic_vector(data1 + data2);
			when "0110" =>  res <= std_logic_vector(data1 - data2);
			when "0001" =>  res <= std_logic_vector(data1 or data2);
			when "0000" =>  res <= std_logic_vector(data1 and data2);
			when "0011" =>  res <= std_logic_vector(data1 xor data2 );
			when "0100" =>  res <= to_stdlogicvector(to_bitvector(data1) SRL conv_integer(data2));
			when "0101" =>  res <=to_stdlogicvector(to_bitvector(data1) SLL conv_integer(data2)); 
			when "0111" =>  res <=to_stdlogicvector(to_bitvector(data1) sra conv_integer(data2)); 
			when "1111" =>  res <= data2(19 downto 0) & X"000";	
			when others => res <= X"00000000";
		end case;
	end process;
	p0:process(clk)
	begin
		if(rising_edge(clk)) then
		alu_res <= res;
		if(res=X"00000000") then
		zero <= '1'; 
		end if;
		end if;
	end process;
end;
