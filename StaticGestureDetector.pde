class StaticGestureDetector {
  
  private int poseFrameCount()
  
  public StaticGestureDetector() {    
    this.poseFrameCount = 0;    
  }
  
  public boolean detectPose() {
    int[] userList = context.getUsers();
    PVector rightHandPos = new PVector();
    PVector lowerJointPos = new PVector();
    PVector torsoPos = new PVector();
    boolean poseAssumed = false;
    
    for(int i=0;i<userList.length;i++)v{
      if(context.isTrackingSkeleton(userList[i])) {
      
      context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_LEFT_HAND,leftHandPos);
      context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_RIGHT_HAND,rightHandPos);
      context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_TORSO,torsoPos);
      if(rightHandPos.y < torsoPos.y && leftHandPos.y < torsoPos.y) {
        poseFrameCount++;
      }
  }
   if(poseframeCount > 10) {
     poseframeCount = 0;
   }
   
}
