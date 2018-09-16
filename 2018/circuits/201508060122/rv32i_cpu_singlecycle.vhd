library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity rv32i_cpu_singlecycle is
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
end entity rv32i_cpu_singlecycle;

architecture behav of rv32i_cpu_singlecycle is
		signal ir: std_logic_vector(31 downto 0);
		signal pc: std_logic_vector(31 downto 0);

		signal next_pc: std_logic_vector(31 downto 0);

		-- Fields in instruction
		signal opcode: std_logic_vector(6 downto 0);
		signal rd: std_logic_vector(4 downto 0);
		signal funct3: std_logic_vector(2 downto 0);
		signal rs1: std_logic_vector(4 downto 0);
		signal rs2: std_logic_vector(4 downto 0);
		signal crs:  std_logic_vector(12 downto 0);
		signal funct7: std_logic_vector(6 downto 0);
		
		signal src1: std_logic_vector(31 downto 0);
		signal src2: std_logic_vector(31 downto 0);
		signal src3: std_logic_vector(31 downto 0);
		signal zimm: std_logic_vector(31 downto 0);
		signal CSRRSres : std_logic_vector(31 downto 0);
		signal CSRRWIres: std_logic_vector(31 downto 0);
		signal CSRRCIres: std_logic_vector(31 downto 0);
		signal ebreakaddr:std_logic_vector(31 downto 0);
		type regfile is array(31 downto 0) of std_logic_vector(31 downto 0);
		signal regs: regfile;
		signal reg_write: std_logic;
		signal reg_write_id: std_logic_vector(4 downto 0);
		signal reg_write_data: std_logic_vector(31 downto 0);
		begin
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
		crs <= ir(31 downto 20);
		funct7 <= ir(31 downto 25);
		
		-- Read operands from register file
		src1 <= regs(TO_INTEGER(UNSIGNED(rs1)));
		src2 <= regs(TO_INTEGER(UNSIGNED(rs2)));
		src3 <= regs(TO_INTEGER(UNSIGNED(crs)));
		zimm <= STD_LOGIC_VECTOR(rs1);
		-- Prepare index and data to write into register file
		reg_write_id <= rd;

		-- more
		-- ......
		
		CSRRSres <= STD_LOGIC_VECTOR(SIGNED(src3) or SIGNED(src2));
		CSRRWIres<= zimm when rd /= "0000" else
					"00000000000000000000000000000000";
					
		CSRRCIres<=STD_LOGIC_VECTOR(SIGNED(src3) and SIGNED(zimm)) when rd /= "0000" else
					"00000000000000000000000000000000";
		
		ebreakaddr <= regs(31);
		
		reg_write <= '1' when opcode = "1110011" and (funct3 = "010" or funct3 ="101" or (funct3 = "111" and rd /= "0000")) else
					 '0';
		
					 
		reg_write_data <= CSRRSres  when opcode = "1110011" and funct3 = "010" else
						  CSRRWIres when opcode = "1110011" and funct3 = "101" else
						  CSRRCIres when opcode = "1110011" and funct3 = "111" else 
						  
						  -- more 
						  -- ......
						  -- At last, set a default value
						  "00000000000000000000000000000000";
		next_pc <= 	ebreakaddr when src3 = "00000000000000000000000000000001" and opcode = "1110011" and funct3 = "000" else
					STD_LOGIC_VECTOR(UNSIGNED(pc)+4);
		data_addr <= pc;
		data_write <= reg_write;
		data_read <= '1';
		data_out <= reg_write_data;
		-- Execute
		-- Not finished

		-- Update pc and register file at rising edge of clk
		process(clk)
		begin
			if(rising_edge(clk)) then
				if (reset='1') then
					pc <= "00000000000000000000000000000000";
						
					data_write<='0';
					data_read <='0';
					data_out<="00000000000000000000000000000000";
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

