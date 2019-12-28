--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
---- Design Name:   
-- Module Name:   D:/xilinx/project/cpu_xx_for_wave/test_writeback.vhd
-- Project Name:  cpu_xx_for_wave
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: writeback
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
 
ENTITY test_writeback IS
END test_writeback;
 
ARCHITECTURE behavior OF test_writeback IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT writeback
    PORT(
         clrn : IN  std_logic;
         writeback_cs : IN  std_logic;
         rdata_out : OUT  std_logic_vector(15 downto 0);
         raddr_out : OUT  std_logic_vector(2 downto 0);
         rupdate_out : OUT  std_logic;
         rdata_in : IN  std_logic_vector(15 downto 0);
         raddr_in : IN  std_logic_vector(2 downto 0);
         pcnew_in : IN  std_logic_vector(15 downto 0);
         pcnew_out : OUT  std_logic_vector(15 downto 0);
         pcupdate_out : OUT  std_logic;
         cy_in : IN  std_logic;
         z_in : IN  std_logic;
         ir : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clrn : std_logic := '0';
   signal writeback_cs : std_logic := '0';
   signal rdata_in : std_logic_vector(15 downto 0) := (others => '0');
   signal raddr_in : std_logic_vector(2 downto 0) := (others => '0');
   signal pcnew_in : std_logic_vector(15 downto 0) := (others => '0');
   signal cy_in : std_logic := '0';
   signal z_in : std_logic := '0';
   signal ir : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal rdata_out : std_logic_vector(15 downto 0);
   signal raddr_out : std_logic_vector(2 downto 0);
   signal rupdate_out : std_logic;
   signal pcnew_out : std_logic_vector(15 downto 0);
   signal pcupdate_out : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: writeback PORT MAP (
          clrn => clrn,
          writeback_cs => writeback_cs,
          rdata_out => rdata_out,
          raddr_out => raddr_out,
          rupdate_out => rupdate_out,
          rdata_in => rdata_in,
          raddr_in => raddr_in,
          pcnew_in => pcnew_in,
          pcnew_out => pcnew_out,
          pcupdate_out => pcupdate_out,
          cy_in => cy_in,
          z_in => z_in,
          ir => ir
        );

  
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		clrn <= '1' ;
		
		-----jc ok
		--fetch
		ir <= "1011000000000011" ;
		wait for clk_period ;
		--alu
		cy_in <= '1' ;
		wait for clk_period ;
		--rw
		pcnew_in <= "0000000000000101" ;
		--wb
		writeback_cs <= '1'  ;
		wait for clk_period ;
		
		-----jc not 
		--fetch
		writeback_cs <= '0' ;
		ir <= "1011000000000011" ;
		wait for clk_period ;
		--alu
		cy_in <= '0' ;
		wait for clk_period ;
		--rw
		pcnew_in <= "0000000000000001" ;
		--wb
		writeback_cs <= '1'  ;
		wait for clk_period ;

		--reg writeback
		--fetch
		writeback_cs <= '0' ;
		ir <= "0000000000000001" ;
		wait for clk_period ;
		--alu
		raddr_in <= "000" ;
		wait for clk_period ;
		--rw
		rdata_in <= "1010101010101010" ;
		--wb
		writeback_cs <= '1'  ;
		wait for clk_period ;
		
		-----no wb
		--fetch
		writeback_cs <= '0' ;
		ir <= "1000100000000000" ;
		wait for clk_period ;
		--alu
		cy_in <= '1' ;
		wait for clk_period ;
		--rw
		rdata_in <= "1010101010101010" ;
		--wb
		writeback_cs <= '1'  ;
		wait for clk_period ;
		writeback_cs <= '0' ;
      wait;
   end process;

END;
