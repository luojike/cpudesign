library iEEE ;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;

entity alu is
	port(
		clk:in std_logic;
		data1:in std_logic_vector(31 downto 0);
		data2:in std_logic_vector(31 downto 0);
		alu_ctr:in std_logic_vector( 4 downto 0 );
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
			when "00010" =>  res <= std_logic_vector(data1 + data2);
			when "00110" => res <= std_logic_vector(data1 - data2);
			
			when "00001" =>  res <= std_logic_vector(data1 or data2);
			when "00000" =>  res <= std_logic_vector(data1 and data2);

			when "00011" =>  res <= std_logic_vector(data1 xor data2 );
			when "00100" =>  res <= to_stdlogicvector(to_bitvector(data1) SRL conv_integer(data2));
			when "00101" =>  res <=to_stdlogicvector(to_bitvector(data1) SLL conv_integer(data2)); 
			when "00111" =>  res <=to_stdlogicvector(to_bitvector(data1) sra conv_integer(data2)); 
			when "01111" =>  res <= data2;
			
			when "11000" => res <= std_logic_vector(data1 - data2);
			when "11001" => res <= std_logic_vector(data1 - data2);
			when "11100" => res <= std_logic_vector(data1 - data2);
			when "11101" => res <= std_logic_vector(data1 - data2);
			when "11110" =>res <= std_logic_vector(data1 - data2);
			when "11111" => res <= std_logic_vector(data1 - data2);
			
			when others => res <= X"00000000";
		end case;
	end process;

	ot:process(clk)
	begin
		if(rising_edge(clk)) then
			alu_res <= res;
			if(alu_ctr="11000"and res=X"00000000") then
				zero <= '1'; 
			elsif(alu_ctr="11001"and res /= X"00000000") then
				zero <= '1';
			elsif(alu_ctr="11100"and signed(res) < 0 ) then
				zero <= '1';
			elsif(alu_ctr="11101"and signed(res) > 0) then
				zero <= '1';
			elsif(alu_ctr="11110"and unsigned(res) < 0) then
				zero <= '1';
			elsif(alu_ctr="11111"and unsigned(res) > 0) then
				zero <= '1';
			else
				zero <= '0';
			end if;
		end if;
	end process;
end;