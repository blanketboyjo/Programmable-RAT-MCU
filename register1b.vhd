----------------------------------------------------------------------------------
-- 
-- Create Date: 12/3/16
-- Design Name: 
-- Module Name: reg_1b behavioral
-- Project Name: Programmable RAT MCU
-- Target Devices: Basys 3
-- Tool Versions: Vivado 2016.3
-- Description: Single Bit Register
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
-- Model for a single bit register
----------------------------------------------------------------------------------
entity reg_1b is
   port(  CLR   : in  STD_LOGIC;
          LD    : in  STD_LOGIC;
          D_IN  : in  STD_LOGIC;
          Q     : out STD_LOGIC;
          CLK   : in  STD_LOGIC);       
       
end reg_1b;

architecture my_reg of reg_1b is
  signal s_Q  : STD_LOGIC := '1'; 
begin

process (CLK,LD,D_IN,s_Q,CLR) 
begin
  if (CLR = '1') then 
    s_Q <= ('0'); 
  elsif (rising_edge(CLK)) then   
    if (LD = '1') then
      s_Q <= D_IN;  
    end if;  
  end if; 
end process; 

Q <= s_Q; 

end my_reg;
