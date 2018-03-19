public static final int POWERUP = 3;

class wordFall extends minigame
{
  PFont font;
  int fontSize;
  boolean next;
  int oldTime;
  ArrayList<fallingWord> words;
  String currentWord;
  String[] wordChoices;
  int index;
  int counter;
  int status;
  int powerUpTimer;
  public wordFall(int x, int y, int fontSize)
  {
    super(x, y, fontSize);
    this.fontSize = fontSize;
    font = createFont("Consolas", fontSize);
    textFont(font);
    next = false;
    words = new ArrayList<fallingWord>();
    currentWord = "";
    words.add(new fallingWord(rand.nextInt(width-20)+20, 0, "dab", false));
    oldTime = 0;
    wordChoices = loadStrings("1000.txt");
    index = 0;
    counter = 0;
    powerUpTimer = 0;
  }
  public void outputText(car playerCar) {
    if (counter%16==0) {
      boolean special = rand.nextInt(60)<playerCar.streak;
      words.add(new fallingWord(rand.nextInt(width-80), 0, wordChoices[index], special));
      index++;
      if (index == 1000)
        index = 0;
    }
    counter++;

    text(currentWord, playerCar.x, playerCar.y);
    for (int i = words.size()-1; i >= 0; i--) {
      words.get(i).output(fontSize);
      words.get(i).y+=4;
      if (words.get(i).y > height-fontSize) {
        imgHandler.pm.addP(words.get(i).x, words.get(i).y, music.position(), "boom 2");
        playerCar.damage(1);
        words.remove(words.get(i));
      }
    }
    if (status == POWERUP) {
      powerUpTimer++;
      fill(0, 255, 255);
      rect(width-50, 50, 45, 100);
      fill(0, 128, 128);
      rect(width-50, 50, 45, powerUpTimer);
      fill(255);
    }
    if (status == POWERUP && powerUpTimer >=100) {
      status = NOEFFECT;
      currentWord = "";
      playerCar.streak = 0;
    }
  }

  public int tryType(char letter, int code, car playerCar) {
    if (status == POWERUP && words.size() > 1) {
      fallingWord w = words.get(words.size()-1);
      imgHandler.pm.addP(w.x, w.y, music.position(), "boom");
      playerCar.setW(w);
      words.remove(w);
      currentWord = "";
      return CORRECT;
    }
    if (code == SHIFT) return NOEFFECT;
    else if (code == BACKSPACE) {
      if (currentWord.length() > 0)
        currentWord = currentWord.substring(0, currentWord.length()-1);  
      return NOEFFECT;
    } else if (letter == ' ' || letter == ';') {
      for (fallingWord w : words)
        if (w.check(currentWord) || letter == ';') {        
          imgHandler.pm.addP(w.x, w.y, music.position(), "nice");
          playerCar.x = w.x;
          playerCar.setW(w);
          if (w.special) {
            status = POWERUP;
            imgHandler.pm.addP(w.x, w.y, music.position(), "instantType", 2);
            powerUpTimer = 0;
          } else status = CORRECT;
          words.remove(w);
          currentWord = "";
          return status;
        }
      imgHandler.pm.addP(blueCar.x, blueCar.y, music.position(), "wrong");
      currentWord = "";
      return INCORRECT;
    }
    currentWord += Character.toString(letter);
    return NOEFFECT;
  }
}