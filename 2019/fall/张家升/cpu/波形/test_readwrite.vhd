--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Design Name:   
-- Module Name:   D:/xilinx/project/cpu_xx_for_wave/test_readwrite.vhd
-- Project Name:  cpu_xx_for_wave
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: readwrite
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
 
ENTITY test_readwrite IS
END test_readwrite;
 
ARCHITECTURE behavior OF test_readwrite IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT readwrite
    PORT(
         readwrite_cs : IN  std_logic;
         clrn : IN  std_logic;
         aluout_in : IN  std_logic_vector(15 downto 0);
         mdr_in : IN  std_logic_vector(15 downto 0);
         rtemp_out : OUT  std_logic_vector(15 downto 0);
         mdr_out : OUT  std_logic_vector(15 downto 0);
         ir : IN  std_logic_vector(15 downto 0);
         nMREQ : OUT  std_logic;
         nRD : OUT  std_logic;
         nWR : OUT  std_logic;
         nBHE : OUT  std_logic;
         nBLE : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal readwrite_cs : std_logic := '0';
   signal clrn : std_logic := '0';
   signal aluout_in : std_logic_vector(15 downto 0) := (others => '0');
   signal mdr_in : std_logic_vector(15 downto 0) := (others => '0');
   signal ir : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal rtemp_out : std_logic_vector(15 downto 0);
   signal mdr_out : std_logic_vector(15 downto 0);
   signal nMREQ : std_logic;
   signal nRD : std_logic;
   signal nWR : std_logic;
   signal nBHE : std_logic;
   signal nBLE : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: readwrite PORT MAP (
          readwrite_cs => readwrite_cs,
          clrn => clrn,
          aluout_in => aluout_in,
          mdr_in => mdr_in,
          rtemp_out => rtemp_out,
          mdr_out => mdr_out,
          ir => ir,
          nMREQ => nMREQ,
          nRD => nRD,
          nWR => nWR,
          nBHE => nBHE,
          nBLE => nBLE
        );

   -- Clock process definitions

 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		clrn <= '1' ;
		----write
		
		--fetch
		ir <= "0001000000000000" ;
		wait for clk_period ;
		--alu
		aluout_in <= "0000111110101010" ;
		wait for clk_period ;
		--rw
		readwrite_cs <= '1' ;
		wait for clk_period ;
		--wb
		readwrite_cs <= '0' ;
		wait for clk_period ;
		
		----read 

		--fetch
		ir <= "0001100010101010" ;
		wait for clk_period ;
		--alu
		aluout_in <= "0000111110101010" ;
		wait for clk_period ;
		--rw
		readwrite_cs <= '1' ;
		mdr_in <= "0101010101010101" ;
		wait for clk_period ;
		--wb
		readwrite_cs <= '0' ;
		wait for clk_period ;
		
		--just transport
		
		--fetch
		ir <= "0000000000000001" ;
		wait for clk_period ;
		--alu
		aluout_in <= "1010101010101010" ;
		wait for clk_period ;
		--rw
		readwrite_cs <= '1' ;
		mdr_in <= "0101010101010101" ;
		wait for clk_period ;
		--wb
		readwrite_cs <= '0' ;
		wait for clk_period ;

      wait;
   end process;

END;
