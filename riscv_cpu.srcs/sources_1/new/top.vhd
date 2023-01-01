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
    signal is_halted: STD_LOGIC;

    signal axi_awaddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal axi_awvalid : STD_LOGIC;
    signal axi_awready : STD_LOGIC;
    signal axi_wdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal axi_wstrb : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal axi_wvalid : STD_LOGIC;
    signal axi_wready : STD_LOGIC;
    signal axi_bresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal axi_bvalid : STD_LOGIC;
    signal axi_bready : STD_LOGIC;
    signal axi_araddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal axi_arvalid : STD_LOGIC;
    signal axi_arready : STD_LOGIC;
    signal axi_rdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal axi_rresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal axi_rvalid : STD_LOGIC;
    signal axi_rready : STD_LOGIC;
    
begin
    clk <= CLK100MHZ;
    rst <= btn(0);
    ja(0) <= is_halted;
        
    ram : entity work.ram
        port map (
            s_aclk => clk,
            s_aresetn => not rst,
            s_axi_awaddr => axi_awaddr,
            s_axi_awvalid => axi_awvalid,
            s_axi_awready => axi_awready,
            s_axi_wdata => axi_wdata,
            s_axi_wstrb => axi_wstrb,
            s_axi_wvalid => axi_wvalid,
            s_axi_wready => axi_wready,
            s_axi_bresp => axi_bresp,
            s_axi_bvalid => axi_bvalid,
            s_axi_bready => axi_bready,
            s_axi_araddr => axi_araddr,
            s_axi_arvalid => axi_arvalid,
            s_axi_arready => axi_arready,
            s_axi_rdata => axi_rdata,
            s_axi_rresp => axi_rresp,
            s_axi_rvalid => axi_rvalid,
            s_axi_rready => axi_rready
        );
        
    processor : entity work.processor
        port map (
            clk => clk,
            rst => rst,
            is_halted => is_halted,
            m_axi_awaddr => axi_awaddr,
            m_axi_awvalid => axi_awvalid,
            m_axi_awready => axi_awready,
            m_axi_wdata => axi_wdata,
            m_axi_wstrb => axi_wstrb,
            m_axi_wvalid => axi_wvalid,
            m_axi_wready => axi_wready,
            m_axi_bresp => axi_bresp,
            m_axi_bvalid => axi_bvalid,
            m_axi_bready => axi_bready,
            m_axi_araddr => axi_araddr,
            m_axi_arvalid => axi_arvalid,
            m_axi_arready => axi_arready,
            m_axi_rdata => axi_rdata,
            m_axi_rresp => axi_rresp,
            m_axi_rvalid => axi_rvalid,
            m_axi_rready => axi_rready
        );
end Behavioral;