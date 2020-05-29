class HomeScene extends Scene {
  HomeBackground background;
  Plane plane;
  Button playButton;
  
  boolean endingScene; //if scene is ending
  
  PImage tutorialImg;
  
  HomeScene() {
    score = 0; //reset score
    backgroundSpeed = 1; //reset background speed
    
    background = new HomeBackground();
    
    plane = new Plane(new PVector(preWidth*0.9, preHeight*0.25));
    playButton = new Button(new PVector(150, 70), new PVector(preWidth/2, min(preHeight-80, preHeight/1.25)), #ffffaa, "Play", #bbbbff);
    
    endingScene = false; //start scene not ending
    
    tutorialImg = loadImage("./res/Tutorial.png"); //load the selected img
    tutorialImg.resize((int) round(preWidth*0.8), (int) round(preHeight*0.8)); //resize image
  }
  
  void drawScene() {
    if (!endingScene) { //run if not ending
      background.drawBackground();
      
      plane.move(new PVector(preWidth*0.75, preHeight*0.25)); //move closer to center
    
      if (playButton.pressed) { // if pressed, start end transition
        endingScene = true;
      }
    }
    else { //end transition
      background.transitionBackground(); //transition the background
      
      //move button off screen
      playButton.position.set(playButton.position.x+1, playButton.position.y-1);
      
      //move plane offscreen
      plane.position.add(-1, 0.5);
      
      //if both plane & button off screen, end the scene
      if (plane.position.y > preHeight && playButton.position.y < 0) endScene = true;
      
      image(tutorialImg, 25, 25); //draw the tutorial image
    }
    
    plane.draw();
    playButton.drawButton();
  }
}

class EndScene extends Scene {
  EndBackground background;
  Button continueButton; //button to continue to HomeScene
  
  Plane plane; //plane from PlayScene
  
  int subScene; //current scene state
  
  float midAlpha;
  
  EndScene(Plane plane, int crumpleImgID) {
    //set local to passed
    this.plane = plane;
    
    background = new EndBackground(crumpleImgID);
    
    continueButton = new Button(new PVector (260, 65), new PVector(preWidth/2, preHeight/1.5), #2b2b2b, "RESTART", #FFFFFF);
    
    //start at transition in sub
    subScene = 1;
    
    midAlpha = 0;
  }
  
  void drawScene() {
    background.drawBackground();
    
    plane.crumple();
    
    /* draw size whole screen
    over plane and background (building) */
    fill(color(0, 0, 0, midAlpha));
    rect(0, 0, preWidth, preHeight);
    
    switch (subScene) {
      case 2: //transition out
        transitionOut();
      break;
      case 1: //transition in
        transitionIn();
      break;
      default: //running
        textSize(50); //big text size
        fill(#FFFFFF); //white colour
        text("Your Score:\n" + score, preWidth*0.25, preHeight*00.25); //draw the text
      
        continueButton.drawButton();
        
        //move to transition out when button pressed
        if (continueButton.pressed) subScene = 2;
    }
  }
  
  void transitionIn() {
    midAlpha = midAlpha+1; // increase alpha
    
    if (midAlpha > 155) subScene = 0; //once in 
  }
  
  void transitionOut() {
    if (midAlpha < 255) midAlpha++; //increase alpha
    
    continueButton.drawButton(); //display button
    continueButton.position.y++; //move out
    if (continueButton.position.y >= preHeight) endScene = true; //when off, endScene
  }
}

class PlayScene extends Scene {
  PlayBackground background;
  
  Button inputAreaButton;
  Terminal terminal;
  
  boolean buttonPressHandled;
  long framePressed = 0;
  
  long countDown;
  
  int subScene;
  
  Plane plane;
  Question currentQuestion;
  
  PlayScene() {
    background = new PlayBackground(); //initialise background
    
    //initialise terminal and background button
    inputAreaButton = new Button(new PVector(200, 250), new PVector(100, 125), color(0, 0, 0, 200));
    terminal = new Terminal();
    
    buttonPressHandled = false; //button not been pressed yet
    
    countDown = answerTimeGiven; //start countdown full
    
    subScene = 1; //start at intro
    
    plane = new Plane(new PVector(preWidth, 0)); //new plane at top-right of screen
    
    terminal.acceptingInput = false; //don't accept terminal input
    askQuestion(); //ask an initial question
  }
  
  void drawScene() {
    if (subScene == 3) background.crumple(); //run the crumple
    else if (subScene != 2) background.drawBackground(); //draw background
    else if (background.transition()) subScene = 3; //transition the scene 
    
    if (subScene != 3) plane.draw(); //it's run in multiple scenes, so out of switch statement, prevent duplicate
    
    switch(subScene) {
      case 3: //game over crumple sub scene
        plane.position.x = background.crumplePos.x; //move with the crumple building
        plane.crumple();
        
        if (abs(background.crumplePos.x-preWidth*0.5) < 2) { //if within 5 of center - horizontal
          endScene = true;
        }
      break;
      case 2: //game over sub scene
        if (plane.position.x > 0) { //move the plane to left-edge, total background relative speed 30
          backgroundSpeed = 20; //background fast
          plane.position.x -= 10; //move plane to edge
        }
        else backgroundSpeed = 30; //plane stopped, relative speed stay same at 30
      break;
      case 1: //pre game sub scene (plane moves into place)
        //move to position. If done, go to the play subScene 
        if (plane.move(new PVector(preWidth*0.9, 25))) subScene = 0;
        break;
      default: //game play sub scene
        //terminal & button handle code
        inputAreaButton.drawButton();
        terminal.drawTerminal();
        
        if (!buttonPressHandled && inputAreaButton.pressed) {
          buttonPressHandled = true; // only run handle once per press
          inputAreaButton.colour = color(25, 25, 25, 200); //brighten
          framePressed = frameCount;
        }
        else if ((frameCount - framePressed)*1000/frameRate > 100) { //keeps the button looking pressed for the same amount of time regardless of framerate, is in milliseconds
          inputAreaButton.colour = color(0, 0, 0, 200); // darken
        }
        
        if (buttonPressHandled && !inputAreaButton.pressed) buttonPressHandled = false;
        
        terminal.acceptingInput = true;
        handleTimer();
        
        //draw score visualisation
        fill(#000000);
        textSize(25);
        text("Score: " + score, 240, 25);
    }
  }
  
  void handleTimer() {
    //temp, testing start
    //fill(#000000);
    //text("" + countDown, 250, 10);
    //text("" + score, 300, 10);
    //temp, testing end
    
    //draws countdown bar
    fill(color(255-255*countDown/answerTimeGiven, 255*countDown/answerTimeGiven, 0, 200)); //change fill colour depending on time left
    rect(200, 250-250*countDown/answerTimeGiven, 25, 250*countDown/answerTimeGiven); //change size depending on time left
    
    if (currentQuestion != null) { //only if question set
      //lower countDown by ms since last second
      countDown -= 1000/frameRate;
      
      if (countDown <= 0) { //game end
        terminal.acceptingInput = false; //don't accept new answers
        
        //print gibberish start
        String gibberish = ""; //to print
        
        // on set strings there's some random character on each side
        if (countDown < -3000) subScene = 2; //end condition (3 seconds)
        else if (countDown < -2000) {
          gibberish = (char) round(random(32, 126)) + " DEATH DEATH DEATH DEATH " + (char) round(random(32, 126));
        }
        else if (countDown < -1500) { //create random string
          for (int char_it = 0; char_it < 25; char_it++) {
            gibberish += (char) round(random(32, 126)); //random character (ascii)
          }
        }
        else if (countDown < -1000) gibberish = (char) round(random(32, 126)) + " GAME OVER GAME OVER " + (char) round(random(32, 126));
        else if (countDown < -500) gibberish = (char) round(random(32, 126)) + " FAIL FAIL FAIL FAIL FAIL FAIL " + (char) round(random(32, 126));
        else { //create random string
          for (int char_it = 0; char_it < 25; char_it++) {
            gibberish += (char) round(random(32, 126)); //random character (ascii)
          }
        }
        
        terminal.addLine(gibberish); //insert the gibberish
        //print gibberish end
        
        backgroundSpeed += 1; //speed up buildings
      }
    }
  }
  
  void askQuestion() {
    int chosenQuestionType;
    
    do {
      chosenQuestionType = round(random(3)); //random question type
    } while ((chosenQuestionType == 1 && score < 1250) //if subtraction & score too low (1250)
    || (chosenQuestionType == 2 && score < 2500) //or if multiplication & score too low (2500)
    || (chosenQuestionType == 3 && score < 5000)); //or if division & score too low (5000)
    
    switch (chosenQuestionType) {
      case 1: //subtraction
        currentQuestion = getSubtractionQuestion((int) max(1, score / 1250));
        break;
      case 2: //multiplication
        currentQuestion = getMultiplicationQuestion((int) max(1, score / 2500));
        break;
      case 3: //division
        currentQuestion = getDivisionQuestion((int) max(1, score / 5000));
        break;
      default: //default is an addition question
        //use max so difficulty is never <1
        currentQuestion = getAdditionQuestion((int) max(1, score / 1000));
    }
    
    terminal.addLine("What is " + currentQuestion.string); //ask the question
  }
  
  void submitAnswer() {
    if (terminal.inputLine == "") return; //don't run if blank
    
    //check answer
    boolean correct = int(terminal.inputLine) == currentQuestion.answer;
    
    //add to score if correct, based on score and time left
    score += correct ? 103+(score/100)*(countDown/answerTimeGiven) : 0;
    
    //add to countDown if answer correct based on time left, max value is answerTimeGiven
    countDown = (long) min(answerTimeGiven, countDown + (correct ? 0.1 : -0.1)*answerTimeGiven);
    if (countDown < 0) countDown = 0;
    
    terminal.submitInput(); //push user input to terminal line
    
    //user feedback
    if (correct) terminal.addLine("Correct Answer!"); //correct answer feedback
    else terminal.addLine("Incorrect, the answer is " + currentQuestion.answer, #ff2222); //incorrect answer feedback (red)
    
    //new question
    askQuestion();
  }
}
