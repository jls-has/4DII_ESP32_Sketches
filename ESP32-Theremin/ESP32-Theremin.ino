//Based on this project https://hackaday.io/project/21047/logs
//Timer info: https://www.youtube.com/watch?v=LONGI_JcwEQ
//DAC info: https://www.youtube.com/watch?v=-7FosQmioRY
//Do this next: https://www.youtube.com/shorts/1A9V0TAANMg
// Include DacESP32 Library
#include <DacESP32.h>
 
// Create DAC object
DacESP32 dac1(GPIO_NUM_25);
 
void setup() {
 
  // Output a Cosine Wave with frequency of 1000Hz and max. amplitude (default)
  dac1.outputCW(1000);
 
  // Wait 5 seconds before changing amplitude
  delay(5000);
}
 
void loop() {
 
  // Change signal amplitude every second
  for (uint8_t i = 0; i < 4; i++) {
    delay(1000);
    if (i == 0)
      dac1.setCwScale(DAC_CW_SCALE_1);
    else if (i == 1)
      dac1.setCwScale(DAC_CW_SCALE_2);
    else if (i == 2)
      dac1.setCwScale(DAC_CW_SCALE_4);
    else if (i == 3)
      dac1.setCwScale(DAC_CW_SCALE_8);
  }
}