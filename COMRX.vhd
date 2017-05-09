----------------------------------------------------------------------------------
-- 
-- Create Date: 12/02/2016 12:45:19 PM
-- Design Name: 
-- Module Name: COMRX - Behavioral
-- Project Name: Programmable RAT MCU
-- Target Devices: Basys 3
-- Tool Versions: Vivado 2016.3
-- Description: See write up on COMRX
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


entity COMRX is
    Port ( RX        : in  STD_LOGIC;
           CLK       : in  STD_LOGIC;
           DATA_OUT  : out STD_LOGIC_VECTOR (7 downto 0);
           READ      : in  STD_LOGIC;
           RX_EMPTY  : out STD_LOGIC);
end COMRX;

architecture Behavioral of COMRX is

component COUNT_4B is
   port( RESET : in  STD_LOGIC;
         CLK   : in  STD_LOGIC;
         UP    : in  STD_LOGIC; 
         COUNT : out STD_LOGIC_VECTOR (3 downto 0);
         RCO   : out STD_LOGIC); 
end component; 

component sr_8b is
    port (    CLR : in std_logic;
                Q : out std_logic_vector(7 downto 0);
             SR_CLK: in std_logic;
             D_IN : in std_logic);                  -- input for shifts 
end component;

component reg_8b is
   port( CLR   : in  STD_LOGIC;
       LD   : in  STD_LOGIC;
         D_IN : in  STD_LOGIC_VECTOR(7 downto 0); -- parallel input
         Q     : out STD_LOGIC_VECTOR(7 downto 0);
         CLK   : in  STD_LOGIC);       
       
end component;

component reg_1b is
   port( CLR   : in  STD_LOGIC;
       LD   : in  STD_LOGIC;
         D_IN : in  STD_LOGIC; -- parallel input
         Q     : out STD_LOGIC;
         CLK   : in  STD_LOGIC);       
end component;

component clk_div_fs is
   Port( CLK   : in  STD_LOGIC;
         FCLK  : out STD_LOGIC;
         SCLK  : out STD_LOGIC);
end component;

component uartFSM is 
   port( RCO   : in  STD_LOGIC;
         CLK   : in  STD_LOGIC;
         DIN   : in  STD_LOGIC;
         GENRE : in  STD_LOGIC;
         CLR   : out STD_LOGIC;
         SEN   : out STD_LOGIC;
         DATAR : out STD_LOGIC;
         Y     : out STD_LOGIC_VECTOR(1 downto 0));
end component;

signal s_GEN        : STD_LOGIC := '0';
signal s_GENP       : STD_LOGIC := '0';
signal s_GENE       : STD_LOGIC := '0';
signal s_GENRE      : STD_LOGIC := '0';
signal s_SEN        : STD_LOGIC := '0';
signal s_SRCLK      : STD_LOGIC := '0';
signal s_DATAREADY  : STD_LOGIC := '0';
signal s_DINRXEMPTY : STD_LOGIC := '0';
signal s_LDRXEMPTY  : STD_LOGIC := '0';
signal s_SROUT      : STD_LOGIC_VECTOR (7 downto 0):= "00000000";
signal s_RCO        : STD_LOGIC := '0';
signal s_COUNTCLR   : STD_LOGIC := '0';
signal s_DATA       : STD_LOGIC_VECTOR(7 downto 0);

begin

data_SR : sr_8b
port map(    CLR    => '0',
             Q      =>  s_SROUT,
            SR_CLK  =>  s_SRCLK,
            D_IN    =>  RX);

buffer_REG : reg_8b    
port map(   CLR     => '0',
          LD      => s_DATAREADY,
            D_IN    => s_DATA,
            Q       => DATA_OUT,
            CLK     => CLK);   

data_COUNTER : COUNT_4B
port map( RESET =>s_COUNTCLR,
         CLK   =>s_SRCLK,
         UP    =>'1', 
         COUNT => open,
         RCO   => s_RCO);

ready_FLAG : reg_1b
port map( CLR=> '0',
      LD=> s_LDRXEMPTY,
      D_IN=> s_DINRXEMPTY,
      Q=> RX_EMPTY,
      CLK=>CLK);

prev_GEN : reg_1b
port map (CLR => '0',
      LD=> '1',
      D_IN=> s_GEN,
      Q=> s_GENP,
      CLK=>CLK);
      
baud_GEN : clk_div_fs
Port map( CLK   => CLK,
         FCLK  => s_GEN,
         SCLK  => open);

fsm : uartFSM
port map( RCO  => s_RCO,
         CLK   => CLK,
         DIN   => RX,
         GENRE => s_GENRE,
         CLR   => s_COUNTCLR,
         SEN   => s_SEN,
         DATAR => s_DATAREADY,
         Y     => open);

muxEmptyData :process(s_DATAREADY,READ)
    begin
        if(s_DATAREADY = '1') then
            s_DINRXEMPTY <= NOT s_DATAREADY;
        else
            s_DINRXEMPTY <= READ;
        end if;
end process muxEmptyData;

muxEmptyLD :process(s_DATAREADY,READ)
    begin
        if(s_DATAREADY = '1') then
            s_LDRXEMPTY <= s_DATAREADY;
        else
            s_LDRXEMPTY <= READ;
        end if;
end process muxEmptyLD;

exorGen :process(s_GEN, s_GENP)
    begin
        s_GENE <= s_GEN XOR s_GENP;
end process exorGen;

andGen :process(s_GENE, s_GEN)
    begin
        s_GENRE <= s_GENE AND s_GEN;
end process andGen;

srclock :process(s_GENRE, s_SEN)
    begin
        s_SRCLK <= s_GENRE AND s_SEN;
end process srclock;

s_DATA <= (s_SROUT(0) & s_SROUT(1) & s_SROUT(2) & s_SROUT(3) & s_SROUT(4) & s_SROUT(5) & s_SROUT(6) & s_SROUT(7));

end Behavioral;
