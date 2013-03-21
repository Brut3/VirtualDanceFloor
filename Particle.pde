  class Particle {
  
  PVector velocity;
  float lifespan = 100;
  
  PShape part;
  float partSize;
  color[] part_colors = {color(255,0,0), color(0,255,0), color(0,0,255), color(0,0,255)};
  color part_color;
  
  PVector gravity = new PVector(0,0.3);

  public Particle() {
    partSize = random(20,200);
    part_color = part_colors[(int)random(3)];
    PShape part1 = createShape();
    part1.beginShape(QUAD);
    part1.noStroke();
    part1.texture(sprite);
    part1.fill(0);
    part1.emissive(part_color);
    part1.normal(0, 0, 1);
    part1.vertex(-partSize/2, -partSize/2, 0, 0);
    part1.vertex(+partSize/2, -partSize/2, sprite.width, 0);
    part1.vertex(+partSize/2, +partSize/2, sprite.width, sprite.height);
    part1.vertex(-partSize/2, +partSize/2, 0, sprite.height);
    part1.endShape();
    
    PShape part2 = createShape();
    part2.beginShape(QUAD);
    part2.noStroke();
    part2.texture(sprite);
    part2.fill(0);
    part2.emissive(part_color);
    part2.normal(0, 0, 1);
    part2.vertex(0, -partSize/2, -partSize/2, 0, 0);
    part2.vertex(0, +partSize/2, -partSize/2, sprite.width, 0);
    part2.vertex(0, +partSize/2, +partSize/2, sprite.width, sprite.height);
    part2.vertex(0, -partSize/2, +partSize/2, 0, sprite.height);
    part2.endShape();
    
    part = createShape(GROUP);
    part.addChild(part1);
    part.addChild(part2);

    
    rebirth(0,0,0);
    lifespan = random(255);
  }

  public PShape getShape() {
    return part;
  }
  
  public void rebirth(float x, float y, float z) {
    float a = random(TWO_PI);
    float b = random(TWO_PI);
    float speed = random(0.5,2);
    velocity = new PVector(cos(a), sin(a), cos(b));
    velocity.mult(speed);
    lifespan = 255;   
    part.resetMatrix();
    part.translate(x, y, z); 
  }
  
  boolean isDead() {
    if (lifespan < 0) {
     return true;
    } else {
     return false;
    } 
  }
  

  public void update() {
    lifespan = lifespan - 1;
    velocity.add(gravity);
    color c = part_color;
    part.setTint(color(red(c),green(c),blue(c),lifespan));
    part.translate(velocity.x, velocity.y, velocity.z);
  }
}
