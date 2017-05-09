----------------------------------------------------------------------------------
--
-- Create Date: 10/19/2016 02:10:57 AM
-- Module Name:    ALU - Behavioral 
-- Project Name:   Experiment 6
-- Target Devices: Basys 3
-- Tool versions:  Vivado 2016.2
--
-- Description: Combinational ALU
--    This ALU will compute the following commands based one a select input
--       (See RAT Assembler Manual for detailed description of commands)
--      0000 - ADD
--      0001 - ADD
--      0010 - SUB
--      0011 - SUBC
--      0100 - CMP
--      0101 - AND   
--      0110 - OR
--      0111 - EXOR
--      1000 - TEST
--      1001 - LSL
--      1010 - LSR
--      1011 - ROL
--      1100 - ROR
--      1101 - ASR
--      1110 - MOV
--      1111 - Nothing
--
--    Ports:
--       SEL      - input to select operation
--       A        - input 8 bit for operation
--       B        - input 8 bit for operation
--       CIN      - input 1 bit 
--       RESULT   - output 8 bit result from operation
--       C     - output 1 bit carry bit from operation
--       Z        - output 1 bit zero flag from operation
--
--    Variable:
--       m_RESULT - 9 bit for operation result, 9th bit is carry
--
-- Dependencies: 
--    IEEE library
--       - IEEE.STD_LOGIC_1164
--       - IEEE.STD_LOGIC_ARITH
--       - IEEE.STD_LOGIC_UNSIGNED
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.00 - ALU completed for Experiment 6
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
-- Model for counter
----------------------------------------------------------------------------------
entity ALU is
    Port ( SEL    : in STD_LOGIC_VECTOR (3 downto 0);
           A      : in STD_LOGIC_VECTOR (7 downto 0);
           B      : in STD_LOGIC_VECTOR (7 downto 0);
           CIN    : in STD_LOGIC;
           RESULT : out STD_LOGIC_VECTOR(7 downto 0);
           C   : out STD_LOGIC;
           Z   : out STD_LOGIC);
end ALU;

----------------------------------------------------------------------------------
-- Definition of Counter
----------------------------------------------------------------------------------
architecture Behavioral of ALU is

begin
   process (A,B,CIN,SEL)
      variable m_RESULT : std_logic_vector(8 downto 0):= "000000000"; -- Internal variable see above
   begin
         m_RESULT := "000000000";
         case SEL is                               --Switch case to select operation
         
            when "0000" =>                            --ADD
               m_RESULT := ('1' & A) + ('1' & B);        --Add A and B

            when "0001" =>                            --ADDC
               m_RESULT := ('1' & A) + ('1' & B) + CIN;  --Add A and B and CIN

            when "0010" =>                            --SUB
               m_RESULT := ('1' & A) - ('1' & B);        --Subtract B from A

            when "0011" =>                            --SUBC
               m_RESULT := ('1' & A) - ('1' & B) - CIN;  --Subtract B and CIN from A

            when "0100" =>                            --CMP
               m_RESULT := ('0' & A) - ('0' & B);        --Subtract B from A

            when "0101" =>                            --AND
               m_RESULT := '0' & (A and B);              --AND A with B, clear carry bit

            when "0110" =>                            --OR
               m_RESULT :='0' & (A or B);                --OR A with B, clear carry bit

            when "0111" =>                            --EXOR
               m_RESULT := '0' & (A xor B);              --EXOR A with B, clear carry bit

            when "1000" =>                            --TEST
               m_RESULT := '0' & (A and B);              --AND A with B, clear carry bit

            when "1001" =>                            --LSL
               m_RESULT := A(7 downto 0) & CIN;          --Shift A left once, place CIN as LSB

            when "1010" =>                            --LSR
               m_RESULT := A(7)& CIN & A(7 downto 1);    --Store MSB A to carry, Shift A left, CIN as bit 8

            when "1011" =>                            --ROL
               m_RESULT := A(7) & A(6 downto 0) & A(7);  --Store MSB A to carry, rotate MSB to LSB and shift
               
            when "1100" =>                            --ROR
               m_RESULT := A(0) & A(0) & A(7 downto 1);  --Store LSB A to carry, rotate LSB to MSB and shift

            when "1101" =>                            --ASR
               m_RESULT := A(0) & A(7) & A(7 downto 1);  --Store LSB A to carry, shift A right once, keep MSB

            when "1110" =>                            --MOV
            m_RESULT := (CIN& B);                        --Output B, leave carry bit unchanged
            
            when others =>                            --Catch all
                                                         --Do nothing
         end case;

         C <= m_RESULT(8);                      --Output carry bit
         RESULT <= m_RESULT(7 downto 0);           --Output result of operation
         if(m_RESULT(7 downto 0) = "0000000") then --If result is 0x00
            Z <= '1';                                 --Set Zero flag
         else
            Z <= '0';                                 --Clear Zero flag
         end if;
         
   end process;
        

end Behavioral;