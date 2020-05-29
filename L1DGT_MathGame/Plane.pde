class Plane {
  PVector position;
  Animation floating, crumple;
  PlaneFire fire;
  
  boolean goingUp = false;
  float ranChange = 0;
  
  Plane(PVector position) {
    floating = new Animation("./Plane/Plane_", 4); //load plane animation - relative path
    crumple = new Animation("./Plane_Crumple/Plane_", 50); //load plane crumple animation /\
    this.position = position; //set pos to passed pos
  }
  
  void draw() {
    //random up/down movement start
    //it moves the plane up and down slightly randomly
    float toChange = goingUp ? 0.1 : -0.1;
    toChange = random(toChange);
    position.y += toChange;
    ranChange += toChange;
    
    if (abs(ranChange) > 5) goingUp = !goingUp;
    //random up/down movement end
    
    //draw the plane
    //don't draw if above screen
    //only change frame every 10 frames
    if (position.y > -5) floating.display(position.x, position.y, frameCount % 10 == 0);
  }
  
  void crumple() {
    //animate crumple, stop at final frame
    crumple.display(position.x, position.y, crumple.frame < crumple.imageCount-1);
    
    if (crumple.frame >= crumple.imageCount-1) { //at animation end
      if (fire == null) fire = new PlaneFire(position, 1000); //initialise fire if needed
      
      fire.position = position; //fire position track plane
      fire.draw(); //run fire
    }
  }
  
  boolean move(PVector endPos) { //returns whether or not reached goal
    //move direction at planeSpeed
    PVector change = new PVector(endPos.x-position.x > 0 ? planeSpeed : -planeSpeed, endPos.y-position.y > 0 ? planeSpeed : -planeSpeed);
    position.add(change);
    
    if (max(abs(endPos.x-position.x), abs(endPos.y-position.y)) < planeSpeed) return true; //if near goal end
    
    ranChange = 0; //don't randomly move plane while moving
    
    return false;
  }
}

class FireParticle {
  PVector position;
  PVector velocity;
  color pColour; //file particle colour
  long lifetime; //how many ticks allive
  
  boolean dead; //is dead?
  
  FireParticle(PVector position) {
    this.position = position.copy(); //set local position to passed
    this.position.x += random(-1, 1); //add a bit of random
    velocity = new PVector(random(-1, 2), random(-2, 0.5)); //random velocities
    pColour = #FFFFFF; //start with colour white
    lifetime = 0; //no lifetime yet
    dead = false; //still alive
  }
  
  void draw() {
    if (lifetime > lifeExpectancy) dead = true; //if lived long, die
    
    //set the fire particle colour, depending on life time % of expected
    pColour = color(155*lifeExpectancy/(lifetime+1), 25*lifeExpectancy/(lifetime+1), 10*lifeExpectancy/(lifetime+1));
    
    position.add(velocity); //move particle
    
    //draw the particle
    stroke(pColour);
    fill(pColour);
    square(position.x, position.y, 1);
    stroke(#000000); //reset stroke, 'cause not really changed anywhere else
    
    lifetime++; //increase lifetime
  }
}

class PlaneFire {
  PVector position; //fire position
  FireParticle[] particles;
  PVector area; //area of the fire
  
  PlaneFire(PVector position, int particleAmount) {
    this.position = position; //set local to passed
    
    particles = new FireParticle[particleAmount]; //created fire paticle array with the passed amount
    area = new PVector(60, 20); //around size of the plane crumple image
  }
  
  void draw() {
    int firstInactive = -1; //first "inactive" file particle found
    
    //loop over each file particle
    for (int particle_it = 0; particle_it < particles.length; particle_it++) {
      /* check if fire particle is "inactive"
      a fire particle is "inactive" if it doesn't exist,
      it hasn't been run yet, or if it is dead */
      if (particles[particle_it] == null || particles[particle_it].lifetime == 0 || particles[particle_it].dead) {
        /* if first inactive one set firstInactive as current,
        else if not in the current "chunk of inactives to run, continue */
        if (firstInactive == -1) firstInactive = particle_it;
        else if (particle_it > firstInactive+particles.length/lifeExpectancy-1) continue;
        
        particles[particle_it] = new FireParticle(position); //reset the particle
        particles[particle_it].position.add(random(-area.x/2, area.x/2), random(-area.y/2, area.y/2)); //randomize the position by the area
      }
      
      particles[particle_it].draw(); //draw the particle
    }
  }
}
