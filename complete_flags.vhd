----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2016 08:22:22 AM
-- Design Name: 
-- Module Name: complete_flags - Behavioral
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

entity complete_flags is
   Port( DX       : in  STD_LOGIC;
         LDX      : in  STD_LOGIC;
         SETX     : in  STD_LOGIC;
         CLRX     : in  STD_LOGIC;
         QX       : out STD_LOGIC;
         DY       : in  STD_LOGIC;
         LDY      : in  STD_LOGIC;
         SETY     : in  STD_LOGIC;
         CLRY     : in  STD_LOGIC;
         QY       : out STD_LOGIC;
         DIN_SEL  : in  STD_LOGIC;
         LDSHAD   : in  STD_LOGIC;
         CLK      : in  STD_LOGIC);
end complete_flags;

architecture Behavioral of complete_flags is

   component FlagReg is
       Port ( D    : in  STD_LOGIC; --flag input
              LD   : in  STD_LOGIC; --load Q with the D value
              SET  : in  STD_LOGIC; --set the flag to '1'
              CLR  : in  STD_LOGIC; --clear the flag to '0'
              CLK  : in  STD_LOGIC; --system clock
              Q    : out  STD_LOGIC); --flag output
   end component;
   
   signal s_DX       : STD_LOGIC := '0'; 
   signal s_DY       : STD_LOGIC := '0'; 
   signal s_DXSHAD   : STD_LOGIC := '0'; 
   signal s_DYSHAD   : STD_LOGIC := '0';
   signal s_DXIN     : STD_LOGIC := '0';
   signal s_DYIN     : STD_LOGIC := '0';
   signal s_QX       : STD_LOGIC := '0';
   signal s_QY       : STD_LOGIC := '0';
   
begin
   process(DIN_SEL,s_DXSHAD,DX)
   begin
      case DIN_SEL is
        when '1'  => s_DXIN <= s_DXSHAD;
        when '0'  => s_DXIN <= DX;
        when others =>
        end case;
   end process;
   
   process(DIN_SEL,s_DYSHAD,DY)
   begin
      case DIN_SEL is
        when '1'  => s_DYIN <= s_DYSHAD;
        when '0'  => s_DYIN <= DY;
        when others =>
        end case;
   end process;

   my_DX_Flag : FlagReg
      port map(D  => s_DXIN,
               LD => LDX,
               SET=> SETX,
               CLR=> CLRX,
               CLK=> CLK,
               Q  => s_QX);
   
   my_DY_Flag : FlagReg
      port map(D  => s_DYIN,
               LD => LDY,
               SET=> SETY,
               CLR=> CLRY,
               CLK=> CLK,
               Q  => s_QY);
   
   my_DXSHAD_Flag : FlagReg
      port map(D  => s_QX,
               LD => LDSHAD,
               SET=> '0',
               CLR=> '0',
               CLK=> CLK,
               Q  => s_DXSHAD);
   
   my_DYSHAD_Flag : FlagReg
      port map(D  => s_QY,
               LD => LDSHAD,
               SET=> '0',
               CLR=> '0',
               CLK=> CLK,
               Q  => s_DYSHAD);

   QX <= s_QX;
   QY <= s_QY;
end Behavioral;
