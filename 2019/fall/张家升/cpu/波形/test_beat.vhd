--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Design Name:   
-- Module Name:   D:/xin/cpu_xx/test_beat.vhd
-- Project Name:  cpu_xx
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: beat
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
 
ENTITY test_beat IS
END test_beat;
 
ARCHITECTURE behavior OF test_beat IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT beat
    PORT(
         clk : IN  std_logic;
         clrn : IN  std_logic;
         T1 : OUT  std_logic;
         T2 : OUT  std_logic;
         T3 : OUT  std_logic;
         T4 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clrn : std_logic := '0';

 	--Outputs
   signal T1 : std_logic;
   signal T2 : std_logic;
   signal T3 : std_logic;
   signal T4 : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: beat PORT MAP (
          clk => clk,
          clrn => clrn,
          T1 => T1,
          T2 => T2,
          T3 => T3,
          T4 => T4
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
      wait for 100 ns;	

      wait for clk_period*10;
		clrn <= '1' ;
      -- insert stimulus here 

      wait;
   end process;

END;
