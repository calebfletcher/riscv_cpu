----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/27/2022 09:09:14 PM
-- Design Name: 
-- Module Name: tb_top - Behavioral
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

entity tb_top is
--  Port ( );
end tb_top;

architecture Behavioral of tb_top is
    constant period: TIME := 10ns;
    signal clk: STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal led : STD_LOGIC_VECTOR (3 downto 0);
begin
    rom : entity work.top
        port map (
            CLK100MHZ => clk,
            btn(0) => rst,
            led => led
        );

    clk <= not clk after period/2;
    
    process begin
        rst <= '1';
        wait for period;
        rst <= '0';
        wait for period/2;
        
        wait for period*50;
        
        assert false report "No errors found" severity failure;
        wait;
    end process;

end Behavioral;
