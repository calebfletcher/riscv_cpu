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
           ja : out STD_LOGIC_VECTOR (0 downto 0);
           uart_rxd_out : out STD_LOGIC;
           uart_txd_in : in STD_LOGIC
    );
end top;

architecture Behavioral of top is
    signal clk: STD_LOGIC;
    signal rst: STD_LOGIC;
    signal is_halted: STD_LOGIC;

    signal cpu_awaddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal cpu_awvalid : STD_LOGIC;
    signal cpu_awready : STD_LOGIC;
    signal cpu_wdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal cpu_wstrb : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal cpu_wvalid : STD_LOGIC;
    signal cpu_wready : STD_LOGIC;
    signal cpu_bresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal cpu_bvalid : STD_LOGIC;
    signal cpu_bready : STD_LOGIC;
    signal cpu_araddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal cpu_arvalid : STD_LOGIC;
    signal cpu_arready : STD_LOGIC;
    signal cpu_rdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal cpu_rresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal cpu_rvalid : STD_LOGIC;
    signal cpu_rready : STD_LOGIC;
    
    signal ram_awaddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ram_awvalid : STD_LOGIC;
    signal ram_awready : STD_LOGIC;
    signal ram_wdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ram_wstrb : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal ram_wvalid : STD_LOGIC;
    signal ram_wready : STD_LOGIC;
    signal ram_bresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal ram_bvalid : STD_LOGIC;
    signal ram_bready : STD_LOGIC;
    signal ram_araddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ram_arvalid : STD_LOGIC;
    signal ram_arready : STD_LOGIC;
    signal ram_rdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ram_rresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal ram_rvalid : STD_LOGIC;
    signal ram_rready : STD_LOGIC;
    
    signal uart_awaddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal uart_awvalid : STD_LOGIC;
    signal uart_awready : STD_LOGIC;
    signal uart_wdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal uart_wstrb : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal uart_wvalid : STD_LOGIC;
    signal uart_wready : STD_LOGIC;
    signal uart_bresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal uart_bvalid : STD_LOGIC;
    signal uart_bready : STD_LOGIC;
    signal uart_araddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal uart_arvalid : STD_LOGIC;
    signal uart_arready : STD_LOGIC;
    signal uart_rdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal uart_rresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal uart_rvalid : STD_LOGIC;
    signal uart_rready : STD_LOGIC;
