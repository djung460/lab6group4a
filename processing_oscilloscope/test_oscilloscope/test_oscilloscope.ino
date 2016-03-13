#include <math.h>

const int stop = 10000;

void setup() {
  Serial.begin(115200);
}

void loop() {
  float i = 0;
  while(i < stop){
    Serial.println(511.5*sin(double(i))+511.5);
    i+=0.001;
    //delay(500);
  }


}
