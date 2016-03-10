import processing.serial.*;

Serial port;
int val;
int[] values;
static final int width = 400;
static final int height = 400;

void setup()
{
	size(640, 480);

	port = new Serial(this, Serial.list()[0], 9600);
	values = new int[width];
	smooth();
}

int getY(int val)
{
	return (int)(val / 1023.0f * height) - 1;
}

void draw()
{
	while (port.available() >=3) {
		if (port.read() == 0xff) {
			val = (port.read() << 8) | (port.read());
			}
		}
	
	for (int i = 0; i < width-1; i++) 
		values[i] = values[i+1];

	values[width - 1] = val;
	background(0);
	stroke(255);
	for (int x = 1; x < width; x++) {
		line(width-x, height-1-getY(values[x-1]), width-1-x, height-1-getY(values[x]));
	}

}