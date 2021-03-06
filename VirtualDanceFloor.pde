
import saito.objloader.*;
import java.util.Random;
import ddf.minim.*;
import SimpleOpenNI.*;

SimpleOpenNI  context;
boolean       autoCalib=true;

PVector handPos = new PVector();
PVector handPos2 = new PVector();

AudioPlayer player; //musiikkisoitin
AudioSnippet efekti; //efektisoitin
Minim minim; //minim-olio

OBJModel model; //3d-malli

Pallo diskopallo; //diskopallo
Valoefekti disko; //diskopallo-valoefekti

boolean bileet; //onko bileet kaynnissa?
boolean musa; //soiko poppi
boolean strobo; //välkkyykö strobo
int strobolaskuri; //valkyntalaskuri

ArrayList<Valo> valot; //kokoelma erilaisa valoja
ArrayList<Valo> samatValot;
Random noppa;

ParticleSystem ps, ps2;
boolean psDisplayed;
PImage sprite;


//----------------- ELEET ---------------------
PushDetector pushDetector;
XnVSessionManager sessionManager;
StaticGestureDetector staticGesture;
SaturdayNightFeverDetector snfDetector;
HadoukenDetector hadDetector;

//----------------- KAMERA ---------------------

int STAND_HEIGHT = 100;
int MOVEMENT_SPEED = 50;
float SENSITIVITY = 15;      //Suurempi arvo, hitaampi liike
int STILL_BOX = 100;        
int CAMERA_DISTANCE = 1000;

float x, y, z, ay; //Sijainti
float tx, ty, tz; //Katsevektori
float rotX, rotY; 
float xComp, zComp;
float angle;
int moveX;
int moveZ;
boolean moveUP, moveDOWN, moveLEFT, moveRIGHT;

//------------------------------------------------

color[] _colors = {color(255,255,0), color(255,0,255), color(0,255,255)};

void setup()
{
  size(800, 600, P3D);
  smooth(4);
  frameRate(60);
  bileet = false;
  musa = false;
  strobo = false;
  strobolaskuri = 0;

  noppa = new Random();

  //Alustetaan diskopallo
  diskopallo = new Pallo(0, -370, 10, 50, 20); 
  diskopallo.luoPallo();

  disko = new Valoefekti();

  //Ladataan wavefront-object-tiedosto
  model = new OBJModel(this, "olkkari.obj", "relative", TRIANGLES);
  sprite = loadImage("sprite.png");
  model.disableDebug();
  //Skaalataan malli sopivan kokoiseksi
  model.scale(100);
  //Siirretään malli keskelle koordinaatistoa
  model.translateToCenter();
  
  ps = new ParticleSystem(300);
  ps2 = new ParticleSystem(300);
  psDisplayed = true;

  initMusic();
  
  initLights();
  
  initCamera();

  //Alustetaan liikkeflagit
  moveUP = false;
  moveDOWN = false;
  moveLEFT = false;
  moveRIGHT = false;
  
  initOpenNI();
  initGestures();
}

void initOpenNI() {
   context = new SimpleOpenNI(this);
  
  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  context.setMirror(false);
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL); 
}

void initGestures() {
  context.enableHands();
  context.enableGesture();
  context.addGesture("Wave");
  sessionManager = context.createSessionManager("", "");
  
  hadDetector = new HadoukenDetector();
  snfDetector = new SaturdayNightFeverDetector();
  staticGesture = new StaticGestureDetector();
  pushDetector = new PushDetector(this);
  sessionManager.AddListener(pushDetector);
  
}

void initCamera() {
  x = width/2;
  y = height/2;
  ay-= STAND_HEIGHT;
  z = (height/2.0) / tan(PI*60.0 / 360.0);
  tx = width/2;
  ty = height/2;
  tz = 0;
  rotX = 0;
  rotY = 0;
  xComp = tx - x;
  zComp = tz - z;
  angle = 0;
}

