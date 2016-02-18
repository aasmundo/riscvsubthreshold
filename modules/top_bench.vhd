LIBRARY ieee;
USE ieee.math_real.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
library work;
use work.constants.all;


entity top_bench is
end top_bench;

architecture behave of top_bench is	
constant hex_folder : String(1 to 51) := "C:\prosjektoppgave\riscvsubthreshold\tests\myTests\"; 
signal clk : std_logic := '0';
signal sleep : std_logic;
signal nreset : std_logic := '0';
type mem_t is array(0 to ((2**PC_WIDTH) - 1)) of std_logic_vector(31 downto 0);
type tests_t is array(0 to 37) of mem_t;


impure function ocram_ReadMemFile(FileName : STRING) return mem_t is
  file FileHandle       : TEXT open READ_MODE is FileName;
  variable CurrentLine  : LINE;
  variable TempWord     : STD_LOGIC_VECTOR(31 downto 0);
  variable Result       : mem_t    := (others => (others => 'U'));

begin
  for i in 0 to (2**PC_WIDTH) - 1 loop
    exit when endfile(FileHandle);

    readline(FileHandle, CurrentLine);
    hread(CurrentLine, TempWord);
    Result(i)    := TempWord;
  end loop;

  return Result;
end function;


signal tests : tests_t;
signal imem_we : std_logic;
signal imem_data : std_logic_vector(31 downto 0);
signal imem_write_address : std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
signal pass : std_logic;
signal fail : std_logic;
signal dmem_we : std_logic;
signal dmem_data : std_logic_vector(31 downto 0);
signal dmem_write_address : std_logic_vector(DATA_MEM_WIDTH - 1 downto 0);
signal dmem_be : std_logic_vector(1 downto 0);

signal data_memory_address :  std_logic_vector(DATA_MEM_WIDTH - 1 downto 0);
signal data_memory_read_data :  std_logic_vector(31 downto 0);
signal data_memory_be        :  std_logic_vector(1 downto 0);
signal data_memory_write_data :  std_logic_vector(31 downto 0);
signal data_memory_write_enable :  std_logic;
	
	--instruction memory interface
signal inst_memory_address :  std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
signal inst_memory_read_data :  std_logic_vector(31 downto 0);
signal inst_memory_write_data :  std_logic_vector(31 downto 0);
signal inst_memory_write_enable :  std_logic;
begin
clk <= not clk after 1000 ns;
dmem_be <= "10"; 
sleep <= '0';
design : entity work.top port map
	(
	clk => clk,
	nreset => nreset,
	sleep => sleep,
	imem_we => imem_we,
	imem_data => imem_data,
	imem_write_address => imem_write_address,
	pass => pass,
	fail => fail,
	dmem_we => dmem_we,
	dmem_data => dmem_data,
	dmem_write_address => dmem_write_address,
	dmem_be => dmem_be,
	data_memory_address	=> data_memory_address,
	data_memory_read_data => data_memory_read_data,
	data_memory_be => data_memory_be,
	data_memory_write_data => data_memory_write_data,
	data_memory_write_enable => data_memory_write_enable,
	
	inst_memory_address => inst_memory_address,
	inst_memory_read_data => inst_memory_read_data,
	inst_memory_write_data => inst_memory_write_data,
	inst_memory_write_enable => inst_memory_write_enable
	);

instruction_memory : entity work.SP_32bit generic map(
	address_width => INSTRUCTION_MEM_WIDTH)
port map(
	clk => clk,
	we	=>inst_memory_write_enable,
	address  =>  inst_memory_address,
	data_in  => inst_memory_write_data,
	data_out => inst_memory_read_data
);

data_memory : entity work.bram generic map(
	address_width => DATA_MEM_WIDTH)
port map(
	clk => clk,
	byte_enable => data_memory_be,
	address => data_memory_address,
	we => data_memory_write_enable,
	write_data => data_memory_write_data,
	read_data => data_memory_read_data
);


process(clk) 
variable i : integer := 128;
variable j : integer := 0;
variable reading_done : integer := 0;
begin 
assert (j /= 0 or i /= 128) report "Assertion test, this should fire when starting" severity note;
assert ((fail /= '1') or (nreset = '0')) report "test " & integer'image(j) &" FAIL" severity failure;
assert ((pass /= '1') or (nreset = '0')) report "test " & integer'image(j) &" PASS" severity note;
--assert ((instruction /= x"ffffffff") or (nreset = '0')) report "test " & integer'image(j) &" returned" severity failure;
assert (j < 37) or (nreset = '0') report "All tests finished" severity failure;
--assert (i = 0 or (i = 128 and j = 0) or inst_memory_write_data = tests(j)(i - 1) or inst_memory_write_enable = '0') report "imem sanity check failed" severity failure;
if(reading_done = 0) then
	tests(1) <= ocram_ReadMemFile(hex_folder & "super_simple_test.hex");	  --pass
	tests(0) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-addi.hex");	  --pass
	tests(2) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-and.hex");		 --pass
	tests(3) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-andi.hex");		 --pass
	tests(4) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-auipc.hex");
	tests(5) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-beq.hex");		--pass
	tests(6) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-bge.hex"); 		--pass
	tests(7) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-bgeu.hex");		--pass
	tests(8) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-blt.hex");	   --pass
	tests(9) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-bltu.hex");	   --pass
	tests(10) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-bne.hex");
	tests(11) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-j.hex");
	tests(12) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-jal.hex");
	tests(13) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-jalr.hex");
	tests(14) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-lb.hex");
	tests(15) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-lbu.hex");
	tests(16) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-lh.hex");
	tests(17) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-lhu.hex");
	tests(18) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-lui.hex");
	tests(19) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-lw.hex");
	tests(20) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-or.hex");
	tests(21) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-ori.hex");
	tests(22) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-sb.hex");
	tests(23) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-sh.hex");
	tests(24) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-simple.hex");
	tests(25) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-sll.hex");
	tests(26) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-slt.hex");
	tests(27) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-slti.hex");
	tests(28) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-sra.hex");
	tests(29) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-srai.hex");
	tests(30) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-srl.hex");
	tests(31) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-srli.hex");
	tests(32) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-sub.hex");
	tests(33) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-sw.hex");
	tests(34) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-xor.hex");
	tests(35) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-xori.hex");
	tests(36) <= ocram_ReadMemFile(hex_folder & "rv32ui-p-add.hex");
	tests(37) <= ocram_ReadMemFile(hex_folder & "rv32ui-findPrimeHuge.hex");
	reading_done := 1;
end if;
--j:=37;
if(clk'event and clk = '1') then
	imem_write_address <= std_logic_vector(to_unsigned(4 * i, INSTRUCTION_MEM_WIDTH));
	dmem_write_address <= std_logic_vector(to_unsigned(i, DATA_MEM_WIDTH - 2)) & "00";
	if(tests(j)(i) /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU") then
		imem_data <= tests(j)(i);
		dmem_data <= tests(j)(i);
		if(i < 1000 and (i * 4) < (2**INSTRUCTION_MEM_WIDTH + 64)) then
			imem_we <= '1';
			dmem_we <= '1';
		elsif(i > 1000) then
			dmem_we <= '1';
			imem_we <= '0';
		else
			dmem_we <= '1';
			imem_we <= '0';
		end if;
			i := i + 1;
			nreset <= '0';
	else
		imem_we <= '0';
		dmem_we <= '0';
		imem_data <= x"00000000";
		nreset <= '1';
		if(pass = '1' or fail = '1') then
			j := j + 1;
			i := 0;
		end if;
	end if;
end if;


	
end process;

	
end behave;
