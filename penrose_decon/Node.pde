class Node {
  
  final Vec2D oPos;
  Vec2D pos;
  float weight;
  PImage img;

  public Node(Vec2D pos, float weight) {
    this.pos = pos;
    this.weight = weight;
    oPos = new Vec2D(pos);
  } 
  
  public void setImage(PImage p) {
   this.img = p; 
  }
  
  public void draw() {
    
    if (drawImg) {
      image((PImage) imgMap.get(oPos), pos.x-(vSize/2), pos.y-(vSize/2));
    }
    else {
      noStroke();
      fill(255, 200*(pow(weight/10, 1.3)));
      ellipse(pos.x, pos.y, vSize, vSize);
    }
  }
}

