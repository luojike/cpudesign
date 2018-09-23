library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity cpu_singlecycle is
	port(
		clk: in std_logic;
		reset: in std_logic;
		inst_addr: out std_logic_vector(31 downto 0);
		inst: in std_logic_vector(31 downto 0);
		data_addr: out std_logic_vector(31 downto 0);
		data: inout std_logic_vector(31 downto 0);
		data_read: out std_logic;
		data_write: out std_logic
	);
end entity cpu_singlecycle;

architecture behav of cpu_singlecycle is
		signal ir: std_logic_vector(31 downto 0);
		signal pc: std_logic_vector(31 downto 0);

		signal next_pc: std_logic_vector(31 downto 0);

		signal opcode: std_logic_vector(6 downto 0);
		signal rd: std_logic_vector(4 downto 0);
		signal funct3: std_logic_vector(2 downto 0);
		signal Imm11: std_logic_vector(11 downto 0);
		signal rs1: std_logic_vector(4 downto 0);
		signal rs2: std_logic_vector(4 downto 0);
		signal shamt: std_logic_vector(4 downto 0);
		signal funct7: std_logic_vector(6 downto 0);
		
		signal src1: std_logic_vector(31 downto 0);
		signal src2: std_logic_vector(31 downto 0);
		signal BLTaddr: std_logic_vector(4 downto 0);
		signal SLTIres: std_logic_vector(31 downto 0);
		signal SRLIres:std_logic_vector(31 downto 0);
		signal SLTUres:std_logic_vector(31 downto 0);
		type regfile is array(31 downto 0) of std_logic_vector(31 downto 0);
		signal regs: regfile;
		signal reg_write: std_logic;
		signal reg_write_id: std_logic_vector(4 downto 0);
		signal reg_write_data: std_logic_vector(31 downto 0);
		begin
		-- Instruction Fetch
		inst_addr <= pc;
		ir <= inst;

		opcode <= ir(6 downto 0);
		rd <= ir(11 downto 7);
		funct3 <= ir(14 downto 12);
		rs1 <= ir(19 downto 15);
		rs2 <= ir(24 downto 20);
		shamt <= ir(31 downto 20);
		funct7 <= ir(31 downto 25);
		
		-- Read operands from register file
		src1 <= regs(TO_INTEGER(UNSIGNED(rs1)));
		src2 <= regs(TO_INTEGER(UNSIGNED(rs2)));
		-- Prepare index and data to write into register file
		reg_write_id <= rd;

		-- more
		-- ......
		
		BLTaddr <= ir(11 downto 7);
					
		SLTIres<="00000000000000000000000000000001" when SIGNED(src1) <  SIGNED(funct7) else
					"00000000000000000000000000000000";
		
		SRLIres <= src1 SRA UNSIGNED(shamt);

		SLTUres<="00000000000000000000000000000001" when SIGNED(src2) /= 0 else
					"00000000000000000000000000000000";
		
		reg_write <= '1' when (opcode = "0010011" and (funct3 = "010" or funct3 = "101") or (opcode = "0110011" and funct3 = "011") else
					 '0';
					 
		reg_write_data <= SLTIres when opcode = "0010011" and funct3 = "010" else
						  SRLIres when opcode = "0010011" and funct3 = "101" else
						  SLTUres when opcode = "0110011" and funct3 = "011" else
						  "00000000000000000000000000000000";
		next_pc <= 	STD_LOGIC_VECTOR(UNSIGNED(pc)+UNSIGNED(BLTaddr)) when SIGNED(src1) < SIGNED(src2) and opcode = "1100011" and funct3 = "100" else
					STD_LOGIC_VECTOR(UNSIGNED(pc)+4);

		-- Update pc and register file at rising edge of clk
		process(clk)
		begin
			if(rising_edge(clk)) then
				if (reset='1') then
					pc <= "00000000000000000000000000000000";
				else
					pc <= next_pc;

					if (reg_write = '1') then
						regs(TO_INTEGER(UNSIGNED(reg_write_id))) <= reg_write_data;
					end if;
				end if;
			end if;
		end process;

end architecture behav;
