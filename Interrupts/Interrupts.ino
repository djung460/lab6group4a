/**
 * References:  http://www.instructables.com/id/Arduino-Software-debouncing-in-interrupt-function/
 */

const int push_button_pin = 2;
const long debounce_time = 100;
volatile unsigned long last_micro_debounce;
const long processing_time = 15000000;
int signal_pin = 0;

const int ADC_BUFFER_SIZE = 8;
volatile uint16_t ADC_counter;
volatile uint16_t ADC_buffer[ADC_BUFFER_SIZE];

void setup() {
    pinMode(push_button_pin, INPUT);
    attachInterrupt(digitalPinToInterrupt(push_button_pin), debounceButton, CHANGE);
		enableAnalogInterrupts();
    Serial.begin(9600);
}

void loop() {
	Serial.print(ADC_buffer[ADC_counter]);
}

void debounceButton(){
  if ((long)(micros()-last_micro_debounce) >= debounce_time *1000){
    buttonInterrupt();
    last_micro = micros();
  }
}

void buttonInterrupt() {
    long currentTime = micros();
    while (micros() - currentTime <= processing_time){
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
ISR(ADC_vect) {
	uint16_t = analog_val = ADCL;	// store lower byte from ADC
	analog_val += ADCH << 8	// store higher byte from ADC
	ADC_buffer[ADC_counter] = analog_val;
	ADC_counter = (ADC_counter + 1) % ADC_BUFFER_SIZE;
}

