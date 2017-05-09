----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/05/2016 12:19:47 PM
-- Design Name: 
-- Module Name: testbench - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testbenchprog is
--  Port ( );
end testbenchprog;

architecture Behavioral of testbenchprog is

component programmer is
    port(   CLK         : in STD_LOGIC;
            RX          : in STD_LOGIC;
            PROG_EN     : out STD_LOGIC;
            PROG_ADDR   : out STD_LOGIC_VECTOR(9 downto 0);
            PROG_DATA   : out STD_LOGIC_VECTOR(17 downto 0);
            PROG_LD     : out STD_LOGIC);
end component programmer;


component prog_rom is 
   port (     ADDRESS : in std_logic_vector(9 downto 0); 
          INSTRUCTION : out std_logic_vector(17 downto 0); 
                  CLK : in std_logic;
                  DIN : in std_logic_vector(17 downto 0);
                   WE : in std_logic
                  );  
end component prog_rom;

    signal s_RX : STD_LOGIC := '0';   
    signal s_DATA_OUT: STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal s_READ : STD_LOGIC := '0';
    signal s_RX_EMPTY: STD_LOGIC := '0';
    signal s_CLK : STD_LOGIC := '0';
    signal s_PROG_EN : STD_LOGIC := '0';
    signal s_PROG_LD : STD_LOGIC := '0';
    signal s_PROG_ADDR : STD_LOGIC_VECTOR(9 downto 0):= "0000000000";
    signal s_PROG_DATA : STD_LOGIC_VECTOR(17 downto 0);
    
begin
    testProg : programmer
    port map(
        CLK => s_CLK,
        RX  => s_RX,
        PROG_EN => s_PROG_EN,
        PROG_ADDR => s_PROG_ADDR,
        PROG_DATA => s_PROG_DATA,
        PROG_LD => s_PROG_LD);
    
    testProgROM : prog_rom
    port map(
            ADDRESS => s_PROG_ADDR, 
        INSTRUCTION => open,
                CLK => s_CLK,
                DIN => s_PROG_DATA,
                 WE => s_PROG_LD);
    
    clk_process :process
    begin
        s_CLK <= '0';
        wait for 5ns;
        s_CLK <= '1';
        wait for 5ns;
    end process clk_process;
    
    stim_process : process
    begin
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;        
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        
        s_RX <= '0';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;        
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;        
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        
     end process stim_process;
        
    



end Behavioral;
