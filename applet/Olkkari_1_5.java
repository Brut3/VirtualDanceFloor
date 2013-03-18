import processing.core.*; 
import processing.xml.*; 

import processing.opengl.*; 
import javax.media.opengl.GL; 
import saito.objloader.*; 
import java.util.Random; 
import ddf.minim.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class Olkkari_1_5 extends PApplet {


//Olkkarissa voi liikkua hiiren ja nappaimiston avulla. Jos aika rupeaa kaymaan pitkaksi
//kannattaa paina b-nappainta. 

 





AudioPlayer player; //musiikkisoitin
AudioSnippet efekti; //efektisoitin
Minim minim; //minim-olio

OBJModel model; //3d-malli

//OpenGL muuttujat
PGraphicsOpenGL pgl;
GL gl;

Pallo diskopallo; //diskopallo
Valoefekti disko; //diskopallo-valoefekti

boolean bileet; //onko bileet kaynnissa? ;)
boolean musa; //soiko poppi
boolean strobo; //v\u00e4lkkyyk\u00f6 strobo
int strobolaskuri; //valkyntalaskuri

ArrayList<Valo> valot; //kokoelma erilaisa valoja
ArrayList<Valo> samatValot;
Random noppa;

//----------------- KAMERA ---------------------

//Vakiot
int STAND_HEIGHT = 100;
int MOVEMENT_SPEED = 50;
float SENSITIVITY = 15;      //Suurempi arvo, hitaampi liike
int STILL_BOX = 100;        
int CAMERA_DISTANCE = 1000;

//Muuttujat
float x, y, z, ay; //Sijainti
float tx, ty, tz; //Katsevektori
float rotX, rotY; 
float xComp, zComp;
float angle;
int moveX;
int moveZ;
boolean moveUP, moveDOWN, moveLEFT, moveRIGHT;

//------------------------------------------------

public void setup()
{
  size(800,600,P3D);
  

  frameRate(24); //Rajoitetaan framerate 24

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

  //Skaalataan malli sopivan kokoiseksi
  model.scale(100);
  //Siirret\u00e4\u00e4n malli keskelle koordinaatistoa
  model.translateToCenter();

  //OPENGL h\u00e4ss\u00e4kk\u00e4\u00e4
//  pgl = (PGraphicsOpenGL) g;
//  gl = pgl.beginGL();
//  gl.glEnable(GL.GL_CULL_FACE); 
//  gl.glCullFace(GL.GL_BACK); //Ei piirret\u00e4 takatahkoja
//  pgl.endGL();

  //Alustetaan musiikkisoitin
  minim = new Minim(this); 
  player = minim.loadFile("diskojytaa.mp3");
  efekti = minim.loadSnippet("djscratch1.wav");

  //Luodaan listat
  this.valot = new ArrayList();
  this.samatValot = new ArrayList();

  //Lis\u00e4t\u00e4\u00e4n valot listaan
  valot.add(new Valo(0, 255, 0, 0, 100, 0, -0.7f, 0, -1, PI/9, 150));
  valot.add(new Valo(255, 255, 0, 0, 100, 0, -0.7f, 0, -1, PI/9, 150));
  valot.add(new Valo(0, 0, 255, 0, 100, 0, -0.7f, 0, -1, PI/9, 150));

  valot.add(new Valo(0, 255, 0, 0, 100, 0, 0, 0, -1, PI/3, 50));
  valot.add(new Valo(255, 0, 0, 0, 100, 0, 0, 0, 1, PI/3, 50));
  valot.add(new Valo(0, 0, 255, 0, 100, 0, 0, 0, 1, PI/3, 50));

  valot.add(new Valo(255, 0, 255, 0, 100, 0, 0, 1, 0, PI/3, 50));
  valot.add(new Valo(0, 0, 255, 0, 100, 0, 0, 1, 0, PI/3, 50));

  valot.add(new Valo(0, 255, 0, 0, 100, 0, -0.5f, 0, -1, PI/3, 50));
  valot.add(new Valo(0, 255, 255, 0, 100, 0, -0.5f, 0, -1, PI/3, 50));

  valot.add(new Valo(0, 255, 100, 0, 100, 0, 0.8f, -0.4f, -1, PI/3, 150));
  valot.add(new Valo(200, 0, 200, 0, 100, 0, 0.8f, -0.4f, -1, PI/3, 120));
  valot.add(new Valo(0, 230, 150, 0, 100, 0, 0.8f, -0.5f, -0.9f, PI/6, 300));
  valot.add(new Valo(200, 100, 200, 0, 100, 0, 0.8f, -0.5f, -0.9f, PI/6, 300));

  //Alustetaan kameroa
  x = width/2;
  y = height/2;
  ay-= STAND_HEIGHT;
  z = (height/2.0f) / tan(PI*60.0f / 360.0f);
  tx = width/2;
  ty = height/2;
  tz = 0;
  rotX = 0;
  rotY = 0;
  xComp = tx - x;
  zComp = tz - z;
  angle = 0;

  //Alustetaan liikkeflagit
  moveUP = false;
  moveDOWN = false;
  moveLEFT = false;
  moveRIGHT = false;
}

public void draw() {

  background(0);
  println(frameRate);
  translate(width/2, height/2, 0);

  if(!bileet) {
    //Normitilassa p\u00e4rj\u00e4t\u00e4\u00e4n yhdell\u00e4 pistevalolla ja taustavalolla
    pointLight(255,255,255, 0, 100, 0);
    ambientLight(150, 150, 150);

    //Jos musiikki soi laitetaan se tauolle.
    if(musa) {
      player.pause();
      musa = false;
    }
  }
  if (bileet) {
    if(!musa) {
      efekti.rewind(); //Kelataan efekti alkuun
      efekti.play(); //Soitetaan efekti ennen musiikin alkamista
    }
    if(!efekti.isPlaying()) {
      player.play(); //Kun efekti on p\u00e4\u00e4ttynty aloitetaan musiikki
    }
    musa = true;

    //Himme\u00e4 taustavalo
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
    //Strobo paalle 50 freimin valein
    if(frameCount % 50 == 0) {
      this.strobo = true;
    }
    //Strobo valkkyy 10 freimin ajan
    if(this.strobo && strobolaskuri < 10) {
      if(frameCount%2 == 0) {
        pointLight(100, 100, 100, 160, 160, 100);
      }  
      strobolaskuri++;
    }
    if(strobolaskuri >= 10) {
      this.strobo = false;
      strobolaskuri = 0;
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
  //Jos diskopallo on bileasennossa, aloitetaan py\u00f6ritys ja valoefekti
  if(bileet && diskopallo.y() > -110) {
    diskopallo.pyorita(2);
    disko.piirra();
  }

  //Piirret\u00e4\u00e4n diskopallo
  diskopallo.piirraPallo();

  //Piirret\u00e4\u00e4n olkkari
  model.draw();

  noFill();
  noStroke();

  paivitaKamera();
  paivitaKameranSijainti();
  camera(x, y, z, tx, ty, tz, 0, 1, 0);
}

public void stop()
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

//P\u00e4ivitt\u00e4\u00e4 kameran suunnan
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
    ty += diffY/(SENSITIVITY/1.5f);
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


//Pallo-luokka kuvaa teksturoitua palloa, joka voidaan piirt\u00e4\u00e4 haluttuun kohtaan avaruudessa ja
//liikuttaa t\u00e4m\u00e4n j\u00e4lkeen kiert\u00e4\u00e4 akselin ymp\u00e4ri ja siirt\u00e4\u00e4 y-akselia pitkin. 

class Pallo {

  ArrayList<Verteksi> verteksit; //Pallon verteksit 
  float zP, xP, yP; //pallon sijainti
  float rP; //pallon sade
  int nP; //pallon tarkkuus
  float kulma; //kiertokulma
  int yT; //translaatio y-akselilla
  PImage teksturi;

  public Pallo(float x, float y, float z, float r, int n) {
    this.xP = x;
    this.zP = z;
    this.yP = 0;
    this.rP = r;
    this.nP = n;
    this.yT = (int)y;
    this.kulma = 0;
    this.teksturi = loadImage("disko2.jpg");
    verteksit = new ArrayList();
  }

  //Luo halutun pallon ja tallentaa sen verteksit listaan
  public void luoPallo()
  {
    int i = 0;
    int j = 0;  
    float x1;
    float y1;
    float z1;

    float x2;
    float y2;
    float z2;
    
    float theta1;
    float theta2;
    float theta3;
    
    float u;
    float v;
    
    for (j = 0; j < (nP/2); j++) {

      theta1 = j * (2 * PI) / nP - PI/2;
      theta2 = (j + 1) * (2 * PI) / nP - PI/2 ;

      for (i = 0; i <= nP; i++) {

        theta3 = i * (2*PI) / nP;

        x1 = cos(theta2) * cos(theta3);
        y1 = sin(theta2);
        z1 = cos(theta2) * sin(theta3);
        x2 = xP + rP * x1;
        y2 = yP + rP * y1;
        z2 = zP + rP * z1;

        u = i / (float)nP;
        v = 2 * (j + 1) / (float)nP;

        this.verteksit.add(new Verteksi(x2, y2, z2, u, v)); 

        x1 = cos(theta1) * cos(theta3);
        y1 = sin(theta1);
        z1 = cos(theta1) * sin(theta3);
        x2 = xP + rP * x1;
        y2 = yP + rP * y1;
        z2 = zP + rP * z1;

        u = i / (float)nP;
        v = 2 * j / (float)nP;

        this.verteksit.add(new Verteksi(x2,y2, z2, u, v));
      }
    }
  }

  //Render\u00f6i teksturoidun pallon oikeaan kohtaan ja 
  public void piirraPallo() {
    pushMatrix();
    translate(0, yT, 0); //Muutetaan pallon sijaintia y-akselilla
    rotateY(radians(this.kulma)); //Kierret\u00e4\u00e4n palloa haluttuun kulmaan
    beginShape(QUAD_STRIP);
    texture(teksturi);
    textureMode(NORMALIZED); 
    //K\u00e4yd\u00e4\u00e4n verteksilista l\u00e4pi ja piirret\u00e4\u00e4n verteksit
    if(this.verteksit != null) {
      for(int i = 0; i < this.verteksit.size(); i++) {
        Verteksi ver = (Verteksi)verteksit.get(i);
        vertex(ver.x(), ver.y(), ver.z(), ver.u(), ver.v());
      }
    }
    endShape();
    popMatrix();
  }
  
  //Muuttaa pallon y-koordinaattia
  public void muutaY(int deltaY) {
    yT += deltaY;
  }
  
  //Muuttaa pallon kiertokulmaa annetun kulman verran
  public void pyorita(float kulma) {
    this.kulma += kulma;
  }
  
  //Palauttaa pallon virtuaalisen y-koordinaatin
  //Todellisuudessa pallon y-koordinaatti on koko ajan 0, mutta koordinaatiosta siirret\u00e4\u00e4n. 
  public int y() {
   return this.yT; 
  }
  
}




//Valo on apuluokka jonka avulla on helppo tallentaa listaan erilaisia spottivaloja.

class Valo {

  int v1 = 0;
  int v2 = 0; 
  int v3 = 0; 
  int x = 0; 
  int y = 0;
  int z = 0;
  float nx = 0;
  float ny = 0;
  float nz = 0; 
  float angle = 0;
  float concentration = 0;

  public Valo(int v1,int v2,int v3,int x,int y,int z,float nx,float ny,
  float nz,float angle,float concentration) {
    this.v1 = v1;
    this.v2 = v2; 
    this.v3 = v3; 
    this.x = x; 
    this.y = y;
    this.z = z;
    this.nx = nx;
    this.ny = ny;
    this.nz = nz; 
    this.angle = angle;
    this.concentration = concentration;
  }

  public void nayta() {
    spotLight(v1, v2, v3, x, y, z, nx, ny, nz, angle, concentration);
  }
}

public int SIVU = 2;
public int X_KOORD = 499;
public int Y_KOORD = -189;

class Valoefekti {

  ArrayList<PVector> neliot; //seinaneliot
  ArrayList<PVector> neliot_katto; //kattoneliot
  ArrayList<PVector> vektorit; //perusvektorit, kaytetaan kattonelioiden laskemiseens
  int kulma;

  public Valoefekti() {
    neliot = new ArrayList();
    neliot_katto = new ArrayList();
    vektorit = new ArrayList();
    kulma = 0;
    //Luodaan perusvektorit 
    for(int i = 360; i > 0; i -= 18) {
      println("sin: " + sin(radians(i)) + " cos: " + cos(radians(i)));
      vektorit.add(new PVector(sin(i), cos(i)));
    }
    luoListat();
  }

  public void piirra() {
    //P\u00e4ivitet\u00e4\u00e4n pisteiden koordinaatit
    paivitaLista();

    //Piirret\u00e4\u00e4n seinien valoefektit
    for(int i = 0; i < neliot.size(); i ++) {
      for(int j = 0; j < 360; j += 90) {
        pushMatrix();
        rotateY(radians(j));
        piirraNelio(neliot.get(i));
        popMatrix();
      }
    }
    
    for(int i = 0; i < neliot_katto.size(); i++) {
      //Piirret\u00e4\u00e4n katon valoefekti
      pushMatrix();
      rotateY(radians(kulma));
      piirraKattonelio(neliot_katto.get(i));
      popMatrix();
      //Piirret\u00e4\u00e4n lattian valoefekti
      pushMatrix();
      rotateZ(PI);
      rotateY(radians(-kulma));
      piirraKattonelio(neliot_katto.get(i));
      popMatrix();
    }
    kulma ++;
  }

  //Piirt\u00e4\u00e4 yksitt\u00e4isen valoneli\u00f6n sein\u00e4lle
  private void piirraNelio(PVector vek) {
    int x = (int)vek.x;
    //Kasvatetaan y-koordinaatta suhteessa et\u00e4isyyten origosta
    int y = (int)(vek.y * (abs(vek.y)/200));
    //Valoneli\u00f6t eiv\u00e4t heijasta valonl\u00e4hteist\u00e4 tulevaa valoa
    fill(0);
    //Valoneli\u00e4t s\u00e4teilev\u00e4t omaa valoaan
    emissive(150);
    beginShape(); 
    //Kasvatetaan valoneli\u00f6n kokoa suhteessa et\u00e4isyyteen origosta 
    vertex(X_KOORD, x - SIVU, y - SIVU * (max(1,abs(y)) / 100));
    vertex(X_KOORD, x + SIVU, y - SIVU * (max(1,abs(y)) / 100));
    vertex(X_KOORD, x + SIVU, y + SIVU);
    vertex(X_KOORD, x - SIVU, y + SIVU);
    endShape();

    emissive(0);
    noFill();
  }
  //Piirt\u00e4\u00e4 yksitt\u00e4isen valoneli\u00f6n kattoon
  private void piirraKattonelio(PVector vek) {
    int x = (int)vek.x;
    int y = (int)vek.y;
    fill(0);
    colorMode(HSB);
    //Neliot himmenevat kun etaisyys keskipisteeseen kasvaa
    emissive(0, 0, 255 - vek.mag()/4);
    beginShape(); 
    //Piirrettavan nelion kokoa kasvatetaan kun etaisyys keskipisteeseen kasvaa
    vertex(x - SIVU * vek.mag() / 200, Y_KOORD, y - SIVU * vek.mag() / 200);
    vertex(x + SIVU * vek.mag() / 200, Y_KOORD, y - SIVU * vek.mag() / 200);
    vertex(x + SIVU * vek.mag() / 200, Y_KOORD, y + SIVU * vek.mag() / 200);
    vertex(x - SIVU * vek.mag() / 200, Y_KOORD, y + SIVU * vek.mag() / 200);
    endShape();
    emissive(0);
    noFill();
    colorMode(RGB);
  }
  //Luo listat nelioiden keskipisteista
  private void luoListat() {
    //Seinaneliot
    for(int i = 0; i < 30; i += 2) { 
      for(int j = -200; j < 200; j += 40) {
        luoNelio(j + (int)random(3), (i * i) + (int)random(3));
        luoNelio(j + (int)random(3), (-10 - i * i)  + (int)random(3));
      }
    }
    //Kattoneliot
    for(int i = 100; i < 800; i += 20) {
      for(int j = 0; j < vektorit.size(); j++) {
        PVector v = new PVector();
        v.set(vektorit.get(j));
        v.mult(i);
        v.add(random(i/3), 0, random(i/3));
        neliot_katto.add(v);
      }
    }
  }

  //Lis\u00e4\u00e4 neli\u00f6n keskipisteen listaan
  private void luoNelio(int x, int y) {
    neliot.add(new PVector(x, y));
  }

  //P\u00e4ivitt\u00e4\u00e4 valoneli\u00f6iden koordinaatit ja poistaa tarpeettomaksi k\u00e4yneet neli\u00f6t listasta.
  private void paivitaLista() {   

    for(int i = 0; i < neliot.size(); i++) {
      PVector v = neliot.get(i);
      v.add(new PVector(0, -5, 0)); 
      if(v.y < -400) {
        //luodaan uusi nelio poistettavan tilalle
        luoNelio((int)v.x, 560 + (int)random(3));
        //poistetaan nelio listasta
        neliot.remove(i);
      }
    }
  }
}


//Verteksi-luokka helpottaa valmiiksi laskettujen verteksien ja tekstuurikoordinaattien
//tallentamista my\u00f6hemp\u00e4\u00e4 k\u00e4ytt\u00f6\u00e4 varten.

class Verteksi {

  float xV, yV, zV;
  float uV, vV;

  public Verteksi(float x, float y, float z, float u, float v) {
    this.xV = x;
    this.yV = y;
    this.zV = z;
    this.uV = u;
    this.vV = v;
  }

  public float x() {
    return this.xV;
  }

  public float y() {
    return this.yV;
  }

  public float z() {
    return this.zV;
  }

  public float u() {
    return this.uV;
  }

  public float v() {
    return this.vV;
  }
}


  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "Olkkari_1_5" });
  }
}
