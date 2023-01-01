----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/27/2022 01:36:45 PM
-- Design Name: 
-- Module Name: top - Behavioral
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

library xpm;
use xpm.vcomponents.all;

entity top is
    port ( CLK100MHZ : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (0 downto 0);
           led : out STD_LOGIC_VECTOR (3 downto 0);
           ja : out STD_LOGIC_VECTOR (0 downto 0));
end top;

architecture Behavioral of top is
    signal clk: STD_LOGIC;
    signal rst: STD_LOGIC;
    
    signal bus_addr: STD_LOGIC_VECTOR (31 downto 0);
    signal bus_r_data: STD_LOGIC_VECTOR (31 downto 0);
    signal bus_r_strb: STD_LOGIC;
    signal bus_w_data: STD_LOGIC_VECTOR (31 downto 0);
    signal bus_w_mask: STD_LOGIC_VECTOR (3 downto 0);
    
    signal is_halted: STD_LOGIC;
begin
    rst <= btn(0);
    ja(0) <= is_halted;

    clkgen : entity work.clockworks
        generic map (divider => 0)
        port map (
            clk => CLK100MHZ,
            rst => rst,
            clk_out => clk
        );
        
    ram : entity work.ram
        port map (
            clk => clk,
            addr => bus_addr,
            din => bus_w_data,
            dout => bus_r_data,
            w_en => bus_w_mask
        );
        
    processor : entity work.processor
        port map (
            clk => clk,
            rst => rst,
            bus_addr => bus_addr,
            bus_r_data => bus_r_data,
            bus_r_strb => bus_r_strb,
            bus_w_data => bus_w_data,
            bus_w_mask => bus_w_mask,
            is_halted => is_halted
        );
end Behavioral;