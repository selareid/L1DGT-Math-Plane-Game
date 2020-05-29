class terminalLine {
  String lineText; //the text
  color lineColour; //text colour 
  
  terminalLine(String text, color colour) {
    //set local to passed
    lineText = text;
    lineColour = colour;
  }
}

class Terminal {
  terminalLine[] onScreenText; //the text on the terminal, each value has text and colour for line
  String inputLine; //where the user input is stored before pushing to onScreenText
  
  boolean acceptingInput; //accept new user input
  
  int textSize = 13;
  color textColour = #00ff00;
  
  int topLine; //the line drawn at the top of the terminal
  
  Terminal() {
    //clear everything
    onScreenText = new terminalLine[18]; //number of terminal lines set here
    inputLine = "";
    topLine = 0;
    //clear everything
    
    acceptingInput = false; //start with no user input enabled
  }
  
  void drawTerminal() {
    //draw start
    fill(textColour);
    textSize(textSize);
    
    boolean termLooped = false;
    
    for (int lineContents_it = topLine;;) { //start looping from the marked 'top'
      terminalLine line = onScreenText[lineContents_it];
      
      if (line != null) { //only draw if not null, else we get an error
        fill(line.lineColour);
        text(line.lineText, 3, (lineContents_it-topLine < 0 ? onScreenText.length-1+lineContents_it-topLine+1 : lineContents_it-topLine) * textSize + textSize);
        //I know that the top-left of the terminal is 0,0
      }
      
      
      lineContents_it = lineContents_it < onScreenText.length-1 ? lineContents_it+1 : 0;
      //if reach the end of the onScreenText array, move to start (0) else continue drawing next in array
      
      if (lineContents_it == topLine-1) termLooped = true; //have we looped over past the end of the array
      
      if ((topLine == 0 && lineContents_it == 0) || (termLooped && lineContents_it > topLine-1)) break; //if we've drawn everything, end the draw loop
    }
    
    text("Input:" + inputLine + (frameCount % 120 > 70 ? " " : "_"), 3, 250-3); //draw input line, space 3 from edges, also, blinking _
  }
  
  void addLine(String contents) {
    addLine(contents, textColour); //call other addLine with default colour
  }
  
  void addLine(String contents, color colour) {
    for (int lineContents_it = 0; lineContents_it < onScreenText.length; lineContents_it++) { //loops over each line
      terminalLine lineContents = onScreenText[lineContents_it];
      
      if (lineContents != null) continue; //if line not empty, continue
      
      onScreenText[lineContents_it] = new terminalLine(contents, colour); //set the line to the contents passed
      return; //if found a line, end the function
    }
    
    //it only gets here if it finds no empty lines
    onScreenText[topLine] = new terminalLine(contents, colour); //sets topLine to contents passed
    topLine = topLine >= onScreenText.length-1 ? 0 : topLine+1; //move topLine down by one, if at bottom reset back to top (0)
  }
  
  
  void addToInput(char inputChar) {
    addToInput("" + inputChar); //convert to string and send to the other addToInput
  }
  
  void addToInput(String inputString) {
    if (inputString != null && acceptingInput
      && inputLine.length() < 18) inputLine += inputString; //checks if "valid" input and if accepting then adds to inputString
  }
  
  void removeCharFromInput() {
    if (inputLine.length() < 1 || !acceptingInput) return; //if nothing to remove, don't. Also if not accepting.
    
    inputLine = inputLine.substring(0, inputLine.length() - 1); //remove one character from the end of the input
  }
  
  void submitInput() { //submits the input from inputLine to a line in the terminal
    if (inputLine == "" || !acceptingInput) return; //check valid input and accepting
    
    addLine(inputLine); //add to the terminal
    inputLine = ""; //reset input
  }
}

class Question {
  String string; //the question to display
  int answer;
  
  Question(String gString, int gAnswer) {
    //sets local values to passed
    string = gString;
    answer = gAnswer;
  }
  
  boolean check(int gAnswer) {
    return answer == gAnswer; //check answer correct
  }
}

Question getAdditionQuestion(int difficulty) {
  //random max operand based on difficulty 
  long maxQuestion = round(10 * difficulty * pow(difficulty, 11/10));
  long minQuestion = 0;
  
  int[] things = new int[3]; //the question & string parts
  things[0] = round(random(minQuestion, maxQuestion)); //first operand
  things[1] = round(random(minQuestion, maxQuestion)); //second operand
  things[2] = things[0] + things[1]; //the question answer
  
  //creates the string and gives the answer
  return new Question(things[0] + "+" + things[1], things[2]);
}

Question getSubtractionQuestion(int difficulty) {
  //random max operand based on difficulty 
  long maxQuestion = round(10 * difficulty * pow(difficulty, 11/10));
  long minQuestion = 1;
  
  int[] things = new int[3]; //the question & string parts
  things[0] = round(random(minQuestion, maxQuestion)); //first operand
  things[1] = round(random(minQuestion, things[0])); //second operand max 1st operand
  things[2] = things[0] - things[1]; //the question answer
  
  //creates the string and gives the answer
  return new Question(things[0] + "-" + things[1], things[2]);
}

Question getMultiplicationQuestion(int difficulty) {
  //random max operand based on difficulty 
  long maxQuestion = round(10 * difficulty);
  long minQuestion = 0;
  
  int[] things = new int[3]; //the question & string parts
  things[0] = round(random(minQuestion, maxQuestion)); //first operand
  things[1] = round(random(minQuestion, maxQuestion)); //second operand
  things[2] = things[0] * things[1]; //the question answer
  
  //creates the string and gives the answer
  return new Question(things[0] + "×" + things[1], things[2]);
}

Question getDivisionQuestion(int difficulty) {
  //random max operand and answer based on difficulty 
  long maxQuestion = round(10 * difficulty);
  long minQuestion = 1;
  
  int[] things = new int[3]; //the question & string parts
  things[0] = round(random(minQuestion, maxQuestion)); //answer
  things[1] = round(random(minQuestion, maxQuestion)); //second operand
  things[2] = things[0] * things[1]; //first operand
  
  //creates the string and gives the answer
  return new Question(things[2] + "÷" + things[1], things[0]);
}
