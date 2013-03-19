
//Pallo-luokka kuvaa teksturoitua palloa, joka voidaan piirtää haluttuun kohtaan avaruudessa ja
//liikuttaa tämän jälkeen kiertää akselin ympäri ja siirtää y-akselia pitkin. 

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
  void luoPallo()
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

  //Renderöi teksturoidun pallon oikeaan kohtaan ja 
  public void piirraPallo() {
    pushMatrix();
    translate(0, yT, 0); //Muutetaan pallon sijaintia y-akselilla
    rotateY(radians(this.kulma)); //Kierretään palloa haluttuun kulmaan
    pushStyle();
    emissive(150);
    beginShape(QUAD_STRIP);
    texture(teksturi);
    textureMode(NORMAL); 
    //Käydään verteksilista läpi ja piirretään verteksit
    if(this.verteksit != null) {
      for(int i = 0; i < this.verteksit.size(); i++) {
        Verteksi ver = (Verteksi)verteksit.get(i);
        vertex(ver.x(), ver.y(), ver.z(), ver.u(), ver.v());
      }
    }
    endShape();
    popStyle();
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
  //Todellisuudessa pallon y-koordinaatti on koko ajan 0, mutta koordinaatiosta siirretään. 
  public int y() {
   return this.yT; 
  }
  
}



