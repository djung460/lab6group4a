import processing.serial.*;
static final int MAX_VOLTAGE = 5;

Serial port;
int baudRate = 115200;

// graph titles
String axisY = "Voltage";
String axisX = "Time";

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

float yScale = 1.0f;   // each box = 2V
float xScale = 2.0f;

boolean dataAvailable = false;
boolean paused = false;

PImage img_w, img_a, img_s, img_d, img_p;

void setup() 
{
    size(770, 600);
    background(96, 96, 96);
    
    img_w = loadImage("letter_w.png");
    img_a = loadImage("letter_a.png");
    img_s = loadImage("letter_s.png");
    img_d = loadImage("letter_d.png");
    img_p = loadImage("letter_p.png");
    
    initializeScreen();
  
    printArray(Serial.list());
    port = new Serial(this, Serial.list()[0], baudRate);
   
    port.bufferUntil('\n');
    smooth();
    

}

float getYHeight(float y){
    y = map(y, 0, 1023, 0, MAX_VOLTAGE);    // convert analog value to voltage range
    return screenTopOffset + screenHeight/2 - (y / yScale) * (screenHeight / numHorzLines) ;
}

void draw()
{
   
    if (dataAvailable && paused==false){
    smooth();
    fill(255, 255, 51);  // yellow
    stroke(255, 255, 51);
    
    // find correct yVal for our scale
    float yHeight = getYHeight(yVal);
    if(xPos == 2){
       ellipse(float(screenLeftOffset+xPos),yHeight, 1, 1);
    }

    else{
      line(screenLeftOffset+(xPos - xScale), prevYVal, screenLeftOffset + xPos, yHeight);
    }
    prevYVal = yHeight;
    
    if(xPos >= screenWidth-2) {
      xPos = 2;
      initializeScreen();
    }
    else {
      xPos+=xScale;
    }
    }
    
}

void serialEvent (Serial port) {
    
    String inString = port.readStringUntil('\n');
    inString = trim(inString);
    
    if(inString != null || float(inString) == -1) {
      dataAvailable = true;
      yVal = float(inString);
      println(yVal);

     
    } else {
      dataAvailable = false;
      yVal = 0;
      xPos = 2;
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
    
    // print xaxis
    fill(255, 255, 51);
    textSize(20);
    textAlign(CENTER, TOP);
    text(axisX, screenLeftOffset+screenWidth/2, height-screenBottomOffset+2);
    
    // print yaxis
    textAlign(CENTER, BOTTOM);
    pushMatrix();
    translate(screenLeftOffset-3, screenTopOffset+screenHeight/2);
    rotate(-HALF_PI);
    text(axisY, 0, 0);
    popMatrix();
    
    // print scales to bottom left under screen    
    printYScale();
    printXScale();
        
    // draw gridlines for the screen
    drawGrid(numHorzLines, numVertLines);
    noFill();
    stroke(192, 192, 192);
    rect(screenLeftOffset, screenTopOffset, screenWidth, screenHeight);  
    
    addKeyImages();
    addKeyText();
}

void addKeyImages(){
    image(img_w, width-screenRightOffset+30, screenTopOffset-5, 70, 70);
    image(img_s, width-screenRightOffset+30, screenTopOffset+70+50-5-10-5, 70, 70);
    image(img_d, width-screenRightOffset+30, screenTopOffset+70+50+70+50-5-10-5, 70, 70);
    image(img_a, width-screenRightOffset+30, screenTopOffset+70+50+70+50+70+50-5-10-5, 70, 70);
    image(img_p, width-screenRightOffset+30, screenTopOffset+70+50+70+50+70+50+70+50-5-10-5, 70, 70);
    
}

void addKeyText(){
    fill(0, 0, 0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Inc. y-scale", width-screenRightOffset+30+40, screenTopOffset+99-20-5);
    text("Dec. y-scale", width-screenRightOffset+30+40, screenTopOffset+99+99+20-20-10);
    text("Inc. x-scale", width-screenRightOffset+30+40, screenTopOffset+99+99+20+99+20-20-10);
    text("Dec. x-scale", width-screenRightOffset+30+40, screenTopOffset+99+99+20+99+20+99+20-20-10);
    text("Pause", width-screenRightOffset+30+40, screenTopOffset+99+99+20+99+20+99+20-20+99+20-10);
}

void printYScale(){
    noStroke();
    fill(96, 96, 96);
    rect(screenLeftOffset, height-screenBottomOffset+15, 180, 20);
  
    textSize(20);
    textAlign(LEFT, TOP);
    
    fill(255, 255, 51);     // yellow
    text("y-scale = " + yScale + " V", screenLeftOffset+2, height-screenBottomOffset+15);
}

void printXScale(){
    noStroke();
    fill(96, 96, 96);
    rect(screenLeftOffset, height-screenBottomOffset+38, 180, 20);
    
    textSize(20);
    textAlign(LEFT, TOP);
    fill(255, 255, 51);
    text("x-scale = " + xScale + "x", screenLeftOffset+2, height-screenBottomOffset+38);
    
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

/*****************************/
void keyPressed(){
  switch(key){
    case 'w':             // increases y-Scale
      yScale+=0.5f;
      printYScale();
      break;
   case 's':              // decreases y-scale
      if(yScale != 0.5f){
        yScale-=0.5f;
        printYScale();
      }
      break;
    case 'a':            // decreases x-scale
      if(xScale!=0.5f){
        xScale-=0.5f;
        printXScale();
      }
      break; 
    case 'd':            // increases x-scale
      xScale+=0.5f;
      printXScale();
      break;
    case 'p':
      if(paused) paused = false;
      else paused = true;
      break;
  }

}