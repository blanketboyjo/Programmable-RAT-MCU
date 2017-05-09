----------------------------------------------------------------------------------
-- Create Date:    10:05:00 09/28/2016 
-- Design Name:    
-- Module Name:    count_2B - Behavioral 
-- Project Name:   Programmable RAT MCU
-- Target Devices: Basys 3
-- Tool versions:  Vivado 2016.2
--
-- Description:  count_2B
--    Count up to 0x03 when UP is held high
--    Load in values from DIN when LD is held high
--    Reset to 0x00 when RESET is held high
--    Raise RCO when count is at max
--
--    Port descriptions:
--      RESET  - Input for reset signal
--      CLK    - Input for system clock
--      LD     - Load input (high to load)
--      UP     - Up input (high to count up)
--      DIN    - Input for data to load
--      COUNT  - Output for count value
--      RCO    - Output for overflow/underflow
--
-- Dependencies: 
--    IEEE library
--       - IEEE.STD_LOGIC_1164
--       - IEEE.STD_LOGIC_ARITH
--       - IEEE.STD_LOGIC_UNSIGNED
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 1.00 - Modified to be 4 bits wide for Experiment 1
-- Additional Comments: 
--
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Included libraries
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


----------------------------------------------------------------------------------
-- Model for counter
----------------------------------------------------------------------------------
entity COUNT_2B is
   port ( RESET   : in STD_LOGIC;
          CLK     : in STD_LOGIC;
          LD      : in STD_LOGIC;
          UP      : in STD_LOGIC; 
          DIN     : in STD_LOGIC_VECTOR (1 downto 0); 
          COUNT   : out STD_LOGIC_VECTOR (1 downto 0);
          RCO     : out STD_LOGIC); 
end COUNT_2B; 

----------------------------------------------------------------------------------
-- Definition of Counter
----------------------------------------------------------------------------------
architecture my_count of COUNT_2B is 
   signal  t_cnt : STD_LOGIC_VECTOR(1 downto 0):= "00"; 
begin 
         
----------------------------------------------------------------------------------
-- Function for manipulating counter
----------------------------------------------------------------------------------
   process (CLK, RESET) 
   begin
      if (RESET = '1') then    
         t_cnt <= (others => '0'); -- clear
      elsif (rising_edge(CLK)) then
         if (LD = '1') then     t_cnt <= DIN;  -- load
         else 
            if (UP = '1') then  t_cnt <= t_cnt + 1; -- incr
            end if;
         end if;
      end if;
   end process;
   
   RCO_PROC: process(t_cnt)     -- Checks to see if RCO should be set
   begin
        if (t_cnt = "11") then
            RCO <= '1';
        else
            RCO <= '0';
        end if;
   end process RCO_PROC;
   
   COUNT <= t_cnt; 

end my_count; 
