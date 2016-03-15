/**
 * References:  http://www.instructables.com/id/Arduino-Software-debouncing-in-interrupt-function/
 *              http://www.instructables.com/id/Arduino-Timer-Interrupts/
 */

const int push_button_pin = 2;
const long debounce_time = 100;
volatile unsigned long last_micro_debounce;
const long processing_time = 15000000;

const int ADC_BUFFER_SIZE = 4;
volatile uint16_t ADC_counter;
volatile uint16_t ADC_buffer[ADC_BUFFER_SIZE];

//storage variables
boolean toggle1 = 0;
boolean sendData = 0;
int count;

void setup() {
    pinMode(push_button_pin, INPUT);
    attachInterrupt(digitalPinToInterrupt(push_button_pin), debounceButton, CHANGE);
    enableAnalogInterrupt();
    Serial.begin(115200);
}

void loop() {
  while (sendData){
    for(int i = 0; i < ADC_BUFFER_SIZE; i++) {
      Serial.println(ADC_buffer[i]);
    }
  }
  Serial.println(-1);
}

void debounceButton(){
  if ((long)(micros()-last_micro_debounce) >= debounce_time *1000){
    last_micro_debounce = micros();
  }
  enableTimerInterrupt();
}

void enableTimerInterrupt(){
  cli();//stop interrupts

  //Set timer1 interrupt at 1Hz
  TCCR1A = 0;     // set entire TCCR1A register to 0
  TCCR1B = 0;     // same for TCCR1B
  TCNT1  = 0;     //initialize counter value to 0
  
  // set compare match register for 1/3hz increments
  OCR1A = 46874;  // = (16*10^6) / (1/3*1024) - 1 (must be <65536)
  
  // turn on CTC mode
  TCCR1B |= (1 << WGM12);
  // Set CS10 and CS12 bits for 1024 prescaler
  TCCR1B |= (1 << CS12) | (1 << CS10);  
  // enable timer compare interrupt
  TIMSK1 |= (1 << OCIE1A);
  count = 0;
  sei();//allow interrupts
  sendData = 1;
}

ISR(TIMER1_COMPA_vect){   //timer1 interrupt 1/3Hz toggles pin 13 (LED)
  //Timer interrupt triggered every 3 seconds.
  //To make the data send for 15 seconds, implement a counter to make each 5th interrupt stop the sending of the data.

  //If we have reached 15 seconds, then set sendData to 0 to stop the Serial data, restart the count to 0 and stop interrupts.
  if (count == 4){
    sendData = 0;
    count = 0;
    cli();
  }
  else{
    count++;
  }
}

void enableAnalogInterrupt() {
	DIDR0 = 0x3F;
	ADMUX = 0x40; //Select analog pin 0 as the input
	ADCSRA = 0xAC;
	ADCSRB = 0x40;
	bitWrite(ADCSRA, 6, 1);
	sei();
}

/*
ADC takes 13 clock cycles so max frequency is 16 MHz/(16*13) ~= 77 kHz
*/
ISR(ADC_vect) {
  uint16_t analog_val = ADCL;	// store lower byte from ADC
  analog_val |= ADCH << 8;    // store upper byte from ADC  
  ADC_buffer[ADC_counter] = analog_val;
  ADC_counter = (ADC_counter + 1) % ADC_BUFFER_SIZE;
}
