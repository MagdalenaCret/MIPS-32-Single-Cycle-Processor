----------------------------------------------------------------------------------
-- Company: 
-- Student: Cret Maria-Magdalena
-- Group: 30223
-- Create Date: 04/12/2024 09:56:41 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
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
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);     
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is --monoimpuls
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component SSD is   --display 7 segments
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;


component IFetch is
    Port( 
        clk: in std_logic;
        enable: in std_logic;
        reset: in std_logic;
        JumpAddress: in std_logic_vector(31 downto 0);
        BranchAddress: in std_logic_vector(31 downto 0);
        Jump: in std_logic;
        PCSrc: in std_logic;
        PcOut: out std_logic_vector (31 downto 0);
        Instruction: out std_logic_vector(31 downto 0));
end component;

component UnitControl  is
     Port(
            Instr: in std_logic_vector(5 downto 0);
            RegDst: out std_logic;
            ExtOp: out std_logic;
            ALUSrc: out std_logic;
            Branch: out std_logic;
            Branch_N: out std_logic;
            Jump: out std_logic;
            ALUOp: out std_logic_vector(1 downto 0);
            MemWrite: out std_logic;
            MemToReg: out std_logic;
            RegWrite: out std_logic);
end component;

component InstructionDecode is
Port (
      clk: in std_logic;
      enable: in std_logic;
      RegWrite: in std_logic;
      Instr: in std_logic_vector(25 downto 0);
      RegDst: in std_logic;
      ExtOp: in std_logic;
      RD1: out std_logic_vector(31 downto 0);
      RD2: out std_logic_vector(31 downto 0);
      WD: in std_logic_vector(31 downto 0);
      Ext_Imm: out std_logic_vector(31 downto 0);
      func: out std_logic_vector(5 downto 0);
      sa: out std_logic_vector(4 downto 0));
end component;

component ExecutionUnit is
 Port 
    ( 
        RD1: in std_logic_vector(31 downto 0);
        RD2: in std_logic_vector(31 downto 0);
        ALUSrc: in std_logic;
        Ext_Imm: in std_logic_vector(31 downto 0);
        sa: in std_logic_vector(4 downto 0);
        func: in std_logic_vector(5 downto 0);
        ALUOp: in std_logic_vector(1 downto 0);
        PC4: in std_logic_vector(31 downto 0);
        Zero: out std_logic;
        ALURes: out std_logic_vector(31 downto 0);
        BranchAddress: out std_logic_vector(31 downto 0));
end component;

component MemoryUnit is
    Port 
    ( 
        clk: in std_logic;
        enable: in std_logic;
        MemWrite: in std_logic;
        ALURes_in: in std_logic_vector(31 downto 0);
        RD2: in std_logic_vector(31 downto 0);
        MemData: out std_logic_vector(31 downto 0);
        AluRes_out: out std_logic_vector(31 downto 0));
end component;

component WBUnit is
Port 
    ( 
    MemToReg: in std_logic;
    MemData: in std_logic_vector(31 downto 0);
    ALURes_out: in std_logic_vector(31 downto 0);
    WD: out std_logic_vector(31 downto 0));
end component;

--semnale definite
    signal enable: std_logic := '0';
    signal reset: std_logic := '0';
    signal Instruction: std_logic_vector(31 downto 0) := (others => '0');
    signal PC4: std_logic_vector(31 downto 0) :=(others => '0');
    signal JumpAddress: std_logic_vector(31 downto 0) := (others => '0');
    signal BranchAddress: std_logic_vector(31 downto 0) :=(others => '0');
    signal RD1: std_logic_vector(31 downto 0) := (others => '0');
    signal RD2: std_logic_vector(31 downto 0) := (others => '0');
    signal WD: std_logic_vector(31 downto 0) :=(others => '0');
    signal Ext_Imm: std_logic_vector(31 downto 0) := (others => '0');
    signal opCode:  std_logic_vector(5 downto 0) := (others => '0');
    signal func: std_logic_vector(5 downto 0) := (others => '0');
    signal sa: std_logic_vector(4 downto 0) := (others => '0');
    signal RegDst: std_logic := '0';
    signal ExtOp: std_logic := '0';
    signal ALUSrc: std_logic := '0';
    signal PCSrc: std_logic := '0';
    signal MemWrite: std_logic := '0';
    signal MemToReg: std_logic := '0';
    signal RegWrite: std_logic := '0';
    signal Branch: std_logic := '0';
    signal Branch_N: std_logic := '0';
    signal Jump: std_logic := '0';
    signal ALUOp: std_logic_vector(1 downto 0) := "00";
    signal Zero: std_logic := '0';
    signal ALUIntermidate: std_logic_vector(31 downto 0) := (others => '0');
    signal MemData: std_logic_vector(31 downto 0) :=(others => '0');
    signal ALUResult: std_logic_vector(31 downto 0) := (others => '0');
    signal selection: std_logic_vector(2 downto 0) := "000";
    signal ssdOut: std_logic_vector(31 downto 0) := (others => '0');

