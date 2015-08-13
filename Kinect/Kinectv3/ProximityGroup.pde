static class ProximityGroup {
  
  private static int tolerance = 10;
  public PVector center;
  public int depth;
  public int size = 0;
  public ArrayList<PVector> componentPoints;
  
  public ProximityGroup(PVector initCenter) {
    this.center.x = initCenter.x;
    this.center.y = initCenter.y;
    this.size = this.size+1;
    this.componentPoints = new ArrayList();
    this.componentPoints.add(initCenter);
  }
  
  public boolean addPoint(PVector newPoint) {
    if (PVector.dist(newPoint, this.center) < tolerance) {
      this.center.x = ((this.center.x*this.size)+newPoint.x)/(this.size+1);
      this.center.y = ((this.center.y*this.size)+newPoint.y)/(this.size+1);
      this.size = this.size+1;
      this.componentPoints.add(newPoint);
      return true;
    }
    else return false;
  }
  
  public static void fill(ArrayList<PVector> candidatePoints, Detector bd, int blobSize) {
    for(int i = 0; i < bd.getBlobsNumber(); i++)  {
      if (bd.getBlobWeight(i) > blobSize) {
        candidatePoints.add(new PVector(bd.getCentroidX(i), bd.getCentroidY(i)));
      }
    }
  }
  
  public static void empty(ArrayList<ProximityGroup> allGroups, 
                           ArrayList<PVector> candidatePoints) {
    for (PVector candidate: candidatePoints) {
      if (allGroups.size()>0) {
        Iterator iterator = allGroups.iterator();
        Boolean addNew = true;
        while(iterator.hasNext()) {
          ProximityGroup thisGroup = (ProximityGroup)iterator.next();
          addNew = addNew && !(thisGroup.addPoint(candidate));
        }
        if (addNew) allGroups.add(new ProximityGroup(candidate));
      }
      else allGroups.add(new ProximityGroup(candidate));
    }
    candidatePoints.clear();
  }
  
  public static PVector[] getPourPath(ArrayList<ProximityGroup> allGroups, SimpleOpenNI kinect) {
    cullGroups(allGroups);
    int pathSize = allGroups.size();
    PVector[] pourPath = new PVector[pathSize];
    int pathIndex = 0;
    PVector[] realWorldMap = kinect.depthMapRealWorld();
    Iterator iterator = allGroups.iterator();
    while (iterator.hasNext())  {
      ProximityGroup thisGroup = (ProximityGroup) iterator.next();
      PVector point = thisGroup.center;
      int index = (int) (point.x + (point.y * kinect.depthWidth()));
      PVector realWorldPoint = realWorldMap[index];
      pourPath[pathIndex] = realWorldPoint;
      pathIndex++;
    }
    minTraversal(pourPath, pathSize);
    return pourPath;
  }
  
  private static void minTraversal(PVector[] pourPath, int pathSize) {
    int startIndex = 0;
    for (int i = 0; i < pathSize; i++) {
      if (pourPath[startIndex].x < pourPath[i].x) startIndex = i;
    }
    //swap rightmost point with first point
    swapIndices(pourPath, 0, startIndex);
    //reorder into minimal distance traversal
    for (int i = 0; i < pathSize-1; i++) {
      int closestPtIndex = i+1;
      int distance = Integer.MAX_VALUE;
      for (int j = closestPtIndex; j < pathSize; j++) {
        if (PVector.dist(pourPath[i], pourPath[j])<distance) {
          closestPtIndex = j;
        }
      }
      if (closestPtIndex != i+1) swapIndices(pourPath, i+1, closestPtIndex);
    }
  }
   
  private static void swapIndices(PVector[] pourPath, int index1, int index2) {
    PVector temp = pourPath[index1];
    pourPath[index1] = pourPath[index2];
    pourPath[index2] = temp;
  }
  
  private static void cullGroups(ArrayList<ProximityGroup> allGroups) {
    Iterator iterator = allGroups.iterator();
    while (iterator.hasNext())  {
      ProximityGroup currentGroup = (ProximityGroup) iterator.next();
      if (currentGroup.size < tolerance) allGroups.remove(currentGroup);
    }
  }
      

}

    
    
    
  