begin
    clk <= CLK100MHZ;
    rst <= btn(0);
    ja(0) <= is_halted;
    
    crossbar : entity work.crossbar
        port map (
            aclk => clk,
            aresetn => not rst,

            m_axi_awprot => open,
            m_axi_arprot => open,
            s_axi_awprot => "000",
            s_axi_arprot => "000",
            
            s_axi_awaddr => cpu_awaddr,
            s_axi_awvalid => cpu_awvalid,
            s_axi_awready => cpu_awready,
            s_axi_wdata => cpu_wdata,
            s_axi_wstrb => cpu_wstrb,
            s_axi_wvalid => cpu_wvalid,
            s_axi_wready => cpu_wready,
            s_axi_bresp => cpu_bresp,
            s_axi_bvalid => cpu_bvalid,
            s_axi_bready => cpu_bready,
            s_axi_araddr => cpu_araddr,
            s_axi_arvalid => cpu_arvalid,
            s_axi_arready => cpu_arready,
            s_axi_rdata => cpu_rdata,
            s_axi_rresp => cpu_rresp,
            s_axi_rvalid => cpu_rvalid,
            s_axi_rready => cpu_rready,
            
            m_axi_awaddr(63 downto 32) => uart_awaddr,
            m_axi_awaddr(31 downto 0) => ram_awaddr,
            m_axi_awvalid(1) => uart_awvalid,
            m_axi_awvalid(0) => ram_awvalid,
            m_axi_awready(1) => uart_awready,
            m_axi_awready(0) => ram_awready,
            m_axi_wdata(63 downto 32) => uart_wdata,
            m_axi_wdata(31 downto 0) => ram_wdata,
            m_axi_wstrb(7 downto 4) => uart_wstrb,
            m_axi_wstrb(3 downto 0) => ram_wstrb,
            m_axi_wvalid(1) => uart_wvalid,
            m_axi_wvalid(0) => ram_wvalid,
            m_axi_wready(1) => uart_wready,
            m_axi_wready(0) => ram_wready,
            m_axi_bresp(3 downto 2) => uart_bresp,
            m_axi_bresp(1 downto 0) => ram_bresp,
            m_axi_bvalid(1) => uart_bvalid,
            m_axi_bvalid(0) => ram_bvalid,
            m_axi_bready(1) => uart_bready,
            m_axi_bready(0) => ram_bready,
            m_axi_araddr(63 downto 32) => uart_araddr,
            m_axi_araddr(31 downto 0) => ram_araddr,
            m_axi_arvalid(1) => uart_arvalid,
            m_axi_arvalid(0) => ram_arvalid,
            m_axi_arready(1) => uart_arready,
            m_axi_arready(0) => ram_arready,
            m_axi_rdata(63 downto 32) => uart_rdata,
            m_axi_rdata(31 downto 0) => ram_rdata,
            m_axi_rresp(3 downto 2) => uart_rresp,
            m_axi_rresp(1 downto 0) => ram_rresp,
            m_axi_rvalid(1) => uart_rvalid,
            m_axi_rvalid(0) => ram_rvalid,
            m_axi_rready(1) => uart_rready,
            m_axi_rready(0) => ram_rready
        );
        
    ram : entity work.ram
        port map (
            s_aclk => clk,
            s_aresetn => not rst,
            s_axi_awaddr(27 downto 0) => ram_awaddr(27 downto 0),
            s_axi_awaddr(31 downto 28) => (others => '0'),
            s_axi_awvalid => ram_awvalid,
            s_axi_awready => ram_awready,
            s_axi_wdata => ram_wdata,
            s_axi_wstrb => ram_wstrb,
            s_axi_wvalid => ram_wvalid,
            s_axi_wready => ram_wready,
            s_axi_bresp => ram_bresp,
            s_axi_bvalid => ram_bvalid,
            s_axi_bready => ram_bready,
            s_axi_araddr(27 downto 0) => ram_araddr(27 downto 0),
            s_axi_araddr(31 downto 28) => (others => '0'),
            s_axi_arvalid => ram_arvalid,
            s_axi_arready => ram_arready,
            s_axi_rdata => ram_rdata,
            s_axi_rresp => ram_rresp,
            s_axi_rvalid => ram_rvalid,
            s_axi_rready => ram_rready
        );
        
    uart : entity work.uart
        port map (
            s_axi_aclk => clk,
            s_axi_aresetn => not rst,
            s_axi_awaddr => uart_awaddr(12 downto 0),
            s_axi_awvalid => uart_awvalid,
            s_axi_awready => uart_awready,
            s_axi_wdata => uart_wdata,
            s_axi_wstrb => uart_wstrb,
            s_axi_wvalid => uart_wvalid,
            s_axi_wready => uart_wready,
            s_axi_bresp => uart_bresp,
            s_axi_bvalid => uart_bvalid,
            s_axi_bready => uart_bready,
            s_axi_araddr => uart_araddr(12 downto 0),
            s_axi_arvalid => uart_arvalid,
            s_axi_arready => uart_arready,
            s_axi_rdata => uart_rdata,
            s_axi_rresp => uart_rresp,
            s_axi_rvalid => uart_rvalid,
            s_axi_rready => uart_rready,
            int => open,
            tx => uart_rxd_out,
            rx => uart_txd_in
        );
        
    processor : entity work.processor
        port map (
            clk => clk,
            rst => rst,
            is_halted => is_halted,
            m_axi_awaddr => cpu_awaddr,
            m_axi_awvalid => cpu_awvalid,
            m_axi_awready => cpu_awready,
            m_axi_wdata => cpu_wdata,
            m_axi_wstrb => cpu_wstrb,
            m_axi_wvalid => cpu_wvalid,
            m_axi_wready => cpu_wready,
            m_axi_bresp => cpu_bresp,
            m_axi_bvalid => cpu_bvalid,
            m_axi_bready => cpu_bready,
            m_axi_araddr => cpu_araddr,
            m_axi_arvalid => cpu_arvalid,
            m_axi_arready => cpu_arready,
            m_axi_rdata => cpu_rdata,
            m_axi_rresp => cpu_rresp,
            m_axi_rvalid => cpu_rvalid,
            m_axi_rready => cpu_rready
        );
end Behavioral;