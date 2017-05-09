----------------------------------------------------------------------------------
-- Company:  RAT Technologies
-- Engineer:  Various RAT rats
-- 
-- Create Date:    1/31/2012
-- Design Name: 
-- Module Name:    RAT_wrapper - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Wrapper for RAT CPU. This model provides a template to interfaces 
--    the RAT CPU to the Nexys2 development board. This version provides an 
--    interface for the timer counter module. 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAT_wrapper is
    Port ( LEDS     : out   STD_LOGIC_VECTOR (10 downto 0);
           SEGMENTS : out   STD_LOGIC_VECTOR (7 downto 0); 
           DISP_EN  : out   STD_LOGIC_VECTOR (3 downto 0); 
           SWITCHES : in    STD_LOGIC_VECTOR (7 downto 0);
           BUTTONS  : in    STD_LOGIC_VECTOR (3 downto 0);
           RX       : in    STD_LOGIC;
           RESET    : in    STD_LOGIC;
           CLK      : in    STD_LOGIC);
end RAT_wrapper;

architecture Behavioral of RAT_wrapper is

   -------------------------------------------------------------------------------
   -- INPUT PORT IDS -------------------------------------------------------------
   -- Right now, the only possible inputs are the switches
   -- In future labs you can add more port IDs, and you'll have
   -- to add constants here for the mux below
   CONSTANT SWITCHES_ID : STD_LOGIC_VECTOR (7 downto 0) := X"20";
   CONSTANT BUTTONS_ID  : STD_LOGIC_VECTOR (7 downto 0) := X"21";
   -------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------
   -- OUTPUT PORT IDS ------------------------------------------------------------
   -- In future labs you can add more port IDs
   CONSTANT LEDS_ID       : STD_LOGIC_VECTOR (7 downto 0) := X"40";
   CONSTANT SEGMENTS_ID   : STD_LOGIC_VECTOR (7 downto 0) := X"82";
   CONSTANT DISP_EN_ID    : STD_LOGIC_VECTOR (7 downto 0) := X"83";
   CONSTANT TCCR_ID       : STD_LOGIC_VECTOR (7 downto 0) := X"B5"; 
   CONSTANT TCNT0_ID      : STD_LOGIC_VECTOR (7 downto 0) := X"B0"; 
   CONSTANT TCNT1_ID      : STD_LOGIC_VECTOR (7 downto 0) := X"B1"; 
   CONSTANT TCNT2_ID      : STD_LOGIC_VECTOR (7 downto 0) := X"B2"; 
   -------------------------------------------------------------------------------

   -------------------------------------------------------------------------------   
   -- Declare RAT_MCU ------------------------------------------------------------
   component RAT_MCU 
       Port ( IN_PORT  : in   STD_LOGIC_VECTOR (7 downto 0);
              RESET    : in   STD_LOGIC;
              CLK      : in   STD_LOGIC;
              INT      : in   STD_LOGIC;
              PROG_DIN : in   STD_LOGIC_VECTOR(17 downto 0);
              PROG_ADDR: in   STD_LOGIC_VECTOR(9 downto 0);
              PROG_EN  : in   STD_LOGIC;
              PROG_LD  : in   STD_LOGIC;
              OUT_PORT : out  STD_LOGIC_VECTOR (7 downto 0);
              PORT_ID  : out  STD_LOGIC_VECTOR (7 downto 0);
              IO_STRB  : out  STD_LOGIC);
   end component RAT_MCU;
   -------------------------------------------------------------------------------
   
   component programmer is
       port(   CLK         : in STD_LOGIC;
               RX          : in STD_LOGIC;
               PROG_EN     : out STD_LOGIC;
               PROG_ADDR   : out STD_LOGIC_VECTOR(9 downto 0);
               PROG_DATA   : out STD_LOGIC_VECTOR(17 downto 0);
               PROG_LD     : out STD_LOGIC);
   end component programmer;
   
   component timer_counter 
      Port (  CLK : in  STD_LOGIC;
            TCCR  : in  STD_LOGIC_VECTOR (7 downto 0);
            TCNT0 : in  STD_LOGIC_VECTOR (7 downto 0);
            TCNT1 : in  STD_LOGIC_VECTOR (7 downto 0);
            TCNT2 : in  STD_LOGIC_VECTOR (7 downto 0);
           TC_INT : out  STD_LOGIC);
   end component;

   -- Signals for connecting RAT_CPU to RAT_wrapper -------------------------------
   signal s_input_port  : std_logic_vector (7 downto 0);
   signal s_output_port : std_logic_vector (7 downto 0);
   signal s_port_id     : std_logic_vector (7 downto 0);
   signal s_load        : std_logic;
   signal s_interrupt   : std_logic; 
   
   -- Register definitions for output devices ------------------------------------
   signal r_LEDS        : std_logic_vector (7 downto 0) := (others => '0'); 
   signal r_SEGMENTS    : std_logic_vector (7 downto 0) := (others => '0'); 
   signal r_DISP_EN     : std_logic_vector (3 downto 0) := (others => '0'); 
   signal r_tccr        : std_logic_vector (7 downto 0) := (others => '0'); 
   signal r_tccnt0      : std_logic_vector (7 downto 0) := (others => '0'); 
   signal r_tccnt1      : std_logic_vector (7 downto 0) := (others => '0'); 
   signal r_tccnt2      : std_logic_vector (7 downto 0) := (others => '0'); 
   -------------------------------------------------------------------------------

   -- Added for programmable version ------------------------
   signal s_PROG_EN : STD_LOGIC := '0';
   signal s_PROG_LD : STD_LOGIC := '0';
   signal s_PROG_ADDR : STD_LOGIC_VECTOR(9 downto 0):= "0000000000";
   signal s_PROG_DATA : STD_LOGIC_VECTOR(17 downto 0);
   signal s_RESET     : STD_LOGIC := '0';
 --  signal s_LEDS      : STD_LOGIC_VECTOR(10 downto 0):= "00000000000";
   
   ------------------------------------------------------------
   
   
   
  
