----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/27/2022 02:42:28 PM
-- Design Name: 
-- Module Name: clockworks - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clockworks is
    generic (divider: INTEGER := 27);
    port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk_out : out STD_LOGIC;
           rst_n : out STD_LOGIC);
end clockworks;

architecture Behavioral of clockworks is
begin
    process (clk)
        variable count: UNSIGNED (divider downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            count := count + 1;
        end if;
        clk_out <= count(divider);
    end process;
end Behavioral;
