----------------------------------------------------------------------------------
-- Create Date:    12/4/2016
-- Design Name:    
-- Module Name:    uartFSM - Behavioral
-- Project Name:   Programmable RAT MCU
-- Target Devices: Basys 3
-- Tool versions:  Vivado 2016.2
--
-- Description:  FSM template
--    This module will handle the USART port
--
--    States: Review write up flow charts for more information
--
-- Dependencies: 
--    IEEE library
--       - IEEE.STD_LOGIC_1164
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 1.00 - FSM for experiment 1 created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Included library
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

----------------------------------------------------------------------------------
-- Model for State machine
----------------------------------------------------------------------------------
entity uartFSM is 
   port( RCO   : in  STD_LOGIC;
         CLK   : in  STD_LOGIC;
         DIN   : in  STD_LOGIC;
         GENRE : in  STD_LOGIC;
         CLR   : out STD_LOGIC;
         SEN   : out STD_LOGIC;
         DATAR : out STD_LOGIC;
         Y     : out STD_LOGIC_VECTOR(1 downto 0));
end uartFSM;

----------------------------------------------------------------------------------
-- Definition of state machine
----------------------------------------------------------------------------------
architecture my_uartFSM of uartFSM is
   type state_type is (HOLD,SHIFT,COMPLETE);   --Type define for state value
   signal PS : state_type;                            --Current state variable
   signal NS : state_type;                            --Next state variable
begin

----------------------------------------------------------------------------------
-- Clock and reset handling
----------------------------------------------------------------------------------
   sync_proc: process(CLK,NS)
   begin
      if (rising_edge(CLK)) then --If rising edge
         PS <= NS;                     --Load next state
      end if;
   end process sync_proc; 

----------------------------------------------------------------------------------
-- State handling
----------------------------------------------------------------------------------
   comb_proc: process(PS,DIN,RCO,GENRE)
   begin
      CLR <= '0';
      SEN <= '0';
      DATAR <= '0';
         
      case PS is                    --Switch case for states
         when HOLD =>                  --Hold state
            SEN <= '0';
            CLR <= '1';
            DATAR <= '0';
            if(DIN = '1')then
                NS <= HOLD;
            else
                if(GENRE = '1') then
                    NS <= SHIFT;
                else
                    NS <= HOLD;
                end if;
            end if;
            
         when SHIFT =>                  -- Shift data into system
            CLR <= '0';
            SEN <= '1';
            if(RCO = '1')then
                NS <= COMPLETE;
            else
                NS <= SHIFT;
            end if;
            
         when COMPLETE =>               -- Data ready lower RX_EMPTY Flag, load buffer
            DATAR <= '1';
            CLR <= '1';
            SEN <= '0';
            NS <= HOLD;
            
         when others =>                 --Catch all condition
            NS <= HOLD;
      end case; 
   end process comb_proc; 

   with PS select                     --Set Y to output number based on present state
      Y <= "00" when HOLD, 
           "01" when SHIFT, 
           "10" when COMPLETE,
           "11" when others; 
end my_uartFSM;
