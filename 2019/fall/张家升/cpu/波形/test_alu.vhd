--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
---- Design Name:   
-- Module Name:   D:/xin_project/cpu_xx_final_forWave/test_alu.vhd
-- Project Name:  cpu_xx_final_forWave
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL ;
use IEEE.STD_LOGIC_UNSIGNED.ALL ;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_alu IS
END test_alu;
 
ARCHITECTURE behavior OF test_alu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         alu_cs : IN  std_logic;
         clrn : IN  std_logic;
         ir : IN  std_logic_vector(15 downto 0);
         pc_in : IN  std_logic_vector(15 downto 0);
         Raddr : IN  std_logic_vector(2 downto 0);
         Rdata : IN  std_logic_vector(15 downto 0);
         Rupdate : IN  std_logic;
         ALUOUT : OUT  std_logic_vector(15 downto 0);
         addr_out : OUT  std_logic_vector(15 downto 0);
         Raddr_out : OUT  std_logic_vector(2 downto 0);
         cy_out : OUT  std_logic;
         z_out : OUT  std_logic;
         pcnew : OUT  std_logic_vector(15 downto 0);
         pcupdate : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal alu_cs : std_logic := '0';
   signal clrn : std_logic := '0';
   signal ir : std_logic_vector(15 downto 0) := (others => '0');
   signal pc_in : std_logic_vector(15 downto 0) := (others => '0');
   signal Raddr : std_logic_vector(2 downto 0) := (others => '0');
   signal Rdata : std_logic_vector(15 downto 0) := (others => '0');
   signal Rupdate : std_logic := '0';

 	--Outputs
   signal ALUOUT : std_logic_vector(15 downto 0);
   signal addr_out : std_logic_vector(15 downto 0);
   signal Raddr_out : std_logic_vector(2 downto 0);
   signal cy_out : std_logic;
   signal z_out : std_logic;
   signal pcnew : std_logic_vector(15 downto 0);
   signal pcupdate : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 

	signal inner_pc : std_logic_vector(15 downto 0):="0000000000000000" ;
	constant clk_period : time := 10 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          alu_cs => alu_cs,
          clrn => clrn,
          ir => ir,
          pc_in => pc_in,
          Raddr => Raddr,
          Rdata => Rdata,
          Rupdate => Rupdate,
          ALUOUT => ALUOUT,
          addr_out => addr_out,
          Raddr_out => Raddr_out,
          cy_out => cy_out,
          z_out => z_out,
          pcnew => pcnew,
          pcupdate => pcupdate
        );



   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		clrn <= '0' ;
      wait for 100 ns;	
		clrn <= '1' ;
		--------------MVIR
		--fetch
		
		alu_cs <= '0' ;
		ir <= "0000100010101010" ;
		pc_in <= inner_pc ;
		wait for clk_period ;
		--alu
		alu_cs <= '1' ;
		inner_pc <= inner_pc + '1' ;
		wait for clk_period ;
		--readwrite
		alu_cs <= '0' ;
		wait for clk_period ;
		--writeback
		raddr <= "000" ;
		rdata <= "0000000010101010" ;
		rupdate <= '1' ;
		wait for clk_period ;
      ------MVRR
		alu_cs <= '0' ;
		rupdate <= '0' ;
		ir <= "0000011100000000" ;
		pc_in <= inner_pc ;
		wait for clk_period ;
		--alu
		alu_cs <= '1' ;
		inner_pc <= inner_pc + '1' ;
		wait for clk_period ;
		--readwrite
		alu_cs <= '0' ;
		wait for clk_period ;
		--writeback
		raddr <= "111" ;
		rdata <= "0000000010101010" ;
		rupdate <= '1' ;
		wait for clk_period ;
		-----------MVRM
			--fetch
		rupdate <= '0' ;
		alu_cs <= '0' ;
		ir <= "0001000010000000" ;
		pc_in <= inner_pc ;
		wait for clk_period ;
		--alu
		alu_cs <= '1' ;
		inner_pc <= inner_pc + '1' ;
		wait for clk_period ;
		--readwrite
		alu_cs <= '0' ;
		wait for clk_period ;
		--writeback
		wait for clk_period ;
		--------MVMR
		alu_cs <= '0' ;
		ir <= "0001100100010000" ;
		pc_in <= inner_pc ;
		wait for clk_period ;
		--alu
		alu_cs <= '1' ;
		inner_pc <= inner_pc + '1' ;
		wait for clk_period ;
		--readwrite
		alu_cs <= '0' ;
		wait for clk_period ;
		--writeback
		raddr <= "001" ;
		rdata <= "0000000010101010" ;
		rupdate <= '1' ;
		wait for clk_period ;
		-----------STC
		alu_cs <= '0' ;
		rupdate <= '0' ;
		ir <= "1000100000000000" ;
		pc_in <= inner_pc ;
		wait for clk_period ;
		--alu
		alu_cs <= '1' ;
		inner_pc <= inner_pc + '1' ;
		wait for clk_period ;
		--readwrite
		alu_cs <= '0' ;
		wait for clk_period ;
		--writeback
		wait for clk_period ;
		-------ADC
		alu_cs <= '0' ;
		rupdate <= '0' ;
		ir <= "0100000100000000" ;
		pc_in <= inner_pc ;
		wait for clk_period ;
		--alu
		alu_cs <= '1' ;
		inner_pc <= inner_pc + '1' ;
		wait for clk_period ;
		--readwrite
		alu_cs <= '0' ;
		wait for clk_period ;
		--writeback
		raddr <= "001" ;
		rdata <= "0000000101010100" ;
		rupdate <= '1' ;
		wait for clk_period ;
		-----SBB
		alu_cs <= '0' ;
		rupdate <= '0' ;
		ir <= "0101000100000001" ;
		pc_in <= inner_pc ;
		wait for clk_period ;
		--alu
		alu_cs <= '1' ;
		inner_pc <= inner_pc + '1' ;
		wait for clk_period ;
		--readwrite
		alu_cs <= '0' ;
		wait for clk_period ;
		--writeback
		raddr <= "001" ;
		rdata <= "0000000010101010" ;
		rupdate <= '1' ;
		wait for clk_period ;
		-------Jz
		alu_cs <= '0' ;
		rupdate <= '0' ;
		ir <= "1011000000000001" ;
		pc_in <= inner_pc ;
		wait for clk_period ;
		--alu
		alu_cs <= '1' ;
		inner_pc <= inner_pc + '1' ;
		wait for clk_period ;
		--readwrite
		alu_cs <= '0' ;
		wait for clk_period ;
		--writeback
		wait for clk_period ;
		----MOVMRR
		alu_cs <= '0' ;
		rupdate <= '0' ;
		ir <= "1011111000000000" ;
		pc_in <= inner_pc ;
		wait for clk_period ;
		--alu
		alu_cs <= '1' ;
		inner_pc <= inner_pc + '1' ;
		wait for clk_period ;
		--readwrite
		alu_cs <= '0' ;
		wait for clk_period ;
		--writeback
		raddr <= "110" ;
		rdata <= "0000000000000001" ;
		rupdate <= '1' ;
		wait for clk_period ;
		-----MOVMRIX
		alu_cs <= '0' ;
		rupdate <= '0' ;
		ir <= "1100010000101111" ;
		pc_in <= inner_pc ;
		wait for clk_period ;
		--alu
		alu_cs <= '1' ;
		inner_pc <= inner_pc + '1' ;
		wait for clk_period ;
		--readwrite
		alu_cs <= '0' ;
		wait for clk_period ;
		--writeback
		raddr <= "100" ;
		rdata <= "1010101010101010" ;
		rupdate <= '1' ;
		wait for clk_period ;
      wait;
   end process;

END;
