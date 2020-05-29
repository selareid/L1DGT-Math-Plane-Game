HomeScene homeScene;
PlayScene playScene;
EndScene endScene;

int currentScene; //which scene is on
String[] currentSceneToEng = {"Home", "Play", "End"}; //for testing

final long answerTimeGiven = 30000;
final long preWidth = 750;
final long preHeight = 400;
float scalePercent;

float planeSpeed = 0.5;
float defCloudSpeed = 2;
float backgroundSpeed = 1;
long lifeExpectancy = 100; //fire particle life
long score;

void settings() { //setting thing method for using variables for size()
  //set percentage scaled
  scalePercent = min(floor(displayWidth/750), floor(displayHeight/400));
  
  //use scale percent to scale screen size
  size(floor(750*scalePercent), floor(400*scalePercent), FX2D); //FX2D faster renderer
}

void setup() {
  //start on home scene
  currentScene = 0;
  homeScene = new HomeScene();
}

void draw() {
  scale(scalePercent); //scale whole screen
  
  clear();
  background(#FFFFFF);
  
  //println(currentSceneToEng[currentScene]); //testing
  //homeScene.endScene = true; //testing
  
  switch (currentScene) {
    case 2:
      if (!endScene.endScene) endScene.drawScene(); 
      else { //if scene ended move to home scene
        currentScene = 0;
        homeScene = new HomeScene(); //new instance of home scene
      }
    break;
    case 1:
      if (!playScene.endScene) playScene.drawScene();
      else { //if scene ended move to next
        currentScene = 2;
        //new instance of endscene copies plane and building image
        endScene = new EndScene(playScene.plane, playScene.background.crumpled.imgID);
      }
    break;
    default:
      if (!homeScene.endScene) homeScene.drawScene();
      else { //if home scene ended move to running play scene
        currentScene = 1;
        playScene = new PlayScene(); //use new instance of play scene
      }
  }
}

void keyTyped() {
  switch (currentScene) {
    case 0: //home scene
        //if enter key, act as button press
        if (int(key) == 10) homeScene.playButton.pressed = true;
      break;
    case 1: //if currently in playScene
      switch(int(key)) { //the key code in ASCII
        case 10: //enter key
          playScene.submitAnswer();
        break;
        case 8: //backspace key
          playScene.terminal.removeCharFromInput();
        break;
        default: //any other key
          //add key to input
          //only numbers ASCII 48-57
          if (int(key) >= 48 && int(key) <= 57) playScene.terminal.addToInput(key);
      }
      
      break;
    case 2: //end scene
      //if enter key, act as button press
      if (int(key) == 10) endScene.continueButton.pressed = true;
      break;
  }
}
