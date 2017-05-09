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

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
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

    signal s_RX : STD_LOGIC := '0';   
    signal s_DATA_OUT: STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal s_READ : STD_LOGIC := '0';
    signal s_RX_EMPTY: STD_LOGIC := '0';
    signal s_CLK : STD_LOGIC := '0';
    
begin
    test_COMRX : COMRX Port Map(
        RX => s_RX,
        CLK => s_CLK,
        DATA_OUT => s_DATA_OUT,
        READ => s_READ,
        RX_EMPTY => s_RX_EMPTY);
    
    test_PROG : instructionAssembler Port Map(
        CLK => s_CLK,
        DIN => s_DATA_OUT,
        RX_EMPTY => s_RX_EMPTY,
        READ_RX => s_READ,
        PROG_EN  => open,
        PROG_ADDR => open,
        PROG_DATA => open,
        PROG_LD  => open);
    
    clk_process :process
    begin
        s_CLK <= '0';
        wait for 5ns;
        s_CLK <= '1';
        wait for 5ns;
    end process clk_process;
    
    stim_process : process
    begin
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;        
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        
        s_RX <= '0';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;        
        s_RX <= '1';
        wait for 4us;
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        
        s_RX <= '0';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;        
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        s_RX <= '1';
        wait for 4us;
        
     end process stim_process;
        
    



end Behavioral;
