#include <FastLED.h>

#define NUM_LEDS 1000
#define LED_PIN 2

int idx = 0;

CRGB leds[NUM_LEDS];

void setup() {
  FastLED.addLeds<WS2815, LED_PIN, RGB>(leds, NUM_LEDS);
  FastLED.setBrightness(20);

}

void loop() {
  leds[idx-1] = CRGB::Black;
  leds[idx] = CRGB::Blue;
  FastLED.show();
  delay(2);
  idx += 1;

  if (idx> NUM_LEDS){
    idx = 0;
  }
}
