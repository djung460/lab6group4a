/**
 * References:  http://www.instructables.com/id/Arduino-Software-debouncing-in-interrupt-function/
 */

int push_button_pin = 2;
long debounce_time = 100;
volatile unsigned long last_micro;
long processing_time = 15000000;
int signal_pin = 0;


void setup() {
    pinMode(push_button_pin, INPUT);
    attachInterrupt(digitalPinToInterrupt(push_button_pin), debounceButton, CHANGE);
    Serial.begin(9600);
}

void loop() {
}

void debounceButton(){
  if ((long)(micros()-last_micro) >= debounce_time *1000){
    interrupt();
    last_micro = micros();
  }
}

void interrupt() {
    int signalReadng; 
    long currentTime = micros();
    while (micros() - currentTime <= processing_time){
      //Read analog reading and print to serial monitor
      signalReading = analogRead(signal_pin);
      Serial.print(signalReading);
    }
  
    int state = digitalRead(push_button_pin);
    Serial.print("Interrupted in state ");
    Serial.println(state);
}