void initLights() {
  //Luodaan listat
  this.valot = new ArrayList();
  this.samatValot = new ArrayList();

  //Lisätään valot listaan
  valot.add(new Valo(0, 255, 0, 0, 100, 0, -0.7, 0, -1, PI/9, 150));
  valot.add(new Valo(255, 255, 0, 0, 100, 0, -0.7, 0, -1, PI/9, 150));
  valot.add(new Valo(0, 0, 255, 0, 100, 0, -0.7, 0, -1, PI/9, 150));

  valot.add(new Valo(0, 255, 0, 0, 100, 0, 0, 0, -1, PI/3, 50));
  valot.add(new Valo(255, 0, 0, 0, 100, 0, 0, 0, 1, PI/3, 50));
  valot.add(new Valo(0, 0, 255, 0, 100, 0, 0, 0, 1, PI/3, 50));

  valot.add(new Valo(255, 0, 255, 0, 100, 0, 0, 1, 0, PI/3, 50));
  valot.add(new Valo(0, 0, 255, 0, 100, 0, 0, 1, 0, PI/3, 50));

  valot.add(new Valo(0, 255, 0, 0, 100, 0, -0.5, 0, -1, PI/3, 50));
  valot.add(new Valo(0, 255, 255, 0, 100, 0, -0.5, 0, -1, PI/3, 50));

  valot.add(new Valo(0, 255, 100, 0, 100, 0, 0.8, -0.4, -1, PI/3, 150));
  valot.add(new Valo(200, 0, 200, 0, 100, 0, 0.8, -0.4, -1, PI/3, 120));
  valot.add(new Valo(0, 230, 150, 0, 100, 0, 0.8, -0.5, -0.9, PI/6, 300));
  valot.add(new Valo(200, 100, 200, 0, 100, 0, 0.8, -0.5, -0.9, PI/6, 300));
}

void initMusic() {
  minim = new Minim(this); 
  player = minim.loadFile("diskojytaa.mp3");
  efekti = minim.loadSnippet("djscratch1.wav");
}

void draw() {

  background(0);
  if(frameCount % 100 == 0) {
    println(frameRate);
  }
  translate(width/2, height/2, 0);

  if(!bileet) {
    //Normitilassa pärjätään yhdellä pistevalolla ja taustavalolla
    pointLight(255,255,255, 0, 100, 0);
    ambientLight(150, 150, 150);

    //Jos musiikki soi laitetaan se tauolle.
    if(musa) {
      player.pause();
      musa = false;
    }
    
    if(psDisplayed) psDisplayed = true;
    
    //Test Saturday Night Fever -pose
    if(snfDetector.saturdayNightFever()) {
      println("#### SaturdayNightFever ####");
      bileet = true;
    }
   
  } else {
    
    if(staticGesture.detectPose()) {
      println("#### Standing still ####");
      bileet = false;
    }
    
    if(hadDetector.detect()) {
      strobo = true;
    } else {
      strobo = false;
    }
    
    if(!musa) {
      efekti.rewind(); //Kelataan efekti alkuun
      efekti.play(); //Soitetaan efekti ennen musiikin alkamista
    }
    if(!efekti.isPlaying()) {
      player.play(); //Kun efekti on päättynty aloitetaan musiikki
    }
    musa = true;

    //Himmeä taustavalo
    ambientLight(50, 50, 50);

    int j = 0;
    //Vaihdetaan valokonfiguraatiota parillisissa freimieissa
    if(frameCount%2 == 0) {
      this.samatValot.clear();
      //Arvotaan uusi valosetti
      while(j < 6) {
        int numero = noppa.nextInt(this.valot.size()); 
        Valo valo = this.valot.get(numero);
        valo.nayta();
        this.samatValot.add(valo);
        j++;
      }
    }
    //Parittomissa freimeissa naytetaan samat valot kuin edellisessa freimissa
    else {
      while(j < this.samatValot.size()) {
        this.samatValot.get(j).nayta(); 
        j++;
      }
    }

    //Strobo valkkyy 10 freimin ajan
    if(this.strobo) {
      if(frameCount%2 == 0) {
        emissive(200);
      } else {
        emissive(0);
      }  
    } else {
      emissive(0);
    }
    if(strobolaskuri >= 20) {
      this.strobo = false;
      strobolaskuri = (int)random(5)*2;
      emissive(0);
    }
    // Waveform-efekti
    stroke(220, 0, 50);
    for(int i = 0; i < player.bufferSize() - 1; i++)
    {
      line(i - 500, 50 + player.left.get(i)*80, -540, i - 499, 50 + player.left.get(i+1)*80, -540);
      line(500, 50 + player.right.get(i)*80, i - 550, 500, 50 + player.right.get(i+1)*80, i - 549);
    }
    noStroke();
    
  }
  // jos bileet ovat kaynnissa pallo laskee tiettyyn pisteeseen saakka
  if( bileet && diskopallo.y() < -100) {
    diskopallo.muutaY(3);
  }
  //jos bileet lopetetaan pallo nousee tiettyyn pisteesseen saakka
  if( !bileet && diskopallo.y() > -370) {
    diskopallo.muutaY(-3);
  }
  //Jos diskopallo on bileasennossa, aloitetaan pyöritys ja valoefekti
  if(bileet && diskopallo.y() > -110) {
    diskopallo.pyorita(2);
    disko.piirra();
  }

  //Piirretään diskopallo
  diskopallo.piirraPallo();
  
  //Piirretään olkkari
  model.draw();

  // update context
  context.update();
  // update session
  context.update(sessionManager);
  
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  
  pushMatrix();
  translate(0, 0, 300);
  rotateY(PI);
  scale(0.18);
  
  // draw the skeletons if available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i])) {
      context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, handPos);
      context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, handPos2);
      
      drawSkeleton(userList[i]);
       
      if (psDisplayed) {
        ps.setEmitter(handPos.x, -handPos.y, handPos.z);
        ps.update();     
        ps.display();
        
        ps2.setEmitter(handPos2.x, -handPos2.y, handPos2.z);
        ps2.update();     
        ps2.display();
      }
    }
    
  }
  popMatrix();
  noFill();
  noStroke();
  

  

  //paivitaKamera();
  paivitaKameranSijainti();
  camera(x, y, z, tx, ty, tz, 0, 1, 0);
}


