----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

component ripple_adder is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           Cin : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (7 downto 0);
           Cout : out STD_LOGIC);
end component ripple_adder;

   
    signal w_B : std_logic_vector ( 7 downto 0);
    signal w_Cin : std_logic;
    signal w_ans : std_logic_vector ( 7 downto 0);
    signal w_Cout : std_logic;
    signal w_pl : std_logic_vector ( 7 downto 0);
begin

w_B <= not i_B when i_op = "001" else
        i_B;
w_Cin <= '1' when i_op = "001" else
        '0';
ripple_adder_0 : ripple_adder --addition
        Port map ( 
           A => i_A,
           B => w_B,
           Cin => w_Cin,
           S => w_ans,
           Cout => w_Cout
           );
logic : process (i_op, i_A, i_B, w_ans, w_Cout)
    begin
   
   if i_op = "000" then
        o_result <= w_ans;
        w_pl <= w_ans;
        o_flags(1) <= w_Cout;
   elsif i_op = "001" then 
        o_result <= w_ans;
        w_pl <= w_ans;
        o_flags(1) <= w_Cout;
   elsif i_op = "010" then
        o_result <= i_A and i_B; --and
        w_pl <= i_A and i_B;
        o_flags(1) <= '0';
   elsif i_op = "011" then
        o_result <= i_A or i_B; --or
        w_pl <= i_A or i_B;
        o_flags(1) <= '0';
   end if;
    
    end process logic;  
    
    
flags : process(w_pl,i_A,i_B,i_op) --NZCV flags
    begin
    if w_pl = "00000000" then
        o_flags(2) <= '1';
    else o_flags(2) <= '0';
    end if;
    
    if w_pl(7) = '1' then
        o_flags(3) <= '1';
    else o_flags(3) <= '0';
    end if;
    
    -- almost for overflow, must do different cases for addition/subtraction
    if (i_A(7) and i_B(7) and not w_pl(7) and (not i_op(1) and not i_op(0)))= '1' then  -- case 1 addition
        o_flags(0) <= '1';
    elsif ((not i_A(7)) and (not i_B(7)) and w_pl(7) and (not i_op(1)and not i_op(0))) = '1' then -- case 2 addition
        o_flags(0) <= '1';
    elsif ((not i_A(7)) and i_B(7) and w_pl(7) and (not i_op(1)and i_op(0))) = '1' then -- case 1 subtraction
        o_flags(0) <= '1';
    elsif ( i_A(7) and (not i_B(7)) and (not w_pl(7)) and (not i_op(1)and i_op(0))) = '1' then -- case 2 subtraction
        o_flags(0) <= '1';
    else o_flags(0) <= '0';
    end if;
    
    end process flags;

end Behavioral;
