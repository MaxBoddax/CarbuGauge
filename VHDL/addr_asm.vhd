LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY addr_asm IS
    PORT (
        clk, reset_n : IN STD_LOGIC;
        start, cmd_done : IN STD_LOGIC;
        addr_out : BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0);
        data_wr : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        ena, rw, send : OUT STD_LOGIC;
        pga : BUFFER STD_LOGIC_VECTOR(2 DOWNTO 0);
        dr : BUFFER STD_LOGIC_VECTOR(2 DOWNTO 0);
        data_raw_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        adc_data_ch0, adc_data_ch1, adc_data_ch2, adc_data_ch3 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        data_rd : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END addr_asm;

ARCHITECTURE Behavioral OF addr_asm IS
	TYPE ads1115_state IS (idle, w1, w2, w3, w4, rd1, rd2, command_wr1, command_wr2, command_rd1, command_rd2, hold0, hold, hold2); -- ADS1115 design for 1 channel
	SIGNAL state_reg, state_next : ads1115_state;
	SIGNAL reset, change_state, change_state_d, cmd_done_one_clk : std_logic;
	SIGNAL delay_count : INTEGER;
	SIGNAL adc_data_internal : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Variable to store ADC data

BEGIN
	reset <= reset_n;

	cmd_done_one_clk <= cmd_done AND (NOT change_state_d);

	PROCESS (clk)
	BEGIN
		IF (clk'EVENT AND clk = '1') THEN
			change_state_d <= cmd_done;
		END IF;
	END PROCESS;
	-- next state logic/ output and data path routing
	PROCESS (clk)
		BEGIN
			IF (clk'EVENT AND clk = '1') THEN
				CASE state_next IS
					WHEN idle => 
						delay_count <= 0;
						ena <= '0';
						rw <= '0';
						send <= '0';
						IF reset = '1' THEN
							IF start = '1' THEN
								state_next <= hold0;
							ELSE
								state_next <= idle;
							END IF;
						ELSE
							state_next <= idle;
						END IF;
 
					WHEN hold0 => 
						ena <= '0';
						IF delay_count < 1000 THEN
							delay_count <= delay_count + 1;
							state_next <= hold0;
						ELSE
							delay_count <= 0;
							state_next <= command_wr1;
						END IF;
 
					WHEN command_wr1 => 
						addr_out <= "1001000";
						data_wr <= x"01";
						rw <= '0';
						ena <= '1';
						send <= '0';
						IF cmd_done_one_clk = '1' THEN
							state_next <= w2;
						ELSE
							state_next <= command_wr1;
						END IF;

					WHEN w2 => 
						addr_out <= "1001000";
						data_wr <= x"C" & pga & '1';
						rw <= '0';
						ena <= '1';
						send <= '0';
						IF cmd_done_one_clk = '1' THEN
							state_next <= w3;
						ELSE
							state_next <= w2;
						END IF;

					WHEN w3 => 
						addr_out <= "1001000";
						data_wr <= dr & '0' & x"3";
						rw <= '0';
						send <= '0';

						IF cmd_done_one_clk = '1' THEN
							state_next <= hold;
						ELSE
							state_next <= w3;
						END IF;
 
					WHEN hold => 
						ena <= '0';
						IF delay_count < 1000 THEN
							delay_count <= delay_count + 1;
							state_next <= hold;
						ELSE
							delay_count <= 0;
							state_next <= rd1;
						END IF;
 
					WHEN rd1 => 
						ena <= '1';
						addr_out <= "1001000";
						data_wr <= x"00";
						rw <= '1'; -- read
						send <= '0';

						IF cmd_done_one_clk = '1' THEN
							state_next <= command_rd2;
						ELSE
							state_next <= rd1;
						END IF;
						adc_data_internal <= data_raw_in; -- Store ADC data in the variable

					WHEN command_rd2 => 
						ena <= '1';
						addr_out <= "1001000";
						data_wr <= x"00";
						rw <= '1'; -- read
						send <= '0';

						IF cmd_done_one_clk = '1' THEN
							state_next <= hold2;
						ELSE
							state_next <= command_rd2;
						END IF;
						adc_data_internal <= data_raw_in; -- Store ADC data in the variable

					WHEN hold2 => 
						ena <= '0';
						IF delay_count < 1000 THEN
							delay_count <= delay_count + 1;
							state_next <= hold2;
						ELSE
							delay_count <= 0;
							state_next <= rd2;
						END IF;

					WHEN rd2 => 
						ena <= '0';
						send <= '1';
						adc_data_internal <= data_raw_in; -- Store ADC data in the variable
						
						-- Gestisci i dati del canale 0
						adc_data_ch0 <= adc_data_internal(15 DOWNTO 0);
						
						-- Passa alla scrittura del comando per il secondo canale
						state_next <= command_wr2;
						
					WHEN command_wr2 =>
						addr_out <= "1001001"; -- Indirizzo per il secondo canale
						data_wr <= x"01";
						rw <= '0';
						ena <= '1';
						send <= '0';
						IF cmd_done_one_clk = '1' THEN
							state_next <= w2;
						ELSE
							state_next <= command_wr2;
						END IF;
						
					WHEN OTHERS => 
						state_next <= idle;
				END CASE;
			END IF;
		END PROCESS;
END Behavioral;
