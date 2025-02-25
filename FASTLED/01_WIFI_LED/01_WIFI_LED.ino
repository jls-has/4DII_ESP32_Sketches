#include <FastLED.h>
#include <WiFi.h>
#include <WiFiUdp.h>

/* WiFi network name and password */
//const char * ssid = "ARRIS-8449";
//const char * pwd = "5G5344103682";
const char * ssid = "NETGEAR04";
const char * pwd = "cloudycoconut630";

//check with ipconfig, make sure is right IPv4
const char * udpAddress = "192.168.1.2";
const int udpPort = 7423;

//create UDP instance
WiFiUDP udp;

#define NUM_LEDS 1000
#define LED_PIN 2
#define MAX_MILLIAMPS 2000

int idx = 0;

CRGB leds[NUM_LEDS];

void setup() {
 
  FastLED.addLeds<WS2815, LED_PIN, RGB>(leds, NUM_LEDS);
  FastLED.setBrightness(255);
  // limit my draw to 1A at 5v of power draw
  FastLED.setMaxPowerInVoltsAndMilliamps(12,MAX_MILLIAMPS); 
  fill_solid(leds, NUM_LEDS, CRGB::Black);

   Serial.begin(115200);
  
  //Connect to the WiFi network
   WiFi.begin(ssid, pwd);
  Serial.println("");

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  //This initializes udp and transfer buffer
  udp.begin(udpPort);

}

void loop() {
   Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  //fill_solid(leds, NUM_LEDS, CRGB::White);
  //FastLED.show();
  //delay(500);
  //data will be sent to server
  uint8_t buffer[50] = "hello world";
  //send hello world to server
  udp.beginPacket(udpAddress, udpPort);
  udp.write(buffer, 11);
  udp.endPacket();
  memset(buffer, 0, 50);
  //processing incoming packet, must be called before reading the buffer
  udp.parsePacket();
  //receive response from server, it will be HELLO WORLD
  if(udp.read(buffer, 50) > 0){
    Serial.print("Server to client: ");
    Serial.println((char *)buffer);
  }
  //Wait for 1 second
  delay(1000);
}
