library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

library work;
use work.constants.all;


entity spi_startup is
	port(
	clk : in std_logic;
	nreset : in std_logic;
	
	--SPI controller interface--
	data_to_spi : out std_logic_vector(31 downto 0);
	data_from_spi : in std_logic_vector(31 downto 0);
	spi_finished : in std_logic;
	spi_start : out std_logic;
	spi_clear : out std_logic;
	spi_settings : out std_logic;
	
	
	--Memory interface--
	data_mem : out std_logic_vector(31 downto 0);
	address  : out std_logic_vector(DATA_MEM_WIDTH - 2 downto 0);
	we       : out std_logic;
	
	done     : out std_logic	
	);
end entity;


architecture behave of spi_startup is
type state_t is (STARTUP_WAIT, READ_STATUS_1, READ_STATUS_2, READ_STATUS_3,
READ_DATA_1, READ_DATA_2, READ_DATA_3, READ_DATA_4, IDLE);
constant read_status_settings : std_logic_vector(31 downto 0) := x"00000001";
constant read_status_seq : std_logic_vector(31 downto 0) := x"05000000";
constant read_data_settings_1 : std_logic_vector(31 downto 0) := x"00000002";
constant read_data_settings_2 : std_logic_vector(31 downto 0) := x"00000003";
constant read_data_seq     : std_logic_vector(31 downto 0) := x"03000000";
signal state, n_state : state_t;
signal word_cnt, n_word_cnt, word_cnt_incr : unsigned(10 downto 0);
begin

data_mem <= data_from_spi;
address  <= std_logic_vector(word_cnt(DATA_MEM_WIDTH - 2 downto 0));
word_cnt_incr <= word_cnt + 1;
	
combi : process(state, word_cnt, spi_finished, word_cnt_incr)
begin
	data_to_spi <= (others => '0');
	spi_settings <= '0';
	spi_start <= '0';
	we <= '0';
	n_word_cnt <= word_cnt;
	n_state <= state;
	done <= '0';
	spi_clear <= '0';
	case (state) is
		when STARTUP_WAIT =>
			n_word_cnt <= word_cnt_incr;
			if(word_cnt = "1111111111") then
				n_state <= READ_STATUS_1;
			end if;
		when READ_STATUS_1 =>
			n_word_cnt <= (others => '0');
			data_to_spi <= read_status_settings;
			spi_settings <= '1';
			n_state <= READ_STATUS_2;
		when READ_STATUS_2 =>
			data_to_spi <= read_status_seq;
			spi_start <= '1';
			n_state <= READ_STATUS_3;
		when READ_STATUS_3 =>
			if(spi_finished = '1') then
				spi_clear <= '1';
				if(data_from_spi(0) = '0') then
					n_state <= READ_DATA_1;
				else
					n_state <= STARTUP_WAIT;
				end if;
			end if;
		when READ_DATA_1 =>
			data_to_spi <= read_data_settings_1;
			spi_settings <= '1';
			n_state <= READ_DATA_2;
		when READ_DATA_2 =>
			data_to_spi <= read_data_seq;
			spi_start <= '1';
			n_state <= READ_DATA_3;
		when READ_DATA_3 =>
			if(spi_finished = '1') then
				spi_start <= '1';
				data_to_spi <= read_data_settings_2;
				spi_settings <= '1';
				n_state <= READ_DATA_4;
			end if;
		when READ_DATA_4 =>
			if(spi_finished = '1') then
				n_word_cnt <= word_cnt_incr;
				we <= '1';
				if(word_cnt = "01111111111") then
					n_state <= IDLE;
					spi_clear <= '1';
				else
					spi_start <= '1';
				end if;
			end if;
		when IDLE =>
			done <= '1';
		when others =>
			NULL;
	end case;		
				
end process;

seq : process(clk, nreset)
begin
	if(clk'event and clk = '1') then
		if(nreset = '0') then
			word_cnt <= (others => '0');
			state <= STARTUP_WAIT;
		else
			state <= n_state;
			word_cnt <= n_word_cnt;
		end if;
	end if;
end process;
	
end behave;