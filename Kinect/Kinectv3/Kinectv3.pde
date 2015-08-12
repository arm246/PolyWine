import SimpleOpenNI.*;
import controlP5.*;
import blobscanner.*;
import java.util.*;

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
ArrayList<ProxGroup> allGlasses;

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


