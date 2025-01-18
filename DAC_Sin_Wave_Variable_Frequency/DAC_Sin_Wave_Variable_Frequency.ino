//useful: https://deepbluembedded.com/esp32-dac-audio-arduino-examples/#esp32-sine-wave-generation

#include <Arduino.h>
// Include DacESP32 Library
#include "dac_audio.h"
#include <DacESP32.h>
 
// Create DAC object for Channel 1
DacESP32 dac1(GPIO_NUM_25);

int8_t amplitude = 1000;
int frequency = 180;
//int numSamples = 360;
//const float samplePeriod = 1.0 / frequency / numSamples;
const int AMP_POT_PIN = 36;
const int FREQ_POT_PIN = 36;

// Define DAC pins
#define DAC_CH1 25
#define DAC_CH2 26


void setup() {
  Serial.begin(115200);
  dac1.enable();
}

void loop() {
  int ampPotValue = analogRead(AMP_POT_PIN);
  int freqPotValue = analogRead(FREQ_POT_PIN);
  float freqScalor = 0.5;//freqPotValue/4095.0;
  float ampScalor = ampPotValue/4095.0;
  amplitude = -16.0*ampScalor;
  frequency = (30000)*freqScalor;
  dac_audio_set_volume(amplitude);
  dac1.outputCW(frequency);
  //delay(200);
  Serial.println(frequency);
  }



