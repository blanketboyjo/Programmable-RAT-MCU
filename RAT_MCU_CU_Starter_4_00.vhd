----------------------------------------------------------------------------------
-- Company:   CPE 233 Productions
-- Engineer:  Various Engineers
-- 
-- Create Date:    20:59:29 02/04/2013 
-- Design Name: 
-- Module Name:    RAT Control Unit
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:  Control unit (FSM) for RAT CPU
--    The connections of this unit can be seen on the RAT_MCU Architecture
--
-- Dependencies: 
--    IEEE library
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 1.00 - Experiment 7 control unit complete
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


Entity CONTROL_UNIT is
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
end;

architecture Behavioral of CONTROL_UNIT is

   type state_type is (ST_init, ST_fet, ST_exec, ST_int);
   signal PS,NS : state_type;
   signal sig_OPCODE_7: std_logic_vector (6 downto 0);

begin
   
   -- concatenate the all opcodes into a 7-bit complete opcode for
	-- easy instruction decoding.
   sig_OPCODE_7 <= OPCODE_HI_5 & OPCODE_LO_2;

   sync_p: process (CLK, NS, RESET)
   begin
      if (RESET = '1') then
         PS <= ST_init;
      elsif (rising_edge(CLK)) then 
         PS <= NS;
      end if;
   end process sync_p;


   comb_p: process (sig_OPCODE_7,INT, PS, NS, C, Z)
   begin
   
    	-- schedule everything to known values -----------------------
      PC_LD          <= '0';   
      PC_MUX_SEL     <= "00";   	    
      PC_INC         <= '0';		  			      				

      SP_LD          <= '0';   
      SP_INCR        <= '0'; 
      SP_DECR        <= '0'; 

      RF_WR          <= '0';   
      RF_WR_SEL      <= "00";   

      ALU_OPY_SEL    <= '0';  
      ALU_SEL        <= "0000";       			

      SCR_WR         <= '0';   
      SCR_DATA_SEL   <= '1';
      SCR_ADDR_SEL   <= "00";  

      FLG_C_SET      <= '0';   
      FLG_C_CLR      <= '0'; 
      FLG_C_LD       <= '0';   
      FLG_Z_LD       <= '0'; 
      FLG_LD_SEL     <= '0';   
      FLG_SHAD_LD    <= '0';    

      I_FLAG_SET     <= '0';        
      I_FLAG_CLR     <= '0';    

      IO_STRB        <= '0';      
      RST            <= '0'; 
            
      case PS is

      -- STATE: the init cycle ------------------------------------
      -- Initialize all control outputs to non-active states and 
      --   Reset the PC and SP to all zeros.
      when ST_init => 
         RST <= '1'; 
         NS <= ST_fet;


      -- STATE: the fetch cycle -----------------------------------
      when ST_fet => 
         NS <= ST_exec;
         PC_INC <= '1';  -- increment PC


      -- STATE: the execute cycle ---------------------------------
      when ST_exec => 
         if(INT = '1') then
            NS <= ST_int;
         else
            NS <= ST_fet;
         end if;
         
         PC_INC <= '0';  -- don't increment PC

         --------------------------------------------------------------
         --             Switch Case for Instructions                 --
         --------------------------------------------------------------
         case sig_OPCODE_7 is		
         
         --------------------------------------------------------------
         --             Reg/Reg-Type Instructions                    --
         --------------------------------------------------------------
         
         -- AND reg-reg  ------------
         when "0000000" =>
            ALU_SEL     <= "0101";  -- Set ALU select to AND
            ALU_OPY_SEL <= '0';     -- Set ALU input mux to reg
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_CLR   <= '1';     -- Set C flag to clear
            FLG_Z_LD    <= '1';     -- Set Z flag to load
         
         -- OR reg-reg   ------------
         when "0000001" =>
            ALU_SEL     <= "0110";  -- Set ALU select to OR
            ALU_OPY_SEL <= '0';     -- Set ALU input mux to reg
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_CLR   <= '1';     -- Set C flag to clear
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- EXOR reg-reg ------------
         when "0000010" =>
            ALU_SEL     <= "0111";  -- Set ALU select to EXOR
            ALU_OPY_SEL <= '0';     -- Set ALU input mux to reg
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_CLR   <= '1';     -- Set C flag to clear
            FLG_Z_LD    <= '1';     -- Set Z flag to load
         
         -- TEST reg-reg ------------
         when "0000011" =>
            ALU_SEL     <= "1000";  -- Set ALU select to TEST
            ALU_OPY_SEL <= '0';     -- Set ALU input mux to reg
            FLG_C_CLR   <= '1';     -- Set C flag to clear
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- ADD reg-reg  ------------
         when "0000100" =>
            ALU_SEL     <= "0000";  -- Set ALU select to ADD
            ALU_OPY_SEL <= '0';     -- Set ALU input mux to reg
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- ADDC reg-reg ------------
         when "0000101" =>
            ALU_SEL     <= "0001";  -- Set ALU select to ADDC
            ALU_OPY_SEL <= '0';     -- Set ALU input mux to reg
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
         
         -- SUB reg-reg  ------------
         when "0000110" =>					
            ALU_SEL     <= "0010";  -- Set ALU select to SUB
            ALU_OPY_SEL <= '0';     -- Set ALU input mux to reg
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load

         -- SUBC reg-reg ------------
         when "0000111" =>
            ALU_SEL     <= "0011";  -- Set ALU select to SUBC
            ALU_OPY_SEL <= '0';     -- Set ALU input mux to reg
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- CMP reg-reg  ------------
         when "0001000" =>
            ALU_SEL     <= "0100";  -- Set ALU select to CMP
            ALU_OPY_SEL <= '0';     -- Set ALU input mux to reg
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
         
         -- MOV reg-reg  ------------
         when "0001001" =>
            ALU_SEL     <= "1110";  -- Set ALU select to MOV
            ALU_OPY_SEL <= '0';     -- Set ALU input mux to reg
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            
         -- LD reg-reg   ------------
         when "0001010" =>
            RF_WR_SEL   <= "01";    -- Set Register input mux to Scratch RAM output
            RF_WR       <= '1';     -- Set Register to load
            SCR_ADDR_SEL<= "00";    -- Set Scratch RAM address mux to DY_OUT
            
            
            
         -- ST reg-reg   ------------
         when "0001011" =>
            SCR_DATA_SEL<= '0';     -- Set Scratch RAM data in mux to DX_OUT
            SCR_ADDR_SEL<= "00";    -- Set Scratch RAM address mux to DY_OUT
            SCR_WR      <= '1';     -- Set Scratch RAM to load
         
         
         --------------------------------------------------------------
         --             Reg/Immed-Type Instructions                  --
         --------------------------------------------------------------
         
         -- AND reg-immed  ----------
         when "1000000" | "1000001" | "1000010" | "1000011" =>
            ALU_SEL     <= "0101";  -- Set ALU select to AND
            ALU_OPY_SEL <= '1';     -- Set ALU input mux to immed
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_CLR   <= '1';     -- Set C flag to clear
            FLG_Z_LD    <= '1';     -- Set Z flag to load
         
         -- OR reg-immed   ----------
         when "1000100" | "1000101" | "1000110" | "1000111" =>
            ALU_SEL     <= "0110";  -- Set ALU select to OR
            ALU_OPY_SEL <= '1';     -- Set ALU input mux to immed
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_CLR   <= '1';     -- Set C flag to clear
            FLG_Z_LD    <= '1';     -- Set Z flag to load
         
         -- EXOR reg-immed ----------
         when "1001000" | "1001001" | "1001010" | "1001011" =>
            ALU_SEL     <= "0111";  -- Set ALU select to EXOR
            ALU_OPY_SEL <= '1';     -- Set ALU input mux to immed
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_CLR   <= '1';     -- Set C flag to clear
            FLG_Z_LD    <= '1';     -- Set Z flag to load
         
         -- TEST reg-immed ----------
         when "1001100" | "1001101" | "1001110" | "1001111" =>
            ALU_SEL     <= "1000";  -- Set ALU select to TEST
            ALU_OPY_SEL <= '1';     -- Set ALU input mux to immed
            FLG_C_CLR   <= '1';     -- Set C flag to clear
            FLG_Z_LD    <= '1';     -- Set Z flag to load
         
         -- ADD reg-immed  ----------
         when "1010000" | "1010001" | "1010010" | "1010011" =>
            ALU_SEL     <= "0000";  -- Set ALU select to ADD
            ALU_OPY_SEL <= '1';     -- Set ALU input mux to immed
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- ADDC reg-immed ----------
         when "1010100" | "1010101" | "1010110" | "1010111" =>
            ALU_SEL     <= "0001";  -- Set ALU select to ADDC
            ALU_OPY_SEL <= '1';     -- Set ALU input mux to immed
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- SUB reg-immed  ----------
         when "1011000" | "1011001" | "1011010" | "1011011" =>
            ALU_SEL     <= "0010";  -- Set ALU select to SUB
            ALU_OPY_SEL <= '1';     -- Set ALU input mux to immed
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load

            
         -- SUBC reg-immed ----------
         when "1011100" | "1011101" | "1011110" | "1011111" =>         
            ALU_SEL     <= "0011";  -- Set ALU select to SUBC
            ALU_OPY_SEL <= '1';     -- Set ALU input mux to immed
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- CMP reg-immed  ----------
         when "1100000" | "1100001" | "1100010" | "1100011" =>		             
            ALU_SEL     <= "0100";  -- Set ALU select to CMP
            ALU_OPY_SEL <= '1';     -- Set ALU input mux to immed
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- IN reg-immed   ----------
         when "1100100" | "1100101" | "1100110" | "1100111" =>		                             
            RF_WR_SEL   <= "11";    -- Set register input mux to Inport
            RF_WR       <= '1';     -- Set register to load

         -- OUT reg-immed  ----------
         when "1101000" | "1101001" | "1101010" | "1101011" =>		               
            IO_STRB     <= '1';     -- Set io strobe to '1'

         -- MOV reg-immed  ----------
         when "1101100" | "1101101" | "1101110" | "1101111" =>		               
            ALU_SEL    <= "1110";  -- Set ALU select to MOV
            ALU_OPY_SEL <= '1';     -- Set ALU input mux to imm
            RF_WR_SEL   <= "00";    -- Set register input mux to ALU output
            RF_WR       <= '1';     -- Set register to load

         -- LD reg-immed   ----------
         when "1110000" | "1110001" | "1110010" | "1110011" =>		    
            RF_WR_SEL   <= "01";    -- Set Register input mux to Scratch RAM output
            RF_WR       <= '1';     -- Set Register to load
            SCR_ADDR_SEL<= "01";    -- Set Scratch RAM address mux to immed
            
            
         -- ST reg-immed   ----------
         when "1110100" | "1110101" | "1110110" | "1110111" =>		    
            SCR_DATA_SEL<= '0';     -- Set Scratch RAM data in mux to DX_OUT
            SCR_ADDR_SEL<= "01";    -- Set Scratch RAM address mux to immed
            SCR_WR      <= '1';     -- Set Scratch RAM to load
         
         
         --------------------------------------------------------------
         --             Immed-Type Instructions                      --
         --------------------------------------------------------------
         
         -- BRN   -------------------
         when "0010000" => 
            PC_MUX_SEL  <= "00";    -- Set PC mux to load from_immediate
            PC_LD       <= '1';     -- Set PC to load
         
         -- CALL  -------------------
         when "0010001" => 
            PC_MUX_SEL  <= "00";    -- Set PC mux to load from_immediate
            PC_LD       <= '1';     -- Set PC to load
            SP_DECR     <= '1';     -- Set Stack Pointer to decrement
            SCR_DATA_SEL<= '1';     -- Set Scratch RAM data in mux to PC_COUNT
            SCR_ADDR_SEL<= "11";    -- Set Scratch RAM address to Stack Pointer -1
            SCR_WR      <= '1';     -- Set Scratch RAM to load
            
         -- BREQ  -------------------
         when "0010010" => 
            PC_MUX_SEL  <= "00";    -- Set PC mux to load from_immediate
            PC_LD       <= Z;       -- Set PC to load if Z is 1
            
         -- BRNE  -------------------
         when "0010011" => 
            PC_MUX_SEL  <= "00";    -- Set PC mux to load from_immediate
            PC_LD       <= Z xor'1';-- Set PC to load if Z is 0
         
         -- BRCS  -------------------
         when "0010100" => 
            PC_MUX_SEL  <= "00";    -- Set PC mux to load from_immediate
            PC_LD       <= C;       -- Set PC to load if C is 1
            
         -- BRCC  -------------------
         when "0010101" => 
            PC_MUX_SEL  <= "00";    -- Set PC mux to load from_immediate
            PC_LD       <= C xor'1';-- Set PC to load if C is 0
            
            
         --------------------------------------------------------------
         --             Reg-Type Instructions                        --
         --------------------------------------------------------------
         
         -- LSL   -------------------
         when "0100000" => 
            ALU_SEL     <= "1001";  -- Set ALU select to LSL
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- LSR   -------------------
         when "0100001" => 
            ALU_SEL     <= "1010";  -- Set ALU select to LSR
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
         
         -- ROL   -------------------
         when "0100010" => 
            ALU_SEL     <= "1011";  -- Set ALU select to ROL
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
         
         -- ROR   -------------------
         when "0100011" => 
            ALU_SEL     <= "1100";  -- Set ALU select to ROR
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- ASR   -------------------
         when "0100100" => 
            ALU_SEL     <= "1101";  -- Set ALU select to ROR
            RF_WR_SEL   <= "00";    -- Set Register input mux to ALU output
            RF_WR       <= '1';     -- Set Register to load
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            
         -- PUSH  -------------------
         when "0100101" => 
            SP_DECR     <= '1';     -- Set Stack pointer to decrement
            SCR_DATA_SEL<= '0';     -- Set Scratch RAM data in mux to DX_OUT
            SCR_ADDR_SEL<= "11";    -- Set Scratch RAM address mux to Stack Pointer - 1
            SCR_WR      <= '1';     -- Set Scratch RAM to load
         
         -- POP   -------------------
         when "0100110" => 
            RF_WR_SEL   <= "01";    -- Set Register data in mux to Scratch RAM
            RF_WR       <= '1';     -- Set Register to load
            SP_INCR     <= '1';     -- Set Stack Pointer to increment
            SCR_ADDR_SEL<= "10";    -- Set Scratch RAM address mux to Stack Pointer
         
         -- WSP   -------------------
         when "0101000" => 
            SP_LD       <= '1';     -- Set Stack Pointer to load
            
            
         -- RSP   -------------------
         when "0101001" => 
            RF_WR_SEL   <= "10";    -- Set Register data in mux to Stack Pointer
            RF_WR       <= '1';     -- Set Register to load
         
         --------------------------------------------------------------
         --             None-Type Instructions                       --
         --------------------------------------------------------------
         
         -- CLC   -------------------
         when "0110000" => 
            FLG_C_CLR   <= '1';     -- Set C flag to clear
         
         -- SEC   -------------------
         when "0110001" => 
            FLG_C_SET   <= '1';     -- Set C flag to set
         
         -- RET   -------------------
         when "0110010" => 
            PC_MUX_SEL  <= "01";    -- Set PC DIN mux to Scratch Ram out
            PC_LD       <= '1';     -- Set PC to load
            SP_INCR     <= '1';     -- Set Stack pointer to increment
            SCR_ADDR_SEL<= "10";    -- Set Scratch Ram address to stack pointer
         
         -- SEI   -------------------
         when "0110100" => 
            I_FLAG_SET  <= '1';     -- Enable interrupts
         
         -- CLI   -------------------
         when "0110101" => 
            I_FLAG_CLR  <= '1';     -- Disable interrupts
         
         -- RETID -----------------
         when "0110110" => 
            PC_MUX_SEL  <= "01";    -- Set PC DIN mux to Scratch Ram out
            PC_LD       <= '1';     -- Set PC to load
            SP_INCR     <= '1';     -- Set Stack pointer to increment
            SCR_ADDR_SEL<= "10";    -- Set Scratch Ram address to stack pointer
            FLG_LD_SEL  <= '1';     -- Set Flags to load shadow flags
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            I_FLAG_CLR  <= '1';     -- Disable interrupts
                     
         -- RETIE -----------------
         when "0110111" => 
            PC_MUX_SEL  <= "01";    -- Set PC DIN mux to Scratch Ram out
            PC_LD       <= '1';     -- Set PC to load
            SP_INCR     <= '1';     -- Set Stack pointer to increment
            SCR_ADDR_SEL<= "10";    -- Set Scratch Ram address to stack pointer
            FLG_LD_SEL  <= '1';     -- Set Flags to load shadow flags
            FLG_C_LD    <= '1';     -- Set C flag to load
            FLG_Z_LD    <= '1';     -- Set Z flag to load
            I_FLAG_SET  <= '1';     -- Enable interrupts

         when others =>		-- for inner case
            NS <= ST_fet;       
         end case; -- inner execute case statement

      when ST_int =>
         NS <= ST_fet;
         --Push counter to stack
         SCR_ADDR_SEL   <= "11";
         SCR_DATA_SEL   <= '1';
         SCR_WR         <= '1';
         SP_DECR        <= '1';
         --Load shadow flags
         FLG_SHAD_LD    <= '1';
         --Load "0x3FF" to PC
         PC_MUX_SEL     <= "10";
         PC_LD          <= '1';
         I_FLAG_CLR     <= '1';
      when others =>    -- for outer case
         NS <= ST_fet;		    
      end case;  -- outer init/fetch/execute case

   end process comb_p;  


end Behavioral;

