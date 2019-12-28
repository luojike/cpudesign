--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Design Name:   
-- Module Name:   D:/xilinx/project/cpu_xx_for_wave/test_memctrl.vhd
-- Project Name:  cpu_xx_for_wave
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: memctrl
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
 
ENTITY test_memctrl IS
END test_memctrl;
 
ARCHITECTURE behavior OF test_memctrl IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT memctrl
    PORT(
         clrn : IN  std_logic;
         f_nBLE : IN  std_logic;
         f_nBHE : IN  std_logic;
         f_nMREQ : IN  std_logic;
         f_nRD : IN  std_logic;
         f_nWR : IN  std_logic;
         pc_in : IN  std_logic_vector(15 downto 0);
         ir_out : OUT  std_logic_vector(15 downto 0);
         addr_in : IN  std_logic_vector(15 downto 0);
         rw_nBLE : IN  std_logic;
         rw_nBHE : IN  std_logic;
         rw_nMREQ : IN  std_logic;
         rw_nRD : IN  std_logic;
         rw_nWR : IN  std_logic;
         rtemp_in : IN  std_logic_vector(15 downto 0);
         rtemp_out : OUT  std_logic_vector(15 downto 0);
         T0 : IN  std_logic;
         T2 : IN  std_logic;
         nMREQ : OUT  std_logic;
         nBHE : OUT  std_logic;
         nBLE : OUT  std_logic;
         nWR : OUT  std_logic;
         nRD : OUT  std_logic;
         MAR : OUT  std_logic_vector(15 downto 0);
         MDR : INOUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clrn : std_logic := '0';
   signal f_nBLE : std_logic := '0';
   signal f_nBHE : std_logic := '0';
   signal f_nMREQ : std_logic := '0';
   signal f_nRD : std_logic := '0';
   signal f_nWR : std_logic := '0';
   signal pc_in : std_logic_vector(15 downto 0) := (others => '0');
   signal addr_in : std_logic_vector(15 downto 0) := (others => '0');
   signal rw_nBLE : std_logic := '0';
   signal rw_nBHE : std_logic := '0';
   signal rw_nMREQ : std_logic := '0';
   signal rw_nRD : std_logic := '0';
   signal rw_nWR : std_logic := '0';
   signal rtemp_in : std_logic_vector(15 downto 0) := (others => '0');
   signal T1 : std_logic := '0';
   signal T3 : std_logic := '0';

	--BiDirs
   signal MDR : std_logic_vector(15 downto 0);

 	--Outputs
   signal ir_out : std_logic_vector(15 downto 0);
   signal rtemp_out : std_logic_vector(15 downto 0);
   signal nMREQ : std_logic;
   signal nBHE : std_logic;
   signal nBLE : std_logic;
   signal nWR : std_logic;
   signal nRD : std_logic;
   signal MAR : std_logic_vector(15 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memctrl PORT MAP (
          clrn => clrn,
          f_nBLE => f_nBLE,
          f_nBHE => f_nBHE,
          f_nMREQ => f_nMREQ,
          f_nRD => f_nRD,
          f_nWR => f_nWR,
          pc_in => pc_in,
          ir_out => ir_out,
          addr_in => addr_in,
          rw_nBLE => rw_nBLE,
          rw_nBHE => rw_nBHE,
          rw_nMREQ => rw_nMREQ,
          rw_nRD => rw_nRD,
          rw_nWR => rw_nWR,
          rtemp_in => rtemp_in,
          rtemp_out => rtemp_out,
          T0 => T1,
          T2 => T3,
          nMREQ => nMREQ,
          nBHE => nBHE,
          nBLE => nBLE,
          nWR => nWR,
          nRD => nRD,
          MAR => MAR,
          MDR => MDR
        );


   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		MDR <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 100 ns;	
		clrn <= '1' ; 
		----fetch and do nothing
		--fetch
		T1 <= '1' ;
		T3 <= '0' ;
		pc_in <= "0000000000000000" ;
		f_nMREQ <= '0' ;
		f_nRD<= '0' ;
		f_nBHE <= '0' ;
		f_nBLE <= '0' ;
		f_nWR <= '1' ;
		MDR <= "0000000000000000" ;
		wait for clk_period ;
		--alu
		T1 <= '0' ;
		f_nMREQ <= '1' ;
		f_nRD<= '1' ;
		f_nBHE <= '1' ;
		f_nBLE <= '1' ;
		f_nWR <= '1' ;
		MDR<= "ZZZZZZZZZZZZZZZZ" ;
		wait for clk_period ;
		--rw
		T3 <= '1' ;
		rw_nMREQ <= '1' ;
		rw_nWR <= '1' ;
		rw_nBHE <= '1' ;
		rw_nBLE <= '1' ;
		rw_nRD <= '1' ;
		wait for clk_period ;
		--wb
		T3 <= '0' ;
		wait for clk_period ;
		
		---fetch and write
		
		--fetch
		T1 <= '1' ;
		T3 <= '0' ;
		pc_in <= "0000000000000001" ;
		f_nMREQ <= '0' ;
		f_nRD<= '0' ;
		f_nBHE <= '0' ;
		f_nBLE <= '0' ;
		f_nWR <= '1' ;
		MDR <= "0001010101010000" ;
		wait for clk_period ;
		--alu
		T1 <= '0' ;
		f_nMREQ <= '1' ;
		f_nRD<= '1' ;
		f_nBHE <= '1' ;
		f_nBLE <= '1' ;
		f_nWR <= '1' ;
		addr_in <= "0000000010101010" ;
		MDR <= "ZZZZZZZZZZZZZZZZ" ;
		wait for clk_period ;
		--rw
		T3 <= '1' ;
		rtemp_in <= "0101010101010101" ;
		rw_nMREQ <= '0' ;
		rw_nWR <= '0' ;
		rw_nBHE <= '0' ;
		rw_nBLE <= '0' ;
		rw_nRD <= '1' ;
		wait for clk_period ;
		--wb
		T3 <= '0' ;
		rw_nMREQ <= '1' ;
		rw_nWR <= '1' ;
		rw_nBHE <= '1' ;
		rw_nBLE <= '1' ;
		rw_nRD <= '1' ;
		wait for clk_period ;
      -- fetch and read
		
		--fetch
		T1 <= '1' ;
		T3 <= '0' ;
		pc_in <= "0000000000000010" ;
		f_nMREQ <= '0' ;
		f_nRD<= '0' ;
		f_nBHE <= '0' ;
		f_nBLE <= '0' ;
		f_nWR <= '1' ;
		MDR <= "0001100010101010" ;
		wait for clk_period ;
		--alu
		T1 <= '0' ;
		f_nMREQ <= '1' ;
		f_nRD<= '1' ;
		f_nBHE <= '1' ;
		f_nBLE <= '1' ;
		f_nWR <= '1' ;
		MDR <= "ZZZZZZZZZZZZZZZZ" ;
		addr_in <= "0000000010101010" ;
		wait for clk_period ;
		--rw
		T3 <= '1' ;
		rw_nMREQ <= '0' ;
		rw_nWR <= '1' ;
		rw_nBHE <= '0' ;
		rw_nBLE <= '0' ;
		rw_nRD <= '0' ;
		MDR <= "0101010101010101" ;
		wait for clk_period ;
		--wb
		T3 <= '1' ;
		rw_nMREQ <= '1' ;
		rw_nWR <= '1' ;
		rw_nBHE <= '1' ;
		rw_nBLE <= '1' ;
		rw_nRD <= '1' ;
		MDR <= "ZZZZZZZZZZZZZZZZ" ;
		wait for clk_period ;
		
      wait;
   end process;

END;
