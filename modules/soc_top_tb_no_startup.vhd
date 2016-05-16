library IEEE;
USE ieee.math_real.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all; 

library work;
use work.constants.all;

LIBRARY worklib;

entity soc_top_tb_no_startup is
	port(
	pass_out, fail_out : out std_logic --send pass and fail to output because the simulator will optimize them away otherwise
	);
end entity;



architecture behave of soc_top_tb_no_startup is
constant test_folder : String(1 to 52) :=  "C:\prosjektoppgave\riscvsubthreshold\tests\newTests\";
constant modules_folder : String(1 to 57) := "C:\prosjektoppgave\riscvsubthreshold\modules\settings.hex";
constant number_of_tests : integer := 40;
signal begin_test : integer := 0; 
signal last_test  : integer := 0;
type mem_t is array(0 to ((2**PC_WIDTH) - 1)) of std_logic_vector(31 downto 0);
type tests_t is array(0 to number_of_tests - 1) of mem_t;
signal tests : tests_t;
type spi_state_t is (NOT_SELECTED, INSTRUCTION, WRITE_SETTINGS, ADDRESS, READ);

impure function ocram_ReadMemFile(FileName : STRING) return mem_t is
  file FileHandle       : TEXT open READ_MODE is FileName;
  variable CurrentLine  : LINE;
  variable TempWord     : STD_LOGIC_VECTOR(31 downto 0);
  variable Result       : mem_t    := (others => (others => '0'));

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
signal d_clk     :  std_logic;
signal clk_cnt, clk_cnt_n   :  std_logic_vector(3 downto 0) := "0000";
signal nreset    :  std_logic;
--testbench
signal pass      :  std_logic;
signal fail      :  std_logic;
--spi--
signal sclk      :  std_logic;
signal miso      :  std_logic;
signal mosi      :  std_logic;
signal cs1       :  std_logic;
signal cs2       :  std_logic;
signal cs3       :  std_logic;
signal cs4       :  std_logic;
--reroute for fast sim--
signal skip_startup : std_logic := '1';
signal d_clk_out    : std_logic;
--instr-mem-reroute--
signal instr_mem_write_en : std_logic;
signal instr_mem_Address  : std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
signal instr_mem_write_data_input : std_logic_vector(31 downto 0);
signal instr_mem_read_data	: std_logic_vector(31 downto 0);
signal instr_mem_reset_pulse_generator : std_logic;
signal instr_mem_idle : std_logic;
--instr-mem-reroute--
signal data_mem_write_en : std_logic;
signal data_mem_Address  : std_logic_vector(DATA_MEM_WIDTH - 1 downto 0);
signal data_mem_write_data_input : std_logic_vector(31 downto 0);
signal data_mem_read_data	: std_logic_vector(31 downto 0);
signal data_mem_be : std_logic_vector(1 downto 0);
signal data_mem_reset_pulse_generator : std_logic;
signal data_mem_idle : std_logic;
--instr-mem-fast-write--
signal instr_mem_write_all_data : std_logic_vector(((2**INSTRUCTION_MEM_WIDTH) * 8 ) - 1 downto 0);
signal instr_mem_write_all_en   : std_logic;
--data-mem-fast-write--
signal data_mem_write_all_data : std_logic_vector(((2**DATA_MEM_WIDTH) * 8 ) - 1 downto 0);
signal data_mem_write_all_en   : std_logic;

begin

pass_out <= pass;
fail_out <= fail;
	
