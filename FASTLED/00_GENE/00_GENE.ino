#include <MFRC522Constants.h>
#include <MFRC522Debug.h>
#include <MFRC522Driver.h>
#include <MFRC522DriverI2C.h>
#include <MFRC522DriverPin.h>
#include <MFRC522DriverPinSimple.h>
#include <MFRC522DriverSPI.h>
#include <MFRC522Hack.h>
#include <MFRC522v2.h>
#include <require_cpp11.h>

#include <FastLED.h>


#define PIN0 13
#define PIN1 21
#define PIN2 15
#define PIN3 2 
#define PIN4 16
#define PIN5 17
#define PIN6 18
#define PIN7 19

const int NUM_LEDS = 384;

long idx = 0;

CRGB leds0[NUM_LEDS];
CRGB leds1[NUM_LEDS];
CRGB leds2[NUM_LEDS];
CRGB leds3[NUM_LEDS];
CRGB leds4[NUM_LEDS];
CRGB leds5[NUM_LEDS];
CRGB leds6[NUM_LEDS];
CRGB leds7[NUM_LEDS];
CRGB leds8[NUM_LEDS];

void setup() {
  Serial.begin(9600);
  FastLED.addLeds<WS2815, PIN0, RGB>(leds0, NUM_LEDS);
  FastLED.addLeds<WS2815, PIN1, RGB>(leds1, NUM_LEDS);
  FastLED.addLeds<WS2815, PIN2, RGB>(leds2, NUM_LEDS);
  FastLED.addLeds<WS2815, PIN3, RGB>(leds3, NUM_LEDS);
  FastLED.addLeds<WS2815, PIN4, RGB>(leds4, NUM_LEDS);
  FastLED.addLeds<WS2815, PIN5, RGB>(leds5, NUM_LEDS);
  FastLED.addLeds<WS2815, PIN6, RGB>(leds6, NUM_LEDS);
  FastLED.addLeds<WS2815, PIN7, RGB>(leds7, NUM_LEDS);


  FastLED.setBrightness(20);
  FastLED.setMaxPowerInVoltsAndMilliamps(12, 7000);

}

void loop() {
  for (int i = 0; i <= 23; i++){
    int idy = idx*i;

    if (idy < NUM_LEDS){
    leds0[idy] = CRGB::Red;
    leds1[idy] = CRGB::Red;
    leds2[idy] = CRGB::Red;
    leds3[idy] = CRGB::Red;
    leds4[idy] = CRGB::Red;
    leds5[idy] = CRGB::Red;
    leds6[idy] = CRGB::Red;
    leds7[idy] = CRGB::Red;
    }  

    if ((idx-1)*i >= 0 && (idx-1)*i <NUM_LEDS){
      leds0[(idx-1)*i] = CRGB::Blue;
      leds1[(idx-1)*i] = CRGB::Blue;
      leds2[(idx-1)*i] = CRGB::Blue;
      leds3[(idx-1)*i] = CRGB::Blue;
      leds4[(idx-1)*i] = CRGB::Blue;
      leds5[(idx-1)*i] = CRGB::Blue;
      leds6[(idx-1)*i] = CRGB::Blue;
      leds7[(idx-1)*i] = CRGB::Blue;
    }


 
 
  }
  FastLED.show();
  delay(100);

  if (idx >= 23){
    idx = 0;
  } 

  idx = idx +1;

  
  

  Serial.println(idx);
}
