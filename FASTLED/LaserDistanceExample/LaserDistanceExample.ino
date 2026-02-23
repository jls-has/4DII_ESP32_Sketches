#include <FastLED.h>
#include "Adafruit_VL53L0X.h"


//how many leds are in your string?
#define NUM_LEDS 10

//The GPIO connected to Data on the LED
#define LED_PIN 15

// An array of leds using the FASTLED library
CRGB leds[NUM_LEDS];

Adafruit_VL53L0X lox = Adafruit_VL53L0X();


//an integer to show which LED we are going to light up
int id = 0;

void setup() {

  //from the laser code
  Serial.begin(115200);
  // wait until serial port opens for native USB devices
  while (! Serial) {
    delay(1);
  }
  Serial.println("Adafruit VL53L0X test");
  if (!lox.begin()) {
    Serial.println(F("Failed to boot VL53L0X"));
    while(1);
  }
  // power 
  Serial.println(F("VL53L0X API Simple Ranging example\n\n")); 

  //from the LED code
  FastLED.addLeds<WS2812B, LED_PIN, GRB>(leds, NUM_LEDS);

  //this number changes brightness 0-255
  FastLED.setBrightness(50);
}

void loop() {

  VL53L0X_RangingMeasurementData_t measure;
   
  Serial.print("Reading a measurement... ");
  lox.rangingTest(&measure, false); // pass in 'true' to get debug data printout!

  // && means "and".  != means does not equal
  if (measure.RangeStatus != 4 && measure.RangeMilliMeter < 200){  // phase failures have incorrect data
    Serial.print("Distance (mm): "); 
    Serial.println(measure.RangeMilliMeter);

    //from the Laser code
    //turns off all leds, turns on led at id, then increases id integer.
    for(int i = 0; i < NUM_LEDS; i++){
      leds[i] = CRGB(0,0,0);
    }
    leds[id] = CRGB(0,0,255);
    id = id+1;
    if (id >= NUM_LEDS){
      id = 0;
    }
    delay(100);
    FastLED.show();

  } else {
    Serial.print("Distance (mm): "); 
    Serial.println(measure.RangeMilliMeter);
    Serial.println(" out of range ");
  }
  
  
}
