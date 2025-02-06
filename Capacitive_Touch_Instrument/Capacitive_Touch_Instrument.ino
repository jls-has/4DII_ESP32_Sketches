/*
  ESP32 DAC - Musical Fruit 
  espdac-touch-music.ino
  ESP32 DAC & Touch Switch Demo
  Uses DacESP32 Library - https://github.com/yellobyte/DacESP32
  
  DroneBot Workshop 2022
  https://dronebotworkshop.com
*/

// Include DacESP32 Library
#include <DacESP32.h>

// Create DAC object for Channel 1
DacESP32 dac1(GPIO_NUM_25);

// Define the touch pins (you can add more as desired)
#define TOUCH_0 4
#define TOUCH_1 32
#define TOUCH_2 33
#define TOUCH_3 15
#define TOUCH_4 13
#define TOUCH_5 12
#define TOUCH_6 14
#define TOUCH_7 27


// Variables to hold the touch pin values
int tvalue_0;
int tvalue_1;
int tvalue_2;
int tvalue_3;
int tvalue_4;
int tvalue_5;
int tvalue_6;
int tvalue_7;


// Define the threshold levels for each touch pin (adjust as required)
const int threshold_0 = 200;
const int threshold_1 = 200;
const int threshold_2 = 200;
const int threshold_3 = 200;
const int threshold_4 = 200;
const int threshold_5 = 200;
const int threshold_6 = 200;
const int threshold_7 = 200;


// Define the frequencies for our "musical notes" - https://mixbutton.com/mixing-articles/music-note-to-frequency-chart/
const int freq_0 = 523;   //C - Octave 5
const int freq_1 = 587;   //D - Octave 5
const int freq_2 = 659;   //E - Octave 5
const int freq_3 = 698;   //F - Octave 5
const int freq_4 = 784;   //G - Octave 5
const int freq_5 = 880;   //A - Octave 5
const int freq_6 = 988;   //B - Octave 5
const int freq_7 = 1046;  //C - Octave 6

void setup() {
  // Setup serial monitor to check touch thresholds
  Serial.begin(115200);

  // Disable DAC to stop sound
  dac1.disable();
}

void loop() {

  //Check status of touch switches
  tvalue_0 = touchRead(TOUCH_0);
  tvalue_1 = touchRead(TOUCH_1);
  tvalue_2 = touchRead(TOUCH_2);
  tvalue_3 = touchRead(TOUCH_3);
  tvalue_4 = touchRead(TOUCH_4);
  tvalue_5 = touchRead(TOUCH_5);
  tvalue_6 = touchRead(TOUCH_6);
  tvalue_7 = touchRead(TOUCH_7);


  // Print values (useful for adjusting threshold levels)
  Serial.print(" S0 = ");
  Serial.print(tvalue_0);
  Serial.print(" S1 = ");
  Serial.print(tvalue_1);
  Serial.print(" S2 = ");
  Serial.print(tvalue_2);
  Serial.print(" S3 = ");
  Serial.print(tvalue_3);
  Serial.print(" S4 = ");
  Serial.print(tvalue_4);
  Serial.print(" S5 = ");
  Serial.print(tvalue_5);
  Serial.print(" S6 = ");
  Serial.print(tvalue_6);
  Serial.print(" S7 = ");
  Serial.println(tvalue_7);


  // If touch values exceed threshold then play associated note3
  if (tvalue_1 < threshold_1) {
    dac1.enable();
    dac1.outputCW(freq_1);
  } else if (tvalue_2 < threshold_2) {
    dac1.enable();
    dac1.outputCW(freq_2);
  } else if (tvalue_3 < threshold_3) {
    dac1.enable();
    dac1.outputCW(freq_3);
  } else if (tvalue_4 < threshold_4) {
    dac1.enable();
    dac1.outputCW(freq_4);
  } else if (tvalue_5 < threshold_5) {
    dac1.enable();
    dac1.outputCW(freq_5);
  } else if (tvalue_6 < threshold_6) {
    dac1.enable();
    dac1.outputCW(freq_6);
  } else if (tvalue_7 < threshold_7) {
    dac1.enable();
    dac1.outputCW(freq_7);
  } else if (tvalue_0 < threshold_0) {
    dac1.enable();
    dac1.outputCW(freq_0);
  } else {
    // Disable DAC to stop sound
    dac1.disable();  
  }

  // Short delay (adjust as desired)
  delay(100);
}