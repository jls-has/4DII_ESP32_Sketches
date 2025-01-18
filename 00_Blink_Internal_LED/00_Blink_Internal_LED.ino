// Writing after double slashes is ignored by the program.

//This defines an empty container we are labeling as INTERNAL_LED
//We name it in all caps to indicate that the value will be CONSTANT.  INTERNAL_LED should be 2 throughout the program.
//We are setting the value to 2, the label of the pin we want to control
//GPIO pins are explained here: https://randomnerdtutorials.com/esp32-pinout-reference-gpios/
#define INTERNAL_LED 2

//This function outputs no value "void"
//This function inpots no information "()" are empty
//setup is a specal function that runs only once, when the program starts.  
void setup() {

  pinMode(INTERNAL_LED, OUTPUT); //sets pin 2 as output

}

//this function loops over and over again until we turn off the power
void loop() {

  digitalWrite(INTERNAL_LED, HIGH); //turn pin 2 on
  delay(1000);  //wait for 1000ms (1second)
  digitalWrite(INTERNAL_LED, LOW); ////turn pin 2 off
  delay(1000);


}
