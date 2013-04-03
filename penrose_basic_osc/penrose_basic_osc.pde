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

//gui
ControlP5 cp5;
int OPACITY = 100;
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

//booleans
boolean showGUI = true;
boolean drawTiling = false;
boolean drawVertices =true;

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
  setupTriangles();
}

void draw() {
  background(0);
  
  //update();
  
  pushMatrix();
  translate(width/2, height/2);
  scale(.275);

  for (int j = 0; j<10; j++) {
    pushMatrix();
    scale(1, pow(-1, (j % 2)));
    rotate(radians(36*(j+j%2)));
    for (int i=0; i<triangles.size(); i++) {
      triangles.get(i).draw();
    }
    popMatrix();
  }
  popMatrix();
  
  
  currImg.copy(oImg, 0,0,oImg.width,oImg.height, 0,0,width,height);
  PImage test = get();
  //currImg.mask(test);
  pushMatrix();
  translate(width/2, height/2);
  scale(1);
  image(currImg, -currImg.width/2, -currImg.height/2);
  popMatrix();

  
  
  
}

public void update() {
  
param_t = (float)Math.pow(amplitude*cos((frameCount/100.0)*omega),3) + GOLDEN_RATIO;

vSize = 20*sin((frameCount/100.0)*omega) + 75;
setupTriangles();
}


public void setupTriangles() {
  Vec2D[] cvecs = new Vec2D[3];
  cvecs[0] = new Vec2D();
  cvecs[2] = new Vec2D(width, 0);
  cvecs[1] = cvecs[2].getRotated(radians(36));

  triangles.clear();
  Triangle seedTriangle = new Triangle(cvecs, 0);
  triangles.add(seedTriangle);

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

public void keyPressed() {
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


