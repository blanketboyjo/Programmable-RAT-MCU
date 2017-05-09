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

entity testbenchcomplete is
--  Port ( );
end testbenchcomplete;

architecture Behavioral of testbenchcomplete is

component RAT_wrapper is
    Port ( LEDS     : out   STD_LOGIC_VECTOR (7 downto 0);
           SEGMENTS : out   STD_LOGIC_VECTOR (7 downto 0); 
           DISP_EN  : out   STD_LOGIC_VECTOR (3 downto 0); 
           SWITCHES : in    STD_LOGIC_VECTOR (7 downto 0);
           BUTTONS  : in    STD_LOGIC_VECTOR (3 downto 0);
           RX       : in    STD_LOGIC;
           RESET    : in    STD_LOGIC;
           CLK      : in    STD_LOGIC);
end component RAT_wrapper;

    signal s_CLK : STD_LOGIC := '0';
    signal s_RX  : STD_LOGIC := '0';
    signal s_SWITCHES : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal s_BUTTONS  : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal s_RESET : STD_LOGIC := '0';
    
begin
    
    MCU : RAT_wrapper
    port map(
       LEDS     => open,
       SEGMENTS => open,
       DISP_EN  => open,
       SWITCHES => s_SWITCHES,
       BUTTONS  => s_BUTTONS,
       RX       => s_RX,
       RESET    => s_RESET,
       CLK      => s_CLK);
    
    clk_process :process
    begin
        s_CLK <= '0';
        wait for 5ns;
        s_CLK <= '1';
        wait for 5ns;
    end process clk_process;
    
    stim_process : process
    begin
        s_RX <= '1';--hold high
        wait for 4us;
        s_RX <= '0';--fake
        wait for 4us;
        s_RX <= '0';--1
        wait for 4us;
        s_RX <= '0';--2
        wait for 4us;
        s_RX <= '0';--3
        wait for 4us;
        s_RX <= '1';--4
        wait for 4us;        
        s_RX <= '1';--5
        wait for 4us;
        s_RX <= '1';--6
        wait for 4us;
        s_RX <= '1';--7
        wait for 4us;
        s_RX <= '1';--8
        wait for 4us;
        s_RX <= '1';--stop
        wait for 4us;
        
        s_RX <= '0';--fake
        wait for 4us;
        s_RX <= '1';--1
        wait for 4us;
        s_RX <= '1';--2
        wait for 4us;
        s_RX <= '1';--3
        wait for 4us;
        s_RX <= '1';--4
        wait for 4us;
        s_RX <= '1';--5
        wait for 4us;        
        s_RX <= '0';--6
        wait for 4us;
        s_RX <= '0';--7
        wait for 4us;
        s_RX <= '1';--8
        wait for 4us;
        s_RX <= '1';--stop
        wait for 4us;
        
        s_RX <= '0';--fake
        wait for 4us;
        s_RX <= '0';--1
        wait for 4us;
        s_RX <= '0';--2
        wait for 4us;
        s_RX <= '0';--3
        wait for 4us;
        s_RX <= '0';--4
        wait for 4us;
        s_RX <= '0';--5
        wait for 4us;        
        s_RX <= '0';--6
        wait for 4us;
        s_RX <= '0';--7
        wait for 4us;
        s_RX <= '0';--8
        wait for 4us;
        
     end process stim_process;
        
    



end Behavioral;
