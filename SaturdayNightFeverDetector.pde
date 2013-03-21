class SaturdayNightFeverDetector {

  public SaturdayNightFeverDetector() {
  }

  // Saturday Night Fever: Right hand above head, left hand below hip
  boolean saturdayNightFever() {
    int[] userList = context.getUsers();
    PVector upperJointPos = new PVector();
    PVector lowerJointPos = new PVector();
    boolean poseAssumed = false;
    for (int i=0;i<userList.length;i++)
    {
      if (context.isTrackingSkeleton(userList[i])) {
        
        // NO MIRRORING -> right is left, left is right

        // Right hand above head
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, upperJointPos);
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_HEAD, lowerJointPos);
        if (upperJointPos.y > lowerJointPos.y)
          poseAssumed = true;

        // left hand below hip
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, lowerJointPos);
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HIP, upperJointPos);
        // y-axis grows downwards
        if (upperJointPos.y < lowerJointPos.y)
          poseAssumed = false;
      }
    }
    return poseAssumed;
  }
}

