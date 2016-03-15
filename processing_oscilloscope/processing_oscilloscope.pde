/*
 *  Elec 291 Section 20C
 *  Lab 6: Oscilloscope
 *  Authors: David Jung, Andy Lin, Angy Chung
*/

// * -------------------------------------------------------------------

import processing.serial.*;

// accepted voltage range for Arduino
final int MAX_VOLTAGE = 5;
final int MIN_VOLTAGE = 0;

// serial port variables
Serial port;
final int baudRate = 115200;

// images of the arrow keys 
PImage img_w, img_a, img_s, img_d, img_p;

// * -------------------------------------------------------------------

// * ------------------ OSCILLOSCOPE SCREEN VARIABLES ------------------
int screenWidth = 600;
int screenHeight = 480;

// positioning of the screen within in the window
int screenLeftOffset = 28;
int screenRightOffset = 125;
int screenTopOffset = 28;
int screenBottomOffset = 25;

// titles of the x & y axes
String axisY = "Voltage";
String axisX = "Time";

// divides the screen into a grid
int numHorzLines = 8;
int numVertLines = 10;

// data points to write to the screen
float yVal;
float prevYVal;
int xPos = 2;

// grid box division values
float yScale = 1.0f;  
float xScale = 2.0f;

// flat line if data not available (button not pressed)
boolean dataAvailable = false;

// pauses the screen if true
boolean paused = false;
// * -------------------------------------------------------------------

// * ------------------------- KEY INPUT -------------------------------
final char INC_Y = 'w';
final char DEC_Y = 's';
final char INC_X = 'd';
final char DEC_X = 'a';
final char PAUSE_KEY = 'p';
// * -------------------------------------------------------------------

void setup() 
{
    size(770, 600);
    background(96, 96, 96);    // grey background 
    
    // load all the keyboard key input images 
    img_w = loadImage("letter_w.png");
    img_a = loadImage("letter_a.png");
    img_s = loadImage("letter_s.png");
    img_d = loadImage("letter_d.png");
    img_p = loadImage("letter_p.png");
    
    // draws the screen with gridlines and axes
    initializeScreen();
  
    // load the serial port
    printArray(Serial.list());
    port = new Serial(this, Serial.list()[0], baudRate);
   
    port.bufferUntil('\n');
    
    // draw with smooth edges
    smooth();
}


void draw()
{
    // only draw if data is being received and not paused
    if (dataAvailable && paused==false){
        smooth();
        fill(255, 255, 51);  // draw yellow wave
        stroke(255, 255, 51);
    
        // find correct yVal for our scale
        float yHeight = getYHeight(yVal);
        
        // if we're at the very start of the screen, only draw a dot
        if(xPos == 2){
            ellipse(float(screenLeftOffset+xPos), yHeight, 1, 1);
        }

        // otherwise we draw a line connecting the previous yVal to the new one 
        else{
            line(screenLeftOffset+(xPos - xScale), prevYVal, screenLeftOffset + xPos, yHeight);
        }
        
        // update the prevYVal to our current one
        prevYVal = yHeight;
    
        // if the wave has reached the end of the screen, reset it 
        if(xPos >= screenWidth-2) {
            xPos = 2;
            initializeScreen();
        }
        
        // otherwise increment the x position 
        else {
            xPos+=xScale;
        }
    }
}


/*
 * Takes an analog voltage value and returns the height it should be drawn on the oscilloscope graph 
 */
float getYHeight(float y){
    // convert analog value to the Arduino's voltage range
    y = map(y, 0, 1023, MIN_VOLTAGE, MAX_VOLTAGE);    
    // find the corresponding height on the graph based on the yScale
    return screenTopOffset + screenHeight/2 - (y / yScale) * (screenHeight / numHorzLines) ;
}

/*
 * Serial event generated when the serial port has printed data 
 */
void serialEvent (Serial port) {
    // procure data and trim off white space at the end
    String inString = port.readStringUntil('\n');
    inString = trim(inString);
    
    // convert data to a float (which is then drawn) if data is not null or -1 (button not pressed)
    if(inString != null || float(inString) == -1) {
      dataAvailable = true;
      yVal = float(inString);
     
    } else {
      // otherwise, the graph displays a straight line at zero 
      dataAvailable = false;
      yVal = 0;
      xPos = 2;
    }
}

// * -------------------------------------------------------------------
// * ------------------ OSCILLOSCOPE DISPLAY ---------------------------

/*
 * Creates the window display including the oscilloscope screen with gridlines, axes, 
 * text indicating scale, and instructions for the user to manipulate the waveform 
 */
