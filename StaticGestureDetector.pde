class StaticGestureDetector {

  private int poseFrameCount;

  public StaticGestureDetector() {    
    this.poseFrameCount = 0;
  }

  public boolean detectPose() {
    int[] userList = context.getUsers();
    PVector rightHandPos = new PVector();
    PVector leftHandPos = new PVector();
    PVector torsoPos = new PVector();
    boolean poseAssumed = false;

    for (int i=0;i<userList.length;i++) {
      if (context.isTrackingSkeleton(userList[i])) {

        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HIP, torsoPos);
        if (rightHandPos.y < torsoPos.y && leftHandPos.y < torsoPos.y) {
          poseFrameCount++;
          println("###Incrementing pose frame count: " + poseFrameCount);
        } else {
          poseFrameCount = 0;
        }
      }
    }
    if (poseFrameCount > 30) {
      poseFrameCount = 0;
      return true;
    }
    return false;
  }
}

