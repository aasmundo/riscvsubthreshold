library IEEE;
USE ieee.math_real.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all; 

library work;
use work.constants.all;


entity soc_top_tb is
end entity;



architecture behave of soc_top_tb is
constant hex_folder : String(1 to 51) := "C:\prosjektoppgave\riscvsubthreshold\tests\myTests\";

type mem_t is array(0 to ((2**PC_WIDTH) - 1)) of std_logic_vector(31 downto 0);
type tests_t is array(0 to 37) of mem_t;
signal tests : tests_t;
type spi_state_t is (NOT_SELECTED, INSTRUCTION, WRITE_SETTINGS, ADDRESS, READ);

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



signal spi_shift_regs : std_logic_vector(7 downto 0);
signal program_shift_regs : std_logic_vector(31 downto 0);
signal test_num : integer := 0;




signal clk       :  std_logic := '0';
signal nreset    :  std_logic;
--testbench
signal pass      :  std_logic;
signal fail      :  std_logic;
--spi--
signal sclk      :  std_logic;
signal miso      :   std_logic;
signal mosi      :  std_logic;
signal cs1       :  std_logic;
signal cs2       :  std_logic;
signal cs3       :  std_logic;
signal cs4       :  std_logic;
begin

clk <= not clk after 62500 ps;
	
soc : entity work.soc_top port map(

	clk       => clk,
	nreset    => nreset,
	--testbench
	pass      => pass,
	fail      => fail,
	--spi--
	sclk      => sclk,
	miso      => miso,
	mosi      => mosi,
	cs1       => cs1,
	cs2       => cs2,
	cs3       => cs3,
	cs4       => cs4
	); 

	
	
process
variable i : integer := 128;
begin 
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
wait;
end process;

process(sclk, cs1)
variable i : integer := 0;
variable spi_state : spi_state_t; 
variable bit_num : integer := 0;	  
variable read_mode : std_logic := '0';
variable last_bits : std_logic_vector(23 downto 0);
begin
	if(sclk'event and sclk = '1' and cs1 = '0' and nreset = '1') then
		
		if(read_mode = '1') then
			bit_num := bit_num + 1;
			if(bit_num > 31) then 
				bit_num := 0;
				i := i + 1;
			end if;
		end if;
		last_bits(23) := mosi;
		for j in 0 to 22 loop
			last_bits(j) := last_bits(j+1);
		end loop;
		if(last_bits = x"030000") then
			read_mode := '1';
		end if;
	end if;	   
	miso <= tests(test_num)(i)(bit_num);
end process;

process(pass, fail, nreset)
begin
assert ((fail /= '1') or (nreset = '0')) report "test " & integer'image(test_num) &" FAIL" severity failure;
assert ((pass /= '1') or (nreset = '0')) report "test " & integer'image(test_num) &" PASS" severity note;
if(pass'event and pass = '1' and nreset = '1') then
	test_num <= test_num + 1;
end if;
assert (test_num < 37) or (nreset = '0') report "All tests finished" severity failure;
end process;

process
begin
nreset <= '1';
wait for 50 us;
nreset <= '0';
wait for 100 us;
nreset <= '1';
wait;
end process;
end behave;