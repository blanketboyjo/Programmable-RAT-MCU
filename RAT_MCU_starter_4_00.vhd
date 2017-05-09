----------------------------------------------------------------------------------
-- Company: Ratner Engineering
-- Engineer: James Ratner
-- 
-- Create Date:    20:59:29 02/04/2013 
-- Design Name: 
-- Module Name:    RAT_MCU - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Starter MCU file for RAT MCU. 
--
-- Dependencies: 
--
-- Revision: 3.00
-- Revision: 4.00 (8-24-2016): removed support for multibus
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAT_MCU is
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
end RAT_MCU;



architecture Behavioral of RAT_MCU is
   component ret_db_1shot
    Port (   CLK   : in STD_LOGIC; 
			 SIG   : in STD_LOGIC;
             PULSE : out STD_LOGIC; 
             LEVEL : out STD_LOGIC);
    end component;
    
   
   component prog_rom  
      port (     ADDRESS : in STD_LOGIC_VECTOR(9 downto 0); 
             INSTRUCTION : out STD_LOGIC_VECTOR(17 downto 0); 
                     CLK : in STD_LOGIC;
                     DIN : in std_logic_vector(17 downto 0);
                      WE : in std_logic);  
   end component;

   component ALU
       Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
              B : in  STD_LOGIC_VECTOR (7 downto 0);
              Cin : in  STD_LOGIC;
              SEL : in  STD_LOGIC_VECTOR(3 downto 0);
              C : out  STD_LOGIC;
              Z : out  STD_LOGIC;
              RESULT : out  STD_LOGIC_VECTOR (7 downto 0));
   end component;

   component CONTROL_UNIT 
       Port ( CLK           : in   STD_LOGIC;
              C             : in   STD_LOGIC;
              Z             : in   STD_LOGIC;
              INT           : in   STD_LOGIC;
              RESET         : in   STD_LOGIC; 
              OPCODE_HI_5   : in   STD_LOGIC_VECTOR (4 downto 0);
              OPCODE_LO_2   : in   STD_LOGIC_VECTOR (1 downto 0);
              
              PC_LD         : out  STD_LOGIC;
              PC_INC        : out  STD_LOGIC;
              PC_MUX_SEL    : out  STD_LOGIC_VECTOR (1 downto 0);		  

              SP_LD         : out  STD_LOGIC;
              SP_INCR       : out  STD_LOGIC;
              SP_DECR       : out  STD_LOGIC;
 
              RF_WR         : out  STD_LOGIC;
              RF_WR_SEL     : out  STD_LOGIC_VECTOR (1 downto 0);

              ALU_OPY_SEL   : out  STD_LOGIC;
              ALU_SEL       : out  STD_LOGIC_VECTOR (3 downto 0);

              SCR_WR        : out  STD_LOGIC;
              SCR_DATA_SEL  : out  STD_LOGIC;
              SCR_ADDR_SEL  : out  STD_LOGIC_VECTOR (1 downto 0);

              FLG_C_LD      : out  STD_LOGIC;
              FLG_C_SET     : out  STD_LOGIC;
              FLG_C_CLR     : out  STD_LOGIC;
              FLG_SHAD_LD   : out  STD_LOGIC;
              FLG_LD_SEL    : out  STD_LOGIC;
              FLG_Z_LD      : out  STD_LOGIC;
              
              I_FLAG_SET    : out  STD_LOGIC;
              I_FLAG_CLR    : out  STD_LOGIC;

              RST           : out  STD_LOGIC;
              IO_STRB       : out  STD_LOGIC);
   end component;

   component RegisterFile 
       Port ( D_IN   : in     STD_LOGIC_VECTOR (7 downto 0);
              DX_OUT : out    STD_LOGIC_VECTOR (7 downto 0);
              DY_OUT : out    STD_LOGIC_VECTOR (7 downto 0);
              ADRX   : in     STD_LOGIC_VECTOR (4 downto 0);
              ADRY   : in     STD_LOGIC_VECTOR (4 downto 0);
              WE     : in     STD_LOGIC;
              CLK    : in     STD_LOGIC);
   end component;

   component PC 
      port ( RST,CLK,PC_LD,PC_INC : in STD_LOGIC; 
             FROM_IMMED : in STD_LOGIC_VECTOR (9 downto 0); 
             FROM_STACK : in STD_LOGIC_VECTOR (9 downto 0); 
             FROM_INTRR : in STD_LOGIC_VECTOR (9 downto 0); 
             PC_MUX_SEL : in STD_LOGIC_VECTOR (1 downto 0); 
             PC_COUNT   : out STD_LOGIC_VECTOR (9 downto 0)); 
   end component; 
   
   component FlagReg is
       Port ( D    : in  STD_LOGIC; --flag input
              LD   : in  STD_LOGIC; --load Q with the D value
              SET  : in  STD_LOGIC; --set the flag to '1'
              CLR  : in  STD_LOGIC; --clear the flag to '0'
              CLK  : in  STD_LOGIC; --system clock
              Q    : out  STD_LOGIC); --flag output
   end component;
   
   component complete_flags is
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
   end component;

   
   component StackPointer is
      port (RST,CLK,LD,INCR,DECR : in STD_LOGIC; 
                       DATA_IN : in STD_LOGIC_VECTOR (7 downto 0); 
                      DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0);
                          RCO  : out STD_LOGIC); 
   end component; 

    component RAM is
    Port ( IN_DATA  : in  STD_LOGIC_VECTOR (9 downto 0);
	       OUT_DATA : out STD_LOGIC_VECTOR (9 downto 0); 
           ADDR     : in  STD_LOGIC_VECTOR (7 downto 0);
           WE       : in  STD_LOGIC; 
           CLK      : in  STD_LOGIC);
    end component;

   -- intermediate signals ----------------------------------
   signal s_pc_ld          : STD_LOGIC := '0'; 
   signal s_pc_inc         : STD_LOGIC := '0'; 
   signal s_rst            : STD_LOGIC := '0'; 
   signal s_pc_mux_sel     : STD_LOGIC_VECTOR(1 downto 0) := "00"; 
   signal s_PC_COUNT       : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');   
   signal s_inst_reg       : STD_LOGIC_VECTOR(17 downto 0) := (others => '0'); 
   signal s_FROM_INTRR     : STD_LOGIC_VECTOR (9 downto 0) := "1111111111";
   signal s_DX_OUT         : STD_LOGIC_VECTOR(7 downto 0);
   signal s_DY_OUT         : STD_LOGIC_VECTOR(7 downto 0);
   signal s_ALU_B          : STD_LOGIC_VECTOR(7 downto 0);
   signal s_C              : STD_LOGIC;
   signal s_Z              : STD_LOGIC;
   signal s_C_Flag         : STD_LOGIC;
   signal s_Z_Flag         : STD_LOGIC;
   signal s_ALU_RES        : STD_LOGIC_VECTOR(7 downto 0);
   signal s_ALU_SEL        : STD_LOGIC_VECTOR(3 downto 0);
   signal s_RF_WR          : STD_LOGIC;
   signal s_RF_WR_SEL      : STD_LOGIC_VECTOR (1 downto 0);
   signal s_ALU_OPY_SEL    : STD_LOGIC;
   signal s_FLG_C_LD       : STD_LOGIC;
   signal s_FLG_C_SET      : STD_LOGIC;
   signal s_FLG_C_CLR      : STD_LOGIC;
   signal s_FLG_Z_LD       : STD_LOGIC;
   signal s_FLG_SHAD_LD    : STD_LOGIC;
   signal s_FLG_LD_SEL     : STD_LOGIC;
   signal s_I_FLG_SET      : STD_LOGIC;
   signal s_I_FLG_CLR      : STD_LOGIC;
   signal s_I_FLG          : STD_LOGIC;
   signal s_REG_Din        : STD_LOGIC_VECTOR(7 downto 0);
   signal s_SP_LD          : STD_LOGIC;
   signal s_SP_INCR        : STD_LOGIC;
   signal s_SP_DECR        : STD_LOGIC;
   signal s_SP_OUT         : STD_LOGIC_VECTOR(7 downto 0);
   signal s_SCR_ADDR       : STD_LOGIC_VECTOR(7 downto 0);
   signal s_SCR_ADDR_SEL   : STD_LOGIC_VECTOR(1 downto 0);
   signal s_SCR_DIN        : STD_LOGIC_VECTOR(9 downto 0):= "0000000000";
   signal s_SCR_DIN_SEL    : STD_LOGIC;
   signal s_SCR_WR         : STD_LOGIC;
   signal s_SCR_OUT        : STD_LOGIC_VECTOR (9 downto 0);
   signal s_int            : STD_LOGIC;
   
   -- Added to enable com port programming
   signal s_ROM_ADDR     : STD_LOGIC_VECTOR(9 downto 0);
   signal s_ROM_LD       : STD_LOGIC;
   -- helpful aliases ------------------------------------------------------------------

   
   

