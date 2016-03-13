import processing.serial.*;
static final int MAX_VOLTAGE = 5;

Serial port;

// oscilloscope screen with wave
int screenWidth = 600;
int screenHeight = 480;

int screenLeftOffset = 28;
int screenRightOffset = 125;
int screenTopOffset = 28;
int screenBottomOffset = 25;

// have to be even
int numHorzLines = 8;
int numVertLines = 10;

// coordinates of points written to screen
float yVal;
float prevYVal;
int xPos = 2;

int yScale = 2;   // each box = 2V
int xScale = 2;

void setup() 
{
    size(770, 600);
    background(96, 96, 96);
    
    initializeScreen();
  
    printArray(Serial.list());
    port = new Serial(this, Serial.list()[0], 115200);
    
    port.bufferUntil('\n');
    smooth();
}

float getYHeight(float y){
  //  y = map(y, 0, 1023, -MAX_VOLTAGE, MAX_VOLTAGE);    // convert analog value to voltage range
    return screenTopOffset + screenHeight/2 - (y / yScale) * (screenHeight / numHorzLines) ;
}

void draw()
{
    smooth();
    fill(255, 255, 51);  // yellow
    stroke(255, 255, 51);
    
    // find correct yVal for our scale
    float yHeight = getYHeight(yVal);
    if(xPos == 2){
       ellipse(float(screenLeftOffset+xPos),yHeight, 1, 1);
    }

    else{
      line(screenLeftOffset+(xPos - 1), prevYVal, screenLeftOffset + xPos, yHeight);
    }
    prevYVal = yHeight;
    
    if(xPos >= screenWidth-2) {
      xPos = 2;
      initializeScreen();
    }
    else {
      xPos+= xScale;
    }
    
}

void serialEvent (Serial port) {
    
    String inString = port.readStringUntil('\n');
    inString = trim(inString);
    
    if(inString != null) {
      yVal = float(inString);
      println(yVal);

     
    } else {
      yVal = 0;
      xPos = 0;
    }
}


/***************** CREATING PRETTY OSCILLISCOPE DISPLAY ******************************/

void initializeScreen(){
    background(96, 96, 96);   // grey background

    // black oscilloscope screen
    fill(0, 0, 0);
    rect(screenLeftOffset, screenTopOffset, screenWidth, screenHeight);
    
    // calculate some offset values
    screenRightOffset = width - (screenLeftOffset + screenWidth);
    screenBottomOffset = height - (screenTopOffset + screenHeight);
    
    // print horizontal scale to bottom left under screen    
    textSize(20);
    textAlign(LEFT, TOP);
    fill(255, 255, 51);
    text("y-scale = " + yScale + ".00 V", screenLeftOffset+2, height-screenBottomOffset+4);
        
    // draw gridlines for the screen
    drawGrid(numHorzLines, numVertLines);
    noFill();
    stroke(192, 192, 192);
    rect(screenLeftOffset, screenTopOffset, screenWidth, screenHeight);
    
    
}

// draws grid lines
void drawGrid(int numHorzLines, int numVertLines){
    stroke(128, 128, 128);    // grey lines
    fill(128, 128, 128);
    float distBtwnHorzLines = (float) screenHeight / numHorzLines;    
    float distBtwnVertLines = (float) screenWidth / numVertLines;    
    int dotSize = 1;
     
    // draw horizontal lines
    for(int i = 1; i < numHorzLines; i++) {
      // want center lines to be thicker 
      if(i == numHorzLines/2){
           dotSize = 2;
       }
        
       drawDottedLine(screenLeftOffset, i*distBtwnHorzLines+screenTopOffset+1, width-screenRightOffset, i*distBtwnHorzLines+screenTopOffset+1, 60, dotSize);
       dotSize = 1;
    }
  
    // draw vertical lines
    for(int i = 1; i < numVertLines; i++) {
      if(i == numVertLines / 2){
        dotSize = 2;
      }
      drawDottedLine(i*distBtwnVertLines+screenLeftOffset+1, screenTopOffset, i*distBtwnVertLines+screenLeftOffset+1, height-screenBottomOffset, 60, dotSize);
      dotSize = 1;
  } 
}

// draws a dotted line
void drawDottedLine(float startX, float startY, float endX, float endY, float count, int dotSize){
  for(int i=0; i<=count; i++){
    float x = lerp(startX+1, endX-1, i/count);
    float y = lerp(startY+1, endY-1, i/count);
    ellipse(x, y, dotSize, dotSize);
  }
}