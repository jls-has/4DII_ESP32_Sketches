#include <ESP32Servo.h> //Use the Servo Library

Servo myServo;  //Creates a Servo object from the library, we name it myServo

int servoPin = 18; //creates a variable we name servoPin that can only hold integers, then put the number 18 into it.

int touch0 = 4; //creates a variable we name servoPin that can only hold integers, then puts the number 4 into it.

// Variables to hold the touch pin values
int tvalue_0;

// Define the threshold levels for each touch pin (adjust as required)
int threshold_0 = 0;

void setup() {
  myServo.attach(servoPin); //attaches pin 18 to the servo.
  // Setup serial monitor to check touch thresholds
  Serial.begin(115200);
}

void loop() {
  //Check status of touch switches
  tvalue_0 = touchRead(touch0);// Print values (useful for adjusting threshold levels)

  Serial.print(" S0 = ");
  Serial.println(tvalue_0);

  

  myServo.write(0); //sets the servo to 0 degrees
  delay(10); //delays 1000 ms, or 1 second

  if (tvalue_0 < threshold_0) { //only do this if condition is true.
  myServo.write(170); //sets the servo to 170 degrees
  delay(1000); //delays 1000 ms, or 1 second
  }
}
