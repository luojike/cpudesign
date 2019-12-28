--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Design Name:   
-- Module Name:   D:/xin_project/cpu_xx_final_forWave/test_fetch.vhd
-- Project Name:  cpu_xx_final_forWave
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fetch
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_fetch IS
END test_fetch;
 
ARCHITECTURE behavior OF test_fetch IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fetch
    PORT(
         clk : IN  std_logic;
         t2 : IN  std_logic;
         T4 : IN  std_logic;
         f_cs : IN  std_logic;
         clrn : IN  std_logic;
         pc_update_alu : IN  std_logic;
         pc_new_alu : IN  std_logic_vector(15 downto 0);
         pc_update_writeback : IN  std_logic;
         pc_new_writeback : IN  std_logic_vector(15 downto 0);
         pc_out : OUT  std_logic_vector(15 downto 0);
         ir_in : IN  std_logic_vector(15 downto 0);
         nrd : OUT  std_logic;
         nMREQ : OUT  std_logic;
         nwr : OUT  std_logic;
         nble : OUT  std_logic;
         nbhe : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal t2 : std_logic := '0';
   signal T4 : std_logic := '0';
   signal f_cs : std_logic := '0';
   signal clrn : std_logic := '0';
   signal pc_update_alu : std_logic := '0';
   signal pc_new_alu : std_logic_vector(15 downto 0) := (others => '0');
   signal pc_update_writeback : std_logic := '0';
   signal pc_new_writeback : std_logic_vector(15 downto 0) := (others => '0');
   signal ir_in : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal pc_out : std_logic_vector(15 downto 0);
   signal nrd : std_logic;
   signal nMREQ : std_logic;
   signal nwr : std_logic;
   signal nble : std_logic;
   signal nbhe : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fetch PORT MAP (
          clk => clk,
          t2 => t2,
          T4 => T4,
          f_cs => f_cs,
          clrn => clrn,
          pc_update_alu => pc_update_alu,
          pc_new_alu => pc_new_alu,
          pc_update_writeback => pc_update_writeback,
          pc_new_writeback => pc_new_writeback,
          pc_out => pc_out,
          ir_in => ir_in,
          nrd => nrd,
          nMREQ => nMREQ,
          nwr => nwr,
          nble => nble,
          nbhe => nbhe
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		clrn <= '0' ;
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		--pc + 1
		clrn <= '1' ;
		f_cs <= '1' ;
		T2 <= '0' ;
		T4 <= '0' ;
		wait for clk_period ;
		f_cs <= '0' ;
		t2 <= '1' ;
		pc_update_alu <= '1' ;
		pc_new_alu <= "0000000000000001" ;
		wait for clk_period ;
		t2 <= '0' ;
		wait for clk_period ;
		t4 <= '1' ;
		pc_update_writeback <= '0' ;
		wait for clk_period ;
		--writeback pc at writeback moudle
		f_cs <= '1' ;
		t4 <= '0' ;
		wait for clk_period ;
		f_cs <= '0' ;
		t2 <= '1' ;
		pc_update_alu <= '1' ;
		pc_new_alu <= "0000000000000010" ;
		wait for clk_period ;
		t2 <= '0' ;
		wait for clk_period ;
		t4 <= '1' ;
		pc_update_writeback <= '1' ;
		pc_new_writeback <= "0000000000001111" ;
		wait for clk_period ;
		--
		f_cs <= '1' ;
		T2 <= '0' ;
		T4 <= '0' ;
		wait for clk_period ;
		f_cs <= '0' ;
		t2 <= '1' ;
		pc_update_alu <= '1' ;
		pc_new_alu <= "0000000000010000" ;
		wait for clk_period ;
		t2 <= '0' ;
		wait for clk_period ;
		t4 <= '1' ;
		pc_update_writeback <= '0' ;
		wait for clk_period ;
		--
		f_cs <= '1' ;
		T2 <= '0' ;
		T4 <= '0' ;
		wait for clk_period ;
		f_cs <= '0' ;
		t2 <= '1' ;
		pc_update_alu <= '1' ;
		pc_new_alu <= "0000000000010001" ;
		wait for clk_period ;
		t2 <= '0' ;
		wait for clk_period ;
		t4 <= '1' ;
		pc_update_writeback <= '0' ;
		wait for clk_period ;
		--
		f_cs <= '1' ;
		T2 <= '0' ;
		T4 <= '0' ;
		wait for clk_period ;
		f_cs <= '0' ;
		t2 <= '1' ;
		pc_update_alu <= '1' ;
		pc_new_alu <= "0000000000010010" ;
		wait for clk_period ;
		t2 <= '0' ;
		wait for clk_period ;
		t4 <= '1' ;
		pc_update_writeback <= '0' ;
		wait for clk_period ;
		f_cs <= '1' ;
		T2 <= '0' ;
		T4 <= '0' ;
		wait for clk_period ;
		f_cs <= '0' ;
		t2 <= '1' ;
		pc_update_alu <= '1' ;
		pc_new_alu <= "0000000000010011" ;
		wait for clk_period ;
		t2 <= '0' ;
		wait for clk_period ;
		t4 <= '1' ;
		pc_update_writeback <= '0' ;
		wait for clk_period ;
      wait;
   end process; 

END;
