class Button {
  boolean pressed = false;
  
  PVector size;
  PVector position; // the center
  color colour; // fill colour
  String text;
  color textColour;
  int textSize = 65;

  Button(PVector size, PVector centerPosition, color colour) {
    this.size = size;
    position = centerPosition;
    this.colour = colour;
  }

  Button(PVector size, PVector centerPosition, color colour, String text, color textColour) {
    this(size, centerPosition, colour); //calls other constructor
    this.text = text;
    this.textColour = textColour;
  }

  void drawButton() {
    //draw rectangle
    fill(colour);
    rect(position.x-size.x/2, position.y-size.y/2, size.x, size.y); //math because position is the center
    
    if (text != null) { //if any, draw text
      textSize(textSize);
      fill(textColour);
      text(text, position.x-size.x/2, position.y+textSize/2);
    }
    
    if (mouseX/scalePercent > position.x-size.x/2 && mouseX/scalePercent < position.x+size.x/2
     && mouseY/scalePercent > position.y-size.y/2 && mouseY/scalePercent < position.y+size.y/2) { //mouse over button
      if (!pressed && mousePressed) { //if pressed, only run when first pressed
        pressed = true;
      }
      else if (!mousePressed) { //only resets when mouse stopped pressing
        pressed = false;
      }
    }
  }
}
