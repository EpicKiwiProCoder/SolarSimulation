class DVector{
  double x; double y;
  DVector(double x, double y) {
    this.x = x;
    this.y = y;
  }
}

class Planet {
  double x; double y; int radius; int col; double mass; 
  double xVel; double yVel;
  double angle = 400d;
  boolean isSun = false;
  boolean displayAngle = false;
  ArrayList<DVector> orbit = new ArrayList<DVector>();
  
  Planet(double x, double y, int radius, int col, double mass) {
    this.x = x; this.y = y;
    this.radius = radius;
    this.col = col;
    this.mass = mass;
  }
  
  void display() {
    PVector pos = new PVector((float)(this.x * Scale), (float)(this.y * Scale));
    fill(this.col); strokeWeight(2);
    //for (int i = 0; i < this.orbit.size()-1; i++) {
    //  PVector pointA = new PVector((int)(this.orbit.get(i).x * Scale), (int)(this.orbit.get(i).y * Scale));
    //  PVector pointB = new PVector((int)(this.orbit.get(i+1).x * Scale), (int)(this.orbit.get(i+1).y * Scale));
    //  stroke(0);
    //  line(pointA.x, pointA.y, pointB.x, pointB.y);
    //  stroke(this.col, 100);
    //  line(pointA.x, pointA.y, pointB.x, pointB.y);
    //}
    //noFill();
    stroke(this.col); //stroke(0, 150, 0);
    noStroke(); 
    circle(pos.x, pos.y, this.radius);
  }
  
  DVector attraction(Planet other) {
    double distX = other.x - this.x;
    double distY = other.y - this.y;
    double dist = Math.sqrt(distX*distX + distY*distY);
    //if (other.isSun) this.distanceToSun = dist;
    
    double force = G * this.mass * other.mass / Math.pow(dist,2);
    double theta = Math.atan2(distY, distX);
    double forceX = Math.cos(theta) * force;
    double forceY = Math.sin(theta) * force;
    return new DVector(forceX, forceY);
  }
  
  void updatePosition(Planet[] planets) {
    double totalForceX = 0; double totalForceY = 0;
    for (Planet planet : planets) {
      if (planet == this) continue;
      DVector forces = this.attraction(planet);
      totalForceX += forces.x; totalForceY += forces.y;
    }
    this.xVel += totalForceX / this.mass * Timestep;
    this.yVel += totalForceY / this.mass * Timestep;
    this.x += this.xVel * Timestep;
    this.y += this.yVel * Timestep;
    //this.orbit.add(new DVector(this.x, this.y));
    
    if (this.displayAngle) {
      double newAngle = Math.atan2(this.y, this.x)/TWO_PI*360.0+180.0;
      if (newAngle > this.angle) println(loopCount*hoursPerLoop/24.0);
      this.angle = newAngle;
    }
  }
}

double Au = 1.496e11;
double G = 6.67428e-11;
double Scale = width / 3.2 / Au; // 1 Au = 250 pixels
float hoursPerLoop = 0.01;
float Timestep = 3600f*hoursPerLoop;
int loopsPerFrame = 1000;
int loopCount = 0;

int White = color(255);
int Yellow = color(255, 255, 0);
int Blue = color(100, 149, 237);
int Red = color(188, 39, 50);
int Grey = color(80, 78, 81);
int LightGrey = color(200);

Planet[] planets;
Planet[] planetsDrawingOrder;

void setup() {
  size(1100, 1100);
  frameRate(60);
  
  Scale = (float)width / 3.2 / Au;
  
  Planet sun = new Planet(0, 0, 30, Yellow, 1.98892e30);
  sun.isSun = true;
  Planet earth = new Planet(-1*Au, 0, 16, Blue, 5.9742e24); //-1 * Au
  earth.yVel = 29.783e3;
  earth.displayAngle = true;
  Planet moon = new Planet(-1.0025695 * Au, 0, 4, LightGrey, 7.342e22);
  moon.yVel = 1.022e3 + earth.yVel;
  Planet mars = new Planet(-1.524 * Au, 0, 12, Red, 6.39e23);
  mars.yVel = 24.077e3;
  Planet mercury = new Planet(0.387 * Au, 0, 8, Grey, 3.3e23);
  mercury.yVel = -47.4e3;
  Planet venus = new Planet(0.723 * Au, 0, 14, White, 4.8685e24);
  venus.yVel = -35.02e3;
  
  planets = new Planet[] {sun, moon, earth, mars, mercury, venus};
  planetsDrawingOrder = new Planet[] {sun, earth, moon, mars, mercury, venus};
  //planets = new Planet[] {earth, moon};
  //noLoop();
}

void draw() {
  fill(255); stroke(255);
  textSize(20); 
  background(0);
  text("Day "+str(round(loopCount*hoursPerLoop/24.0))+"  Graphics "+str(round(frameRate))+"FPS  Physics "+str(round(frameRate)*loopsPerFrame)+"FPS",0,16); 
  translate(width/2, height/2);
  for (int i = 0; i < max(loopsPerFrame,1); i++) {
    loopCount++;
    for (Planet planet : planets) {
      planet.updatePosition(planets);
    }
  }
  for (Planet planet : planetsDrawingOrder) {
    planet.display();
  }
}