begin

    PCSrc <= (Branch and Zero) or (Branch_N and (not Zero));
    opCode <= Instruction(31 downto 26);
    JumpAddress <= PC4(31 downto 28) & (Instruction(25 downto 0) & "00");
    
    selection <= sw(2)&sw(1)&sw(0);
    led(1 downto 0) <= ALUOp;
    led(2) <= RegDst;
    led(3) <= EXTOp; 
    led(4) <= ALUSrc;
    led(5) <= MemWrite;
    led(6) <= MemToReg;
    led(7) <= RegWrite;
    led(8) <= Branch;
    led(9) <= Branch_N;
    led(10) <= PCSrc;
    led(11) <= Jump;
    led(15 downto  12) <= "0000";
    
    process(selection, Instruction, RD1, RD2, PC4, Ext_Imm, ALUResult, MemData, WD)
        begin
            case selection is
                when "000" => ssdOut <= Instruction;
                when "001" => ssdOut <= RD1;
                when "010" => ssdOut <= RD2;
                when "011" => ssdOut <= PC4;
                when "100" => ssdOut <= Ext_Imm;
                when "101" => ssdOut <= ALUResult;
                when "110" => ssdOut <= MemData;
                when others => ssdOut <= WD;
             end case;   
    end process;
  
MPG_port1: MPG port map(btn => btn(0), enable=>enable, clk => clk);
MPG_port2: MPG port map(enable => reset, btn => btn(1), clk => clk);
IFetch_port: IFetch port map(clk => clk, enable => enable, reset => reset, JumpAddress => JumpAddress, Jump => Jump, BranchAddress => BranchAddress, PCSrc => PCSrc, PcOut => PC4, Instruction => Instruction);
InstructionDecode_port: InstructionDecode port map(clk => clk, enable => enable, RegWrite => RegWrite, Instr => Instruction(25 downto 0), RegDst => RegDst, ExtOp => ExtOp, RD1 => RD1, RD2 => RD2, WD => WD, Ext_Imm => Ext_Imm, func => func, sa => sa);
UnitControl_port: UnitControl port map(Instr => opCode, RegDst => RegDst, ExtOp => ExtOp, ALUSrc => ALUSrc, Branch => Branch, Branch_N => Branch_N, Jump => Jump, ALUOp => ALUOp, MemWrite => MemWrite, MemToReg => MemToReg, RegWrite => RegWrite);
ExecutionUnit_port: ExecutionUnit port map(RD1 => RD1, RD2 => RD2, ALUSrc => ALUSrc, Ext_Imm => Ext_Imm, sa => sa, func => func, ALUOp => ALUOp, PC4 => PC4, Zero => Zero, ALURes => ALUIntermidate, BranchAddress => BranchAddress);
MemoryUnit_port: MemoryUnit port map(clk => clk, enable => enable, MemWrite => MemWrite, ALURes_in => ALUIntermidate, AluRes_out=>ALUResult, RD2 => RD2, MemData => MemData);
WBUnit_port: WBUnit port map(MemToReg => MemToReg, MemData => MemData, ALURes_out => ALUResult, WD => WD);
SSD_port: SSD port map(clk => clk, digits => ssdOut, an => an, cat => cat);

    
end Behavioral;
