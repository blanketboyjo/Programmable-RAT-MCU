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

entity programmer is
    port(   CLK         : in STD_LOGIC;
            RX          : in STD_LOGIC;
            PROG_EN     : out STD_LOGIC;
            PROG_ADDR   : out STD_LOGIC_VECTOR(9 downto 0);
            PROG_DATA   : out STD_LOGIC_VECTOR(17 downto 0);
            PROG_LD     : out STD_LOGIC);
end programmer;

architecture Behavioral of programmer is
component COMRX is
    Port ( RX        : in  STD_LOGIC;
           CLK       : in  STD_LOGIC;
           DATA_OUT  : out STD_LOGIC_VECTOR (7 downto 0);
           READ      : in  STD_LOGIC;
           RX_EMPTY  : out STD_LOGIC);
end component COMRX;

component instructionAssembler is
 Port(  CLK : in STD_LOGIC;
        DIN : in STD_LOGIC_VECTOR(7 downto 0);
        RX_EMPTY : in STD_LOGIC;
        READ_RX : out STD_LOGIC;
        PROG_EN : out STD_LOGIC;
        PROG_ADDR: out STD_LOGIC_VECTOR(9 downto 0);
        PROG_DATA : out STD_LOGIC_VECTOR(17 downto 0);
        PROG_LD  : out STD_LOGIC);
end component instructionAssembler;

    signal s_DATA_OUT: STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal s_READ : STD_LOGIC := '0';
    signal s_RX_EMPTY: STD_LOGIC := '0';
    
begin
    test_COMRX : COMRX Port Map(
        RX => RX,
        CLK => CLK,
        DATA_OUT => s_DATA_OUT,
        READ => s_READ,
        RX_EMPTY => s_RX_EMPTY);
    
    test_PROG : instructionAssembler Port Map(
        CLK => CLK,
        DIN => s_DATA_OUT,
        RX_EMPTY => s_RX_EMPTY,
        READ_RX => s_READ,
        PROG_EN  => PROG_EN,
        PROG_ADDR => PROG_ADDR,
        PROG_DATA => PROG_DATA,
        PROG_LD  => PROG_LD); 

end Behavioral;
