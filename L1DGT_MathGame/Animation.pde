class Animation {
  PImage[] images;
  int imageCount;
  int frame; //current frame to display
  
  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) { //populate each image
      // get filename from passed imagePrefix
      // nf() to format 'i' into four digits
      String filename = "./res" + imagePrefix + nf(i, 4) + ".png";
      images[i] = loadImage(filename); //load image to array
    }
  }
  
  void display(float xpos, float ypos) { //always change frame
    display(xpos, ypos, true); //call other display with changeFrame true
  }
  
  void display(float xpos, float ypos, boolean changeFrame) { //if we don't want frame to change
    if (changeFrame) frame = (frame+1) % imageCount; // next frame if passed changeFrame true 
    
    image(images[frame], xpos, ypos); //display current frame
  }
}
