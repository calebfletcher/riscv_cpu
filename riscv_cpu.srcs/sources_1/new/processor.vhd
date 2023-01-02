----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/01/2023 03:58:52 PM
-- Design Name: 
-- Module Name: processor - Behavioral
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

entity processor is
    Port (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        is_halted : OUT STD_LOGIC;
        
        m_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axi_awvalid : OUT STD_LOGIC;
        m_axi_awready : IN STD_LOGIC;
        
        m_axi_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axi_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        m_axi_wvalid : OUT STD_LOGIC;
        m_axi_wready : IN STD_LOGIC;
        
        m_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        m_axi_bvalid : IN STD_LOGIC;
        m_axi_bready : OUT STD_LOGIC;
        
        m_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axi_arvalid : OUT STD_LOGIC;
        m_axi_arready : IN STD_LOGIC;
        
        m_axi_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        m_axi_rvalid : IN STD_LOGIC;
        m_axi_rready : OUT STD_LOGIC
    );
end processor;

architecture Behavioral of processor is
    type T_REGISTER_BANK is array (31 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
    
    type STATE is (RESET, FETCH_INST, WAIT_INST, EXECUTE, WAIT_DATA, STORE);
    signal s_current_state: STATE;
    signal s_registers: T_REGISTER_BANK;

    signal s_pc: UNSIGNED (31 downto 0);
    signal s_next_pc: UNSIGNED (31 downto 0);
    signal s_inst: STD_LOGIC_VECTOR (31 downto 0);
    
    signal s_rs1: STD_LOGIC_VECTOR (31 downto 0);
    signal s_rs2: STD_LOGIC_VECTOR (31 downto 0);
    signal s_rd: STD_LOGIC_VECTOR (31 downto 0);

    signal is_alu_reg : BOOLEAN;
    signal is_alu_imm : BOOLEAN;
    signal is_branch : BOOLEAN;
    signal is_jalr : BOOLEAN;
    signal is_jal : BOOLEAN;
    signal is_auipc : BOOLEAN;
    signal is_lui : BOOLEAN;
    signal is_load : BOOLEAN;
    signal is_store : BOOLEAN;
    signal is_system : BOOLEAN;
    signal is_misc_mem : BOOLEAN;
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
    

    signal write_back_en: BOOLEAN;
    signal write_back_data: STD_LOGIC_VECTOR(31 downto 0);
    
    -- ALU
    signal alu_in1: STD_LOGIC_VECTOR (31 downto 0);
    signal alu_in2: STD_LOGIC_VECTOR (31 downto 0);
    signal alu_out: STD_LOGIC_VECTOR (31 downto 0);
    signal alu_sh_amt: INTEGER range 0 to 31;
    
    -- Memory
    signal load_store_addr: STD_LOGIC_VECTOR (31 downto 0);
    signal load_halfword: STD_LOGIC_VECTOR (15 downto 0);
    signal load_byte: STD_LOGIC_VECTOR (7 downto 0);
    signal load_data: STD_LOGIC_VECTOR (31 downto 0);
    signal store_data: STD_LOGIC_VECTOR (31 downto 0);
    signal mem_byte_access: BOOLEAN;
    signal mem_halfword_access: BOOLEAN;
    signal load_sign: STD_LOGIC;
    signal store_mask: STD_LOGIC_VECTOR (3 downto 0);
    signal store_byte_mask: STD_LOGIC_VECTOR (3 downto 0);
    signal store_halfword_mask: STD_LOGIC_VECTOR (3 downto 0);
    
    signal take_branch: BOOLEAN;
begin
    is_alu_reg <= s_inst(6 downto 0) = "0110011";
    is_alu_imm <= s_inst(6 downto 0) = "0010011";
    is_branch  <= s_inst(6 downto 0) = "1100011";
    is_jalr    <= s_inst(6 downto 0) = "1100111";
    is_jal     <= s_inst(6 downto 0) = "1101111";
    is_auipc   <= s_inst(6 downto 0) = "0010111";
    is_lui     <= s_inst(6 downto 0) = "0110111";
    is_load    <= s_inst(6 downto 0) = "0000011";
    is_store   <= s_inst(6 downto 0) = "0100011";
    is_system  <= s_inst(6 downto 0) = "1110011";
    is_misc_mem <= s_inst(6 downto 0) = "0001111";

    rs1_reg <= s_inst(19 downto 15);
    rs2_reg <= s_inst(24 downto 20);
    rd_reg <= s_inst(11 downto 7);

    funct3 <= s_inst(14 downto 12);
    funct7 <= s_inst(31 downto 25);

    u_imm <= s_inst(31 downto 12) & (11 downto 0 => '0');
    i_imm <= (31 downto 11 => s_inst(31)) & s_inst(30 downto 20);
    s_imm <= (31 downto 11 => s_inst(31)) & s_inst(30 downto 25) & s_inst(11 downto 7);
    b_imm <= (31 downto 12 => s_inst(31)) & s_inst(7) & s_inst(30 downto 25) & s_inst(11 downto 8) & '0';
    j_imm <= (31 downto 20 => s_inst(31)) & s_inst(19 downto 12) & s_inst(20) & s_inst(30 downto 21) & '0';
        
    process (clk)
        variable pc: UNSIGNED (31 downto 0) := (others => '0');
        variable current_state: STATE := FETCH_INST;
        variable current_inst: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
        variable registers: T_REGISTER_BANK;
        variable rs1: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
        variable rs2: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
        variable rd: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
        variable halt_state: STD_LOGIC := '0';
    begin
        if rising_edge(clk) then
            if rst then
                current_state := RESET;
                pc := (others => '0');
                for i in 0 to 31 loop
                    registers(i) := (others => '0');
                end loop;
                halt_state := '0';
                current_inst := x"00000000";
                rs1 := x"00000000";
                rs2 := x"00000000";
                rd := x"00000000";
            else
                -- Write back to registers as long as the register isn't r0
                if write_back_en and rd_reg /= "00000" then
                    registers(to_integer(unsigned(rd_reg))) := write_back_data;
                end if;
                
                case current_state is
                    when RESET =>
                        -- Potential bug in Xilinx's BRAM AXI interface, the ARREADY signal
                        -- won't go high if you assert ARVALID within one clock cycle after reset.
--                        if m_axi_arready then
--                            current_state := FETCH_INST;
--                        end if;
                        current_state := FETCH_INST;
                    when FETCH_INST =>
                        if m_axi_arready then
                            current_state := WAIT_INST;
                        end if;
                    when WAIT_INST =>
                        if m_axi_rready and m_axi_rvalid then
                            current_inst := m_axi_rdata;
                            rs1 := registers(to_integer(unsigned(current_inst(19 downto 15))));
                            rs2 := registers(to_integer(unsigned(current_inst(24 downto 20))));
                            current_state := EXECUTE;
                        end if;
                    when EXECUTE =>
                        if is_system then
                            halt_state := '1';
                        end if;
                        
                        if is_store and m_axi_awvalid = '1' and m_axi_awready = '1' then
                            pc := s_next_pc;
                            current_state := STORE;
                        elsif is_load and m_axi_arvalid = '1' and m_axi_arready = '1' then
                            pc := s_next_pc;
                            current_state := WAIT_DATA;
                        elsif not is_load and not is_store then
                            pc := s_next_pc;
                            current_state := FETCH_INST;
                        end if;
                    when WAIT_DATA =>
                        if m_axi_rready and m_axi_rvalid then
                            current_state := FETCH_INST;
                        end if;
                    when STORE =>
                        -- Hold in this state until the write completes
                        if m_axi_wready and m_axi_wvalid then                    
                            current_state := FETCH_INST;
                        end if;
                end case;
            end if;
        end if;
        
        -- export registered values
        s_pc <= pc;
        s_inst <= current_inst;
        s_current_state <= current_state;
        s_registers <= registers;
        is_halted <= halt_state;
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
    write_back_en <= (s_current_state = EXECUTE and (not is_branch and not is_store and not is_load and not is_system))
                     or (s_current_state = WAIT_DATA and m_axi_rready = '1' and m_axi_rvalid = '1');
                         
    s_next_pc <= s_pc + unsigned(b_imm) when (is_branch and take_branch)
                    else s_pc + unsigned(j_imm) when is_jal
                    else unsigned(s_rs1) + unsigned(i_imm) when is_jalr
                    else s_pc + 4;
    
    -- AXI Bus
    m_axi_awaddr <= m_axi_araddr;
    m_axi_awvalid <= '1' when s_current_state = EXECUTE and is_store else '0';
    
    m_axi_wdata <= store_data;
    m_axi_wstrb <= store_mask;
    m_axi_wvalid <= '1' when s_current_state = STORE or (s_current_state = EXECUTE and is_store) else '0';
    
    m_axi_bready <= '1'; -- always accept responses
    
    m_axi_araddr <= STD_LOGIC_VECTOR(s_pc) when s_current_state = FETCH_INST else load_store_addr;
    m_axi_arvalid <= '1' when rst = '0' and (s_current_state = FETCH_INST or (s_current_state = EXECUTE and is_load)) else '0';
    
    m_axi_rready <=  '1' when s_current_state = WAIT_INST or s_current_state = WAIT_DATA else '0';
    
    --
    load_store_addr <= STD_LOGIC_VECTOR(unsigned(s_rs1) + unsigned(s_imm)) when is_store
                        else STD_LOGIC_VECTOR(unsigned(s_rs1) + unsigned(i_imm));
    load_halfword <= m_axi_rdata(31 downto 16) when load_store_addr(1) else m_axi_rdata(15 downto 0);
    load_byte <= load_halfword(15 downto 8) when load_store_addr(0) else load_halfword(7 downto 0);
    mem_byte_access <= funct3(1 downto 0) = "00";
    mem_halfword_access <= funct3(1 downto 0) = "01";
    load_sign <= (not funct3(2) and load_byte(7)) when mem_byte_access else (not funct3(2) and load_halfword(15));
    load_data <= ((31 downto 8 => load_sign) & load_byte) when mem_byte_access
                    else ((31 downto 16 => load_sign) & load_halfword) when mem_halfword_access
                    else m_axi_rdata;

    -- Construct data to write to RAM
    store_data(7 downto 0) <= s_rs2(7 downto 0);
    store_data(15 downto 8) <= s_rs2(7 downto 0) when load_store_addr(0) else s_rs2(15 downto 8);
    store_data(23 downto 16) <= s_rs2(7 downto 0) when load_store_addr(1) else s_rs2(23 downto 16);
    store_data(31 downto 24) <= s_rs2(7 downto 0) when load_store_addr(0)
                                else s_rs2(15 downto 8) when load_store_addr(1)
                                else s_rs2(31 downto 24);
    store_mask <= store_byte_mask when mem_byte_access
                  else store_halfword_mask when mem_halfword_access
                  else "1111";
    store_byte_mask <= "1000" when load_store_addr(1 downto 0) = "11"
                        else "0100" when load_store_addr(1 downto 0) = "10"
                        else "0010" when load_store_addr(1 downto 0) = "01"
                        else "0001";
    store_halfword_mask <= "1100" when load_store_addr(1) else "0011";
     
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

end Behavioral;
