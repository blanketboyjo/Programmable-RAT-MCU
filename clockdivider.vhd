----------------------------------------------------------------------------------
-- Create Date:    15:27:40 04/27/2007 
-- Design Name: 
-- Module Name:    CLK_DIV_FS
-- Project Name:   Experiment 1
-- Target Devices: Basys3
-- Tool versions:  Vivado 2016.2
-- Description: 
--    This divides the input clock frequency into two slower
--    requencies. The frequencies are set by the the MAX_COUNT
--    constant in the declarative region of the architecture. 
--
--    Port descriptions:
--      CLK    - Input for system clock
--      FCLK   - Output for fast clock
--      SCLK   - Output for slow clock
--
-- Dependencies: 
--    IEEE library
--       - IEEE.STD_LOGIC_1164
--       - IEEE.STD_LOGIC_ARITH
--       - IEEE.STD_LOGIC_UNSIGNED
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

----------------------------------------------------------------------------------
-- Model to divide the clock 
----------------------------------------------------------------------------------
entity clk_div_fs is
   Port( CLK   : in  STD_LOGIC;
         FCLK  : out STD_LOGIC;
         SCLK  : out STD_LOGIC);
end clk_div_fs;

----------------------------------------------------------------------------------
-- Definition of clock divider
----------------------------------------------------------------------------------
architecture my_clk_div of clk_div_fs is
   constant MAX_COUNT_SLOW : integer   := (33333333); --Max count for slow clock
   constant MAX_COUNT_FAST : integer   := (199);     --Max count for fast clock
   signal   tmp_clks       : STD_LOGIC := '0';        --Internal signal for slow clock
   signal   tmp_clkf       : STD_LOGIC := '0';        --Internal signal for fast clock
begin

----------------------------------------------------------------------------------
-- Function for slow clock
----------------------------------------------------------------------------------
   my_div_slow: process (clk,tmp_clks)                --Slow clock function
      variable div_cnt : integer := 0;                   --Internal variable storing current count
      begin
         if (rising_edge(clk)) then                         --If clock is received
            if (div_cnt = MAX_COUNT_SLOW) then                 --If count is equal to max count
               tmp_clks <= not tmp_clks;                          --Toggle slow clock signal
               div_cnt := 0;                                      --Reset count
            else                                               --Count is not equal to max count
               div_cnt := div_cnt + 1;                            --Increment count
            end if; 
         end if; 
         SCLK <= tmp_clks;                                  --Output clock signal 
   end process my_div_slow; 

----------------------------------------------------------------------------------
-- Function for fast clock
----------------------------------------------------------------------------------
   my_div_fast: process (clk,tmp_clkf)                --Fast clock function
      variable div_cnt : integer := 0;                   --Internal variable storing current count
      begin
         if (rising_edge(clk)) then                         --If clock is received
            if (div_cnt = MAX_COUNT_FAST) then                 --If count is equal to max count
               tmp_clkf <= not tmp_clkf;                          --Toggle fast clock signal
               div_cnt := 0;                                      --Reset count
            else                                               --Count is not eqaul to max count
               div_cnt := div_cnt + 1;                            --Increment count
            end if; 
         end if; 
         FCLK <= tmp_clkf;                                  --Output clock signal
   end process my_div_fast;    
end my_clk_div;

