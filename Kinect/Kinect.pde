import SimpleOpenNI.*;
import controlP5.*;
import blobscanner.*;

ControlP5 cp5;
Detector bd;

SimpleOpenNI kinect;
int[] depthMap;
PVector[] realWorldMap;

float[] pProjective;
float[] pReal;
boolean selected;
color selectColor; 
int dimension;
int colorTolerance;

int sliderValue = 100;
int sliderTicks1 = 100;
int sliderTicks2 = 30;
int size;

PImage img;

void setup()
{
   size(640, 480, P3D);
   noStroke();
   colorMode(RGB, 255);
   
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
   .setRange(0,500)
   ;  
    cp5.addSlider("size")
   .setPosition(70,20)
   .setRange(0,500)
   ;    
}

void draw()
{
   kinect.update();
   depthMap = kinect.depthMap();
   image(kinect.rgbImage(), 0, 0);
   if (selected){
      filterSimColor(colorTolerance);
      trackBlobs();
      image(kinect.rgbImage(), 0, 0);
      drawBlobs();
   }
   fill(selectColor);
   rect(0,0,50,50);
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

float colorDistance(color c1, color c2) 
{
  long rmean = (((c1 >> 16) & 0xFF) + ((c2 >> 16) & 0xFF)) / 2;
  long r = ((c1 >> 16) & 0xFF) - ((c2 >> 16) & 0xFF);
  long g = ((c1 >> 8) & 0xFF) - ((c2 >> 8) & 0xFF);
  long b = (c1 & 0xFF) - (c2 & 0xFF);
  return sqrt((((512+rmean)*r*r)>>8) + 4*g*g + (((767-rmean)*b*b)>>8));
}

void filterSimColor(long tolerance)
{
  kinect.rgbImage().loadPixels();
  for (int i = 0; i < dimension; i++)
  {
    color testColor = kinect.rgbImage().pixels[i];
    if (colorDistance(testColor,selectColor) <= tolerance)
    {
      kinect.rgbImage().pixels[i] = color(255,255,255);
    }
    else kinect.rgbImage().pixels[i] = color(0,0,0);
  }
  kinect.rgbImage().updatePixels();
}

void trackBlobs()
{
  kinect.rgbImage().filter(THRESHOLD);
  bd.imageFindBlobs(kinect.rgbImage());
  bd.loadBlobsFeatures();
  bd.findCentroids();
  bd.weightBlobs(true);
}

void drawBlobs()
{
  for(int i = 0; i < bd.getBlobsNumber(); i++)
  {
    if (bd.getBlobWeight(i) > size) {
      ellipse(bd.getCentroidX(i), bd.getCentroidY(i), 10, 10);
      bd.drawBlobContour(i,color(255, 0, 0),2);
    }
  }
}

void getDepth()
{
  for(int i = 0; i < bd.getBlobsNumber(); i++)
  {
    if (bd.getBlobWeight(i) > size) {
      realWorldMap = kinect.depthMapRealWorld();
      int index = (int) (bd.getCentroidX(i) + (bd.getCentroidY(i) * width));
      PVector realWorldPoint = realWorldMap[index];
      println("Blob " + i + ": " + realWorldPoint);
    }
  }
}

void getDepth(int o)
{
  for(int i = 0; i < bd.getBlobsNumber(); i++)
  {
    if (bd.getBlobWeight(i) > size) {
      PImage depthImage = kinect.depthImage();
      int index = (int) (bd.getCentroidX(i) + (bd.getCentroidY(i) * width));
      int depth = (int) map(depthImage.pixels[index], 0, 255, 800, 4000);
      println("Blob " + i + " depth: " + depth + "mm");
    }
  }
}

void keyPressed()
{
  if (key == 'd') {
    getDepth();
    getDepth(0);
  }
}
