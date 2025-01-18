//This sketch accesses the internal hall effect detector on the ESP32
//Hall Effect explained here: https://randomnerdtutorials.com/esp32-hall-effect-sensor/

// this creates an integer (whole number) variable we name "val" and assigns the number "0" to it
// we name it in lower case to indicate that it's value will change throughout the program
int val = 0;

void setup() {
  Serial.begin(9600);  //communicate with this window through USB 9600 times a second
}

void loop() {
  val = hallRead(); //hallread is a built in function
  // print the results to the serial monitor
  Serial.println(val); 
  delay(1000);
}