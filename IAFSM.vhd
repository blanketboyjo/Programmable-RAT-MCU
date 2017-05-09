----------------------------------------------------------------------------------
-- Create Date:    12/4/2016
-- Design Name:    
-- Module Name:    progFSM - Behavioral 
-- Project Name:   Programmable RAT MCU
-- Target Devices: Basys 3
-- Tool versions:  Vivado 2016.2
--
-- Description:  progFSM
--    This FSM is used to assemble instructions word from the USART port
--
--    States: Review write up flow charts for more information
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
-- Model for State machine
----------------------------------------------------------------------------------
entity progFSM is 
   port(    RX_EMPTY    : in STD_LOGIC;
            RCO_ADDR    : in STD_LOGIC;
            RCO_LD      : in STD_LOGIC;
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
end progFSM;

----------------------------------------------------------------------------------
-- Definition of state machine
----------------------------------------------------------------------------------
architecture my_progFSM of progFSM is
   type state_type is (HOLD,SETUP,LD,DELAY1,INSTR_COMP,DELAY2);   --Type define for state value
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
   comb_proc: process(PS,RX_EMPTY,RCO_LD, RCO_ADDR)
   begin
      READ_RX <= '0';
      PROG_EN <= '0';
      PROG_LD <= '0';
      ADDR_CLR<= '0';
      ADDR_INC<= '0';
      LOAD_EN <= '0';
      LOAD_INC<= '0';
      LOAD_CLR<= '0';
      case PS is                    
         when HOLD =>                   --Hold state; normal MCU execution
            READ_RX <= '0';
            PROG_EN <= '0';
            PROG_LD <= '0';
            ADDR_CLR<= '1';
            ADDR_INC<= '0';
            LOAD_EN <= '0';
            LOAD_INC<= '0';
            LOAD_CLR<= '1';
            if(RX_EMPTY = '0') then
                NS <= SETUP;
            else
                NS <= HOLD;
            end if;
            
         when SETUP =>                  --SETUP state; prepare MCU for programming
            PROG_EN <= '1';
            LOAD_CLR <= '0';
            ADDR_CLR <= '0';            
            NS <= LD;

         when LD =>                     --LD state; load registers to assemble instruction
            PROG_EN <= '1';
            LOAD_EN <= '1';
            LOAD_INC<= '1';
            READ_RX <= '1';
            NS <= DELAY1;
         
         when DELAY1 =>                 --DELAY1 state; used to prevent registers from loading when waiting for data
            PROG_EN <= '1';
            LOAD_EN <= '0';
            LOAD_INC<= '0';
            READ_RX <= '0';
            if(RCO_LD = '0') then
                if(RX_EMPTY = '0') then
                    NS <= LD;
                else
                    NS <= DELAY1;
                end if;
            else
                NS <= INSTR_COMP;
            end if;

         when INSTR_COMP =>             --INSTR_COMP state; instruction assembled upload to RAT MCU prog_rom
            PROG_EN <= '1';
            PROG_LD <= '1';
            ADDR_INC<= '1';
            LOAD_CLR<= '1';
            if(RCO_ADDR = '1')then
                NS <= HOLD;
            else
                NS <= DELAY2;
            end if;
            
         when DELAY2 =>                 --DELAY2 state; stall until data for first byte of next message
            PROG_EN <= '1';
            PROG_LD <= '0';
            ADDR_INC<= '0';
            LOAD_CLR<= '0';
            if(RX_EMPTY = '0') then
                NS <= LD;
            else
                NS <= DELAY2;
            end if;
         when others =>                --Catch all condition
            NS <= HOLD;
      end case; 
   end process comb_proc; 

   with PS select                     --Set Y to output number based on present state
      Y <= "000" when HOLD, 
           "001" when SETUP, 
           "010" when LD,
           "011" when DELAY1,
           "100" when INSTR_COMP,
           "101" when DELAY2,
           "111" when others; 
end my_progFSM;
