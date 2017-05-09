library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity COUNT_10B is
   port ( RESET,CLK,LD,UP : in std_logic; 
                      DIN : in std_logic_vector (9 downto 0); 
                    COUNT : out std_logic_vector (9 downto 0);
                    RCO : out std_logic); 
end COUNT_10B; 

architecture my_count of COUNT_10B is 
   signal  t_cnt : std_logic_vector(9 downto 0):= "0000000000"; 
begin 
         
   process (CLK, RESET) 
   begin
      if (RESET = '1') then    
         t_cnt <= (others => '0'); -- clear
      elsif (rising_edge(CLK)) then
         if (LD = '1') then     t_cnt <= DIN;  -- load
         else 
            if (UP = '1') then  t_cnt <= t_cnt + 1; -- incr
            end if;

         end if;
      end if;
   end process;
   
   RCO_PROC: process(t_cnt)
   begin
        if (t_cnt = "1111111111") then
            RCO <= '1';
        else
            RCO <= '0';
        end if;
   end process RCO_PROC;

   COUNT <= t_cnt; 

end my_count; 
