class ParticleSystem {
  ArrayList<Particle> particles;

  PShape particleShape;

  ParticleSystem(int n) {
    particles = new ArrayList<Particle>();
    particleShape = createShape(PShape.GROUP);

    for (int i = 0; i < n; i++) {
      Particle p = new Particle();
      particles.add(p);
      particleShape.addChild(p.getShape());
    }
  }

  public void update() {
    for (Particle p : particles) {
      p.update();
    }
  }

  public void setEmitter(float x, float y, float z) {
    for (Particle p : particles) {
      if (p.isDead()) {
        p.rebirth(x, y, z);
      }
    }
  }
  
  public void changeColor() {
    for (Particle p : particles) {
      p.changeColor();
    }
  }

  void display() {

    shape(particleShape);
  }
}