void drawLimb(int userId,int jointType1,int jointType2)
{
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  float  confidence;
  
  // draw the joint position
  context.getJointPositionSkeleton(userId,jointType1,jointPos1);
  context.getJointPositionSkeleton(userId,jointType2,jointPos2);

  //stroke(255,0,0);
  line(jointPos1.x,-jointPos1.y,jointPos1.z,
       jointPos2.x,-jointPos2.y,jointPos2.z);
}

void drawBody(int userId) {
  PVector torsoPos = new PVector();
  PVector headPos = new PVector();
  PVector neckPos = new PVector();
  PVector leftHandPos = new PVector();
  PVector rightHandPos = new PVector();
  PVector leftFootPos = new PVector();
  PVector rightFootPos = new PVector();
  
  float  confidence;
  
  // draw the joint position
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,torsoPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,headPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,neckPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHandPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHandPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_FOOT,leftFootPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_FOOT,rightFootPos);

  pushMatrix();
  //int headX = (int)((headPos.x + neckPos.x)/2);
  //int headY = (int)((headPos.y + neckPos.y)/2);
  //int headZ = (int)((headPos.z + neckPos.z)/2); 
  PVector headSpherePos = PVector.lerp(headPos,neckPos, .2);
  translate(headSpherePos.x, -headSpherePos.y, headSpherePos.z);
  sphere(100);
  popMatrix();
  pushMatrix();
  translate(leftHandPos.x, -leftHandPos.y, leftHandPos.z);
  sphere(60);
  popMatrix();
  pushMatrix();
  translate(rightHandPos.x, -rightHandPos.y, rightHandPos.z);
  sphere(60);
  popMatrix();
  pushMatrix();
  translate(leftFootPos.x, -leftFootPos.y, leftFootPos.z);
  sphere(60);
  popMatrix();
  pushMatrix();
  translate(rightFootPos.x, -rightFootPos.y, rightFootPos.z);
  sphere(60);
  popMatrix();
}

void stop()
{
  //Suljetaan musiikkisoittimet
  player.close();
  efekti.close();
  minim.stop();

  super.stop();
}

//Bileet voi kaynnistaa ja lopettaa b napista
public void keyPressed() {
  if(key == 'b') {
    if(!bileet) {
      bileet = true;
    }
    else
      bileet = false;
    player.pause();
  }
  if(keyCode == UP || key == 'w') {
    moveZ = -10;
    moveUP = true;
  }

  else if(keyCode == DOWN || key == 's') {
    moveZ = 10;
    moveDOWN = true;
  }

  else if(keyCode == LEFT || key == 'a') {
    moveX = -10;
    moveLEFT = true;
  }

  else if(keyCode == RIGHT || key == 'd') {
    moveX = 10;
    moveRIGHT = true;
  }
}

