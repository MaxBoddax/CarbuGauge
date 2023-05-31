-- Led drivers 
-- MaxBoddax

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_bars is
    port (
        clk : in std_logic;
        reset_n : in std_logic;
        adc_data_ch0 : in std_logic_vector(15 downto 0);
        adc_data_ch1 : in std_logic_vector(15 downto 0);
        adc_data_ch2 : in std_logic_vector(15 downto 0);
        adc_data_ch3 : in std_logic_vector(15 downto 0);
        led_bar_out : out std_logic_vector(29 downto 0)
    );
end entity led_bars;

architecture behavioral of led_bars is
    signal peak_hold_ch0 : unsigned(15 downto 0) := (others => '0');
    signal peak_hold_ch1 : unsigned(15 downto 0) := (others => '0');
    signal peak_hold_ch2 : unsigned(15 downto 0) := (others => '0');
    signal peak_hold_ch3 : unsigned(15 downto 0) := (others => '0');
    signal peak_counter : integer := 0;
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                -- Reset all values
                peak_hold_ch0 <= (others => '0');
                peak_hold_ch1 <= (others => '0');
                peak_hold_ch2 <= (others => '0');
                peak_hold_ch3 <= (others => '0');
                peak_counter <= 0;
                led_bar_out <= (others => '0');
            else
                -- Update peak hold values
                if unsigned(adc_data_ch0) >= peak_hold_ch0 then
                    peak_hold_ch0 <= unsigned(adc_data_ch0);
                    peak_counter <= 250;
                elsif peak_counter = 0 then
                    peak_hold_ch0 <= (others => '0');
                else
                    peak_counter <= peak_counter - 1;
                end if;
                
                if unsigned(adc_data_ch1) >= peak_hold_ch1 then
                    peak_hold_ch1 <= unsigned(adc_data_ch1);
                    peak_counter <= 250;
                elsif peak_counter = 0 then
                    peak_hold_ch1 <= (others => '0');
                else
                    peak_counter <= peak_counter - 1;
                end if;
                
                if unsigned(adc_data_ch2) >= peak_hold_ch2 then
                    peak_hold_ch2 <= unsigned(adc_data_ch2);
                    peak_counter <= 250;
                elsif peak_counter = 0 then
                    peak_hold_ch2 <= (others => '0');
                else
                    peak_counter <= peak_counter - 1;
                end if;
                
                if unsigned(adc_data_ch3) >= peak_hold_ch3 then
                    peak_hold_ch3 <= unsigned(adc_data_ch3);
                    peak_counter <= 250;
                elsif peak_counter = 0 then
                    peak_hold_ch3 <= (others => '0');
                else
                    peak_counter <= peak_counter - 1;
                end if;
                
                -- Update LED bar output
                led_bar_out <= std_logic_vector(resize(peak_hold_ch3, 10) & resize(peak_hold_ch2, 10) & resize(peak_hold_ch1, 10) & resize(peak_hold_ch0, 10));
            end if;
        end if;
    end process;
end architecture behavioral;
