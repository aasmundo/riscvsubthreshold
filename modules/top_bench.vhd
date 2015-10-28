library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
library work;
use work.constants.all;


entity top_bench is
end top_bench;

architecture behave of top_bench is
signal clk : std_logic := '0';
signal nreset : std_logic := '0';
type mem_t is array(0 to ((2**PC_WIDTH) - 1)) of std_logic_vector(31 downto 0);
type tests_t is array(0 to 36) of mem_t;
--type string_array is array(0 to 4) of string;
--constant files : string_array := ("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-add.hex",
--"C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-addi.hex", 
--"C:\prosjektoppgave\riscvsubthreshold\tests\myTests", 
--"C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-and.hex",
--"C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-andi.hex");


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
signal instruction : std_logic_vector(31 downto 0);
begin
clk <= not clk after 1ns;

design : entity work.top port map
	(
	clk => clk,
	nreset => nreset,
	imem_we => imem_we,
	imem_data => imem_data,
	imem_write_address => imem_write_address,
	instruction => instruction
	);




process(clk) 
variable i,j : integer := 0;
variable reading_done : integer := 0;
begin 
	
assert ((instruction /= x"0100006f") or (nreset = '0')) report "test " & integer'image(j) &" FAIL" severity error;
assert ((instruction /= x"0040006f") or (nreset = '0')) report "test " & integer'image(j) &" PASS" severity error;
if(reading_done = 0) then
	tests(0) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-add.hex");	  --pass
	tests(1) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-addi.hex");	  --pass
	tests(2) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-and.hex");		 --pass
	tests(3) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-andi.hex");		 --pass
	tests(4) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-auipc.hex");
	tests(5) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-beq.hex");		--pass
	tests(6) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-bge.hex"); 		--pass
	tests(7) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-bgeu.hex");		--pass
	tests(8) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-blt.hex");	   --pass
	tests(9) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-bltu.hex");	   --pass
	tests(10) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-bne.hex");
	tests(11) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-fence_i.hex");	 --pass
	tests(12) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-j.hex");
	tests(13) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-jal.hex");
	tests(14) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-jalr.hex");
	tests(15) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-lb.hex");
	tests(16) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-lbu.hex");
	tests(17) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-lh.hex");
	tests(18) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-lhu.hex");
	tests(19) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-lui.hex");
	tests(20) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-lw.hex");
	tests(21) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-or.hex");
	tests(22) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-ori.hex");
	tests(23) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-sb.hex");
	tests(24) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-sh.hex");
	tests(25) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-simple.hex");
	tests(26) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-sll.hex");
	tests(27) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-slt.hex");
	tests(28) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-slti.hex");
	tests(29) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-sra.hex");
	tests(30) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-srai.hex");
	tests(31) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-srl.hex");
	tests(32) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-srli.hex");
	tests(33) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-sub.hex");
	tests(34) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-sw.hex");
	tests(35) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-xor.hex");
	tests(36) <= ocram_ReadMemFile("C:\prosjektoppgave\riscvsubthreshold\tests\myTests\rv32ui-p-xori.hex");
	reading_done := 1;
end if;

if(clk'event and clk = '1') then
	imem_write_address <= std_logic_vector(to_unsigned(i, INSTRUCTION_MEM_WIDTH));
	if(tests(j)(i) /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU") then
		imem_we <= '1';
		imem_data <= tests(j)(i);
		i := i + 1;
		nreset <= '0';
	else
		imem_we <= '0';
		imem_data <= x"00000000";
		nreset <= '1';
		if(instruction = x"00000073") then
			j := j + 1;
			i := 0;
		end if;
	end if;
end if;


	
end process;

	
end behave;