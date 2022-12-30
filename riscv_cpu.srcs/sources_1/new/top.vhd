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
           led : out STD_LOGIC_VECTOR (3 downto 0));
end top;

architecture Behavioral of top is
    type T_REGISTER_BANK is array (31 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
    
    type STATE is (FETCH_INST_1, FETCH_INST_2, FETCH_REGS, EXECUTE);
    signal s_current_state: STATE;
    signal s_registers: T_REGISTER_BANK;
    
    signal core_clk: STD_LOGIC;
    signal rst: STD_LOGIC;
    signal pc: STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
    signal pc_word: STD_LOGIC_VECTOR (9 downto 0);
    signal inst: STD_LOGIC_VECTOR (31 downto 0);
    signal rom_dout: STD_LOGIC_VECTOR (31 downto 0);

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
    rst <= btn(0);
    clkgen : entity work.clockworks
        generic map (divider => 0)
        port map (
            clk => CLK100MHZ,
            rst => rst,
            clk_out => core_clk
        );
        
    rom : entity work.rom
        port map (
            clk => core_clk,
            addr => pc_word,
            dout => rom_dout
        );
        
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
        
    process (core_clk)
        variable count: UNSIGNED (11 downto 0) := (others => '0');
        variable current_state: STATE := FETCH_INST_1;
        variable registers: T_REGISTER_BANK;
        variable rs1: STD_LOGIC_VECTOR(31 downto 0);
        variable rs2: STD_LOGIC_VECTOR(31 downto 0);
        variable rd: STD_LOGIC_VECTOR(31 downto 0);
        
        variable write_back_en: STD_LOGIC := '0';
        variable write_back_data: STD_LOGIC_VECTOR(31 downto 0);
    begin
        if rising_edge(core_clk) then
            if rst then
                current_state := current_state;
                count := (others => '0');
                for i in 0 to 31 loop
                    registers(i) := (others => '0');
                end loop;
            else
                case current_state is
                    when FETCH_INST_1 =>
                        current_state := FETCH_INST_2;
                    when FETCH_INST_2 =>
                        inst <= rom_dout;
                        current_state := FETCH_REGS;
                    when FETCH_REGS =>
                        rs1 := registers(to_integer(unsigned(rs1_reg)));
                        rs2 := registers(to_integer(unsigned(rs2_reg)));
                        current_state := EXECUTE;
                    when EXECUTE =>
                        if not is_system then
                            count := count + 4;
                            current_state := FETCH_INST_1;
                            
                            write_back_en := '1';
                            write_back_data := x"DEADBEEF";
                        end if;
                end case;
                
                if write_back_en = '1' and rd_reg /= "00000" then
                    registers(to_integer(unsigned(rd_reg))) := write_back_data;
                end if;
            end if;
        end if;
        pc <= STD_LOGIC_VECTOR(count);
        s_current_state <= current_state;
        s_registers <= registers;
    end process;
    
    pc_word <= pc(11 downto 2);
    
    led <= (is_alu_reg & is_alu_imm & is_store & is_load);
end Behavioral;