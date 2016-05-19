library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all; 


entity clock_counter is
	port(
	clk    : in  std_logic;
	pwr_en : in  std_logic;
	cnt_en : in  std_logic;
	nreset : in  std_logic;
	cnt    : out std_logic_vector(63 downto 0)
	);
end entity;

architecture behave of clock_counter is
signal count : unsigned(63 downto 0);
signal n_cnt_with_reset : std_logic_vector(63 downto 0);
signal cnt_i, n_cnt, cnt_p_one : std_logic_vector(63 downto 0);
begin

	clock_counter_regs : entity work.clock_counter_pg_reg port map(
	clk   => clk,
	pwr_en => pwr_en,
	cnt_in => n_cnt_with_reset,
	cnt    => cnt_i
	);
	cnt <= cnt_i;
	n_cnt_with_reset <= n_cnt when pwr_en = '1' else (others => '0');
	cnt_p_one <= std_logic_vector(unsigned(cnt_i) + 1);	
	n_cnt <= cnt_p_one when cnt_en = '1' else cnt_i;
		

	
end behave;