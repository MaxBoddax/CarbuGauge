# CarbuGauge
Synchronizing carburetors gauge tools , 4 channels led vumeter with peak hold.

ADS1115: Adafruit board 4CH ADC.

FPGA:    Altera EP4CE6E22CN8.

SENSORS: 4 +/- vacuum pressure sensors 6847A  Ranges: -100kPa～0kPa...1500kPa(-15PSI～0PSI...225PSI).

LED BARS: 3 bars of 10 leds for each channel.


Special thanks to ChanonTonmai  https://github.com/ChanonTonmai Hes wrote most of the code for His ADS1115-VHDL-with-AXI-DMA project.
 
 i'm just reuse it with modify parts and create additional files vhdl try adapting to my project.


 Goals: Read negative pressure values translated in voltage , converted to digital by ADC then outputs elaborated from fpga that 
 will drive 4 bar of 30 leds each with peak hold function . And use cheaper CPLD with mux led driving function to reduce pins usage.


05/28/2023 Not yet working , actually only I2C comunication between fpga and adc converter is working 
           next step implements reading from all 4 channel.

05/30/2023 Added led bars driver and 4 channel adc reader , everything need to be tested in multisim 
           don't think actually its fully working for sure need modification especially in clocks things
           and internal connections.

