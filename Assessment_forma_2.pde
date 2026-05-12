// =============================
// Alien Snack Attack - Game (ONE ALIEN VERSION)
// Uses your MyAlien class
// Requires: Sketch -> Import Library -> Sound
// =============================

import processing.sound.*;
import java.util.ArrayList;

// ---------- GAME STATES ----------
final int START_MENU = 0;
final int PLAYING    = 1;
final int GAME_OVER  = 2;
final int WIN        = 3;

int gameState = START_MENU;

// ---------- YOUR ALIEN (ONLY ONE) ----------
MyAlien a1;

// ---------- IMAGES ----------
PImage bgImg;
PImage snackImg;
PImage meteorImg;

// ---------- SOUND ----------
SoundFile music;
SoundFile collectSound;
SoundFile hitSound;

// ---------- GAME OBJECTS ----------
ArrayList<Snack> snacks;
ArrayList<Meteor> meteors;

// ---------- GAME VARIABLES ----------
int score = 0;
int targetScore = 15;
int lives = 3;
int timeLimit = 60000;
int startTime;

// movement flags
boolean leftPressed  = false;
boolean rightPressed = false;
boolean upPressed    = false;
boolean downPressed  = false;


// =============================
// SETTINGS
// =============================
void settings() {
  pixelDensity(1);
  size(800, 500);
}


// =============================
// SETUP
// =============================
void setup() {

  // Load images
  snackImg  = loadImage("fuel.png");
  meteorImg = loadImage("hazard.png");

  // Load sounds safely
  try {
    music        = new SoundFile(this, "game.mp3");
    collectSound = new SoundFile(this, "sound.mp3");
    hitSound     = new SoundFile(this, "weee.mp3");
  } 
  catch(Exception e) {
    println("Sound files missing — using silent mode.");
  }

  // Create alien
  a1 = new MyAlien(width/2, height/2, 1.0);

  // Game objects
  snacks  = new ArrayList<Snack>();
  meteors = new ArrayList<Meteor>();

  for (int i = 0; i < 8; i++) snacks.add(new Snack());
  for (int i = 0; i < 5; i++) meteors.add(new Meteor());
}


// =============================
// DRAW
// =============================
void draw() {

  background(25);

  switch(gameState) {
    case START_MENU:
      drawStartMenu();
      break;

    case PLAYING:
      updateGame();
      drawGame();
      break;

    case GAME_OVER:
      drawGame();
      drawGameOver();
      break;

    case WIN:
      drawGame();
      drawWinScreen();
      break;
  }
}


// =============================
// START MENU
// =============================
void drawStartMenu() {
  fill(0, 180);
  rect(0, 0, width, height);

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(40);
  text("ALIEN SNACK ATTACK", width/2, height/2 - 120);

  textSize(20);
  text("Your alien is hungry! Collect snacks and avoid meteors.",
       width/2, height/2 - 60);

  text("Arrow keys to move", width/2, height/2);

  textSize(22);
  text("Press ENTER to Start", width/2, height/2 + 80);

  a1.display();
}


// =============================
// HUD + GAME DRAW
// =============================
void drawHUD() {
  fill(0, 150);
  rect(0, 0, width, 35);

  fill(255);
  textAlign(LEFT, CENTER);
  text("Score: " + score + "/" + targetScore, 10, 18);
  text("Lives: " + lives, 170, 18);

  int elapsed = millis() - startTime;
  int remaining = max(0, timeLimit - elapsed);
  int seconds = remaining / 1000;

  textAlign(RIGHT, CENTER);
  text("Time: " + seconds + "s", width - 10, 18);
}

void drawGame() {
  for (Snack s : snacks) s.display();
  for (Meteor m : meteors) m.display();

  a1.display();

  drawHUD();
}


// =============================
// GAME OVER & WIN
// =============================
void drawGameOver() {
  fill(0, 180);
  rect(0, 0, width, height);

  fill(255, 80, 80);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("GAME OVER", width/2, height/2 - 40);

  fill(255);
  textSize(20);
  text("Final Score: " + score, width/2, height/2);
  text("Press R to Restart or Q to Quit", width/2, height/2 + 60);
}

void drawWinScreen() {
  fill(0, 180);
  rect(0, 0, width, height);

  fill(80, 255, 80);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("YOU WIN!", width/2, height/2 - 40);

  fill(255);
  textSize(20);
  text("You collected enough snacks!", width/2, height/2);
  text("Final Score: " + score, width/2, height/2 + 30);
  text("Press R to Play Again or Q to Quit", width/2, height/2 + 70);
}


// =============================
// GAME LOGIC
// =============================
void startGame() {
  score = 0;
  lives = 3;
  startTime = millis();

  a1.x = width/2;
  a1.y = height/2;

  snacks.clear();
  meteors.clear();

  for (int i = 0; i < 8; i++) snacks.add(new Snack());
  for (int i = 0; i < 5; i++) meteors.add(new Meteor());

  gameState = PLAYING;

  if (music != null && !music.isPlaying()) music.loop();
}


