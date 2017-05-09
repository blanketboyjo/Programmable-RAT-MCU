----------------------------------------------------------------------------------
-- 
-- Create Date: 12/3/16
-- Design Name: 
-- Module Name: reg_8b behavioral
-- Project Name: Programmable RAT MCU
-- Target Devices: Basys 3
-- Tool Versions: Vivado 2016.3
-- Description: 8 Bit Register
--    Inputs:
--      CLK   - CLK input
--      LD    - Load control, Loads on clock edge if LD is high
--      D_IN  - Data in, loaded if LD is high
--    Outputs:
--      Q     - Data out
--
-- Dependencies: 
--    IEEE library
--       - IEEE.STD_LOGIC_1164
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Included library
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

----------------------------------------------------------------------------------
-- Model for an 8 bit register
----------------------------------------------------------------------------------
entity reg_8b  is
  port( CLR   : in  STD_LOGIC;
        LD    : in  STD_LOGIC;
        D_IN  : in  STD_LOGIC_VECTOR(7 downto 0);
        Q     : out STD_LOGIC_VECTOR(7 downto 0);
        CLK   : in  STD_LOGIC);       
       
end reg_8b ;

architecture my_reg of reg_8b  is
  signal s_Q  : STD_LOGIC_VECTOR(7 downto 0):= "00000000"; 
begin

process (CLK,LD,D_IN,s_Q,CLR) 
begin
  if (CLR = '1') then 
    s_Q <= (others => '0'); 
  elsif (rising_edge(CLK)) then   
    if (LD = '1') then
      s_Q <= D_IN;  
    end if;  
  end if; 
end process; 

Q <= s_Q; 

end my_reg;
