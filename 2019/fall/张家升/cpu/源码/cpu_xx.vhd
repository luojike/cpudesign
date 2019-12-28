----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Design Name: 
-- Module Name:    cpu_xx - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu_xx is
	port(
		--for test
		t_beat : out std_logic_vector(3 downto 0) ;
		t_cy,t_z : out std_logic ;
		t_ir: out std_logic_vector(15 downto 0) ;
		t_pc :out std_logic_vector(15 downto 0) ;
		t_DBUS : out std_logic_vector(15 downto 0) ;
		--
		clrn,clk : in std_logic ;
		nMREQ , nWR , nRD : out std_logic ;
		nBHE,nBLE : out std_logic ;
		ABUS : out std_logic_vector(15 downto 0) ;
		DBUS : inout std_logic_vector(15 downto 0) 
	) ;
end cpu_xx;

architecture Behavioral of cpu_xx is
	--beat
	COMPONENT beat
	PORT(
		clk : IN std_logic;
		clrn : IN std_logic;          
		T1 : OUT std_logic;
		T2 : OUT std_logic;
		T3 : OUT std_logic;
		T4 : OUT std_logic
		);
	END COMPONENT;
	--fetch
	COMPONENT fetch
	PORT(
		clk: in std_logic ;
		t2 : IN STD_LOGIC ;
		T4 : IN STD_LOGIC ;
		f_cs : IN std_logic;
		clrn : IN std_logic;
		pc_update_alu: in std_logic ; 
		pc_new_alu: in std_logic_vector(15 downto 0) ;
		pc_update_writeback: in std_logic ; 
		pc_new_writeback: in std_logic_vector(15 downto 0) ;		
		ir_in : IN std_logic_vector(15 downto 0);          
		pc_out : OUT std_logic_vector(15 downto 0);
		nrd : OUT std_logic;
		nMREQ : OUT std_logic;
		nwr : OUT std_logic;
		nble : OUT std_logic;
		nbhe : OUT std_logic
		);
	END COMPONENT;
	--alu
	COMPONENT alu
	PORT(
		alu_cs : IN std_logic;
		clrn : IN std_logic;
		ir : IN std_logic_vector(15 downto 0);
		pc_in : IN std_logic_vector(15 downto 0);
		Raddr : IN std_logic_vector(2 downto 0);
		Rdata : IN std_logic_vector(15 downto 0);
		Rupdate : IN std_logic;          
		ALUOUT : OUT std_logic_vector(15 downto 0);
		addr_out : OUT std_logic_vector(15 downto 0);
		Raddr_out : OUT std_logic_vector(2 downto 0);
		cy_out : OUT std_logic;
		z_out : OUT std_logic;
		pcnew : OUT std_logic_vector(15 downto 0);
		pcupdate : OUT std_logic
		);
	END COMPONENT;
	--readwrite
	COMPONENT readwrite
	PORT(
		readwrite_cs : IN std_logic;
		clrn : IN std_logic;
		aluout_in : IN std_logic_vector(15 downto 0);
		mdr_in : IN std_logic_vector(15 downto 0);
		ir : IN std_logic_vector(15 downto 0);          
		rtemp_out : OUT std_logic_vector(15 downto 0);
		mdr_out : OUT std_logic_vector(15 downto 0);
		nMREQ : OUT std_logic;
		nRD : OUT std_logic;
		nWR : OUT std_logic;
		nBHE : OUT std_logic;
		nBLE : OUT std_logic
		);
	END COMPONENT;
	--writeback
	COMPONENT writeback
	PORT(
		clrn : IN std_logic;
		writeback_cs : IN std_logic;
		rdata_in : IN std_logic_vector(15 downto 0);
		raddr_in : IN std_logic_vector(2 downto 0);
		pcnew_in : IN std_logic_vector(15 downto 0);
		cy_in : IN std_logic;
		z_in : IN std_logic;
		ir : IN std_logic_vector(15 downto 0);          
		rdata_out : OUT std_logic_vector(15 downto 0);
		raddr_out : OUT std_logic_vector(2 downto 0);
		rupdate_out : OUT std_logic;
		pcnew_out : OUT std_logic_vector(15 downto 0);
		pcupdate_out : OUT std_logic
		);
	END COMPONENT;
	--memctrl
	COMPONENT memctrl
	PORT(
		clrn : IN std_logic;
		f_nBLE : IN std_logic;
		f_nBHE : IN std_logic;
		f_nMREQ : IN std_logic;
		f_nRD : IN std_logic;
		f_nWR : IN std_logic;
		pc_in : IN std_logic_vector(15 downto 0);
		addr_in : IN std_logic_vector(15 downto 0);
		rw_nBLE : IN std_logic;
		rw_nBHE : IN std_logic;
		rw_nMREQ : IN std_logic;
		rw_nRD : IN std_logic;
		rw_nWR : IN std_logic;
		rtemp_in : IN std_logic_vector(15 downto 0);
		T0 : IN std_logic ;    
		T2 : IN std_logic ;    
		MDR : INOUT std_logic_vector(15 downto 0);      
		ir_out : OUT std_logic_vector(15 downto 0);
		rtemp_out : OUT std_logic_vector(15 downto 0);
		nMREQ : OUT std_logic;
		nBHE : OUT std_logic;
		nBLE : OUT std_logic;
		nWR : OUT std_logic;
		nRD : OUT std_logic;
		MAR : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
	signal T1 : std_logic ;
	signal T2 : std_logic ;
	signal T3 : std_logic ;
	signal T4 : std_logic ;
	--pcupdate
	signal pcupdateLine_alu : std_logic ;
	signal pcnewLine_alu : std_logic_vector(15 downto 0)  ;
	signal pcupdateLine_writeback : std_logic ;
	signal pcnewLine_writeback : std_logic_vector(15 downto 0)  ;
	--reg update
	signal rupdateLine : std_logic ;
	signal raddrLIne : std_logic_vector(2 downto 0) ;
	signal rdataLine : std_logic_vector(15 downto 0) ;
	--pc
	signal f_pcLine : std_logic_vector(15 downto 0) ;
	--ir
	signal irLine : std_logic_vector(15 downto 0) ; 
	signal f_irInLine: std_logic_vector(15 downto 0) ;
	--
	--mem ctrl
	signal f_nMREQLine , f_nRDLine , f_nWRLine , f_nBHELine , f_nBLELine : std_logic ;
	signal rw_nMREQLine , rw_nRDLine,rw_nWRLine,rw_nBHELine,rw_nBLELine : std_logic ;
	--alu
	signal aluoutLine : std_logic_vector(15 downto 0) ;
	signal alu_raddrOutLine : std_logic_vector(2 downto 0) ;
	signal cyLine,zLine : std_logic ;
	signal addr_outLine : std_logic_vector(15 downto 0) ;
	--readwrite
	signal mdr_inLine : std_logic_vector(15 downto 0) ;
	signal mdr_outLine : std_logic_vector(15 downto 0) ;
	signal rtemp_outLine : std_logic_vector(15 downto 0) ;
begin
	xx1:beat port map(
			clk => clk ,
			clrn => clrn ,
			T1 => T1 ,
			T2 => T2 ,
			T3 => T3 ,
			T4 => T4
			) ;
	xx2:fetch port map(
			clk => clk ,
			t2 => t2 ,
			T4 => t4 ,
			f_cs => T1 ,
			clrn => clrn ,
			pc_update_alu => pcupdateLine_alu ,
			pc_new_alu => pcnewLIne_alu ,
			pc_update_writeback => pcupdateLine_writeback ,
			pc_new_writeback => pcnewLIne_writeback ,
			pc_out => f_pcLine ,
			ir_in => f_irInLine ,
			nrd => f_nRDLine ,
			nMREQ => f_nMREQLine,
			nwr => f_nWRLine ,
			nble => f_nBLELine ,
			nbhe => f_nBHELine
			);
	xx3:alu port map(
			alu_cs => T2 ,
			clrn => clrn ,
			ir => f_irInLine ,
			pc_in => f_pcLine ,
			Raddr => raddrLine ,
			Rdata => rdataLine ,
			Rupdate => rupdateLine ,
			ALUOUT => aluoutLine ,
			addr_out => addr_outLine,
			Raddr_out => alu_raddrOutLine ,
			cy_out => cyLine,
			z_out => zLine ,
			pcnew => pcnewLIne_alu ,
			pcupdate => pcupdateLine_alu 
			);
	xx4: readwrite port map(
			readwrite_cs => T3,
			clrn => clrn ,
			aluout_in => aluoutLine ,
			mdr_in => mdr_inLine ,
			rtemp_out => rtemp_outLine ,
			mdr_out => mdr_outLine ,
			ir => f_irInLine ,
			nMREQ => rw_nMREQLine ,
			nRD => rw_nRDLine ,
			nWR => rw_nWRLine ,
			nBHE => rw_nBHELine ,
			nBLE => rw_nBLELine
			);
	xx5: writeback port map(
			clrn => clrn ,
			writeback_cs => T4 ,
			rdata_out => rdataLine ,
			raddr_out => raddrLine,
			rupdate_out => rupdateLine,
			rdata_in => rtemp_outLine,
			raddr_in => alu_raddrOutLine ,
			pcnew_in => rtemp_outLine ,
			pcnew_out => pcnewLine_writeback ,
			pcupdate_out => pcupdateLine_writeback ,
			cy_in => cyLine,
			z_in => zLine,
			ir => f_irInLine
			);
	xx6: memctrl port map(
			clrn => clrn ,
			f_nBLE => f_nBLELine ,
			f_nBHE => f_nBHELine ,
			f_nMREQ => f_nMREQLine,
			f_nRD => f_nRDLine ,
			f_nWR => f_nWRLine ,
			pc_in => f_pcLine,
			ir_out => f_irInLine ,
			addr_in => addr_outLine ,
			rw_nBLE => rw_nBLELine ,
			rw_nBHE => rw_nBHELine ,
			rw_nMREQ => rw_nMREQLine ,
			rw_nRD => rw_nRDLine ,
			rw_nWR => rw_nWRLine ,
			rtemp_in => mdr_outLine ,
			rtemp_out => mdr_inLine,
			T0 => T1 ,
			T2 => T3 ,------!!!!!!!!!¸ßÎ»ÊÇT0!!!!!!!!!!!
			nMREQ => nMREQ ,
			nBHE => nBHE ,
			nBLE => nBLE ,
			nWR => nWR ,
			nRD => nRD ,
			MAR => ABUS,
			MDR => DBUS
			);
	t_beat(3) <= T1 ;
	t_beat(2) <= T2 ;
	t_beat(1) <= T3 ;
	t_beat(0) <= T4 ;
	t_cy <= cyLine ;
	t_z <= zLine ;
	t_pc <= f_pcLine ;
	t_ir <= f_irInLine ;
	t_DBUS <= DBUS ;
end Behavioral;
  
