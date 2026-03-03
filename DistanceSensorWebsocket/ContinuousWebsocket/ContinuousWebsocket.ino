#include <WiFi.h>
#include <WebServer.h>
#include "html.h"
#include "Adafruit_VL53L0X.h"

Adafruit_VL53L0X lox = Adafruit_VL53L0X();
WebServer server(80);


const char* ssid = "kmt";         /*Enter Your SSID*/
const char* password = "Coconuts1"; /*Enter Your Password*/

int cm;

void MainPage() {
  String _html_page = html_page;              /*Read The HTML Page*/
  server.send(200, "text/html", _html_page);  /*Send the code to the web server*/
}

void Distance() {
  String data = "[\""+String(cm)+"\"]";
  server.send(200, "text/plane", data);
}

void setup(void){
  Serial.begin(115200);                 /*Set the baudrate to 115200*/

  Serial.println("Adafruit VL53L0X test");
  if (!lox.begin()) {
    Serial.println(F("Failed to boot VL53L0X"));
    while(1);
  }

  Serial.println(F("VL53L0X API Simple Ranging example\n\n")); 
  WiFi.mode(WIFI_STA);                  /*Set the WiFi in STA Mode*/
  WiFi.begin(ssid, password);
  Serial.print("Connecting to ");
  Serial.println(ssid);
  delay(1000);                          /*Wait for 1000mS*/
  while(WiFi.waitForConnectResult() != WL_CONNECTED){Serial.print(".");} /*Wait while connecting to WiFi*/
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("Your Local IP address is: ");
  Serial.println(WiFi.localIP());       /*Print the Local IP*/

  server.on("/", MainPage);             /*Display the Web/HTML Page*/
  server.on("/readDistance", Distance); /*Display the updated Distance value(CM and INCH)*/
  server.begin();                       /*Start Server*/
  delay(1000);                          /*Wait for 1000mS*/
}

void loop(void){
 VL53L0X_RangingMeasurementData_t measure;

  Serial.print("Reading a measurement... ");
  lox.rangingTest(&measure, false); // pass in 'true' to get debug data printout!

  Serial.print("Distance (mm): "); 
  cm = measure.RangeMilliMeter;
  Serial.println(cm);
  Serial.print("Your Local IP address is: ");
  Serial.println(WiFi.localIP());       /*Print the Local IP*/
  server.handleClient();
  Serial.println();
  delay(1000);
}