public void keyReleased() {
  if(keyCode == UP || key == 'w') {
    moveUP = false;
    moveZ = 0;
  }
  else if(keyCode == DOWN || key == 's') {
    moveDOWN = false;
    moveZ = 0;
  }

  else if(keyCode == LEFT || key == 'a') {
    moveLEFT = false;
    moveX = 0;
  }

  else if(keyCode == RIGHT || key == 'd') {
    moveRIGHT = false;
    moveX = 0;
  }
}

//Paivittaa kameran sijainnin
public void paivitaKameranSijainti() {

  if(moveUP) {
    z += zComp/MOVEMENT_SPEED;
    tz+= zComp/MOVEMENT_SPEED;
    x += xComp/MOVEMENT_SPEED;
    tx+= xComp/MOVEMENT_SPEED;
  }
  else if(moveDOWN) {
    z -= zComp/MOVEMENT_SPEED;
    tz-= zComp/MOVEMENT_SPEED;
    x -= xComp/MOVEMENT_SPEED;
    tx-= xComp/MOVEMENT_SPEED;
  }
  if (moveRIGHT) {
    z += xComp/MOVEMENT_SPEED;
    tz+= xComp/MOVEMENT_SPEED;
    x -= zComp/MOVEMENT_SPEED;
    tx-= zComp/MOVEMENT_SPEED;
  }
  if (moveLEFT) {
    z -= xComp/MOVEMENT_SPEED;
    tz-= xComp/MOVEMENT_SPEED;
    x += zComp/MOVEMENT_SPEED;
    tx+= zComp/MOVEMENT_SPEED;
  }
}

//Päivittää kameran suunnan
public void paivitaKamera() {

  int diffX = mouseX - width/2;
  int diffY = mouseY - width/2;

  if(abs(diffX) > STILL_BOX) {
    xComp = tx - x;
    zComp = tz - z;
    angle = korjaaKulma(xComp,zComp);

    angle+= diffX/(SENSITIVITY*10);

    if(angle < 0)
      angle += 360;
    else if (angle >= 360)
      angle -= 360;

    float newXComp = CAMERA_DISTANCE * sin(radians(angle));
    float newZComp = CAMERA_DISTANCE * cos(radians(angle));

    tx = newXComp + x;
    tz = -newZComp + z;
  }

  if (abs(diffY) > STILL_BOX) {
    ty += diffY/(SENSITIVITY/1.5);
  }
}

public float korjaaKulma(float xc, float zc) {
  float newAngle = -degrees(atan(xc/zc));
  if (xComp > 0 && zComp > 0) {
    newAngle = (90 + newAngle)+90;
  } 
  else if (xComp < 0 && zComp > 0) {
    newAngle = newAngle + 180;
  }
  else if (xComp < 0 && zComp < 0) {
    newAngle = (90+ newAngle) + 270;
  }
  return newAngle;
}

void drawSkeleton(int userId)
{

  pushStyle();
  
  // different users are of different colors
  stroke(_colors[userId % _colors.length]);
  strokeWeight(3);
  
  // to get the 3d joint data
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
  
  drawBody(userId);
  
  popStyle();  
}

// Handles the PUSH gesture
void handlePush() {
  println(">> PUSH <<");
  strobo = true;
}

void onRecognizeGesture(String strGesture, PVector idPosition, PVector endPosition)
{   
  if (strGesture.equals("Wave")) {
    print("WAVE");
    if (!psDisplayed) psDisplayed = true;
    ps.changeColor();
    ps2.changeColor();
  }
}

// session callbacks
void onStartSession(PVector pos) {
  println("onStartSession: " + pos);
  //context.removeGesture("Click");
}
void onEndSession() {
  println("onEndSession: ");
  //context.addGesture("Click");
}
void onFocusSession(String strFocus, PVector pos, float progress) {
  println("onFocusSession: focus=" + strFocus + ",pos=" + pos + ",progress=" + progress);
}



void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  if(autoCalib)
    context.requestCalibrationSkeleton(userId,true);
  else    
    context.startPoseDetection("Psi",userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi",userId);
  }
}

void onStartPose(String pose,int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}


