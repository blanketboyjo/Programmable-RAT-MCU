----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/06/2016 09:49:04 PM
-- Design Name: 
-- Module Name: InstructionAssembler - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instructionAssembler is
 Port(CLK : in STD_LOGIC;
      DIN : in STD_LOGIC_VECTOR(7 downto 0);
      RX_EMPTY : in STD_LOGIC;
      READ_RX : out STD_LOGIC;
      PROG_EN : out STD_LOGIC;
      PROG_ADDR: out STD_LOGIC_VECTOR(9 downto 0);
      PROG_DATA : out STD_LOGIC_VECTOR(17 downto 0);
      PROG_LD  : out STD_LOGIC);
end instructionAssembler;

architecture Behavioral of instructionAssembler is

component progFSM is 
   port(    RX_EMPTY    : in STD_LOGIC;
            RCO_ADDR    : in STD_LOGIC;
            RCO_LD    : in STD_LOGIC;
            CLK         : in STD_LOGIC;
            READ_RX     : out STD_LOGIC;
            PROG_EN     : out STD_LOGIC;
            PROG_LD     : out STD_LOGIC;
            ADDR_CLR    : out STD_LOGIC;
            ADDR_INC    : out STD_LOGIC;  
            LOAD_EN     : out STD_LOGIC;
            LOAD_INC    : out STD_LOGIC;
            LOAD_CLR    : out STD_LOGIC;
            Y     : out STD_LOGIC_VECTOR(2 downto 0));
end component progFSM;

component reg_8b  is
   port( CLR   : in  STD_LOGIC;
	     LD   : in  STD_LOGIC;
         D_IN : in  STD_LOGIC_VECTOR(7 downto 0); -- parallel input
         Q     : out STD_LOGIC_VECTOR(7 downto 0);
         CLK   : in  STD_LOGIC);       
end component reg_8b ;

component COUNT_10B is
   port (   RESET : in std_logic;
            CLK : in std_logic;
            LD : in std_logic;
            UP : in std_logic;
            DIN : in std_logic_vector (9 downto 0); 
            COUNT : out std_logic_vector (9 downto 0);
            RCO : out std_logic); 
end component COUNT_10B; 

component COUNT_2B is
   port (   RESET : in std_logic;
            CLK : in std_logic;
            LD : in std_logic;
            UP : in std_logic;
            DIN : in std_logic_vector (1 downto 0); 
            COUNT : out std_logic_vector (1 downto 0);
            RCO : out std_logic); 
end component COUNT_2B; 

signal s_LD_SEL     : STD_LOGIC_VECTOR(1 downto 0):= "00";
signal s_LD_REG     : STD_LOGIC:= '0';
signal s_REG1_LD    : STD_LOGIC:= '0';
signal s_REG2_LD    : STD_LOGIC:= '0';
signal s_REG3_LD    : STD_LOGIC:= '0';
signal s_REG1_D     : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal s_REG2_D     : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal s_REG3_D     : STD_LOGIC_VECTOR(7 downto 0) := "00000000";

signal s_ADDR_R     : STD_LOGIC:= '0';
signal s_ADDR_INC   : STD_LOGIC:= '0';
signal s_ADDR_RCO   : STD_LOGIC:= '0';

signal s_LD_R       : STD_LOGIC:= '0';
signal s_LD_INC     : STD_LOGIC:= '0';
signal s_LD_RCO     : STD_LOGIC:= '0';

begin

FSM : progFSM
port map(   RX_EMPTY    =>RX_EMPTY,
            RCO_ADDR    =>s_ADDR_RCO,
            RCO_LD      =>s_LD_RCO,
            CLK         =>CLK,
            READ_RX     =>READ_RX,
            PROG_EN     =>PROG_EN,
            PROG_LD     =>PROG_LD,
            ADDR_CLR    =>s_ADDR_R,
            ADDR_INC    =>s_ADDR_INC,  
            LOAD_EN     =>s_LD_REG,
            LOAD_INC    =>s_LD_INC,
            LOAD_CLR    =>s_LD_R,
            Y           =>open);

CNTADDR :COUNT_10B
port map(   RESET => s_ADDR_R,
            CLK   => CLK,
            LD    => '0',
            UP    => s_ADDR_INC,
            DIN   => "0000000000",
            COUNT => PROG_ADDR,
            RCO   => s_ADDR_RCO);

CNTLD   :COUNT_2B
port map(   RESET => s_LD_R,
            CLK   => CLK,
            LD    => '0',
            UP    => s_LD_INC,
            DIN   => "00",
            COUNT => s_LD_SEL,
            RCO   => s_LD_RCO);

REGBYTE1 :reg_8b
port map(   CLR => '0',
            LD  => s_REG1_LD,
            D_IN=> DIN,
            Q   => s_REG1_D,
            CLK => CLK);

REGBYTE2 :reg_8b
port map(   CLR => '0',
            LD  => s_REG2_LD,
            D_IN=> DIN,
            Q   => s_REG2_D,
            CLK => CLK);

REGBYTE3 :reg_8b
port map(   CLR => '0',
            LD  => s_REG3_LD,
            D_IN=> DIN,
            Q   => s_REG3_D,
            CLK => CLK);

MUX_LD: process (s_LD_SEL,s_LD_REG)
begin
    case s_LD_SEL is
        when "00" =>
            s_REG1_LD <= s_LD_REG;
            s_REG2_LD <= '0';
            s_REG3_LD <= '0';
        when "01" =>
            s_REG1_LD <= '0';
            s_REG2_LD <= s_LD_REG;
            s_REG3_LD <= '0';
        when "10" =>
            s_REG1_LD <= '0';
            s_REG2_LD <= '0';
            s_REG3_LD <= s_LD_REG;
        when others =>
            s_REG1_LD <= '0';
            s_REG2_LD <= '0';
            s_REG3_LD <= '0';
    end case; 
end process MUX_LD;


PROG_DATA <= s_REG3_D(1 downto 0) & s_REG2_D(7 downto 0) & s_REG1_D(7 downto 0);
end Behavioral;
