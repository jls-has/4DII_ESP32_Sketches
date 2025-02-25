#include <FastLED.h>

#define NUM_LEDS 1000
#define LED_PIN 2

CRGB leds[NUM_LEDS];

void setup() {
  FastLED.addLeds<WS2815, LED_PIN, RGB>(leds, NUM_LEDS);
  FastLED.setBrightness(50);

}

void loop() {
  leds[0] = CRGB::Red;
  leds[1] = CRGB::Green;
  leds[2] = CRGB::Blue;
  FastLED.show();
}
