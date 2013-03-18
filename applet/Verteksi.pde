
//Verteksi-luokka helpottaa valmiiksi laskettujen verteksien ja tekstuurikoordinaattien
//tallentamista myöhempää käyttöä varten.

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


