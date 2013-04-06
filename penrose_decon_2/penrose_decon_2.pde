import toxi.math.conversion.*;
import toxi.geom.*;
import toxi.math.*;
import toxi.geom.mesh2d.*;
import toxi.util.datatypes.*;
import toxi.util.events.*;
import toxi.geom.mesh.subdiv.*;
import toxi.geom.mesh.*;
import toxi.math.waves.*;
import toxi.util.*;
import toxi.math.noise.*;
import controlP5.*;
import java.util.*;

//gui
ControlP5 cp5;
int OPACITY = 200;
//data structures
ArrayList<Triangle>  triangles;
ArrayList sliders = new ArrayList();

//settings and constants
float GOLDEN_RATIO = (float) (1 + Math.sqrt(5)) / 2;
float amplitude = .75;
float omega = 5*2*PI;
float param_t = GOLDEN_RATIO;
float vSize = 75;
int recursionLevel = 6;
PImage currImg, oImg;
Node[] nodes;

//booleans
boolean showGUI = true;
boolean drawTiling = false;
boolean drawVertices =true;
boolean drawImg = false;

HashMap<Vec2D, Integer> hashMap;
HashMap<Vec2D, PImage> imgMap;
Vec2D[] equiVecs; 

void setup() {
  size(960, 640); 
  smooth();
  //setup gui
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(showGUI); 
  setupGUI();

  triangles = new ArrayList<Triangle>();
  float[] coords = {
    width/2.0, 0.0, 0.0, height, width, height
  };

  oImg = loadImage("test.jpg", "jpg");
  currImg = createImage(oImg.width, oImg.height, RGB);
  hashMap = new HashMap();
  imgMap = new HashMap();
  setupTriangles();
  setupEquiVectors(triangles);
  setupVertices(triangles);
  makeImages();
}

void draw() {
  background(0);
  update();

  pushMatrix();
  translate(width/2, height/2);
  scale(.325);

  for (int i=0; i<nodes.length;i++) {
    nodes[i].draw();
  }
  popMatrix();

}

public void update() {

  param_t = (float)Math.pow(amplitude*cos((frameCount/500.0)*omega), 3) + GOLDEN_RATIO;
  
  vSize = 20*sin((frameCount/100.0)*omega) + 75;
  setupTriangles();
  setupVertices(triangles);
}

public static void printMap(Map mp) {
  Iterator it = mp.entrySet().iterator();
  while (it.hasNext ()) {
    Map.Entry pairs = (Map.Entry)it.next();
    System.out.println(pairs.getKey() + " = " + pairs.getValue());
    it.remove(); // avoids a ConcurrentModificationException
  }
}


public void keyPressed() {
  if (key == 'i')
    drawImg = !drawImg;
  if (key == 't')
    drawTiling = !drawTiling;
  if (key == 't')
    drawTiling = !drawTiling;
  if (key == 'v')
    drawVertices = !drawVertices;
  if (key == 'r') {
    recursionLevel = recursionLevel%6 + 1;
    println(recursionLevel);
    setupTriangles();
  }
  if (key == 'g') {
    showGUI = !showGUI;
    cp5.setAutoDraw(showGUI);
  }
}

public ArrayList<Triangle> subdivide(ArrayList<Triangle> ts) {
  ArrayList<Triangle> toReturn = new ArrayList<Triangle>();
  Triangle t;
  for (int i=0; i<ts.size(); i++) {
    t = ts.get(i);
    if (t.type == 0) {
      //red
      Vec2D newVertex = t.vertices[0].add((t.vertices[1].sub(t.vertices[0])).scale(1/param_t));
      toReturn.add( new Triangle(t.vertices[2], newVertex, t.vertices[1], 0) );
      toReturn.add( new Triangle(newVertex, t.vertices[2], t.vertices[0], 1) );
    }
    else if (t.type ==1) {
      //blue
      Vec2D newVertexQ = t.vertices[1].add((t.vertices[0].sub(t.vertices[1])).scale(1/param_t));
      Vec2D newVertexR = t.vertices[1].add((t.vertices[2].sub(t.vertices[1])).scale(1/param_t));
      toReturn.add( new Triangle(newVertexR, t.vertices[2], t.vertices[0], 1) );
      toReturn.add( new Triangle(newVertexQ, newVertexR, t.vertices[1], 1) );
      toReturn.add( new Triangle(newVertexR, newVertexQ, t.vertices[0], 0) );
    }
    else {
      println("No implementation for type: " + t.type);
    }
  }
  return toReturn;
}

void setupGUI() {
  println("Setting up GUI..."); 
  int trackMargin = 50;
  int controllerMargin = 25;
  int currHeight = 0;
  sliders.add(cp5.addSlider("param_t", 1, 10, GOLDEN_RATIO, 100, currHeight, width-200, 20));
  currHeight += 30;
  sliders.add(cp5.addSlider("v_size", 1, 500, vSize, 100, currHeight, width-200, 20));
  currHeight += 30;
}

