library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

library work;
use work.constants.all;


entity soc_top is
	port(
	clk       : in std_logic;
	nreset    : in std_logic;
	--testbench
	pass      : out std_logic;
	fail      : out std_logic;
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
component SP_32bit generic(
        address_width : integer )
port(
        clk : in std_logic;
        we  : in std_logic;
        address : in std_logic_vector(address_width - 1 downto 0);
        data_in  : in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)
);
end component;
component bram generic (
        address_width : integer)
port(
        clk : in std_logic;
        byte_enable : in std_logic_vector(1 downto 0);
        address : in std_logic;
        we : in std_logic;
        write_data : in std_logic_vector(31 downto 0);
        read_data : out std_logic_vector(31 downto 0)
);
end component;
--SPI and startup
signal spi_settings     :  std_logic;
signal spi_data_in      :  std_logic_vector(31 downto 0);
signal spi_data_out     :  std_logic_vector(31 downto 0);
	
signal spi_busy         :  std_logic;
signal spi_finished     :  std_logic;
signal spi_clear        :  std_logic;
signal spi_start        :  std_logic;

signal startup_data_mem : std_logic_vector(31 downto 0);	
signal startup_address  : std_logic_vector(DATA_MEM_WIDTH - 2 downto 0);
signal startup_we		: std_logic;
signal startup_done		: std_logic;

signal d_clk            : std_logic; 
signal clk_reset, 
reset_last   : std_logic;
signal sync_reset : std_logic;
--memory
signal instr_we         : std_logic;
signal instr_data_w		: std_logic_vector(31 downto 0);
signal instr_data_r		: std_logic_vector(31 downto 0);
signal instr_addr		: std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
signal instr_re         : std_logic;

signal data_we          : std_logic;
signal data_data_w		: std_logic_vector(31 downto 0);
signal data_data_r		: std_logic_vector(31 downto 0);
signal data_addr        : std_logic_vector(DATA_MEM_WIDTH - 1 downto 0);
signal data_be          : std_logic_vector(1 downto 0);
signal data_re          : std_logic;  

signal startup_instr_addr : std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
signal startup_data_addr  : std_logic_vector(DATA_MEM_WIDTH - 1 downto 0);
signal startup_instr_we   : std_logic;
signal startup_data_we    : std_logic; 

signal cpu_instr_we         : std_logic;
signal cpu_instr_data_w		: std_logic_vector(31 downto 0);
signal cpu_instr_data_r		: std_logic_vector(31 downto 0);
signal cpu_instr_addr		: std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
signal cpu_instr_re         : std_logic;

signal cpu_data_we          : std_logic;
signal cpu_data_data_w		: std_logic_vector(31 downto 0);
signal cpu_data_data_r		: std_logic_vector(31 downto 0);
signal cpu_data_addr        : std_logic_vector(DATA_MEM_WIDTH - 1 downto 0);
signal cpu_data_be          : std_logic_vector(1 downto 0);
signal cpu_data_re          : std_logic;


--CPU
signal cpu_sleep : std_logic;

begin
cpu_sleep <= not startup_done;
	
	
clk_reset <= not (reset_last and not nreset);

	
clk_reset_process : process(clk)
begin	
	if(clk'event and clk = '1') then
		reset_last <= nreset;	
	end if;
end process;


sync_reset_process : process(d_clk)
begin
	if(d_clk'event and d_clk = '1') then
		sync_reset <= nreset;	
	end if;
end process;


startup_instr_addr <= startup_address(DATA_MEM_WIDTH - 3 downto 0) & "00";
startup_data_addr  <= startup_address(DATA_MEM_WIDTH - 3 downto 0) & "00";
startup_instr_we   <= startup_we and not startup_address(DATA_MEM_WIDTH - 2);
startup_data_we	<= startup_we;

memory_control_selector : process(startup_done, startup_instr_addr, 
startup_data_addr, startup_instr_we, startup_data_we, startup_data_mem, 
startup_data_mem, cpu_instr_addr, cpu_data_addr, cpu_instr_we,
cpu_data_we, cpu_data_be, cpu_instr_data_w, cpu_data_re, cpu_instr_re)
begin
	case (startup_done) is
		when '0' =>
			instr_addr   <= startup_instr_addr;
			data_addr    <= startup_data_addr;
			instr_we     <= startup_instr_we;
			data_we      <= startup_data_we;
			data_be      <= "10";
			instr_data_w <= startup_data_mem;
			data_data_w  <= startup_data_mem;
			data_re      <= '0';
			instr_re     <= '0';
		when '1' =>
			instr_addr   <= cpu_instr_addr;
			data_addr    <= cpu_data_addr;
			instr_we     <= cpu_instr_we;
			data_we      <= cpu_data_we;
			data_be      <= cpu_data_be;
			instr_data_w <= cpu_instr_data_w;
			data_data_w  <= cpu_data_data_w;
			data_re      <= cpu_data_re;
			instr_re     <= cpu_instr_re;
		when others =>
			NULL;
	end case;
end process;
	
spi_controller : entity work.SPI_controller port map(
	clk        => d_clk,
	nreset     => sync_reset,
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
	clk        => d_clk,
	nreset     => sync_reset,
	
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


clock_divider : entity work.clock_divider generic map(
	division => 4
	)	
	port map(
	clk => clk,
	nreset => clk_reset,
	d_clk => d_clk	
	);

instruction_memory : entity work.SP_32bit generic map(
	address_width => INSTRUCTION_MEM_WIDTH)
port map(
	clk => d_clk,
	we	=> instr_we,
	address  =>  instr_addr,
	data_in  => instr_data_w,
	data_out => instr_data_r
);

data_memory : entity work.bram generic map(
	address_width => DATA_MEM_WIDTH)
port map(
	clk => d_clk,
	byte_enable => data_be,
	address => data_addr,
	we => data_we,
	write_data => data_data_w,
	read_data => data_data_r
);	


AAsmund_RISC : entity work.top	port map
	(
	clk => d_clk,
	nreset => sync_reset,
	
	sleep => cpu_sleep,
	
	--test interface
	pass  => pass,
	fail  => fail,

	--data memory interface
	data_memory_address      => cpu_data_addr,
	data_memory_read_data    =>	data_data_r, 
	data_memory_be           =>	cpu_data_be,
	data_memory_write_data   => cpu_data_data_w,
	data_memory_write_enable => cpu_data_we, 
	
	--instruction memory interface
	inst_memory_address => cpu_instr_addr,
	inst_memory_read_data => instr_data_r,
	inst_memory_write_enable => cpu_instr_we
	);

cpu_instr_data_w <= x"00000000";
cpu_data_re <= '1'; --TODO: Implement read enable signal
cpu_instr_re <= '1'; --TODO: Implement read enable signal
end behave;
