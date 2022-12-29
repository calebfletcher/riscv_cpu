----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/27/2022 05:11:29 PM
-- Design Name: 
-- Module Name: instruction_decoder - Behavioral
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

entity instruction_decoder is
    Port ( inst : in STD_LOGIC_VECTOR (31 downto 0);
           is_alu_reg : out STD_LOGIC;
           is_alu_imm : out STD_LOGIC;
           is_branch : out STD_LOGIC;
           is_jalr : out STD_LOGIC;
           is_jal : out STD_LOGIC;
           is_auipc : out STD_LOGIC;
           is_lui : out STD_LOGIC;
           is_load : out STD_LOGIC;
           is_store : out STD_LOGIC;
           is_system : out STD_LOGIC;
           rs1_reg : out STD_LOGIC_VECTOR (4 downto 0);
           rs2_reg : out STD_LOGIC_VECTOR (4 downto 0);
           rd_reg : out STD_LOGIC_VECTOR (4 downto 0);
           funct3 : out STD_LOGIC_VECTOR (2 downto 0);
           funct7 : out STD_LOGIC_VECTOR (6 downto 0);
           u_imm : out STD_LOGIC_VECTOR (31 downto 0);
           i_imm : out STD_LOGIC_VECTOR (31 downto 0);
           s_imm : out STD_LOGIC_VECTOR (31 downto 0);
           b_imm : out STD_LOGIC_VECTOR (31 downto 0);
           j_imm : out STD_LOGIC_VECTOR (31 downto 0));
end instruction_decoder;

architecture Behavioral of instruction_decoder is

begin
    is_alu_reg <= '1' when inst(6 downto 0) = "0110011" else '0';
    is_alu_imm <= '1' when inst(6 downto 0) = "0010011" else '0';
    is_branch  <= '1' when inst(6 downto 0) = "1100011" else '0';
    is_jalr    <= '1' when inst(6 downto 0) = "1100111" else '0';
    is_jal     <= '1' when inst(6 downto 0) = "1101111" else '0';
    is_auipc   <= '1' when inst(6 downto 0) = "1101111" else '0';
    is_lui     <= '1' when inst(6 downto 0) = "0110111" else '0';
    is_load    <= '1' when inst(6 downto 0) = "0000011" else '0';
    is_store   <= '1' when inst(6 downto 0) = "0100011" else '0';
    is_system  <= '1' when inst(6 downto 0) = "1110011" else '0';

    rs1_reg <= inst(19 downto 15);
    rs2_reg <= inst(24 downto 20);
    rd_reg <= inst(11 downto 7);

    funct3 <= inst(14 downto 12);
    funct7 <= inst(31 downto 25);

    u_imm <= inst(31 downto 12) & (11 downto 0 => '0');
    i_imm <= (31 downto 11 => inst(31)) & inst(30 downto 20);
    s_imm <= (31 downto 11 => inst(31)) & inst(30 downto 25) & inst(11 downto 7);
    b_imm <= (31 downto 12 => inst(31)) & inst(7) & inst(30 downto 25) & inst(11 downto 8) & '0';
    j_imm <= (31 downto 20 => inst(31)) & inst(19 downto 12) & inst(20) & inst(30 downto 21) & '0';

end Behavioral;
