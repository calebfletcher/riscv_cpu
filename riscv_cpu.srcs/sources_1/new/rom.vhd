----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/27/2022 04:09:01 PM
-- Design Name: 
-- Module Name: rom - Behavioral
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

entity rom is
    port ( clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (9 downto 0);
           w_en: in STD_LOGIC_VECTOR (3 downto 0);
           din : in STD_LOGIC_VECTOR (31 downto 0);
           dout : out STD_LOGIC_VECTOR (31 downto 0));
end rom;

architecture Behavioral of rom is
    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
      );
    END COMPONENT;
begin
    inner : blk_mem_gen_0
        PORT MAP (
            clka => clk,
            wea => w_en,
            addra => addr,
            dina => din,
            douta => dout
        );
end Behavioral;
