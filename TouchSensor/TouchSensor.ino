//Based on this project https://www.youtube.com/watch?v=40tyJfvpcxw
//Capacitive Touch Explained: https://www.instructables.com/Capacitive-Sensing-for-Dummies/


void setup(){
  Serial.begin(115200); //open a connection with computer that will communicate 115200 times a second
  delay(1000); //wait one second 
  Serial.println("ESP32 Touch Test"); //prints to serial monitor
}

void loop(){
  Serial.println(touchRead(T3));  //get value from Touch 3.  Check pinout diagram!
  delay(500); //wait one second before loop
}