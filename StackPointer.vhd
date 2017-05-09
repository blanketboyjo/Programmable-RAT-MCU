library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity StackPointer is
   port (RST,CLK,LD,INCR,DECR : in std_logic; 
                      DATA_IN : in std_logic_vector (7 downto 0); 
                     DATA_OUT : out std_logic_vector (7 downto 0);
                         RCO  : out std_logic); 
end StackPointer; 

architecture my_count of StackPointer is 
   signal  t_cnt : std_logic_vector(7 downto 0):= "00000000"; 
begin 
         
   process (CLK, RST) 
   begin
      if (RST = '1') then    
         t_cnt <= (others => '0'); -- clear
      elsif (rising_edge(CLK)) then
         if (LD = '1') then     t_cnt <= DATA_IN;  -- load
         else 
            if (INCR = '1') then  t_cnt <= t_cnt + 1; -- incr
            end if;
            if (DECR = '1') then  t_cnt <= t_cnt - 1;
            end if;
            if (t_cnt = "11111111") then
                RCO <= '1';
            else
                RCO <= '0';
            end if;
         end if;
      end if;
   end process;

   DATA_OUT <= t_cnt; 

end my_count; 
