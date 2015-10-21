library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;


entity top_bench is
end top_bench;

architecture behave of top_bench is
signal clk : std_logic := '0';
signal nreset : std_logic := '0';
type mem_t is array(0 to ((2**PC_WIDTH) - 1)) of std_logic_vector(31 downto 0);
signal program : mem_t;
signal imem_we : std_logic;
signal imem_data : std_logic_vector(31 downto 0);
signal imem_write_address : std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
begin
clk <= not clk after 10ns;

design : entity work.top port map
	(
	clk => clk,
	nreset => nreset,
	imem_we => imem_we,
	imem_data => imem_data,
	imem_write_address => imem_write_address
	);




process(clk) 
variable i : integer := 0;
begin
	
program(0) <= "00000000000000000011000010010111";	--ADDI rs1 = 0 rd = 1
program(1) <= "00000000000000000011000010010111";
program(2) <= "00000000000000000011000010010111";
program(3) <= "00000000000000000000000000000000";
program(4) <= "00000000000000000000000000000000";
program(5) <= "00000000000000000000000000000000";
program(6) <= "00000000000000000000000000000000";
program(7) <= "00000000000000000000000000000000";
--program(5) <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

if(clk'event and clk = '1') then
	imem_write_address <= std_logic_vector(to_unsigned(i, INSTRUCTION_MEM_WIDTH));
	if(program(i) /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU") then
		imem_we <= '1';
		imem_data <= program(i);
		i := i + 1;
		nreset <= '0';
	else
		imem_we <= '0';
		imem_data <= x"00000000";
		nreset <= '1';
	end if;
end if;


	
end process;

	
end behave;