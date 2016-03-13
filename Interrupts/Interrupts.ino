/**
 * References:  http://www.instructables.com/id/Arduino-Software-debouncing-in-interrupt-function/
 */

const int push_button_pin = 2;
const long debounce_time = 100;
volatile unsigned long last_micro_debounce;
const long processing_time = 15000000;
const int BAUD_RATE = 115200;

const int ADC_BUFFER_SIZE = 4;
volatile uint16_t ADC_counter;
volatile uint16_t ADC_buffer[ADC_BUFFER_SIZE];

void setup() {
    pinMode(push_button_pin, INPUT);
    attachInterrupt(digitalPinToInterrupt(push_button_pin), debounceButton, CHANGE);
    enableAnalogInterrupt();
    Serial.begin(115200);
}

void loop() {
  for(int i = 0; i < ADC_BUFFER_SIZE; i++) {
    Serial.println(ADC_buffer[i]);
  }
}

void debounceButton(){
  if ((long)(micros()-last_micro_debounce) >= debounce_time *1000){
    last_micro_debounce = micros();
    button_read_state = ~button_read_state;
  }
}

void enableAnalogInterrupt() {
	DIDR0 = 0x3F;
	ADMUX = 0x43;
	ADCSRA = 0xAC;
	ADCSRB = 0x40;
	bitWrite(ADCSRA, 6, 1);
	sei();
}

/*
ADC takes 13 clock cycles so max frequency is 16 MHz/(16*13) ~= 77 kHz
*/
//TODO: Use AVR instead of c. Use the instructables tutorial
ISR(ADC_vect) {
  uint16_t analog_val = ADCL;	// store lower byte from ADC
  analog_val |= ADCH << 8;      
  ADC_buffer[ADC_counter] = analog_val;
  ADC_counter = (ADC_counter + 1) % ADC_BUFFER_SIZE;
}
