class PushDetector extends XnVPushDetector {
  
  private VirtualDanceFloor vdf;
  
  public PushDetector(VirtualDanceFloor vdf) {
    this.vdf = vdf;
    
    RegisterPush(this);
  }
  
  void onPush(float vel, float angle) {
    this.vdf.handlePush();
  }
}
