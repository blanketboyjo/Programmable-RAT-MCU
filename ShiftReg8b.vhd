----------------------------------------------------------------------------------
-- 
-- Create Date: 05/22/2016 01:10:33 PM
-- Design Name: 
-- Module Name: sr_8b - Behavioral
-- Project Name: Programmable RAT MCU
-- Target Devices: Basys 3
-- Tool Versions: Vivado 2016.2
-- Description: 8 bit shift register, shifts data in ever SR_CLK rising_edge
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

--------------------------------------------------------------------------
-- Model for an 8 bit shift register
--------------------------------------------------------------------------
entity sr_8b is
    port (  CLR : in std_logic;
            Q : out std_logic_vector(7 downto 0);
            SR_CLK: in std_logic;
            D_IN : in std_logic);                  
end sr_8b;

architecture my_sr of sr_8b is
  signal s_Q : std_logic_vector(7 downto 0) := "00000000"; 
begin

  process (SR_CLK,CLR) 
  begin
    if (CLR = '1') then 
      s_Q <= (others => '0'); 
    elsif (rising_edge(SR_CLK)) then 
        s_Q <= s_Q(6 downto 0) & D_IN;
    end if; 
  end process; 
  Q <= s_Q; 

end my_sr;
