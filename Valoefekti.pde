public int SIVU = 2;
public int X_KOORD = 499;
public int Y_KOORD = -189;

class Valoefekti {

  ArrayList<PVector> neliot; //seinaneliot
  ArrayList<PVector> neliot_katto; //kattoneliot
  ArrayList<PVector> vektorit; //perusvektorit, kaytetaan kattonelioiden laskemiseens
  int kulma;
  PShape nelio;
  PVector nelion_nopeus;

  public Valoefekti() {
    neliot = new ArrayList();
    neliot_katto = new ArrayList();
    vektorit = new ArrayList();
    kulma = 0;
    nelion_nopeus = new PVector(0, -5, 0);
    //Luodaan perusvektorit 
    for (int i = 360; i > 0; i -= 18) {
      vektorit.add(new PVector(sin(i), cos(i)));
    }
    luoListat();

    nelio = createShape();
    nelio.beginShape(QUADS);
    nelio.fill(0);
    nelio.noStroke();  
    nelio.emissive(150); 
    nelio.vertex(0, -SIVU, -SIVU);
    nelio.vertex(0, SIVU, -SIVU);
    nelio.vertex(0, SIVU, SIVU);
    nelio.vertex(0, -SIVU, SIVU);
    nelio.endShape(CLOSE);
  }

  public void piirra() {
    //Päivitetään pisteiden koordinaatit
    paivitaLista();
    
    //Piirretään seinien valoefektit
    for (int j = 0; j < 360; j += 90) {
      pushMatrix();
      rotateY(radians(j));
      for (int i = 0; i < neliot.size(); i++) {
        piirraNelio(neliot.get(i));
      }
      popMatrix();
    }

    for (int i = 0; i < neliot_katto.size(); i++) {
      //Piirretään katon valoefekti
      pushMatrix();
      rotateY(radians(kulma));
      piirraKattonelio(neliot_katto.get(i));
      popMatrix();
      //Piirretään lattian valoefekti
      pushMatrix();
      rotateZ(PI);
      rotateY(radians(-kulma));
      piirraKattonelio(neliot_katto.get(i));
      popMatrix();
    }
    kulma ++;
  }

  //Piirtää yksittäisen valoneliön seinälle
  private void piirraNelio(PVector vek) {
    int x = (int)vek.x;
    //Kasvatetaan y-koordinaatta suhteessa etäisyyten origosta
    int y = (int)(vek.y * (abs(vek.y)/200));
    //pushMatrix();
    //translate(X_KOORD, x, y);
    //shape(nelio);
    //popMatrix();
    pushStyle();
    //Valoneliöt eivät heijasta valonlähteistä tulevaa valoa
    fill(0);  
    emissive(150);
    beginShape(); 
    //Kasvatetaan valoneliön kokoa suhteessa etäisyyteen origosta 
    float factor = 1.2;
    vertex(X_KOORD, x - SIVU*factor, y - SIVU*factor * (max(1,abs(y)) / 100));
    vertex(X_KOORD, x + SIVU*factor, y - SIVU*factor * (max(1,abs(y)) / 100));
    vertex(X_KOORD, x + SIVU*factor, y + SIVU*factor);
    vertex(X_KOORD, x - SIVU*factor, y + SIVU*factor);
    endShape();
    popStyle();
  }
  //Piirtää yksittäisen valoneliön kattoon
  private void piirraKattonelio(PVector vek) {
    int x = (int)vek.x;
    int y = (int)vek.y;
    pushStyle();
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
    popStyle();
    colorMode(RGB);
  }

  //Luo listat nelioiden keskipisteista
  private void luoListat() {
    //Seinaneliot
    for (int i = 0; i < 30; i += 3) { 
      for (int j = -200; j < 200; j += 40) {
        luoNelio(j + (int)random(3), (i * i) + (int)random(3));
        luoNelio(j + (int)random(3), (-10 - i * i)  + (int)random(3));
      }
    }
    //Kattoneliot
    for (int i = 100; i < 800; i += 25) {
      for (int j = 0; j < vektorit.size(); j++) {
        PVector v = new PVector();
        v.set(vektorit.get(j));
        v.mult(i);
        v.add(random(i/3), 0, random(i/3));
        neliot_katto.add(v);
      }
    }
  }

  //Lisää neliön keskipisteen listaan
  private void luoNelio(int x, int y) {
    neliot.add(new PVector(x, y));
  }

  //Päivittää valoneliöiden koordinaatit ja poistaa tarpeettomaksi käyneet neliöt listasta.
  private void paivitaLista() {   

    for (int i = 0; i < neliot.size(); i++) {
      PVector v = neliot.get(i);
      v.add(nelion_nopeus); 
      if (v.y < -500) {
        v.y = 560 + -2 + (int)random(4);
        v.x = v.x + -1 + (int)random(2);
      }
    }
  }
}

