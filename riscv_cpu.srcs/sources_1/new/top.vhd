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
    
    type STATE is (FETCH_INST, WAIT_INST, FETCH_REGS, EXECUTE, LOAD, WAIT_DATA);
    signal s_current_state: STATE;
    signal s_registers: T_REGISTER_BANK;
    
    signal core_clk: STD_LOGIC;
    signal rst: STD_LOGIC;
    signal s_pc: UNSIGNED (31 downto 0);
    signal s_next_pc: UNSIGNED (31 downto 0);
    signal s_inst: STD_LOGIC_VECTOR (31 downto 0);
    signal s_is_halted: STD_LOGIC;
    
    signal s_rs1: STD_LOGIC_VECTOR (31 downto 0);
    signal s_rs2: STD_LOGIC_VECTOR (31 downto 0);
    signal s_rd: STD_LOGIC_VECTOR (31 downto 0);

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
    
    -- Memory
    signal mem_addr: STD_LOGIC_VECTOR (31 downto 0);
    signal mem_din: STD_LOGIC_VECTOR (31 downto 0);
    signal mem_dout: STD_LOGIC_VECTOR (31 downto 0);
    signal mem_w_en: STD_LOGIC_VECTOR (3 downto 0);
    signal load_store_addr: STD_LOGIC_VECTOR (31 downto 0);
    signal load_halfword: STD_LOGIC_VECTOR (15 downto 0);
    signal load_byte: STD_LOGIC_VECTOR (7 downto 0);
    signal load_data: STD_LOGIC_VECTOR (31 downto 0);
    signal mem_byte_access: BOOLEAN;
    signal mem_halfword_access: BOOLEAN;
    signal load_sign: STD_LOGIC;
    
    signal take_branch: BOOLEAN;
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
            addr => mem_addr(11 downto 2),
            din => mem_din,
            dout => mem_dout,
            w_en => mem_w_en
        );
        
    decoder : entity work.instruction_decoder
        port map (
            inst => s_inst,
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
        variable current_state: STATE := FETCH_INST;
        variable current_inst: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
        variable registers: T_REGISTER_BANK;
        variable rs1: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
        variable rs2: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
        variable rd: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
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
                -- Write back to registers as long as the register isn't r0
                if write_back_en = '1' and rd_reg /= "00000" then
                    registers(to_integer(unsigned(rd_reg))) := write_back_data;
                end if;
                
                case current_state is
                    when FETCH_INST =>
                        current_state := WAIT_INST;
                    when WAIT_INST =>
                        current_inst := mem_dout;
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
                        end if;
                        current_state := LOAD when is_load else FETCH_INST;
                    when LOAD =>
                        current_state := WAIT_DATA;
                    when WAIT_DATA =>
                        current_state := FETCH_INST;
                end case;
            end if;
        end if;
        
        -- export registered values
        s_pc <= pc;
        s_inst <= current_inst;
        s_current_state <= current_state;
        s_registers <= registers;
        s_is_halted <= is_halted;
        s_rs1 <= rs1;
        s_rs2 <= rs2;
        s_rd <= rd;
    end process;
    
    alu_in1 <= s_rs1;
    alu_in2 <= s_rs2 when is_alu_reg else i_imm;
    alu_sh_amt <= to_integer(unsigned(s_rs2(4 downto 0))) when is_alu_reg else to_integer(unsigned(rs2_reg));
    write_back_data <= STD_LOGIC_VECTOR(s_pc + 4) when (is_jal or is_jalr)
                        else u_imm when is_lui
                        else STD_LOGIC_VECTOR(s_pc + unsigned(u_imm)) when is_auipc
                        else load_data when is_load
                        else alu_out;
    write_back_en <= '1' when s_current_state = EXECUTE
                             and (is_alu_reg or is_alu_imm or is_jal or is_jalr or is_lui or is_auipc) = '1'
                     else '1' when s_current_state = LOAD and is_load = '1'
                     else '0';
                         
    s_next_pc <= s_pc + unsigned(b_imm) when (is_branch = '1' and take_branch)
                    else s_pc + unsigned(j_imm) when is_jal
                    else unsigned(s_rs1) + unsigned(i_imm) when is_jalr
                    else s_pc + 4;
    
    ja(0) <= s_is_halted;
    
    -- Memory
    mem_addr <= STD_LOGIC_VECTOR(s_pc) when (s_current_state = WAIT_INST or s_current_state = FETCH_INST) else load_store_addr;
    mem_w_en <= "0000";
    
    load_store_addr <= STD_LOGIC_VECTOR(unsigned(s_rs1) + unsigned(i_imm));
    load_halfword <= mem_dout(31 downto 16) when load_store_addr(1) else mem_dout(15 downto 0);
    load_byte <= load_halfword(15 downto 8) when load_store_addr(0) else load_halfword(7 downto 0);
    mem_byte_access <= funct3(1 downto 0) = "00";
    mem_halfword_access <= funct3(1 downto 0) = "01";
    load_sign <= (not funct3(2) and load_byte(7)) when mem_byte_access else (not funct3(2) and load_halfword(15));
    load_data <= ((31 downto 8 => load_sign) & load_byte) when mem_byte_access
                    else ((31 downto 16 => load_sign) & load_halfword) when mem_halfword_access
                    else mem_dout;
    
    process (all)
    begin
        case funct3 is
            when "000" =>
                take_branch <= s_rs1 = s_rs2;
            when "001" =>
                take_branch <= s_rs1 /= s_rs2;
            when "100" =>
                take_branch <= signed(s_rs1) < signed(s_rs2);
            when "101" =>
                take_branch <= signed(s_rs1) >= signed(s_rs2);
            when "110" =>
                take_branch <= unsigned(s_rs1) < unsigned(s_rs2);
            when "111" =>
                take_branch <= unsigned(s_rs1) >= unsigned(s_rs2);
            when others => take_branch <= false;
        end case;
    end process;

    process (all)
    begin
        case funct3 is
            when "000" =>
                alu_out <= STD_LOGIC_VECTOR(unsigned(alu_in1) - unsigned(alu_in2))
                            when (funct7(5) = '1' and s_inst(5) = '1')
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
            when others => alu_out <= x"00000000";
        end case;
    end process;
    
    
    led <= (is_alu_reg & is_alu_imm & is_store & is_load);
end Behavioral;