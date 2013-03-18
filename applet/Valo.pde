
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