void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.controller().getLabel().equals("param_t")) {
    param_t = (float)(theControlEvent.controller().value());
    setupTriangles();
    setupVertices(triangles);
  }
  else if (theControlEvent.controller().getLabel().equals("v_size")) {
    vSize = (float)(theControlEvent.controller().value());
  }
}

/// convenience functions
float average(float[] vs) {
  float sum = 0;
  for (int i = 0; i<vs.length; i++) {
    sum += vs[i];
  } 
  return sum / vs.length;
}

float stdev(float[] vs, float ave) {
  float sum = 0;
  for (int i = 0; i<vs.length; i++) {
    sum += Math.pow(vs[i]-ave, 2);
  } 
  return (float)Math.sqrt(sum / (vs.length-1));
}

float[] shift(float[] vs, float newVal) {
  //create copy
  float[] newVs = new float[vs.length];

  for (int i = 1; i<vs.length; i++) {
    newVs[i-1] = vs[i];
  }
  newVs[vs.length-1] = newVal;

  return newVs;
}


PImage getFrame() {
  PImage img = new PImage(width, height);

  g.loadPixels();
  img.loadPixels();

  img.pixels = g.pixels;

  img.updatePixels();
  g.updatePixels();

  return img;
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
public void setupTriangles() {
  Vec2D[] cvecs = new Vec2D[3];
  cvecs[0] = new Vec2D();
  cvecs[2] = new Vec2D(width, 0);
  cvecs[1] = cvecs[2].getRotated(radians(36));

  triangles.clear();
  
  Triangle seedTriangle = new Triangle(cvecs, 0); 
  for(int i=0;i<10;i++) {
    triangles.add(seedTriangle.getRotated(radians(i*36)).add(new Vec2D(width/2, height/2)));
  }
  
  

  triangles = subdivide(triangles);
  if (recursionLevel>1) {
    triangles = subdivide(triangles);
  }
  if (recursionLevel>2) {
    triangles = subdivide(triangles);
  }
  if (recursionLevel>3) {
    triangles = subdivide(triangles);
  }
  if (recursionLevel>4) {
    triangles = subdivide(triangles);
  }
  if (recursionLevel>5) {
    triangles = subdivide(triangles);
  }
}

public void setupEquiVectors(ArrayList<Triangle> ts) {
  equiVecs = new Vec2D[ ts.size()*3 ];
  Triangle t;
  for (int i = 0; i<ts.size(); i++) {
    t = ts.get(i);
    for (int j = 0; j<t.vertices.length;j++) {
      equiVecs[j + i*t.vertices.length] = t.vertices[j].add(new Vec2D(random(), random()));
    }
  }
}

public void setupVertices(ArrayList<Triangle> ts) {
  //calc weights
  hashMap.clear();
  Triangle t;
  for (int i = 0; i<ts.size(); i++) {
    t = ts.get(i);
    for (int j = 0; j<t.vertices.length;j++) {
      Vec2D k = t.vertices[j];
      if (hashMap.containsKey( k )) {
        hashMap.put( k, hashMap.get(k) + 1) ;
      }
      else {
        hashMap.put( k, 1 );
      }
    }
  }
  
  nodes = new Node[hashMap.size()];
  int counter = 0;
  int nodesAdded = 0;
  for (int i = 0; i<ts.size(); i++) {
    t = ts.get(i);
    for (int j = 0; j<t.vertices.length;j++) {
      //wowo this did not workVec2D k = t.vertices[j];
      Vec2D newVec = t.vertices[j];
      //println(hashMap.containsKey(newVec ));

      if (hashMap.get(newVec)>0) {
        //make node
        nodes[nodesAdded ] = new Node(newVec, equiVecs[counter], hashMap.get(newVec)/10.0);
        hashMap.put( newVec, 0) ;
        nodesAdded++;
      }
      counter++;
    }
  }
  
  //sort nodes
  Node temp;
  for (int i=0; i<nodes.length-1; i++) {

    int minId = i;
    //find min
    for (int j=i+1; j<nodes.length; j++) {
      if (nodes[j].oPos.x<nodes[minId].oPos.x) {
        minId = j;
      }
      //exchange
      temp = nodes[i];
      nodes[i] = nodes[minId];
      nodes[minId] = temp;
    }
  }
  for (int i=0; i<nodes.length-1; i++) {

    int minId = i;
    //find min
    for (int j=i+1; j<nodes.length; j++) {
      if (nodes[j].oPos.y<nodes[minId].oPos.y) {
        minId = j;
      }
      //exchange
      temp = nodes[i];
      nodes[i] = nodes[minId];
      nodes[minId] = temp;
    }
  }
  
}

public void makeImages() {
  PImage nodeImg;
  Vec2D pos;
  int halfSize = (int)(vSize/2);
  int dim = (int)vSize;
  for (int i=0; i<nodes.length; i++) {
    pos = nodes[i].oPos;
    nodeImg = createImage((int)vSize, (int)vSize, ARGB);
    nodeImg.copy(oImg, (int)nodes[i].pos.x-halfSize, (int)nodes[i].pos.y-halfSize, dim, dim, 0, 0, dim, dim);
    imgMap.put( pos, nodeImg );
  }
}