begin

   my_prog_rom: prog_rom  
   port map(     ADDRESS => s_ROM_ADDR, 
             INSTRUCTION => s_inst_reg, 
                     CLK => CLK,
                     DIN => PROG_DIN,
                      WE => s_ROM_LD); 

   my_alu: ALU
   port map ( A => s_DX_OUT,       
              B => s_ALU_B,       
              Cin => s_C_Flag,     
              SEL => s_ALU_SEL,     
              C => s_C,       
              Z => s_Z,       
              RESULT => s_ALU_RES); 


   my_cu: CONTROL_UNIT 
   port map ( CLK           => CLK, 
              C             => s_C_Flag, 
              Z             => s_Z_Flag, 
              INT           => s_int,
              RESET         => RESET, 
              OPCODE_HI_5   => s_inst_reg(17 downto 13), 
              OPCODE_LO_2   => s_inst_reg(1 downto 0), 
              
              PC_LD         => s_pc_ld, 
              PC_INC        => s_pc_inc,  
              PC_MUX_SEL    => s_pc_mux_sel, 

              SP_LD         => s_SP_LD, 
              SP_INCR       => s_SP_INCR, 
              SP_DECR       => s_SP_DECR, 

              RF_WR         => s_RF_WR, 
              RF_WR_SEL     => s_RF_WR_SEL, 

              ALU_OPY_SEL   => s_ALU_OPY_SEL, 
              ALU_SEL       => s_ALU_SEL, 
              
              SCR_WR        => s_SCR_WR,
              SCR_DATA_SEL  => s_SCR_DIN_SEL,
              SCR_ADDR_SEL  => s_SCR_ADDR_SEL,              

              FLG_C_LD      => s_FLG_C_LD, 
              FLG_C_SET     => s_FLG_C_SET, 
              FLG_C_CLR     => s_FLG_C_CLR, 
              FLG_SHAD_LD   => s_FLG_SHAD_LD, 
              FLG_LD_SEL    => s_FLG_LD_SEL, 
              FLG_Z_LD      => s_FLG_Z_LD, 
              I_FLAG_SET    => s_I_FLG_SET, 
              I_FLAG_CLR    => s_I_FLG_CLR,  

              RST           => s_rst,
              IO_STRB       => IO_STRB);
              

   my_regfile: RegisterFile 
   port map ( D_IN   => s_REG_Din,   
              DX_OUT => s_DX_OUT,   
              DY_OUT => s_DY_OUT    ,   
              ADRX   => s_inst_reg (12 downto 8),   
              ADRY   => s_inst_reg (7 downto 3),     
              WE     => s_RF_WR,   
              CLK    => CLK); 

   my_flags: complete_flags
   port map(DX       => s_C,
            LDX      => s_FLG_C_LD,
            SETX     => s_FLG_C_SET,
            CLRX     => s_FLG_C_CLR,
            QX       => s_C_Flag,
            DY       => s_Z,
            LDY      => s_FLG_Z_LD,
            SETY     => s_FLG_C_SET,
            CLRY     => s_FLG_C_CLR,
            QY       => s_Z_flag,
            DIN_SEL  => s_FLG_LD_SEL,
            LDSHAD   => s_FLG_SHAD_LD,
            CLK      => CLK);
   
   my_I_flg : FlagReg
   port map ( D      => '0',
              LD     => '0',
              SET    => s_I_FLG_SET,
              CLR    => s_I_FLG_CLR,
              CLK    => CLK,
              Q      => s_I_FLG); --flag output 
   
   my_PC: PC 
   port map ( RST        => s_rst,
              CLK        => CLK,
              PC_LD      => s_pc_ld,
              PC_INC     => s_pc_inc,
              FROM_IMMED => s_inst_reg(12 downto 3),
              FROM_STACK => s_SCR_OUT,
              FROM_INTRR => s_FROM_INTRR,
              PC_MUX_SEL => s_pc_mux_sel,
              PC_COUNT   => s_PC_COUNT);

    my_SP: StackPointer
    port map(RST        => s_rst,
             CLK        => CLK,
             LD         => s_SP_LD,
             INCR       => s_SP_INCR,
             DECR       => s_SP_DECR, 
             DATA_IN    => s_DX_OUT,
             DATA_OUT   => s_SP_OUT,
             RCO        => open); 

    my_SCR : RAM
        Port map( IN_DATA => s_SCR_DIN,
               OUT_DATA => s_SCR_OUT,
               ADDR => s_SCR_ADDR,
               WE => s_SCR_WR,
               CLK => CLK);
                 
   AND_INT: process(INT,s_I_FLG)
               begin
                  s_int <= (INT and s_I_FLG);
   end process AND_INT;

