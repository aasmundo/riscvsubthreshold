
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity SPI_top3 is
port(
	clk,
	nreset        : in  std_logic;
	start         : in  std_logic;
	byte_complete : out std_logic;

	data_in       : in  std_logic_vector(7 downto 0);
	data_out      : out std_logic_vector(7 downto 0);

	mosi          : out std_logic;
    miso          : in  std_logic;
    sclk          : out std_logic
);
end SPI_top3;

architecture behave of SPI_top3 is
type state_t is (IDLE, ONE, TWO, THREE, FOUR, FIN);

signal state, n_state : state_t;
signal counter, n_counter : unsigned(2 downto 0);
signal regs, reg_input, regs_shifted  : std_logic_vector(7 downto 0);
signal n_sclk, sclk_i, reg_src, reg_we : std_logic;
begin

sclk <= sclk_i;
data_out <= regs;
mosi <= regs(0);
regs_shifted <= miso & regs(7 downto 1);

state_combi : process(counter, state, regs_shifted, data_in, reg_src, start)

begin
	reg_src <= '0';
	n_counter <= counter;
	n_sclk <= '0';
	reg_we <= '0';
	byte_complete <= '0';
	case (state) is
		when IDLE =>
			if(start = '1') then
				n_state <= ONE;
				reg_src <= '1';
				reg_we <= '1';
			end if;
		when ONE =>
			n_sclk <= '1';
			n_state <= TWO;
			n_counter <= counter + 1;
			reg_we <= '1';
		when TWO =>
			n_sclk <= '1';
			if(counter = "000") then
				n_state <= FIN;
			else
				n_state <= THREE;
			end if;
		when THREE =>
			n_state <= FOUR;
		when FOUR => 
			n_state <= ONE;
		when FIN =>
			byte_complete <= '1';
			n_state <= IDLE;
		when others =>
			NULL;
	end case;




	case (reg_src) is
		when '0' => reg_input <= regs_shifted;
		when '1' => reg_input <= data_in;
		when others => reg_input <= regs_shifted;
	end case;

end process;





seq : process(clk, nreset)
begin
	if(clk'event and clk ='1') then
		if(nreset = '0') then
			counter <= "000";
			sclk_i <= '0';
			state <= IDLE;
		else
			sclk_i <= n_sclk;
			counter <= n_counter;
			state <= n_state;
		end if;
		
		if(reg_we = '1') then
			regs <= reg_input;
		end if;
		
	end if;
end process;

end behave;