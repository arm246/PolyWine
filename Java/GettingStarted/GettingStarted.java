package main;


import java.awt.Color;

import com.Robot;

import processing.core.*;
import processing.serial.*;
import SimpleOpenNI.*;
import controlP5.*;
import blobscanner.*;

/**
 * <i>GettingStarted.java</i><br/>
 * 
 * A simple program to check if <i>Server.mod</i> is properly configured.<br/>
 * Once running, you can use your arrow keys to move the robot around in the XZ plane.
 * 
 * <br/><br/>
 * 
 * 
 * Instructions: <br/>
 * 	(1) Fist configure <i>Server.mod</i>, following this tutorial: _____________________ <br/>
 * 	(2) Once configured, run <i>Server.mod</i> on the robot. You must run <i>Server.mod</i> before <i>SettingUp.java</i>.<br/>
 *  (3) With the program running on the Teach Pendant, go ahead and run <i>GettingStarted.java</i>.
 *  <br/><br/><br/>
 *  
 *  See Robo.Op's full project details at <a href="www.madlab.cc/robo-op">madlab.cc/robo-op</a>
 *  <br/><br/>
 *  
 *  
 *  ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥  <br/>
 *
 *  ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥ ¥  
 *  
 * @author mad 
 * <br/>01.25.2015 
 */

@SuppressWarnings("serial")
public class GettingStarted extends PApplet {
	
	// our robot object 
	private Robot robot;
	private String IP_robot = "127.0.0.1";//"127.0.0.1"; // REPLACE with your contorller's IP address
	private int PORT_robot = 1025;		   // should be same port number as in Server.mod
	
	/** You use this flag to test in your sketch,
	 * 	independent of running the robot
	 */
	private boolean robotMode = true;
	private boolean initialized = false;

	// GUI variables
	private PFont font;
	Serial myPort;
	String val;
	
	int offsetDist = 500;
	
	
	ControlP5 cp5;
	Detector bd;
	SimpleOpenNI kinect;
	int[] depthMap;
	PVector[] realWorldMap;

	float[] pProjective;
	float[] pReal;
	boolean selected;
	int selectColor; 
	int dimension;
	int colorTolerance;

	int sliderValue = 100;
	int sliderTicks1 = 100;
	int sliderTicks2 = 30;
	int size;
	
	int slider1_X = 70;
	int slider1_Y = 8;
	float slider1_the_Min= 0;
	float slider1_the_Max= 500;
	float slider2_the_Min= 0;
	float slider2_the_Max= 500;
    
	
	//Kinect's location
	double Kinect_X = 127.0;
	double Kinect_Y = -2209.8;
	double Kinect_Z = 1701.8;
	double Kinect_Angle=28.2;
	

	
	
