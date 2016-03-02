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
type state_t is (STARTUP_WAIT, WRITE_SETTINGS_1, WRITE_INSTR_ADDRESS_START, WRITE_INSTR_ADDRESS_WAIT, 
				 WRITE_SETTINGS_2, RECV_DATA_START, RECV_DATA_WAIT, IDLE);
signal state, n_state : state_t;
signal word_cnt, n_word_cnt : unsigned(10 downto 0);
begin

data_mem <= data_from_spi;
address  <= std_logic_vector(word_cnt(DATA_MEM_WIDTH - 2 downto 0));
	
combi : process(state, word_cnt, spi_finished)
begin
	data_to_spi <= x"000000" & "00000010";
	spi_settings <= '0';
	spi_start <= '0';
	we <= '0';
	n_word_cnt <= word_cnt;
	n_state <= state;
	done <= '0';
	spi_clear <= '0';
	case (state) is
		when STARTUP_WAIT =>
			n_word_cnt <= word_cnt + 1;
			if(word_cnt = "1111111111") then
				n_state <= WRITE_SETTINGS_1;
			end if;
		when WRITE_SETTINGS_1 =>
			n_word_cnt <= (others => '0');
			spi_settings <= '1';
			n_state <= WRITE_INSTR_ADDRESS_START;
		when WRITE_INSTR_ADDRESS_START =>
			data_to_spi <= x"00" & "00000011" & x"0000";
			spi_start <= '1';
			n_state <= WRITE_INSTR_ADDRESS_WAIT;
		when WRITE_INSTR_ADDRESS_WAIT =>
			if(spi_finished = '1') then
				n_state <= WRITE_SETTINGS_2;
			end if;
		when WRITE_SETTINGS_2 =>
			data_to_spi <= x"000000" & "00000011";
			spi_settings <= '1';
			n_state <= RECV_DATA_START;
		when RECV_DATA_START =>
			spi_start <= '1';
			n_state <= RECV_DATA_WAIT;
		when RECV_DATA_WAIT =>
			if(spi_finished = '1') then
				n_word_cnt <= word_cnt + 1;
				if(word_cnt = "1000000000") then 
					n_state <= IDLE;
					spi_clear <= '1';
				else
					spi_start <= '1';
				end if; 
			end if;
			we <= spi_finished;
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