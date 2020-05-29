String[] bImages = {"Building A", "Building B", "Building C", "Crane"}; //these are file names
String[] cImages = {"Cloud 1"}; //for clouds

class bArticle {
  PVector position;
  int imgID; //id of img in bImages array
  
  PImage bImg; //the actual image
  
  bArticle() {
    position = new PVector();
    setNewImage(); //start with an image
  }
  
  void setNewImage() {
    imgID = floor(random(bImages.length)); //get random img id from the array
    bImg = loadImage("./res/Buildings/" + bImages[imgID] + ".png"); //load the selected img
    bImg.resize(bImg.width*400/bImg.height, 400); //resize to common height (400), width is proportional
  }
  
  void drawArticle() {
    position.x += backgroundSpeed; //move speed amount
    image(bImg, position.x, position.y); //draw img at pos
  }
}

class bCloud extends bArticle {
  float speed; //the cloud's movement speed
  
  bCloud(float speed) {
    this.speed = speed; //set local to passed speed
    position = PVector.random2D(); //randomizes position
    position.mult(preHeight); //randomizes position
    setNewImage();
  }
  
  void setNewImage() {
    imgID = floor(random(cImages.length)); //get random image
    bImg = loadImage("./res/Clouds/" + cImages[imgID] + ".png"); //load the selected image
    //resize it randomly, makes same image look different
    bImg.resize(round(bImg.width + random(-0.5*bImg.width, 0.5*bImg.width)), round(bImg.height + random(-0.5*bImg.height, 0.5*bImg.height)));
  }
  
  void drawArticle() {
    super.drawArticle(); //the cloud moves at background speed
    
    position.x += speed; //add cloud speed, could be negative for slower clouds 'cause background speed
    if (position.x > preWidth) reset(); //off screen?, reset
  }
  
  void reset() {
    position = new PVector(0-bImg.width-random(preWidth), random(preHeight)); //resets the cloud position
    setNewImage();
  }
}

class GiantArticle extends bArticle { //giant article for crumpling
  void setNewImage() { //same as regular bArticle, however it needs to be bigger and not a crane
    do { //keep selecting article until not crane
      imgID = floor(random(bImages.length));
    } while (bImages[imgID] == "Crane");
    
    bImg = loadImage("./res/Buildings/" + bImages[imgID] + ".png"); //load image
    bImg.resize(round(bImg.width*1.25), round(preHeight*2)); //resize it to taller than screen
  }
}

class HomeBackground {
  bCloud[] clouds;
  
  float cloudSpeedAdd; //additional cloudspeed for speedy effect
  
  HomeBackground() {
    clouds = new bCloud[13]; //cloud number
    
    for (int cloud_it = 0; cloud_it < clouds.length; cloud_it++) {
      //initialize clouds
      clouds[cloud_it] = new bCloud(random(-backgroundSpeed, defCloudSpeed));
    }
    
    cloudSpeedAdd = 0; //no additional cloud speed
  }
  
  void drawBackground() {
    //set background colour, changes slightly based on cloud speed
    background(color(150-cloudSpeedAdd*6, 150-cloudSpeedAdd*6, 255));
    
    //change cloud speed, neat speed up then quickly slow down effect
    cloudSpeedAdd += cloudSpeedAdd > 4 ? -2*cloudSpeedAdd : 0.1;
    
    //loop over and run all clouds
    for (int cloud_it = 0; cloud_it < clouds.length; cloud_it++) {
      bCloud cloud = clouds[cloud_it];
      cloud.speed += cloudSpeedAdd; //add speed
      cloud.drawArticle();
    }
  }
  
  void transitionBackground() {
    background(#BBBBFF); //set the background colour
    
    cloudSpeedAdd += 0.1; //speed up the clouds
    
    //loop over clouds n' run
    for (int cloud_it = 0; cloud_it < clouds.length; cloud_it++) {
      bCloud cloud = clouds[cloud_it];
      
      //if cloud off end, don't run cloud speed cause clouds reset themselves
      if (cloud.position.x > preWidth-cloud.speed) continue;
      
      cloud.speed = defCloudSpeed+cloudSpeedAdd; //add speeds
      cloud.position.y += -0.5; //cloud goes slightly upwards
      cloud.drawArticle();
    }
  }
}

class EndBackground {
  GiantArticle crumpled;
  
