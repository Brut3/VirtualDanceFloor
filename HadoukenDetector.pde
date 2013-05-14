class HadoukenDetector {
  
 public HadoukenDetector() {
 } 
 
 boolean detect() {
    int[] userList = context.getUsers();
    PVector rightHandPos = new PVector();
    PVector leftHandPos = new PVector();
    PVector rightShoulderPos = new PVector();
    PVector leftShoulderPos = new PVector();
    PVector headPos = new PVector();
    PVector torsoPos = new PVector();
    boolean poseAssumed = false;
    for (int i=0;i<userList.length;i++)
    {
      if (context.isTrackingSkeleton(userList[i])) {
        
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, rightHandPos);
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, leftHandPos);
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulderPos);
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulderPos);
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_HEAD, headPos);
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_TORSO, torsoPos);
        
        if(rightHandPos.y < headPos.y && rightHandPos.y > torsoPos.y && leftHandPos.y < headPos.y && leftHandPos.y > torsoPos.y) {
        float handDistance = rightHandPos.dist(leftHandPos);
        float shoulderDistance = rightShoulderPos.dist(leftShoulderPos);
          if(handDistance < shoulderDistance) {
            return true;
          }
        }
        
 
      }
    }
    return false;
  }
}