clk <= not clk after 31250 ps;
clk_cnt_n <= std_logic_vector(unsigned(clk_cnt) + 1);
d_clk <= clk_cnt(3);
clock_div : process(clk, clk_cnt_n, clk_cnt)
begin
	if(clk'event and clk = '1') then
		clk_cnt <= clk_cnt_n;
	end if;
end process;
	
soc : entity worklib.soc_top port map(

	clk       => clk,
	d_clk     => d_clk,
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
	cs4       => cs4,	
	
	skip_startup => '1',
	d_clk_out => d_clk_out,
	instr_mem_write_en => instr_mem_write_en,
	instr_mem_Address  => instr_mem_Address,
	instr_mem_write_data_input => instr_mem_write_data_input,
	instr_mem_read_data => instr_mem_read_data,
	instr_mem_reset_pulse_generator => instr_mem_reset_pulse_generator,
	instr_mem_idle => instr_mem_idle,
	--instr-mem-reroute--
	data_mem_write_en => data_mem_write_en,
	data_mem_Address  => data_mem_Address,
	data_mem_write_data_input => data_mem_write_data_input,
	data_mem_read_data => data_mem_read_data,
	data_mem_be => data_mem_be,
	data_mem_reset_pulse_generator => data_mem_reset_pulse_generator,
	data_mem_idle => data_mem_idle
	); 
instruction_memory : entity work.instr_mem_sram_model generic map(
		address_width => INSTRUCTION_MEM_WIDTH)
	port map(
		clk => clk,
		write_en => instr_mem_write_en,
		Address  =>  instr_mem_Address,
		write_data_input  => instr_mem_write_data_input,
		read_data => instr_mem_read_data,
		reset_pulse_generator => instr_mem_reset_pulse_generator,
		idle => instr_mem_idle,
		write_all_en => instr_mem_write_all_en,
		write_all_data => instr_mem_write_all_data
		);
	
data_memory : entity work.data_mem_sram_model generic map(
		address_width => DATA_MEM_WIDTH)
	port map(
		clk => clk,
		be  => data_mem_be,
		write_en => data_mem_write_en,
		Address  =>  data_mem_Address,
		write_data_input  => data_mem_write_data_input,
		read_data => data_mem_read_data,
		reset_pulse_generator => data_mem_reset_pulse_generator,
		idle => data_mem_idle,
		write_all_en => data_mem_write_all_en,
		write_all_data => data_mem_write_all_data
	);


	
process
begin
tests(0) <= ocram_ReadMemFile(TEST_FOLDER & "super_simple_test.hex");	  --pass
tests(14) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-addi.hex");	  --pass
tests(39) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-and.hex");		 --pass
tests(28) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-andi.hex");		 --pass
tests(4) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-auipc.hex");
tests(5) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-beq.hex");		--pass
tests(6) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-bge.hex"); 		--pass
tests(7) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-bgeu.hex");		--pass
tests(8) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-blt.hex");	   --pass
tests(9) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-bltu.hex");	   --pass
tests(10) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-bne.hex");
tests(11) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-j.hex");
tests(12) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-jal.hex");
tests(13) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-jalr.hex");
tests(23) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-lb.hex");
tests(15) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-lbu.hex");
tests(16) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-lh.hex");
tests(17) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-lhu.hex");
tests(18) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-lui.hex");
tests(19) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-lw.hex");
tests(20) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-or.hex");
tests(29) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-ori.hex");
tests(22) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-sb.hex");
tests(37) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-sh.hex");
tests(24) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-simple.hex");
tests(25) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-sll.hex");
tests(26) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-slt.hex");
tests(27) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-slti.hex");
tests(3) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-sra.hex");
tests(21) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-srai.hex");
tests(30) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-srl.hex");
tests(31) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-srli.hex");
tests(32) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-sub.hex");
tests(33) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-sw.hex");
tests(34) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-xor.hex");
tests(35) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-xori.hex");
tests(36) <= ocram_ReadMemFile(TEST_FOLDER & "rv32ui-p-add.hex");
tests(2) <= ocram_ReadMemFile(TEST_FOLDER & "asoc_man_link.hex");
--tests(38) <= ocram_ReadMemFile(TEST_FOLDER & "sleep_test.hex");
tests(1) <= ocram_ReadMemFile(TEST_FOLDER & "spi_transfer_test.hex");
tests(38) <= ocram_ReadMemFile(TEST_FOLDER & "rdcycles_test.hex");

wait;
end process;

process
variable status_check_seq : std_logic_vector(0 to 15) := "00000101" & "00000000";
variable start_read_seq : std_logic_vector(0 to 23) := "00000011" & x"0000";
variable ns_passed : integer := 0;
begin
	nreset <= '1';
	wait for 1 us;
	nreset <= '0';
	wait for 1 us;
	nreset <= '1'; 
	for testnum in BEGIN_TEST to LAST_TEST loop 
		wait until d_clk_out'event and d_clk_out = '1';
		ns_passed := 0;
		for i in 1 to ((2**DATA_MEM_WIDTH) / 4)  loop
			data_mem_write_all_data((i*32) - 1 downto (i-1) * 32)  <= tests(testnum)(i+511);
		end loop;
		for i in 1 to ((2**INSTRUCTION_MEM_WIDTH) / 4) loop
			instr_mem_write_all_data((i*32) - 1 downto (i-1) * 32) <= tests(testnum)(i-1);
		end loop;
		data_mem_write_all_en <= '1';
		instr_mem_write_all_en <= '1';
		wait until d_clk_out'event and d_clk_out = '1';
		data_mem_write_all_en <= '0';
		instr_mem_write_all_en <= '0';
		nreset <= '0';
		wait until d_clk_out'event and d_clk_out = '1';
		wait for 30 ns;
		nreset <= '1';
		wait for 2 us;
		while (pass = '0' and fail = '0' and (ns_passed < 1000000 or (testnum > 37 and ns_passed < 24000000))) loop
			miso <= not mosi;
			wait for 5 ns;
			ns_passed := ns_passed + 5;
		end loop;
		assert ((fail /= '1') or (nreset = '0')) report "test " & integer'image(testnum) &" FAIL" severity failure;
		assert ((pass /= '1') or (nreset = '0')) report "test " & integer'image(testnum) &" PASS" severity note;
		assert (ns_passed < 1000000 or (testnum > 37 and ns_passed < 24000000)) report "test " & integer'image(testnum) &" timed out" severity failure;
		nreset <= '0';
		assert (testnum <= LAST_TEST) report "tests finished" severity failure;
		wait for 3 us;
		nreset <= '1';
	end loop;
	
end process;

end behave;
