----------------------------------------------------------------------------------
-- Create Date:    09/30/2016 12:05:49 PM
-- Design Name: 
-- Module Name:    exp3 - Behavioral
-- Project Name:   Experiment 3
-- Target Devices: Basys 3
-- Tool Versions: 
-- Description: 
--    This is the main code experiment 3. It emulates a circuit made up of
--    a program counter and ram. The modules used are a 10bit counter,
--    1024x16 rom module, and a 10bit 3 way mux.
--    
--    Port descriptions:
--       FROM_IMMED  - 10bit input to mux to load counter when selected by mux
--       FROM_STACK  - 10bit input to mux to load counter when selected by mux
--       PC_MUX_SEL  - 2bit input to mux to select from its inputs.
--                      "00" - Selects FROM_IMMED input
--                      "01" - Selects FROM_STACK input
--                      "10" - Loads max value of x3FF
--                      "11" - Technically illegal state sets mux to 0x000
--       PC_LD       - 1bit input to load counter at next clock, high to load
--       PC_INC      - 1bit input to increment counter at next clock, high to increment
--       RST         - 1bit input clears counter
--       CLK         - 1bit input system clock
--       IR          - 18bit output from program rom 
-- 
-- Dependencies: 
--    IEEE library
--       - IEEE.STD_LOGIC_1164
--       - IEEE.STD_LOGIC_ARITH
--       - IEEE.STD_LOGIC_UNSIGNED
--    COUNT10B.vhd
--    prog_ram.vhd
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.00 - Completed and commented
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Included library
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

----------------------------------------------------------------------------------
-- Model for experiment 1
----------------------------------------------------------------------------------
entity PC is
   Port (FROM_IMMED   : in  STD_LOGIC_VECTOR (9 downto 0);
         FROM_STACK   : in  STD_LOGIC_VECTOR (9 downto 0);
         FROM_INTRR   : in  STD_LOGIC_VECTOR (9 downto 0);
         PC_MUX_SEL   : in  STD_LOGIC_VECTOR (1 downto 0);
         PC_COUNT     : out STD_LOGIC_VECTOR (9 downto 0);
         PC_LD        : in  STD_LOGIC;
         PC_INC       : in  STD_LOGIC;
         RST          : in  STD_LOGIC;
         CLK          : in  STD_LOGIC);
end PC;

----------------------------------------------------------------------------------
-- Definition for experiment 1
----------------------------------------------------------------------------------
architecture Behavioral of PC is

----------------------------------------------------------------------------------
-- Declaration of Counter
----------------------------------------------------------------------------------
component COUNT_10B is
   Port (RESET       : in  STD_LOGIC;
         CLK         : in  STD_LOGIC;
         LD          : in  STD_LOGIC;
         UP          : in  STD_LOGIC; 
         DIN         : in  STD_LOGIC_VECTOR (9 downto 0); 
         COUNT       : out STD_LOGIC_VECTOR (9 downto 0);
         RCO         : out STD_LOGIC); 
end component; 


----------------------------------------------------------------------------------
-- Declaration of internal signals
--    See black box signal diagram
----------------------------------------------------------------------------------
signal s_D_IN        : STD_LOGIC_VECTOR(9 downto 0);

----------------------------------------------------------------------------------
-- Signal connections for experiment 3
--    See black box signal diagram
----------------------------------------------------------------------------------
begin

    MUX: process(FROM_IMMED, FROM_STACK, PC_MUX_SEL, FROM_INTRR)
    begin
        case PC_MUX_SEL is
            when "00" => s_D_IN <= FROM_IMMED;
            when "01" => s_D_IN <= FROM_STACK;
            when "10" => s_D_IN <= FROM_INTRR; 
            when others => s_D_IN <= "0000000000";
        end case;
    end process;
    
    PC : COUNT_10B
    port map  ( RESET => RST,
                CLK => CLK,
                LD => PC_LD,
                UP => PC_INC,
                DIN => s_D_IN,
                COUNT => PC_COUNT);
end Behavioral;
