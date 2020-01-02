library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpupipeplined is
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
end entity cpupipeplined;

architecture behav of cpupipeplined is
		signal ir: std_logic_vector(31 downto 0);
		signal pc: std_logic_vector(31 downto 0);
		signal npc: std_logic_vector(31 downto 0);

		signal next_pc: std_logic_vector(31 downto 0);

		signal ar: std_logic_vector(31 downto 0);

		signal alu: std_logic;

		-- Fields in instruction
		signal opcode: std_logic_vector(6 downto 0);
		signal rd: std_logic_vector(4 downto 0);
		signal funct3: std_logic_vector(2 downto 0);
		signal rs1: std_logic_vector(4 downto 0);
		signal rs2: std_logic_vector(4 downto 0);
		signal funct7: std_logic_vector(6 downto 0);

		signal src1: std_logic_vector(31 downto 0);
		signal src2: std_logic_vector(31 downto 0);
		signal src2exe: std_logic_vector(31 downto 0);
		signal rdexe: std_logic_vector(4 downto 0);
		signal rdmem: std_logic_vector(4 downto 0);
		signal addresult: std_logic_vector(31 downto 0);
		signal subresult: std_logic_vector(31 downto 0);
		signal aluresult: std_logic_vector(31 downto 0);

		type regfile is array(natural range<>) of std_logic_vector(31 downto 0);
		signal regs: regfile(31 downto 0);
		signal reg_write: std_logic;
		signal reg_write_id: std_logic_vector(4 downto 0);
		signal reg_write_data: std_logic_vector(31 downto 0);
begin
		-- IF stage
		inst_addr <= pc;

		-- ID stage
		rs1 <= ir(19 downto 15);
		rs2 <= ir(24 downto 20);

		-- EXE stage
		addresult <= STD_LOGIC_VECTOR(SIGNED(src1) + SIGNED(src2));
		subresult <= STD_LOGIC_VECTOR(SIGNED(src1) - SIGNED(src2));
		aluresult <= addresult when opcode = "0110011" and funct7 = "0000000" else
			subresult when opcode = "0110011" and funct7 = "0100000" else
			-- more ......
			-- At last, set a default value
			X"00000000";

		-- MEM stage
		data_addr <= ar;
		data_out <= src2exe;

		reg_write_data <= aluresult when alu='1' else data_in;

		-- WB stage
		-- ......

		-- Update pc, register file and stage registers at rising edge of clk
		process(clk)
		begin
			if(rising_edge(clk)) then
				if (reset='1') then
					pc <= "00000000000000000000000000000000";
					ir <= "00000000000000000000000000000000";

					-- Clear register file? To be determined

				else
					-- Update pc
					pc <= next_pc;

					-- IF stage
					ir <= inst;
					npc <= std_logic_vector(unsigned(pc) + 4);

					-- ID stage
					src1 <= regs(TO_INTEGER(UNSIGNED(rs1)));
					src2 <= regs(TO_INTEGER(UNSIGNED(rs2)));
					rd <= ir(11 downto 7);
					opcode <= ir(6 downto 0);
					funct3 <= ir(14 downto 12);
					funct7 <= ir(31 downto 25);


					-- EXE stage
					rdexe <= rd;

					if(opcode="0110011") then
							alu <= '1';
					else
							alu <= '0';
					end if;

					ar <= aluresult;  -- save calculated address for data
					src2exe <= src2;  -- save src2 for use in MEM stage

					-- MEM stage
					rdmem <= rdexe;

					-- WB stage
					reg_write_id <= rdmem;
					if (reg_write = '1') then
						regs(TO_INTEGER(UNSIGNED(reg_write_id))) <= reg_write_data;
					end if; -- reg_write = '1'

				end if; -- reset = '1'
			end if; -- rising_edge(clk)
		end process; -- clk

end architecture behav;