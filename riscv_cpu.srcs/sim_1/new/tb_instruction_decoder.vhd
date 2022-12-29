----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/27/2022 07:25:37 PM
-- Design Name: 
-- Module Name: tb_instruction_decoder - Behavioral
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

entity tb_instruction_decoder is
--  Port ( );
end tb_instruction_decoder;

architecture Behavioral of tb_instruction_decoder is
    constant period: TIME := 100ns;

    signal clk: BIT := '0';
    signal inst: STD_LOGIC_VECTOR (31 downto 0);
    
    signal is_alu_reg : STD_LOGIC;
    signal is_alu_imm : STD_LOGIC;
    signal is_branch : STD_LOGIC;
    signal is_jalr : STD_LOGIC;
    signal is_jal : STD_LOGIC;
    signal is_auipc : STD_LOGIC;
    signal is_lui : STD_LOGIC;
    signal is_load : STD_LOGIC;
    signal is_store : STD_LOGIC;
    signal is_system : STD_LOGIC;
    signal rs1_reg : STD_LOGIC_VECTOR (4 downto 0);
    signal rs2_reg : STD_LOGIC_VECTOR (4 downto 0);
    signal rd_reg : STD_LOGIC_VECTOR (4 downto 0);
    signal funct3 : STD_LOGIC_VECTOR (2 downto 0);
    signal funct7 : STD_LOGIC_VECTOR (6 downto 0);
    signal u_imm : STD_LOGIC_VECTOR (31 downto 0);
    signal i_imm : STD_LOGIC_VECTOR (31 downto 0);
    signal s_imm : STD_LOGIC_VECTOR (31 downto 0);
    signal b_imm : STD_LOGIC_VECTOR (31 downto 0);
    signal j_imm : STD_LOGIC_VECTOR (31 downto 0);
begin

    decoder : entity work.instruction_decoder
        port map (
            inst => inst,
            is_alu_reg => is_alu_reg,
            is_alu_imm => is_alu_imm,
            is_branch => is_branch,
            is_jalr => is_jalr,
            is_jal => is_jal,
            is_auipc => is_auipc,
            is_lui => is_lui,
            is_load => is_load,
            is_store => is_store,
            is_system => is_system,
            rs1_reg => rs1_reg,
            rs2_reg => rs2_reg,
            rd_reg => rd_reg,
            funct3 => funct3,
            funct7 => funct7,
            u_imm => u_imm,
            i_imm => i_imm,
            s_imm => s_imm,
            b_imm => b_imm,
            j_imm => j_imm
        );
        
    clk <= not clk after period/2;

    process
    begin
        inst <= "00000000000000000000000010110011";
        wait for 1ns;
        assert is_alu_reg = '1' severity failure;
        assert rd_reg = "00001" severity failure;
        assert rs1_reg = "00000" severity failure;
        assert rs2_reg = "00000" severity failure;
        assert funct3 = "000" severity failure;
        assert rs2_reg = "00000" severity failure;
        assert funct7 = "0000000" severity failure;
        
        inst <= "00000000000100001000000010010011";
        wait for 1ns;
        assert is_alu_imm = '1' severity failure;
        assert rd_reg = "00001" severity failure;
        assert rs1_reg = "00001" severity failure;
        assert funct3 = "000" severity failure;
        assert i_imm = std_logic_vector(to_unsigned(1, 32)) severity failure;
        
        inst <= "00000000000000001010000100000011";
        wait for 1ns;
        assert is_load = '1' severity failure;
        assert rd_reg = "00010" severity failure;
        assert rs1_reg = "00001" severity failure;
        assert funct3 = "010" severity failure;
        assert i_imm = std_logic_vector(to_unsigned(0, 32)) severity failure;
        
        assert false report "No errors found" severity failure;
        wait;
    end process;

end Behavioral;
