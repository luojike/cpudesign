library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
	port(
			clk: in std_logic;
			reset: in std_logic;
			inst_addr: out std_logic_vector(31 downto 0);  -- 指令地址
			inst: in std_logic_vector(31 downto 0);
		  inst_read: out std_logic;
			data_addr: out std_logic_vector(31 downto 0);  -- 数据地址
			data: inout std_logic_vector(31 downto 0);
		  data_read: out std_logic;
			data_write: out std_logic
		);
end entity;

architecture cpu_behav of cpu is
	type regfile is array(natural range<>) of std_logic_vector(31 downto 0);
	signal regs: regfile(31 downto 0);
	signal pc: std_logic_vector(31 downto 0);
	signal ir: std_logic_vector(31 downto 0);
  signal next_pc: std_logic_vector(31 downto 0);

begin
	-- 组合逻辑部分
  inst_addr <= pc;  -- 取指地址
	inst_read <= '1' when reset = '0' else '0';  -- 当reset无效时发出指令读取信号;
	ir <= inst;  -- 当前指令
  next_pc <= std_logic_vector(unsigned(pc) + 4);  -- when ... else ... when ... else ...; -- 需补充其它情况
  
  -- ...... (其它组合逻辑)
  
  
  -- 时序逻辑部分
	pc_update: process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset='1') then
				pc <= X"00000000";  -- 当reset信号有效时，pc被重置为0
			else
				pc <= next_pc;
			end if;
		end if;
	end process do_reset;
    
  -- ...... (其它时序逻辑)

end;