begin

   -- Instantiate the timer-counter Module----------------------------------------  
   my_tc: timer_counter 
   Port map(  CLK  => CLK,
            TCCR   => r_tccr,
            TCNT0  => r_tccnt0,
            TCNT1  => r_tccnt1,
            TCNT2  => r_tccnt2,
           TC_INT  => s_interrupt); 
           

   -- Instantiate RAT_MCU --------------------------------------------------------
   MCU: RAT_MCU
   port map(  IN_PORT  => s_input_port,
              RESET    => s_RESET,
              CLK      => CLK,  
              INT      => s_interrupt,
              OUT_PORT => s_output_port,
              PROG_DIN => s_PROG_DATA,
              PROG_ADDR=> s_PROG_ADDR,
              PROG_EN  => s_PROG_EN,
              PROG_LD  => s_PROG_LD,
              PORT_ID  => s_port_id,
              IO_STRB  => s_load);       
              
   -------------------------------------------------------------------------------
   -- Additional modules and process for programming addition
   -------------------------------------------------------------------------------
   PROG : Programmer
       port map(
       CLK => CLK,
       RX  => RX,
       PROG_EN => s_PROG_EN,
       PROG_ADDR => s_PROG_ADDR,
       PROG_DATA => s_PROG_DATA,
       PROG_LD => s_PROG_LD);
   
   OR_RESET : process(s_PROG_EN,RESET)
   begin
        s_RESET <= s_PROG_EN or RESET;
   end process OR_RESET;
   -------------------------------------------------------------------------------
   -- End of additional code for programming addition
   -------------------------------------------------------------------------------
   
   ------------------------------------------------------------------------------- 
   -- MUX for selecting what input to read ---------------------------------------
   -------------------------------------------------------------------------------
   inputs: process(s_port_id, SWITCHES,BUTTONS)
   begin
      if (s_port_id = SWITCHES_ID) then
         s_input_port <= SWITCHES;
      elsif(s_port_id = BUTTONS_ID) then
         s_input_port <= "0000" & BUTTONS; 
      else
         s_input_port <= x"00";
      end if;
   end process inputs;
   -------------------------------------------------------------------------------


   -------------------------------------------------------------------------------
   -- MUX for updating output registers ------------------------------------------
   -- Register updates depend on rising clock edge and asserted load signal
   -------------------------------------------------------------------------------
   outputs: process(CLK) 
   begin   
      if (rising_edge(CLK)) then
         if (s_load = '1') then 
           
            -- the register definition for the LEDS
            if (s_port_id = LEDS_ID) then
               r_LEDS <= s_output_port;
            elsif (s_port_id = SEGMENTS_ID) then
               r_SEGMENTS <= s_output_port;
            elsif (s_port_id = DISP_EN_ID) then
               r_DISP_EN <= s_output_port(3 downto 0);
            elsif (s_port_id = TCCR_ID) then 
               r_tccr <= s_output_port; 
            elsif (s_port_id = TCNT0_ID) then 
               r_tccnt0 <= s_output_port; 
            elsif (s_port_id = TCNT1_ID) then 
               r_tccnt1 <= s_output_port; 
            elsif (s_port_id = TCNT2_ID) then 
               r_tccnt2 <= s_output_port; 
            end if;
           
         end if; 
      end if;
   end process outputs;      
   -------------------------------------------------------------------------------

   -- Register Interface Assignments ---------------------------------------------
   LEDS <= "000" & r_LEDS;
   SEGMENTS <= r_SEGMENTS; 
   DISP_EN <= r_DISP_EN; 
   -------------------------------------------------------------------------------
   
end Behavioral;
