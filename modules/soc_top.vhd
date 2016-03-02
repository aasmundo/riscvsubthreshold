library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

library work;
use work.constants.all;


entity soc_top is
	port(
	clk       : in std_logic;
	clk_reset : in std_logic;
	nreset    : in std_logic;
	--spi--
	sclk      : out std_logic;
	miso      : in  std_logic;
	mosi      : out std_logic;
	cs1       : out std_logic;
	cs2       : out std_logic;
	cs3       : out std_logic;
	cs4       : out std_logic
	);
end entity;




architecture behave of soc_top is

signal	spi_settings    :  std_logic;
signal	spi_data_in     :  std_logic_vector(31 downto 0);
signal	spi_data_out    :  std_logic_vector(31 downto 0);
	
signal	spi_busy        :  std_logic;
signal	spi_finished    :  std_logic;
signal  spi_clear       :  std_logic;
signal	spi_start       :  std_logic;

signal startup_data_mem : std_logic_vector(31 downto 0);	
signal startup_address  : std_logic_vector(DATA_MEM_WIDTH - 2 downto 0);
signal startup_we		: std_logic;
signal startup_done		: std_logic;

signal half_clk         : std_logic; 
signal quarter_clk		: std_logic;
signal eighth_clk       : std_logic;

begin

	
	
spi_controller : entity work.SPI_controller port map(
	clk        => clk,
	nreset     => nreset,
	request    => spi_settings,
	data_in    => spi_data_in,
	data_out   => spi_data_out,
	
	busy       => spi_busy,
	finished   => spi_finished,
	clear      => spi_clear,
	start      => spi_start,

	--SPI interface
	miso       => miso,
	mosi       => mosi,
	sclk       => sclk,
	cs1        => cs1,
	cs2        => cs2,
	cs3        => cs3,
	cs4        => cs4
);

startup_controller : entity work.spi_startup port map(
	clk        => eighth_clk,
	nreset     => nreset,
	
	--SPI controller interface--
	data_to_spi => spi_data_in,
	data_from_spi => spi_data_out,
	spi_finished => spi_finished,
	spi_start => spi_start,
	spi_clear => spi_clear,
	spi_settings => spi_settings,
	
	
	--Memory interface--
	data_mem => startup_data_mem,
	address  => startup_address,
	we       => startup_we,
	
	done     => startup_done
	
);
	
process(clk, half_clk, quarter_clk, eighth_clk) is
begin
	if(clk'event and clk = '1') then
		if(clk_reset = '0') then
			half_clk <= '0';
			quarter_clk <= '0';
			eighth_clk <= '0';
		else
			half_clk <= not half_clk;
		end if;
	end if;
	if(half_clk'event and half_clk = '1') then
		quarter_clk <= not quarter_clk;
	end if;
	if(quarter_clk'event and quarter_clk = '1') then
		eighth_clk <= not eighth_clk;
	end if;
end process;

end behave;