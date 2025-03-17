#include <FastLED.h>

#define NUM_LEDS 10
#define LED_PIN 2

CRGB leds[NUM_LEDS];

bool on = false;

void setup() {
  Serial.begin(9600);
  FastLED.addLeds<WS2815, LED_PIN, RGB>(leds, NUM_LEDS);
  FastLED.setBrightness(50);

}

void loop() {
  for (int i; i<NUM_LEDS; i++){
    if (on){
       leds[i] = CRGB::White;
    } else {
       leds[i] = CRGB::Black;
    }
  }

  FastLED.show();
  delay(1000);
  on = !on;
  Serial.println(on);
}