  EndBackground (int crumpleImgID) {
    this.crumpled = new GiantArticle(); //initialise article
    this.crumpled.imgID = crumpleImgID; //set img id to passed
    this.crumpled.bImg = loadImage("./res/Buildings/" + bImages[this.crumpled.imgID] + ".png"); //set to passed image
    crumpled.bImg.resize(round(crumpled.bImg.width*1.25), round(preHeight*2)); //resize it to taller than screen
    this.crumpled.position = new PVector(preWidth/2-crumpled.bImg.width/2, -preHeight/2); //set position so it's centered same height as play background
  }
  
  void drawBackground() {
    background(#a5a5a5);
    
    //used instead of crumpled.drawArticle because that method changes position
    image(crumpled.bImg, crumpled.position.x, crumpled.position.y);
  }
}

class PlayBackground {
  bArticle[] articles;
  bCloud[] clouds;
  
  PVector crumplePos; //crumple building center position
  GiantArticle crumpled; //crumple building
  
  PlayBackground() {
    //cloud start
    clouds = new bCloud[13]; //this is how many total clouds
    
    for (int cloud_it = 0; cloud_it < clouds.length; cloud_it++) {
      clouds[cloud_it] = new bCloud(random(-backgroundSpeed, defCloudSpeed)); //new cloud random speed
    }
    
    //article start
    articles = new bArticle[5]; //this is how many articles in total
    
    for (int article_it = 0; article_it < articles.length; article_it++) {
      //populates each value in the array
      articles[article_it] = new bArticle();
      
      /* makes sure that the position is set behind the last bArticle so that they don't overlap
      if there is no bArticle (this is first one) it just sets the position to the width
      this means that the articles are drawn across the screen when first started
      as opposed to starting off screen and coming on */
      articles[article_it].position.x = article_it-1 >= 0 ? articles[article_it-1].position.x-articles[article_it].bImg.width : preWidth;
    }
    
    //crumple stuffs start
    crumplePos = new PVector(0, -preHeight/2); //start of crumple
    crumpled = new GiantArticle(); //initialise crumple building
  }
  
  void drawBackground() {
    background(#AAAAFF); //set background colour
    
    //clouds start
    //loop over & run cloud
    for (int cloud_it = 0; cloud_it < clouds.length; cloud_it++) {
      bCloud cloud = clouds[cloud_it];
      
      cloud.drawArticle();
    }
    
    //articles start
    
    //start at -1 to know if set yet
    int articleToReset_it = -1;
    int articleMostLeft_it = -1;
    
    for (int article_it = 0; article_it < articles.length; article_it++) {
      //draw each article
      bArticle article = articles[article_it];
      
      article.drawArticle();
      
      if (articleToReset_it == -1 && article.position.x > preWidth) { //if not set & off screen
        articleToReset_it = article_it;
      }
      else if (articleMostLeft_it == -1 || articles[articleMostLeft_it].position.x > article.position.x) { //if not set & most left
        articleMostLeft_it = article_it;
      }
    }
    
    if (articleToReset_it != -1) { // any to reset
      bArticle articleToReset = articles[articleToReset_it]; //to reset
      
      //distance extra to avoid the farthest left article
      long howFarBack = articleMostLeft_it == -1 ? 0 : (long) -articles[articleMostLeft_it].position.x; 
      
      //reset article
      articleToReset.setNewImage();
      
      /*
      the position
      back the article's img width
      back the background speed
      back howFarBack (most left pos)
      */
      articleToReset.position.x = 0-articleToReset.bImg.width-backgroundSpeed-howFarBack;
    }
  }
  
  void crumple() {
    background(#a5a5a5); //grey background colour
    
    if (crumplePos.x < preWidth/2) crumplePos.x++; //move to half width
    
    //set position of crumpled so that it is centered on crumplePos
    crumpled.position = crumplePos.copy();
    crumpled.position.add(-crumpled.bImg.width/2, 0);
    
    crumpled.drawArticle(); //draw crumpled
  }
  
  boolean transition() { //returns if all the articles are off the screen
    background(#AAAAFF); //set background colour
    
    //clouds start
    //loop over and draw clouds
    for (int cloud_it = 0; cloud_it < clouds.length; cloud_it++) {
      bCloud cloud = clouds[cloud_it];
      
      cloud.drawArticle();
    }
    
    //articles start
    boolean articlesGone = true; //all articles of screen
    
    for (int article_it = 0; article_it < articles.length; article_it++) {
      bArticle article = articles[article_it];
      if (article.position.x > preWidth) continue; //don't run, off screen
      
      article.drawArticle();
      articlesGone = false; //this article is on screen
    }
    
    return articlesGone;
  }
}
