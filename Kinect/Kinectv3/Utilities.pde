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
    if (bd.getBlobWeight(i) > minimumSize) {
      ellipse(bd.getCentroidX(i), bd.getCentroidY(i), 10, 10);
      bd.drawBlobContour(i,color(255, 0, 0),2);
    }
  }
}

void getDepth()
{
  for(int i = 0; i < bd.getBlobsNumber(); i++)
  {
    if (bd.getBlobWeight(i) > minimumSize) {
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
    if (bd.getBlobWeight(i) > minimumSize) {
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

void scan() {
  //add new Blob centers from this frame to the glasses buffer
  trackBlobs();
  ProximityGroup.fill(glassesBuffer, bd, minimumSize);
}

PVector[] getPath() {
  //glasses buffer is full; construct groups and get their pour path
  ProximityGroup.empty(allGlasses, glassesBuffer);
  return ProximityGroup.getPourPath(allGlasses, kinect);
}

    
    