	PImage img;
 
	
	public void setup(){
		size(640,480);
	    // myPort = new Serial(this, Serial.list()[0], 9600);
		
		// set up fonts to display messages from the robot
		font = loadFont("Menlo-Bold.vlw");
		textFont(font, 16);
		
		// setup P5's connection to the Robot
		if (robotMode){			
			println("Setting up robot's socket connection ... ");
			this.robot = new Robot(this, IP_robot, PORT_robot);
			thread("startRobot");	
		}
				
		
		  noStroke();
		   colorMode(RGB, 255);
		   
		   kinect = new SimpleOpenNI(this);
		   kinect.enableDepth();
		   kinect.enableRGB();
		   kinect.alternativeViewPointDepthToImage();
		   kinect.setMirror(false);
		   
		   
		   bd = new Detector(this, 255);
		   
		   selected = false;
		   dimension = width * height;
		   colorTolerance = 10;
		   
		   cp5 = new ControlP5(this);
		   cp5.addSlider("colorTolerance",slider1_the_Min,slider1_the_Max)
	
		   ;  
		    cp5.addSlider("size",slider2_the_Min,slider2_the_Max) ; 
		
	}
	

	
	public void draw(){
		
		
	
		
				
		// set the speed a bit higher at the start of the routine
		if (robotMode && robot.isSetup() && !initialized){
			robot.setSpeed(150, 100, 100, 100);
			robot.setZone(Robot.z0);
			initialized = true;
		}
		
		// move relative to the tool coordinates
		/*if (keyPressed && robotMode){
			if (keyCode == LEFT)
				robot.moveOffset(-offsetDist, 0, 0, 0, 0, 0);
			if (keyCode == RIGHT)
				robot.moveOffset(offsetDist, 0, 0, 0, 0, 0);
			if (keyCode == DOWN)
				robot.moveOffset(0, 0, -offsetDist, 0, 0, 0);
			if (keyCode == UP)
				robot.moveOffset(0, 0, offsetDist, 0, 0, 0);
			
		}
		
		// move relative to the world coordinates
		if (mousePressed && robotMode){
			
			int offset = 0;
			if (mouseButton == LEFT)
				offset = -offsetDist;
			else if (mouseButton == RIGHT)
				offset = offsetDist;			
			
			float[] xyz = robot.getPosition();
			robot.setPosition((int)xyz[0], (int)xyz[1]+offset, (int)xyz[2]);
			
		}
		val = myPort.readStringUntil('\n');
		    if (val != null) {
		      print(val);
		    }*/
		
		   kinect.update();
		   depthMap = kinect.depthMap();
		   realWorldMap = kinect.depthMapRealWorld();
		
		   
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
	
//	/**
//	 * Use your arrow keys to move the robot around 
//	 * in the XZ plane
//	 */
//	public void keyPressed(){
//		
//		if (keyPressed && robotMode){
//			if (keyCode == LEFT)
//				robot.moveOffset(-15, 0, 0, 0, 0, 0);
//			if (keyCode == RIGHT)
//				robot.moveOffset(15, 0, 0, 0, 0, 0);
//			if (keyCode == DOWN)
//				robot.moveOffset(0, 0, -15, 0, 0, 0);
//			if (keyCode == UP)
//				robot.moveOffset(0, 0, 15, 0, 0, 0);
//		}
//		
//	}
//	
//	public void mousePressed() {
//		
//		if (mousePressed && robotMode){
//			
//			// another way of moving
//			
//			int offset = 0;
//			if (mouseButton == LEFT)
//				offset = -15;
//			else if (mouseButton == RIGHT)
//				offset = 15;			
//			
//			float[] xyz = robot.getPosition();
//			robot.setPosition((int)xyz[0], (int)xyz[1]+offset, (int)xyz[2]);
//		}
//		
//	}
	
	public void mousePressed()
	{
	   if (!selected)
	    {
		   kinect.rgbImage().loadPixels();
		      selectColor = kinect.rgbImage().get(mouseX, mouseY);
		      kinect.rgbImage().updatePixels();
		      selected = !selected;
	    }
	}
	
	
	float colorDistance(int c1, int c2) 
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
	  for (int i = 0; i < dimension-5; i++)
	  {
	    int testColor = kinect.rgbImage().pixels[i];
	    int testColor2 = kinect.rgbImage().pixels[i+5];
	    
	    if (colorDistance(testColor,selectColor) <= tolerance && colorDistance(testColor2,selectColor) <= tolerance)
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
	      
	      int pixelX= (int)bd.getCentroidX(i);
	      int pixelY = (int)bd.getCentroidY(i) * kinect.depthWidth();
	      int index = pixelX+pixelY;
	      int depth = depthMap[index];
	      
	      
	      PVector realWorldPoint =realWorldMap[index];
	      PVector projectivePoint = new PVector();
	       kinect.convertRealWorldToProjective(realWorldPoint,projectivePoint);
	      
	      
	      if (depth !=0){
	      println("Blob " + i + ": " + realWorldPoint);
	      println("Depth" + ": "+ depth); 
	      println("index" + "= " + bd.getCentroidX(i) + " " + bd.getCentroidY(i));
         
	      //Translate realWorldPoint coordinate to World coordinates
	       int transX = -(int) realWorldPoint.x;
	       int transY = (int) (realWorldPoint.z*Math.cos(Math.toRadians(Kinect_Angle))-realWorldPoint.y*Math.sin(Math.toRadians(Kinect_Angle)));
	       int transZ = (int) (-realWorldPoint.z*Math.sin(Math.toRadians(Kinect_Angle))+ realWorldPoint.y*Math.cos(Math.toRadians(Kinect_Angle)));
	 
       
           robot.setPosition((int)(Kinect_X+transX), (int)(transY+Kinect_Y),(int)(transZ+Kinect_Z) );
	    }
	      }
	  }
	}

	public void keyPressed()
	{
	  if (key == 'd') 
		  getDepth();
	}
	
	
	/**
	 * Starts the robot on its own thread.
	 * That way it won't hold up the canvas from drawing. 
	 * 
	 * @return
	 */
	public String startRobot(){
		return robot.connect();
	}
	

}
