import SimpleOpenNI.*;
import controlP5.*;
import blobscanner.*;
import java.util.*;

ControlP5 cp5;
Detector bd;

SimpleOpenNI kinect;
PVector[] realWorldMap;

boolean selected;
color selectColor; 
int dimension;
int colorTolerance;

int minimumSize;

ArrayList<ProximityGroup> allGlasses;
ArrayList<PVector> glassesBuffer;
PVector[] pourPath;

int SCAN;
int POUR;
int DELAY;
int operation;

void setup()
{
   size(640, 480, P3D);
   noStroke();
   colorMode(RGB, 255);
   frameRate(30);
   
   kinect = new SimpleOpenNI(this);
   kinect.enableDepth();
   kinect.enableRGB();
   
   bd = new Detector(this, 255);
   
   selected = false;
   dimension = width * height;
   colorTolerance = 100;
   
   cp5 = new ControlP5(this);
   cp5.addSlider("colorTolerance")
     .setPosition(70,8)
     .setRange(0,500);  
   cp5.addSlider("minimumSize")
     .setPosition(70,20)
     .setRange(0,500); 
  
   allGlasses = new ArrayList();
   glassesBuffer = new ArrayList(100);
   boolean exit;  
   
   SCAN = 1;
   POUR = 2;
   DELAY = 3;
   operation = DELAY;
   
}

void draw()
{
   switch(operation) {
     //Scanning Routine
     case 1:
       // Gather Glass Position Information every 5 Frames
       if (frameCount%5 == 0 && frameCount%150 != 0) {
         kinect.update();
         scan();
         //println("scan");
       }
       // Construct Pour Path after 5 seconds
       else if(frameCount%150 == 0) {
         pourPath = getPath();
         operation = POUR;
         //println("path");
       }
       break;
       
     //Pouring Routine
     case 2:
       //Using the array of center points in the correct order, send toolpath to robot.
       //Still needs to be written
       operation = DELAY;
       //println("pour");
       break;
     
     //Delay Routine
     default:
       //Listen for signal to begin next scan
       break;
   }
}

void mousePressed()
{
   if (!selected)
    {
      kinect.rgbImage().loadPixels();
      selectColor = kinect.rgbImage().get(mouseX, mouseY);
      kinect.rgbImage().updatePixels();
      selected = !selected;
    }
}


