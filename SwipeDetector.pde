class SwipeDetector extends XnVSwipeDetector {
  
  private VirtualDanceFloor vdf;
  
  public SwipeDetector(VirtualDanceFloor vdf) {   
    this.vdf = vdf;
    
    RegisterSwipeRight(this);
    RegisterSwipeLeft(this);
    RegisterSwipeUp(this);
    RegisterSwipeDown(this);
  }
  
  void onSwipeUp(float vel, float angle) {
    this.vdf.handleSwipe("up");
  }
  void onSwipeDown(float vel, float angle) {
    this.vdf.handleSwipe("down");
  }
  void onSwipeLeft(float vel, float angle) {
    this.vdf.handleSwipe("left");
  }
  void onSwipeRight(float vel, float angle) {
    this.vdf.handleSwipe("right");
  }
}
