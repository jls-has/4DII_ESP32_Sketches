#include <FastLED.h>

#define NUM_LEDS 10
#define LED_PIN 2

int idx = 0;

CRGB leds[NUM_LEDS];
CRGB leds1[NUM_LEDS];


void setup() {
  Serial.begin(9600);
  FastLED.addLeds<WS2815, LED_PIN, RGB>(leds, NUM_LEDS);
   FastLED.addLeds<WS2815, 15, RGB>(leds1, NUM_LEDS);
  FastLED.setBrightness(20);

}

void loop() {
  leds[idx-1] = CRGB::Black;
  leds[idx] = CRGB::Blue;
  leds1[idx-1] = CRGB::Black;
  leds1[idx] = CRGB::Green;
  FastLED.show();
  delay(200);
  idx += 1;

  if (idx>= NUM_LEDS){
    leds[idx-1] = CRGB::Black;
    leds1[idx-1] = CRGB::Black;
    idx = 0;
  }
  Serial.println(idx);
}
