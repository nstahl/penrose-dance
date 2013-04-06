class Node {

  Vec2D oPos;
  Vec2D pos;
  float weight;
  PImage img;

  public Node(Vec2D pos, Vec2D oPos, float weight) {
    this.pos = pos;
    this.weight = weight;
    this.oPos = oPos;
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

  public String toString() {
    return oPos.toString();
  }
}


