class VecKey {
  Vec2D v0, v1;
 public VecKey( Vec2D v0, Vec2D v1) {
  
   this.v0 = v0;
   this.v1 = v1;
 } 
 
 
 public boolean equals(VecKey key2) {
   
   return true;
   
 }

     /**
     * Returns a hash code value based on the data values in this object. Two
     * different Vec2D objects with identical data values (i.e., Vec2D.equals
     * returns true) will return the same hash code value. Two objects with
     * different data members may return the same hash value, although this is
     * not likely.
     * 
     * @return the hash code value of this vector.
     */
      /*
    public int hashCode() {
        long bits = 1L;
        bits = 31L * bits + VecMathUtil.floatToIntBits(v0.x);
        bits = 31L * bits + VecMathUtil.floatToIntBits(v1.x);
        bits = 31L * bits + VecMathUtil.floatToIntBits(v0.y);
        bits = 31L * bits + VecMathUtil.floatToIntBits(v1.y);
        return (int) (bits ^ (bits >> 32));
    }
  */
}
