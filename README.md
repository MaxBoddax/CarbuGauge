# CarbuGauge
Synchronizing carburetors gauge tools , 4 channels led vumeter with peak hold.

ADS1115: Adafruit board 4CH ADC

FPGA:    Altera EP4CE6E22CN8

SENSORS: 4 +/- vacuum pressure sensors 6847A  Ranges: -100kPa～0kPa...1500kPa(-15PSI～0PSI...225PSI)

LED BARS: 3 bars 


Special thanks to ChanonTonmai  https://github.com/ChanonTonmai Hes wrote all the code for His ADS1115-VHDL-with-AXI-DMA project.
 
 i'm just reuse it with modified parts and try adapting to my project.


 Goals: Read negative pressure values translated in voltage , converted to digital by ADC then outputs elaborated from fpga that 
 will drive 4 bar of 30 leds each with peak hold function .


05/28/2023 Not yet working , actually only I2C comunication between fpga and adc converter is working 
           next step implements reading from all 4 channel.
