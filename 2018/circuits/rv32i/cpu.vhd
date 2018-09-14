library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.regsprober.all;

entity cpu is
	port(
		clk: in std_logic;
		reset: in std_logic;
		inst_addr: out std_logic_vector(31 downto 0);
		inst: in std_logic_vector(31 downto 0);
		data_addr: out std_logic_vector(31 downto 0);
		data_in: in std_logic_vector(31 downto 0);
		data_out: out std_logic_vector(31 downto 0);
		data_read: out std_logic;
		data_write: out std_logic
	);
end entity cpu;

architecture behav of cpu is
		signal ir: std_logic_vector(31 downto 0);
		signal pc: std_logic_vector(31 downto 0);

		signal next_pc: std_logic_vector(31 downto 0);

		-- Fields in instruction
		signal opcode: std_logic_vector(6 downto 0);
		signal rd: std_logic_vector(4 downto 0);
		signal funct3: std_logic_vector(2 downto 0);
		signal rs1: std_logic_vector(4 downto 0);
		signal rs2: std_logic_vector(4 downto 0);
		signal funct7: std_logic_vector(6 downto 0);

		signal src1: std_logic_vector(31 downto 0);
		signal src2: std_logic_vector(31 downto 0);
		signal addresult: std_logic_vector(31 downto 0);
		signal subresult: std_logic_vector(31 downto 0);

		type regfile is array(natural range<>) of std_logic_vector(31 downto 0);
		signal regs: regfile(31 downto 0);
		signal reg_write: std_logic;
		signal reg_write_id: std_logic_vector(4 downto 0);
		signal reg_write_data: std_logic_vector(31 downto 0);
begin
		-- register file prober
		gen: for i in 31 downto 0 generate
			regsview(i) <= regs(i);
		end generate gen;

		-- Instruction Fetch
		inst_addr <= pc;
		ir <= inst;

		-- Decode
		-- Not finished
		opcode <= ir(6 downto 0);
		rd <= ir(11 downto 7);
		funct3 <= ir(14 downto 12);
		rs1 <= ir(19 downto 15);
		rs2 <= ir(24 downto 20);
		funct7 <= ir(31 downto 25);

		-- Read operands from register file
		src1 <= regs(TO_INTEGER(UNSIGNED(rs1)));
		src2 <= regs(TO_INTEGER(UNSIGNED(rs2)));

		-- Prepare index and data to write into register file
		reg_write_id <= rd;

		addresult <= STD_LOGIC_VECTOR(SIGNED(src1) + SIGNED(src2));
		subresult <= STD_LOGIC_VECTOR(SIGNED(src1) - SIGNED(src2));
		-- more
		-- ......

		reg_write_data <= addresult when opcode = "0110011" and funct7 = "0000000" else
						  subresult when opcode = "0110011" and funct7 = "0100000" else
						  -- more 
						  -- ......
						  -- At last, set a default value
						  "00000000000000000000000000000000";

		-- Execute
		-- Not finished

		-- Update pc and register file at rising edge of clk
		process(clk)
		begin
			if(rising_edge(clk)) then
				if (reset='1') then
					pc <= "00000000000000000000000000000000";
					-- Clear register file?
				else
					pc <= next_pc;

					if (reg_write = '1') then
						regs(TO_INTEGER(UNSIGNED(reg_write_id))) <= reg_write_data;
					end if; -- reg_write = '1'
				end if; -- reset = '1'
			end if; -- rising_edge(clk)
		end process; -- clk

end architecture behav;

