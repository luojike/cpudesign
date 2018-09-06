library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity rv32i_cpu_singlecycle is
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
end entity rv32i_cpu_singlecycle;

architecture behav of rv32i_cpu_singlecycle is
		signal ir: std_logic_vector(31 downto 0);
		signal pc: std_logic_vector(31 downto 0);

		signal next_pc: std_logic_vector(31 downto 0);

		-- 指令各个字段
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

		type regfile is array(31 downto 0) of std_logic_vector(31 downto 0);
		signal regs: regfile;
		signal reg_write: std_logic;
		signal reg_write_id: std_logic_vector(4 downto 0);
		signal reg_write_data: std_logic_vector(31 downto 0);
begin
		-- 取指
		inst_addr <= pc;
		ir <= inst;

		-- 译码
		-- 待补充
		opcode <= ir(6 downto 0);
		rd <= ir(11 downto 7);
		funct3 <= ir(14 downto 12);
		rs1 <= ir(19 downto 15);
		rs2 <= ir(24 downto 20);
		funct7 <= ir(31 downto 25);

		-- 读取寄存器操作数
		src1 <= regs(TO_INTEGER(UNSIGNED(rs1), 5));
		src2 <= regs(TO_INTEGER(UNSIGNED(rs2), 5));

		-- 准备写入寄存器组的下标和数据
		reg_write_id <= rd;

		addresult <= SIGNED(src1) + SIGNED(src2);
		subresult <= SIGNED(src1) - SIGNED(src2);
		-- 其它情况
		-- ......

		reg_write_data <= addresult when opcode = "0110011" and funct7 = "0000000" else
						  subresult when opcode = "0110011" and funct7 = "0100000" else
						  -- 其它情况
						  -- ......
						  -- 最后设置一个默认值
						  "0000000000000000000000000000000";

		-- 执行
		-- 待补充

		-- 在时钟clk上升沿更新PC和寄存器组
		process(clk)
		begin
			if(rising_edge(clk)) then
				if (reset='1') then
					pc <= "00000000000000000000000000000000";
					-- 寄存器组是否也清零？
				else
					pc <= next_pc;

					if (reg_write = '1') then
						regs(TO_INTEGER(UNSIGNED(reg_write_id), 5)) <= reg_write_data;
					end if; -- reg_write = '1'
				end if; -- reset = '1'
			end if; -- rising_edge(clk)
		end process; -- clk

end architecture behav;