--- ADDED TO ENABLE COM PORT PROGRAMMING
   
   MUX_PROG_ROM_ADDR: process (PROG_EN,s_PC_COUNT,PROG_ADDR)
   begin
        case PROG_EN is
            when '0' => s_ROM_ADDR <= s_PC_COUNT;
            when '1' => s_ROM_ADDR <= PROG_ADDR;
            when others =>
        end case;
   end process MUX_PROG_ROM_ADDR;   
   
   AND_LD_PROG_ROM: process (PROG_EN,PROG_LD)
   begin
        s_ROM_LD <= PROG_EN and PROG_LD;
   end process AND_LD_PROG_ROM;
   
--- ORIGINAL PARTS
   MUX_ALU: process (s_ALU_OPY_SEL, s_DY_OUT, s_inst_reg)
   begin
        case s_ALU_OPY_SEL is
            when '0' => s_ALU_B <= s_DY_OUT;
            when '1' => s_ALU_B <= s_inst_reg (7 downto 0);
            when others =>
        end case;
   end process;
   
   MUX_REG: process (s_RF_WR_SEL, IN_PORT,s_SP_OUT, s_ALU_RES,s_SCR_OUT)
   begin
      case s_RF_WR_SEL is
         when "00" => s_REG_Din <= s_ALU_RES;
         when "01" => s_REG_Din <= s_SCR_OUT(7 downto 0);
         when "10" => s_REG_Din <= s_SP_OUT - "00000001";
         when "11" => s_REG_Din <= IN_PORT;
         when others =>
      end case;
   end process;   
                         
   MUX_SCR_ADDR: process (s_SCR_ADDR_SEL, s_DY_OUT,s_inst_reg,s_SP_OUT)
   begin
      
      case s_SCR_ADDR_SEL is
         when "00" => s_SCR_ADDR <= s_DY_OUT;
         when "01" => s_SCR_ADDR <= s_inst_reg(7 downto 0);
         when "10" => s_SCR_ADDR <= s_SP_OUT;
         when "11" => s_SCR_ADDR <= s_SP_OUT - "00000001";
         when others =>
      end case;
   end process MUX_SCR_ADDR;         
    
    MUX_SCR_DIN: process (s_SCR_DIN_SEL, s_PC_COUNT,s_DX_OUT)

      begin
         
         case s_SCR_DIN_SEL is
            when '0' => s_SCR_DIN <= "00" & s_DX_OUT;
            when '1' => s_SCR_DIN <= s_PC_COUNT;
            when others =>
         end case;
         
      end process MUX_SCR_DIN; 


    PORT_ID <= s_inst_reg (7 downto 0);
    OUT_PORT <= s_DX_OUT;
end Behavioral;

