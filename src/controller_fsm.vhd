----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
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

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is
    signal f_S : std_logic_vector ( 1 downto 0 ) := "00";
    signal f_S_next : std_logic_vector ( 1 downto 0) := "00";
begin

Next_state_proc : process (f_S)
    begin
   
   if f_S = "00" then
        f_S_next <= "01";
   elsif f_S = "01" then
        f_S_next <= "10";
   elsif f_S = "10" then
        f_S_next <= "11";
   elsif f_S = "11" then
        f_S_next <= "00";
        end if;
    
    end process Next_state_proc;
    
Output_proc : process (f_S)
	begin
	if f_S = "00" then
        o_cycle <= "0001";
   elsif f_S = "01" then
        o_cycle <= "0010";
   elsif f_S = "10" then
        o_cycle <= "0100";
   elsif f_S = "11" then
        o_cycle <= "1000";
        end if;
	end process Output_proc;

register_proc : process (i_adv, i_reset)
        begin
        if i_reset = '1' then
            f_S <= "00";        -- reset state is load a 
        elsif rising_edge(i_adv) then
            f_S <= f_S_next;    -- next state becomes current state
        end if;
    end process register_proc;
end FSM;