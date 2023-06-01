LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY vumeter IS
	PORT (
		clk : IN STD_LOGIC; --system clock
		reset_n : IN STD_LOGIC; -- reset addr_asm and address gen
		start : IN STD_LOGIC;
		-- write data to ADC pin
		data_rd : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0); -- Digital data from ADC channel
		adc_data_ready : OUT STD_LOGIC; -- Signal indicating that ADC data is ready
		pga : OUT std_logic_vector(2 DOWNTO 0);
		dr : OUT std_logic_vector(2 DOWNTO 0);
		--i2c_clk : out std_logic;
		sda : INOUT STD_LOGIC; --serial data output of I2C bus
		scl : INOUT STD_LOGIC; --serial clock output of I2C bus
		ch_sel : in  STD_LOGIC;
		led_bar_out : out std_logic_vector(29 downto 0)
	);
END vumeter;

ARCHITECTURE Behavioral OF vumeter IS

	COMPONENT i2c_master IS
		GENERIC (
			input_clk : INTEGER :=  25000000; --input clock speed from user logic in Hz
			bus_clk : INTEGER := 400000
		);
		PORT (
			clk : IN STD_LOGIC; --system clock
			reset_n : IN STD_LOGIC; --active low reset
			ena : IN STD_LOGIC; --latch in command
			addr : IN STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
			rw : IN STD_LOGIC; --'0' is write, '1' is read
			data_wr : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
			busy : OUT STD_LOGIC; --indicates transaction in progress
			finish : OUT std_logic;
			data_rd : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0); --data read from slave
			ack_error : BUFFER STD_LOGIC; --flag if improper acknowledge from slave
			sda : INOUT STD_LOGIC; --serial data output of I2C bus
			scl : INOUT STD_LOGIC --serial clock output of I2C bus
		);
	END COMPONENT;

	COMPONENT addr_asm IS
		PORT (
			clk, reset_n : IN STD_LOGIC;
			start, cmd_done : IN STD_LOGIC;
			addr_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			ena, rw, send : OUT std_logic;
			pga : OUT std_logic_vector(2 DOWNTO 0);
			dr : OUT std_logic_vector(2 DOWNTO 0);
			data_raw_in : IN std_logic_vector(15 DOWNTO 0);
			data_rd : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT led_bars IS
		PORT (
			clk, reset_n : IN STD_LOGIC;
			adc_data_ch0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			adc_data_ch1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			adc_data_ch2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			adc_data_ch3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			led_bar_out : OUT STD_LOGIC_VECTOR(29 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL clk_50 : STD_LOGIC;
	SIGNAL ena : STD_LOGIC;
	SIGNAL addr : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL rw : STD_LOGIC;
	SIGNAL data_wr : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL busy, send : STD_LOGIC;
	SIGNAL data_rd_intermediate : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Intermediate signal for data_rd
	SIGNAL ack_error : STD_LOGIC;
	SIGNAL count : INTEGER RANGE 0 TO 8191 := 0;
	SIGNAL finish : std_logic;

	SIGNAL d_ready_sig, frame_complete_delay, start_one_clk, change_state_d : std_logic;
	SIGNAL globalCounter : std_logic_vector(12 - 1 DOWNTO 0) := (OTHERS => '0');

BEGIN

	i2c : i2c_master
		GENERIC MAP (
			input_clk =>  25000000, --input clock speed from user logic in Hz
			bus_clk => 400000
		)
		PORT MAP (
			clk => clk, 
			reset_n => '1', 
			ena => ena, 
			addr => addr, 
			rw => rw, 
			data_wr => data_wr, 
			busy => busy, 
			data_rd => data_rd_intermediate, 
			ack_error => ack_error, 
			sda => sda, 
			scl => scl
		);

	address_gen : addr_asm
		PORT MAP (
			clk => clk, 
			reset_n => '1', 
			start => start, 
			cmd_done => finish, 
			addr_out => addr, 
			data_wr => data_wr, 
			ena => ena, 
			rw => rw, 
			send => send, 
			pga => pga, 
			dr => dr, 
			data_raw_in => data_rd_intermediate, 
			data_rd => data_rd
		);

	led_bars_inst : led_bars
		PORT MAP (
			clk => clk,
			reset_n => reset_n,
			adc_data_ch0 => data_rd,
			adc_data_ch1 => (others => '0'),
			adc_data_ch2 => (others => '0'),
			adc_data_ch3 => (others => '0'),
			led_bar_out => led_bar_out
		);

END Behavioral;
