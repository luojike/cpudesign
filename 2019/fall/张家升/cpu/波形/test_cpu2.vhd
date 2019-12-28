--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Design Name:   
-- Module Name:   D:/xin/cpu_xx/test_cpu2.vhd
-- Project Name:  cpu_xx
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cpu_xx
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
 
ENTITY test_cpu2 IS
END test_cpu2;
 
ARCHITECTURE behavior OF test_cpu2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu_xx
    PORT(
         clrn : IN std_logic;
			clk : IN std_logic;    
			DBUS : INOUT std_logic_vector(15 downto 0);      
			t_beat : OUT std_logic_vector(3 downto 0);
			t_cy : OUT std_logic;
			t_z : OUT std_logic;
			t_ir : OUT std_logic_vector(15 downto 0);
			t_pc : OUT std_logic_vector(15 downto 0);
			nMREQ : OUT std_logic;
			nWR : OUT std_logic;
			nRD : OUT std_logic;
			nBHE : OUT std_logic;
			nBLE : OUT std_logic;
			ABUS : OUT std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clrn : std_logic := '0';
   signal clk : std_logic := '0';

	--BiDirs
  

 	--Outputs
   signal t_beat : std_logic_vector(3 downto 0);
   signal t_cy : std_logic;
   signal t_z : std_logic;
   signal t_ir : std_logic_vector(15 downto 0);
   signal t_pc : std_logic_vector(15 downto 0);
   signal nMREQ : std_logic;
   signal nWR : std_logic;
   signal nRD : std_logic;
   signal nBHE : std_logic;
   signal nBLE : std_logic;
   signal ABUS : std_logic_vector(15 downto 0);
	signal DBUS : std_logic_vector(15 downto 0);
   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu_xx PORT MAP (
          t_beat => t_beat ,
          t_cy => t_cy ,
          t_z => t_z ,
          t_ir => t_ir ,
          t_pc => t_pc ,
          clrn => clrn,
          clk => clk,
          nMREQ => nMREQ,
          nWR => nWR,
          nRD => nRD,
          nBHE => nBHE,
          nBLE => nBLE,
          ABUS => ABUS,
          DBUS => DBUS
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		clrn <= '1' ;
		--MVIR
		DBUS <= "0000100010101010" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 3*clk_period ;
		--MVRR
		DBUS <= "0000011100000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 3*clk_period ;
		--MVRM
		DBUS <= "0001001010101000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 3*clk_period ;
		--MVMR
		DBUS <= "0001100101010101" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for clk_period ;
		DBUS <= "0000000010101010" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for clk_period ;
		--MVRM
		DBUS <= "0001000000000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 3*clk_period ;
		--ADC
		DBUS <= "0100000100000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 3*clk_period ;
		--MVRM
		DBUS <= "0001000000001001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 3*clk_period ;
		--SBB
		DBUS <= "0101000100000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 3*clk_period ;
		--MVRM
		DBUS <= "0001000000010001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--LR
		DBUS <= "1100100100000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--LR
		DBUS <= "1100100000000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--ADC
		DBUS <= "0100000100000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 3*clk_period ;
		--MVRM
		DBUS <= "0001000000011001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--SBB
		DBUS <= "0101000100000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
      wait for 3*clk_period ;
		--MVRM
		DBUS <= "0001000000100001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--MVIR
		DBUS <= "0000101000000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--OR
		DBUS <= "0111000100000010" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--MVRM
		DBUS <= "0001000000101001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--AND
		DBUS <= "0110000100000010" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--MVRM
		DBUS <= "0001000000110001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--ADC INS
		DBUS <= "0100100100000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--SBB INS
		DBUS <= "0101100100000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--OR INS
		DBUS <= "0111100111111111" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--AND INS
		DBUS <= "0110100100000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--MVRR
		DBUS <= "0000011100000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--STC
		DBUS <= "1000100000000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--!!注意指令顺序和仿真顺序的区别!!!
		--JC
		DBUS <= "1011000000000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--JZ
		DBUS <= "1010100011111110" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--JMP
		DBUS <= "1010000000011101" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--CLC
		DBUS <= "1000000000000000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--ADC INS
		DBUS <= "0100100100000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--JC
		DBUS <= "1011000000000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--JZ
		DBUS <= "1010100000000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		------------------EXTEND---------------
		--MVRM
		DBUS <= "0001000100000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--MVIR
		DBUS <= "0000101100100000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		--MOVMRR
		DBUS <= "1011111000000011" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for clk_period ;
		DBUS <= "0000000000000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for clk_period ;
		--MOVRMIX
		DBUS <= "1100010000000001" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for clk_period ;
		DBUS <= "0001001010101000" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for clk_period ;
		--MVRM
		DBUS <= "0001000100001100" ;
		wait for clk_period ;
		DBUS <= "ZZZZZZZZZZZZZZZZ" ;
		wait for 3*clk_period ;
		wait ;
   end process;

END;
