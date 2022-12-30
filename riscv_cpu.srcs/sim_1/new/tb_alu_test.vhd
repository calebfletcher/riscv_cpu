----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/30/2022 08:31:05 PM
-- Design Name: 
-- Module Name: tb_alu_test - Behavioral
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

entity tb_alu_test is
--  Port ( );
end tb_alu_test;

architecture Behavioral of tb_alu_test is
    constant period: TIME := 10ns;
    signal clk: STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal led : STD_LOGIC_VECTOR (3 downto 0);
    signal is_halted : STD_LOGIC;
begin
    top : entity work.top
        port map (
            CLK100MHZ => clk,
            btn(0) => rst,
            led => led,
            ja(0) => is_halted
        );

    clk <= not clk after period/2;
    
    process begin
        rst <= '1';
        wait for period;
        rst <= '0';
        wait for period/2;
        
        wait until is_halted = '1';
        wait for period;
        
        assert funct3 = "000" severity failure;
        
        assert false report "No errors found" severity failure;
        wait;
    end process;

end Behavioral;