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
