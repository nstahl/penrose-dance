import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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

import toxi.math.conversion.*; 
import toxi.geom.*; 
import toxi.math.*; 
import toxi.geom.mesh2d.*; 
import controlP5.*; 
import toxi.util.datatypes.*; 
import toxi.util.events.*; 
import toxi.geom.mesh.subdiv.*; 
import toxi.math.waves.*; 
import toxi.geom.mesh.*; 
import toxi.util.*; 
import toxi.math.noise.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class penrose_final extends PApplet {















//gui
ControlP5 cp5;
int OPACITY = 15;
//data structures
ArrayList<Triangle>  triangles;
ArrayList sliders = new ArrayList();

//settings and constants
float GOLDEN_RATIO = (float) (1 + Math.sqrt(5)) / 2;
float amplitude = .75f;
float omega = 5*2*PI;
float omegaV = 5*2*PI;
float param_t = GOLDEN_RATIO;
float vSize = 75;
int recursionLevel = 6;
PImage currImg, oImg;

//booleans
boolean showGUI = false;
boolean drawTiling = false;
boolean drawVertices =true;

HashMap<String, Integer> hashMap;

public void setup() {
  size(1300, 800); 
  smooth();
  //setup gui
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(showGUI); 
  setupGUI();

  triangles = new ArrayList<Triangle>();
  float[] coords = {
    width/2.0f, 0.0f, 0.0f, height, width, height
  };
  
  oImg = loadImage("test.jpg", "jpg");
  currImg = createImage(oImg.width, oImg.height, RGB);
  hashMap = new HashMap();
  setupTriangles();
}

public void draw() {
  background(0);
  
  update();
  
  pushMatrix();
  translate(width/2, height/2);
  scale(.275f);

  for (int j = 0; j<10; j++) {
    pushMatrix();
    rotate(radians(j*36));
    //scale(1, pow(-1, (j % 2)));
    //rotate(radians(36*(j+j%2)));
    for (int i=0; i<triangles.size(); i++) {
      triangles.get(i).draw();
    }
    popMatrix();
  }
  popMatrix();
  
}

public void update() {
//5*2*PI
omega += random(.5f)-1;
int thresh = 1;
if(omega>  5*2*PI+thresh) {
  omega =  5*2*PI+thresh;
}
else if(omega<  5*2*PI-thresh) {
  omega =  5*2*PI-thresh;
}
param_t = (float)Math.pow(amplitude*cos((frameCount/100.0f)*omega),3) + GOLDEN_RATIO;

vSize = 20*sin((frameCount/100.0f)*omegaV) + 75;
setupTriangles();
}

public void setupVertices(ArrayList<Triangle> ts) {
  hashMap.clear();
  Triangle t;
   for(int i = 0; i<ts.size(); i++) {
     t = ts.get(i);
     for(int j = 0; j<t.vertices.length;j++) {
       hashMap.put( t.vertices[j].toString(), 1);
     }
   }
  //println(hashMap.size());
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
  setupVertices(triangles);
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

public void setupGUI() {
  println("Setting up GUI..."); 
  int trackMargin = 50;
  int controllerMargin = 25;
  int currHeight = 0;
  sliders.add(cp5.addSlider("param_t", 1, 10, GOLDEN_RATIO, 100, currHeight, width-200, 20));
  currHeight += 30;
  sliders.add(cp5.addSlider("v_size", 1, 500, vSize, 100, currHeight, width-200, 20));
  currHeight += 30;
}

public void controlEvent(ControlEvent theControlEvent) {

  if (theControlEvent.controller().getLabel().equals("param_t")) {
    param_t = (float)(theControlEvent.controller().value());
    setupTriangles();
  }
  else if (theControlEvent.controller().getLabel().equals("v_size")) {
    vSize = (float)(theControlEvent.controller().value());
  }
}

/// convenience functions
public float average(float[] vs) {
  float sum = 0;
  for (int i = 0; i<vs.length; i++) {
    sum += vs[i];
  } 
  return sum / vs.length;
}

public float stdev(float[] vs, float ave) {
  float sum = 0;
  for (int i = 0; i<vs.length; i++) {
    sum += Math.pow(vs[i]-ave, 2);
  } 
  return (float)Math.sqrt(sum / (vs.length-1));
}

public float[] shift(float[] vs, float newVal) {
  //create copy
  float[] newVs = new float[vs.length];

  for (int i = 1; i<vs.length; i++) {
    newVs[i-1] = vs[i];
  }
  newVs[vs.length-1] = newVal;

  return newVs;
}


public PImage getFrame() {
  PImage img = new PImage(width, height);
  
  g.loadPixels();
  img.loadPixels();
  
  img.pixels = g.pixels;
  
  img.updatePixels();
  g.updatePixels();
  
  return img;
}


class Triangle {

 Vec2D[] vertices;
 int type;
 
 //constructors
 public Triangle(Vec2D v0, Vec2D v1, Vec2D v2, int type) {
  this.vertices = new Vec2D[3];
  vertices[0] = v0;
  vertices[1] = v1;
  vertices[2] = v2;
  this.type = type;
 } 
 
 public Triangle(Vec2D[] vertices, int type) {
  this.vertices = vertices;
  //println(vertices);
  this.type = type;
 } 
 
 public Triangle(float[] coords, int type) {
  this.type = type;
  if (coords.length !=6) {
   println("incorrect number of arguments");
  }
  else {
   vertices = new Vec2D[3];
   for(int i=0; i<coords.length; i+=2) {
    vertices[i/2] = new Vec2D(coords[i], coords[i+1]);
    //println(vertices[i/2]);
   } 
  }
 } 
 
 public void draw() {
   if(drawTiling) {
   if(type == 0){fill(255,0,0, 50);}
   else if(type == 1) {fill(0,0,255, 50);} 
   else {noFill();}
   noStroke();
   beginShape();
   for(int i=0; i<vertices.length; i++) {
     vertex(vertices[i].x, vertices[i].y);
   }
   endShape(CLOSE);
   stroke(255);
   noFill();
   line(vertices[0].x, vertices[0].y, vertices[1].x, vertices[1].y);
   line(vertices[0].x, vertices[0].y, vertices[2].x, vertices[2].y);
   }
   
   if(drawVertices) {
   noStroke();
   fill(255, OPACITY);
   for(int i=0; i<vertices.length; i++) {
   ellipse(vertices[i].x,vertices[i].y,vSize,vSize);
   }
   }
 }
   
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "penrose_final" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