void updateGame() {
  int elapsed = millis() - startTime;
  if (elapsed >= timeLimit && score < targetScore) {
    stopMusic();
    gameState = GAME_OVER;
    return;
  }

  float moveSpeed = 4;

  a1.speedX = (leftPressed ? -moveSpeed : 0) + (rightPressed ? moveSpeed : 0);
  a1.speedY = (upPressed ? -moveSpeed : 0) + (downPressed ? moveSpeed : 0);
  a1.move();

  float collisionSize = 60;  

  for (Snack s : snacks) {
    s.update();
    if (dist(s.x, s.y, a1.x, a1.y) < collisionSize) {
      s.reset();
      score++;
      if (collectSound != null) collectSound.play();
    }
  }

  for (Meteor m : meteors) {
    m.update();
    if (dist(m.x, m.y, a1.x, a1.y) < collisionSize) {
      m.reset();
      lives--;
      if (hitSound != null) hitSound.play();
      if (lives <= 0) {
        stopMusic();
        gameState = GAME_OVER;
      }
    }
  }

  if (score >= targetScore) {
    stopMusic();
    gameState = WIN;
  }
}

void stopMusic() {
  if (music != null && music.isPlaying()) music.stop();
}


// =============================
// INPUT
// =============================
void keyPressed() {
  if (gameState == START_MENU && keyCode == ENTER) {
    startGame();
    return;
  }

  if (gameState == PLAYING) {
    if (keyCode == LEFT)  leftPressed  = true;
    if (keyCode == RIGHT) rightPressed = true;
    if (keyCode == UP)    upPressed    = true;
    if (keyCode == DOWN)  downPressed  = true;
  }

  if (gameState == GAME_OVER || gameState == WIN) {
    if (key == 'r' || key == 'R') startGame();
    if (key == 'q' || key == 'Q') exit();
  }
}

void keyReleased() {
  if (keyCode == LEFT)  leftPressed  = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (keyCode == UP)    upPressed    = false;
  if (keyCode == DOWN)  downPressed  = false;
}


// =============================
// SNACK CLASS
// =============================
class Snack {
  float x, y;
  float speedY;

  Snack() { reset(); }

  void reset() {
    x = random(40, width - 40);
    y = random(-300, -40);
    speedY = random(2, 4);
  }

  void update() {
    y += speedY;
    if (y > height + 40) reset();
  }

  void display() {
    if (snackImg != null) {
      imageMode(CENTER);
      image(snackImg, x, y, 32, 32);
    } else {
      fill(255, 255, 0);
      ellipse(x, y, 32, 32);
    }
  }
}


// =============================
// METEOR CLASS
// =============================
class Meteor {
  float x, y;
  float speedY;

  Meteor() { reset(); }

  void reset() {
    x = random(40, width - 40);
    y = random(-300, -40);
    speedY = random(3, 6);
  }

  void update() {
    y += speedY;
    if (y > height + 40) reset();
  }

  void display() {
    if (meteorImg != null) {
      imageMode(CENTER);
      image(meteorImg, x, y, 40, 40);
    } else {
      fill(200, 80, 40);
      ellipse(x, y, 40, 40);
    }
  }
}


// =====================================================
// YOUR ORIGINAL MyAlien CLASS — ONLY move() FIXED
// =====================================================
class MyAlien { 
  float x, y, size;
  float speedX, speedY;
  color alienColor;
  int mouthType;
 
  MyAlien(float startX, float startY, float s) { 
    x = startX; 
    y = startY;
    size = s;

    alienColor = color(random(255), random(255), random(255)); 
    mouthType = int(random(3)); 
  } 
 
  void move() { 
    x += speedX;
    y += speedY;

    // KEEP ALIEN IN CANVAS — NO PARAMETER CHANGES
    x = constrain(x, 40, width - 40);
    y = constrain(y, 50, height - 50);
  } 
 
  void display() { 
    pushMatrix();
    translate(x, y);
    scale(size);

    noStroke();
    fill(alienColor);
    ellipse(0, 0, 80, 100);

    fill(255);
    ellipse(-20, -20, 20, 20);
    ellipse(20, -20, 20, 20);

    fill(0);
    ellipse(-20, -20, 8, 8);
    ellipse(20, -20, 8, 8);

    stroke(180); 
    strokeWeight(3);
    line(-20, -50, -30, -70);
    line(20, -50, 30, -70);

    stroke(0);
    strokeWeight(2);
    noFill();
    if (mouthType == 0) arc(0, 20, 30, 15, 0, PI);
    else if (mouthType == 1) arc(0, 35, 30, 15, PI, TWO_PI);
    else line(-15, 30, 15, 30);

    noStroke();
    fill(100);
    ellipse(-25, 55, 20, 10);
    ellipse(25, 55, 20, 10);

    popMatrix();
  } 
}
