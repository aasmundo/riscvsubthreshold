library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;
library work;
use work.constants.all;


entity sleep_controller is
	port(
		clk          : in std_logic;
		nreset       : in std_logic;
		data         : in std_logic_vector(31 downto 0);  
		sleep_type   : in std_logic; 
		we           : in std_logic;
		spi_finished : in std_logic;
		spi_busy     : in std_logic;
		sleep        : out std_logic
	);
end sleep_controller; 

architecture behave of sleep_controller is
type state_t is (IDLE, TIME_WAIT, SPI_WAIT);
signal state, state_n : state_t;

signal cnt, cnt_n, cnt_minus_one : std_logic_vector(31 downto 0);
signal time_or_spi, time_or_spi_n : std_logic;
signal sleep_n : std_logic;
begin

cnt_minus_one <= std_logic_vector(unsigned(cnt) - 1);

combi : process(state, sleep_type, cnt, spi_finished, cnt_minus_one, data, spi_busy, we)
begin
	sleep_n <= '0';
	cnt_n <= cnt;
	state_n <= state;
	case (state) is
		when IDLE =>
			if(we = '1') then 
				if(sleep_type = '1') then
					if(spi_busy = '1') then	
						sleep_n <= '1';
						state_n <= SPI_WAIT;
					end if;
				else
					state_n <= TIME_WAIT;
				end if;
			end if;			
		when TIME_WAIT =>
			sleep_n <= '1';
			if(cnt = x"00000000") then
				state_n <= IDLE;
			else
				cnt_n <= cnt_minus_one;
			end if;
		when SPI_WAIT =>
			if(spi_finished = '1' or spi_busy = '0') then
				state_n <= IDLE;
			end if;
			sleep_n <= '1';
		when others =>
			null;
	end case;		
end process;
	
	
seq : process(clk)
begin
	if(clk'event and clk = '1') then
		if(nreset = '0') then
			cnt <= (others => '0');
			time_or_spi <= '0';
			sleep <= '0';
			state <= IDLE;
		else
			cnt <= cnt_n;
			time_or_spi <= time_or_spi_n;
			sleep <= sleep_n;
			state <= state_n;
		end if;
	end if;
end process;
	
end behave;
	