void initializeScreen(){
    background(96, 96, 96);   // grey background

    // black oscilloscope screen, slightly offset from left and top sides of window
    fill(0, 0, 0);
    rect(screenLeftOffset, screenTopOffset, screenWidth, screenHeight);
    
    // calculate some offset values
    screenRightOffset = width - (screenLeftOffset + screenWidth);
    screenBottomOffset = height - (screenTopOffset + screenHeight);
    
    // print horizontal xaxis at bottom of oscilloscope screen
    fill(255, 255, 51);
    textSize(20);
    textAlign(CENTER, TOP);
    text(axisX, screenLeftOffset+screenWidth/2, height-screenBottomOffset+2);
    
    // print vertical yaxis to the left of the oscilloscope screen
    textAlign(CENTER, BOTTOM);
    pushMatrix();
    translate(screenLeftOffset-3, screenTopOffset+screenHeight/2);
    rotate(-HALF_PI);
    text(axisY, 0, 0);
    popMatrix();
    
    // print scales to the bottom left under the screen    
    printYScale();
    printXScale();
        
    // draw gridlines for the screen
    drawGrid(numHorzLines, numVertLines);
    
    // outline for the screen 
    noFill();
    stroke(192, 192, 192);
    rect(screenLeftOffset, screenTopOffset, screenWidth, screenHeight);  
    
    // add the instructions for keyboard input for the user to the right of the screen
    addKeyImages();
    addKeyText();
}

/*
 * Prints the current scaling for the yaxis on the bottom left under the oscilloscope screen
 */
void printYScale(){
    noStroke();
    fill(96, 96, 96);
    rect(screenLeftOffset, height-screenBottomOffset+15, 180, 20);
  
    textSize(20);
    textAlign(LEFT, TOP);
    
    fill(255, 255, 51);     // yellow
    text("y-scale = " + yScale + " V", screenLeftOffset+2, height-screenBottomOffset+15);
}

/*
 * Prints the current scaling for the xaxis on the bottom left under the oscilloscope screen 
 * and yscale text
 */
void printXScale(){
    noStroke();
    fill(96, 96, 96);
    rect(screenLeftOffset, height-screenBottomOffset+38, 180, 20);
    
    textSize(20);
    textAlign(LEFT, TOP);
    fill(255, 255, 51);
    text("x-scale = " + xScale + "x", screenLeftOffset+2, height-screenBottomOffset+38);
}

/*
 * Draws the given number of horizontal and verticle grid lines on the oscilloscope screen
 */
void drawGrid(int numHorzLines, int numVertLines){
    stroke(128, 128, 128);    // grey lines
    fill(128, 128, 128);
    
    // calculate distances between the lines 
    float distBtwnHorzLines = (float) screenHeight / numHorzLines;    
    float distBtwnVertLines = (float) screenWidth / numVertLines;    
    
    // drawing dotted lines
    int dotSize = 1;
     
    // draw horizontal lines
    for(int i = 1; i < numHorzLines; i++) {
        // want center lines to be thicker 
        if(i == numHorzLines/2){
             dotSize = 2;
         }
         // draw the lines equally spaced apart on the screen 
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


/*
 * Draws a dotted line at the given start position to the given end position 
 * 
 * Params:  startX - starting x-position of the line
 *          startY - starting y-position of the line
 *          endX - ending x-position of the line
 *          endY - ending y-position of the line
 *          count - number of dots that comprise the line
 *          dotSize - size of the dot to draw 
 */ 
void drawDottedLine(float startX, float startY, float endX, float endY, float count, int dotSize){
    for(int i=0; i<=count; i++){
        float x = lerp(startX+1, endX-1, i/count);
        float y = lerp(startY+1, endY-1, i/count);
        ellipse(x, y, dotSize, dotSize);
    }
}

/*
 *  Displays each of the corresponding keyboard keys for user input on the right side of the screen
 */ 
void addKeyImages(){
    image(img_w, width-screenRightOffset+30, screenTopOffset-5, 70, 70);
    image(img_s, width-screenRightOffset+30, screenTopOffset+100, 70, 70);
    image(img_d, width-screenRightOffset+30, screenTopOffset+220, 70, 70);
    image(img_a, width-screenRightOffset+30, screenTopOffset+340, 70, 70);
    image(img_p, width-screenRightOffset+30, screenTopOffset+460, 70, 70);
}

/*
 *  Displays text under each image of the keys to indicate their action 
 */ 
void addKeyText(){
    fill(0, 0, 0);    // black text
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Inc. y-scale", width-screenRightOffset+70, screenTopOffset+74);
    text("Dec. y-scale", width-screenRightOffset+70, screenTopOffset+188);
    text("Inc. x-scale", width-screenRightOffset+70, screenTopOffset+307);
    text("Dec. x-scale", width-screenRightOffset+70, screenTopOffset+426);
    text("Pause", width-screenRightOffset+65, screenTopOffset+545);
}

// * -------------------------------------------------------------------
// * -------------------- KEY INPUT ------------------------------------

/*
 *  Changes the corresponding variable when a key is pressed 
 */
void keyPressed(){
    switch(key){
        case INC_Y:             // increases y-Scale
            yScale+=0.5f;
            printYScale();
            break;
        case DEC_Y:              // decreases y-scale if scale not at minimum 
            if(yScale != 0.5f){
                yScale-=0.5f;
                printYScale();
            }
            break;
        case DEC_X:            // decreases x-scale if scale not at minimum 
            if(xScale!=0.5f){
                xScale-=0.5f;
                printXScale();
            }
            break; 
        case INC_X:            // increases x-scale
            xScale+=0.5f;
            printXScale();
            break;
        case PAUSE_KEY:        // pauses and unpauses the wave drawing on the screen
            if(paused) paused = false;
            else paused = true;
            break;
    }
}

// * -------------------------------------------------------------------