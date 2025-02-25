#include <FastLED.h>

#define NUM_LEDS 1000
#define LED_PIN 2
#define MAX_AMPS 2

int idx = 0;

CRGB leds[NUM_LEDS];

void setup() {
 

  FastLED.addLeds<WS2815, LED_PIN, RGB>(leds, NUM_LEDS);
  FastLED.setBrightness(255);
  // limit my draw to 1A at 5v of power draw
   FastLED.setMaxPowerInVoltsAndMilliamps(12,1000); 

}

void loop() {
  fill_solid(leds, NUM_LEDS, CRGB::White);
  FastLED.show();
  delay(500);
}
