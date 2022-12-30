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
    type T_REGISTER_BANK is array (31 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
    
    type STATE is (FETCH_INST_1, FETCH_INST_2, FETCH_REGS, EXECUTE);
    signal s_current_state: STATE;
    signal s_registers: T_REGISTER_BANK;
    
    signal core_clk: STD_LOGIC;
    signal rst: STD_LOGIC;
    signal s_pc: UNSIGNED (31 downto 0);
    signal s_next_pc: UNSIGNED (31 downto 0);
    signal pc_word: STD_LOGIC_VECTOR (29 downto 0);
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
    

    signal write_back_en: STD_LOGIC;
    signal write_back_data: STD_LOGIC_VECTOR(31 downto 0);
    
    -- ALU
    signal alu_in1: STD_LOGIC_VECTOR (31 downto 0);
    signal alu_in2: STD_LOGIC_VECTOR (31 downto 0);
    signal alu_out: STD_LOGIC_VECTOR (31 downto 0);
    signal alu_sh_amt: INTEGER range 0 to 31;
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
            addr => pc_word(9 downto 0),
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
        variable pc: UNSIGNED (31 downto 0) := (others => '0');
        variable current_state: STATE := FETCH_INST_1;
        variable registers: T_REGISTER_BANK;
        variable rs1: STD_LOGIC_VECTOR(31 downto 0);
        variable rs2: STD_LOGIC_VECTOR(31 downto 0);
        variable rd: STD_LOGIC_VECTOR(31 downto 0);
        variable is_halted: STD_LOGIC := '0';
    begin
        if rising_edge(core_clk) then
            if rst then
                current_state := current_state;
                pc := (others => '0');
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
                        if is_system then
                            is_halted := '1';
                        else
                            pc := s_next_pc;
                            current_state := FETCH_INST_1;
                        end if;
                end case;
                
                -- Write back to registers as long as the register isn't r0
                if write_back_en = '1' and rd_reg /= "00000" then
                    registers(to_integer(unsigned(rd_reg))) := write_back_data;
                end if;
            end if;
        end if;
        s_pc <= pc;
        s_current_state <= current_state;
        s_registers <= registers;
        
        alu_in1 <= rs1;
        alu_in2 <= rs2 when is_alu_reg else i_imm;
        alu_sh_amt <= to_integer(unsigned(rs2(4 downto 0))) when is_alu_reg else to_integer(unsigned(rs2_reg));
        write_back_data <= STD_LOGIC_VECTOR(pc + 4) when (is_jal or is_jalr) else alu_out;
        write_back_en <= '1' when current_state = EXECUTE
                                 and (is_alu_reg or is_alu_imm or is_jal or is_jalr) = '1'
                             else '0';
                             
        s_next_pc <= s_pc + unsigned(j_imm) when is_jal
                            else unsigned(rs1) + unsigned(i_imm) when is_jalr
                            else s_pc + 4;
        
        ja(0) <= is_halted;
    end process;

    process (all)
    begin
        case funct3 is
            when "000" =>
                alu_out <= STD_LOGIC_VECTOR(unsigned(alu_in1) - unsigned(alu_in2))
                            when (funct7(5) = '1' and inst(5) = '1')
                            else STD_LOGIC_VECTOR(unsigned(alu_in1) + unsigned(alu_in2));
            when "001" =>
                alu_out <= STD_LOGIC_VECTOR(shift_left(unsigned(alu_in1), alu_sh_amt));
            when "010" =>
                alu_out <= x"00000001" when signed(alu_in1) < signed(alu_in2) else x"00000000";
            when "011" =>
                alu_out <= x"00000001" when unsigned(alu_in1) < unsigned(alu_in2) else x"00000000";
            when "100" =>
                alu_out <= alu_in1 xor alu_in2;
            when "101" =>
                alu_out <= STD_LOGIC_VECTOR(shift_right(signed(alu_in1), alu_sh_amt))
                            when funct7(5)
                            else STD_LOGIC_VECTOR(shift_right(unsigned(alu_in1), alu_sh_amt));
            when "110" =>
                alu_out <= alu_in1 or alu_in2;
            when "111" =>
                alu_out <= alu_in1 and alu_in2;
            when others => 
        end case;
    end process;
    
    pc_word <= STD_LOGIC_VECTOR(s_pc(31 downto 2));    
    
    led <= (is_alu_reg & is_alu_imm & is_store & is_load);
end Behavioral;