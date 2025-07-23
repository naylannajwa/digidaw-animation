// Import library Sound
import processing.sound.*;
import processing.core.PApplet; // Import PApplet untuk referensi

// ==================================================================
// == Variabel Global
// ==================================================================

// Objek untuk mengelola subtitle dan audio yang sedang aktif
TimedSubtitle activeSubtitle;

// Deklarasi semua narasi dan dialog menggunakan class TimedSubtitle
TimedSubtitle narasi1, narasi3, narasi5, narasi7, narasi11, narasi13, narasi15;
TimedSubtitle nenek2, nenek4, nenek9;
TimedSubtitle putihPilihLabu, putihTerimaKasih; // putihPamit dihapus karena digabung
TimedSubtitle merahMintaLabu;

// Variabel untuk font
PFont msGothic;

// Variabel untuk animasi
float time = 0;
float bawangPutihX = 1280 + 200; // Start di luar frame kanan
float nenekX = -200; // Start di luar frame kiri
float bawangPutihTargetX = 1280 * 0.65; // Target position (65% dari lebar)
float nenekTargetX = 1280 * 0.45; // Target position (45% dari lebar)
boolean bawangPutihMoving = true;
boolean nenekMoving = true;
float walkSpeed = 5.5f; 
float nenekWalkSpeed = 5.0f;
float bawangMerahX = -200; // Mulai dari luar frame kiri
float bawangMerahTargetX = 320 + 60 - 200; // Posisi target bawang merah, di belakang pohon
boolean bawangMerahMoving = true;
float sneakSpeed = 3.0; // Kecepatan mengendap-endap

// Variabel untuk animasi perspektif Bawang Merah
float bawangMerahScale = 0.5; // Skala awal
float bawangMerahYOffset = 0; // Offset Y awal
float walkForwardProgress = 0.0; // Progres animasi berjalan ke depan

// Variabel untuk Sistem State
float offerProgress = 0.0;
float handoverProgress = 0.0;
float bawangPutihThankProgress = 0.0;
float bawangMerahAppearProgress = 0.0;
float nenekGiveBigPumpkinProgress = 0.0;
float bawangMerahLeaveProgress = 0.0;
float nenekLeaveProgress = 0.0;

// State machine untuk mengontrol alur cerita
int interactionState = 0;
int stateTimer = 0;

// Variabel status kepemilikan labu
boolean smallPumpkinInBawangPutihHand = false;
boolean bigPumpkinInNenekHand = false;
boolean bigPumpkinInBawangMerahHand = false;

// Variabel untuk Bubble Chat (tidak diubah, terpisah dari subtitle utama)
String currentDialog = "";
float dialogAlpha = 0;
int dialogSpeaker = 0; // 0: None, 1: Nenek, 2: Bawang Putih, 3: Bawang Merah


// ==================================================================
// == Class untuk Mengelola Audio & Subtitle
// ==================================================================
class TimedSubtitle {
  SoundFile audio;
  String speaker;
  String[] textParts;
  long[] durations;

  int currentIndex = -1;
  long startTime = 0;
  boolean isPlaying = false;
  boolean isFinished = false;

  String displayedText = "";

  TimedSubtitle(PApplet parent, String audioPath, String speakerName, String[] texts, long[] times) {
    if (audioPath != null && !audioPath.isEmpty()) {
        try {
            audio = new SoundFile(parent, audioPath);
        } catch (Exception e) {
            println("Error loading sound file: " + audioPath);
            e.printStackTrace();
            audio = null;
        }
    }
    speaker = speakerName;
    textParts = texts;
    durations = times;
  }

  void play() {
    if (audio != null && !audio.isPlaying()) {
      audio.play();
    }
    isPlaying = true;
    isFinished = false;
    currentIndex = 0;
    startTime = millis();
  }

  void update() {
    if (!isPlaying || isFinished) return;

    long elapsedTime = millis() - startTime;

    if (currentIndex >= 0 && currentIndex < textParts.length) {
      String currentFullText = textParts[currentIndex];
      long partDuration = durations[currentIndex];
      
      long typingDuration = partDuration - 100;
      if (typingDuration <= 0) typingDuration = partDuration;

      if (elapsedTime < typingDuration && typingDuration > 0) {
        float progress = (float)elapsedTime / (float)typingDuration;
        int charsToShow = (int)(currentFullText.length() * progress);
        
        charsToShow = constrain(charsToShow, 0, currentFullText.length());
        displayedText = currentFullText.substring(0, charsToShow);
      } else {
        displayedText = currentFullText;
      }
    }

    if (currentIndex < durations.length) {
      if (elapsedTime > durations[currentIndex]) {
        currentIndex++;
        startTime = millis(); 
        
        if (currentIndex >= textParts.length) {
          displayedText = "";
        }
      }
    }

    if (currentIndex >= textParts.length) {
        if (audio == null || !audio.isPlaying()) {
            finish();
        }
    }
  }

  void finish() {
    isPlaying = false;
    isFinished = true;
    currentIndex = -1;
  }

  String getDisplayedText() {
    return displayedText;
  }

  String getSpeakerName() {
    return speaker;
  }
}


// ==================================================================
// == Setup & Inisialisasi
// ==================================================================

float easeInOutSine(float x) {
  return -(cos(PI * x) - 1) / 2;
}

void setup() {
  size(1280, 720);
  msGothic = createFont("MS Gothic", 24);
  
  initializeContent();
  
  playSubtitle(narasi1);
}

void initializeContent() {
  narasi1 = new TimedSubtitle(this, "audo_enhanced_narasi_1.mp3", "Narasi",
    new String[] {
      "Setelah dilanda kesedihan, Putih berjalan sendirian di tengah hutan yang sunyi.",
      "Tak lama kemudian, ia berpapasan dengan seorang Nenek tua yang juga sedang menyusuri jalan.",
      "Putih yang baik hati segera membantu Nenek yang terlihat kesulitan membawa keranjangnya."
    },
    new long[] { 5000, 5500, 5500 }
  );

  narasi3 = new TimedSubtitle(this, "audo_enhanced_narasi_3.mp3", "Narasi",
    new String[] {
      "Nenek itu membawa sebuah keranjang berwarna ungu, di dalamnya terdapat dua buah labu: satu labu besar dan satu labu kecil.",
      "Meskipun masih terlihat raut kesedihan di wajahnya, Putih membalas sapaan Nenek dengan senyuman."
    },
    new long[] { 8000, 6000 }
  );
  
  narasi5 = new TimedSubtitle(this, "audo_enhanced_narasi_5.mp3", "Narasi",
    new String[] { "Nenek kemudian menawarkan sebuah labu dan meminta Putih untuk memilih salah satu." },
    new long[] { 5000 }
  );
  
  narasi7 = new TimedSubtitle(this, "audo_enhanced_narasi_7.mp3", "Narasi",
    new String[] {
      "Dengan sikap rendah hati, Putih segera menunjuk labu yang kecil.",
      "Nenek lantas menyodorkan labu kecil tersebut, dan Putih menerimanya."
    },
    new long[] { 4500, 5000 }
  );

  narasi11 = new TimedSubtitle(this, "audo_enhanced_narasi_11.mp3", "Narasi",
    new String[] {
      "Putih pun berlalu dengan hati gembira.",
      "Tanpa disadari mereka, Merah telah mengendap-endap di balik pepohonan sejak awal...",
      "...menguping percakapan dengan penuh rasa penasaran.",
      "Setelah Putih pergi, Merah tiba-tiba muncul di hadapan Nenek dengan cepat."
    },
    new long[] { 3000, 5500, 4500, 5000 }
  );
  
  narasi13 = new TimedSubtitle(this, "audo_enhanced_narasi_13.mp3", "Narasi",
    new String[] {
      "Tanpa basa-basi, ia langsung meminta labu besar dengan nada dan sikap yang tidak sopan.",
      "Nenek terkejut melihat kedatangan Merah yang mendadak.",
      "Dengan perasaan heran atas perilaku kasar Merah, Nenek menyerahkan labu besar tersebut."
    },
    new long[] { 7000, 4500, 6500 }
  );
  
  narasi15 = new TimedSubtitle(this, "audo_enhanced_narasi_15.mp3", "Narasi",
    new String[] {
      "Setelah menerima labu, Merah pergi begitu saja dengan angkuh, tanpa mengucapkan terima kasih atau berpamitan.",
      "Nenek, dengan kesabaran, membawa keranjang kosongnya dan melanjutkan perjalanannya menyusuri hutan."
    },
    new long[] { 8000, 8000 }
  );

  nenek2 = new TimedSubtitle(this, "audo_enhanced_nenek_2.mp3", "Nenek",
    new String[] { "Halo, Nak!" },
    new long[] { 2000 }
  );
  
  nenek4 = new TimedSubtitle(this, "audo_enhanced_nenek_4.mp3", "Nenek",
    new String[] { "Nenek punya 2 buah labu." },
    new long[] { 3000 }
  );
  
  nenek9 = new TimedSubtitle(this, "audo_enhanced_nenek_9.mp3", "Nenek",
    new String[] { "Baik Nak, hati-hati di jalan yaa." },
    new long[] { 3500 }
  );

  putihPilihLabu = new TimedSubtitle(this, "putih-pilih labu.mp3", "Putih",
    new String[] { "Saya pilih labu yang kecil saja, Nek." },
    new long[] { 3500 }
  );
  
  putihTerimaKasih = new TimedSubtitle(this, "putih-terima kasih nek.mp3", "Putih",
    new String[] { "Terima kasih banyak, Nek!", "Saya pamit dulu ya, Nek..." },
    new long[] { 2500, 2500 }
  );

  merahMintaLabu = new TimedSubtitle(this, "Merah_4.1.1.mp3", "Merah",
    new String[] { "Hei Nenek! Berikan labu besar itu padaku!" },
    new long[] { 4000 }
  );
}


// ==================================================================
// == Draw Loop & Update
// ==================================================================

void draw() {
  background(180, 220, 160);  
  time += 0.02;
  
  updateCharacterPositions();
  updateInteractionState();
  updateActiveSubtitle();
  
  drawBackgroundLayer();

  boolean merahDiDepanPohon = (interactionState == 8 || interactionState == 9) || (interactionState == 75 && walkForwardProgress >= 0.5);

  if (merahDiDepanPohon) {
    // Gambar pohon dulu, lalu Bawang Merah di atasnya (di depan)
    drawCoveringTree();
    drawBawangMerahLayer(bawangMerahMoving, interactionState);
  } else {
    // Gambar Bawang Merah dulu, lalu pohon di atasnya (menutupi)
    drawBawangMerahLayer(bawangMerahMoving, interactionState);
    drawCoveringTree();
  }

  drawNenekLayer();
  drawBawangPutihLayer(bawangPutihMoving, interactionState);
  drawBubbleChat();
  drawSubtitleBox();
}

void updateCharacterPositions() {
  if (interactionState == 0 && bawangPutihMoving) {
    bawangPutihX -= walkSpeed;
    if (bawangPutihX <= bawangPutihTargetX) {
      bawangPutihX = bawangPutihTargetX;
      bawangPutihMoving = false;
    }
  }

  if (interactionState == 0 && nenekMoving) {
    nenekX += nenekWalkSpeed;
    if (nenekX >= nenekTargetX) {
      nenekX = nenekTargetX;
      nenekMoving = false;
    }
  }

  if (bawangMerahMoving && interactionState < 6) {  
    bawangMerahX += sneakSpeed;
    if (bawangMerahX >= bawangMerahTargetX) {
      bawangMerahX = bawangMerahTargetX;
      bawangMerahMoving = false;  
    }
  }

  if (interactionState == 5) {
    bawangPutihX -= walkSpeed;
  }
  
  if (interactionState == 9) {
    bawangMerahX -= walkSpeed * 2;  
  }

  if (interactionState == 10) {
    nenekX += nenekWalkSpeed;
  }
}

void updateInteractionState() {
  boolean isSubtitleFinished = (activeSubtitle == null || activeSubtitle.isFinished);

  if (interactionState == 0) {
    if (!nenekMoving && !bawangPutihMoving && isSubtitleFinished) {  
      interactionState = 1;  
      setDialog("Halo, Nak!", 1);  
      playSubtitle(nenek2);
    }
  }
  else if (interactionState == 1) {
    if (isSubtitleFinished) {
      interactionState = 2;  
      playSubtitle(narasi3);
    }
  }  
  else if (interactionState == 2) {
    if (activeSubtitle == nenek4 && offerProgress < 1.0) {
      offerProgress += 0.02; 
    }
    
    if (isSubtitleFinished) {
        if(activeSubtitle == narasi3) {
            setDialog("Nenek punya 2 buah labu", 1);
            playSubtitle(nenek4);
        } else if (activeSubtitle == nenek4) {
            playSubtitle(narasi5);
        } else if (activeSubtitle == narasi5) {
            interactionState = 3;
            setDialog("Saya pilih labu yang kecil saja, Nek.", 2);
            playSubtitle(putihPilihLabu);
        }
    }
  }
  else if (interactionState == 3) {
    if (isSubtitleFinished) {
        if(activeSubtitle == putihPilihLabu) {
            playSubtitle(narasi7);
        } else if (activeSubtitle == narasi7) {
            interactionState = 4;
            clearDialog();
            activeSubtitle = null;
        }
    }
  }
  else if (interactionState == 4) {
    if (handoverProgress < 1.0) {
      handoverProgress += 0.03;
      if (handoverProgress >= 0.5 && !smallPumpkinInBawangPutihHand) {
        smallPumpkinInBawangPutihHand = true;
      }
    } else {
      handoverProgress = 1.0;
      interactionState = 45;
      setDialog("Terima kasih banyak, Nek!", 2);
      playSubtitle(putihTerimaKasih);
    }
  }
  else if (interactionState == 45) {
      if (bawangPutihThankProgress < 1.0) {
          bawangPutihThankProgress += 0.05;
      }
      
      if (activeSubtitle == putihTerimaKasih && activeSubtitle.currentIndex == 1) {
          setDialog("Saya pamit dulu ya, Nek...", 2);
      }

      if (bawangPutihThankProgress >= 1.0 && isSubtitleFinished) {
          bawangPutihThankProgress = 1.0;
          interactionState = 46;
          setDialog("Baik Nak, hati-hati di jalan yaa", 1);
          playSubtitle(nenek9);
      }
  }
  else if (interactionState == 46) {
      if(isSubtitleFinished && activeSubtitle == nenek9) {
          clearDialog();
          activeSubtitle = null;
          interactionState = 5;
      }
  }
  else if (interactionState == 5) {
    if (bawangPutihX < -200) {
      interactionState = 55; // Ganti ke state jeda
      stateTimer = millis();   // Mulai timer untuk jeda
    }
  }
  else if (interactionState == 55) { // State jeda baru
    // Tunggu selama 2.5 detik (2500 milidetik) sebelum Bawang Merah muncul
    if (millis() - stateTimer > 2500) { 
      interactionState = 6;
      bawangMerahMoving = true;  
      playSubtitle(narasi11);
    }
  }
  else if (interactionState == 6) {
    if (bawangMerahMoving) {
      float finalSpotX = nenekX - 180;
      if (bawangMerahX < finalSpotX) {
          bawangMerahX += walkSpeed;
      } else {
          bawangMerahX = finalSpotX;
          bawangMerahMoving = false;
      }
    }
    
    if (!bawangMerahMoving && isSubtitleFinished) {
      interactionState = 7;
      setDialog("Hei Nenek! Berikan labu besar itu padaku!", 3);
      playSubtitle(merahMintaLabu);
    }
  }
  else if (interactionState == 7) {
    if (isSubtitleFinished) {
      clearDialog();
      interactionState = 75;  
      walkForwardProgress = 0.0;  
      bawangMerahMoving = true;  
      playSubtitle(narasi13);
    }
  }
  else if (interactionState == 75) {
    if (walkForwardProgress < 1.0) {
      walkForwardProgress += 0.02;  
      walkForwardProgress = min(walkForwardProgress, 1.0);
      float easedProgress = easeInOutSine(walkForwardProgress);
      float startX = nenekX - 180;
      float startScale = 0.5;
      float startYOffset = 0;
      float targetX = bawangPutihTargetX - 180;  
      float targetScale = 0.8;  
      float initialBottomY = getGrassHeightAt(320) - 45 + (480 * 0.6);
      float targetBottomY = 600;
      float targetYOffset = targetBottomY - initialBottomY;
      bawangMerahX = lerp(startX, targetX, easedProgress);
      bawangMerahScale = lerp(startScale, targetScale, easedProgress);
      bawangMerahYOffset = lerp(startYOffset, targetYOffset, easedProgress);
    }
    
    if (walkForwardProgress >= 1.0 && isSubtitleFinished) {
      bawangMerahMoving = false;
      interactionState = 8;  
      nenekGiveBigPumpkinProgress = 0.0;
      bigPumpkinInNenekHand = false;
      bigPumpkinInBawangMerahHand = false;
      activeSubtitle = null;
    }
  }
  else if (interactionState == 8) {
    if (nenekGiveBigPumpkinProgress < 1.0) {
      nenekGiveBigPumpkinProgress += 0.03;
      if (nenekGiveBigPumpkinProgress >= 0.3 && !bigPumpkinInNenekHand) {
        bigPumpkinInNenekHand = true;
      }
      if (nenekGiveBigPumpkinProgress >= 0.7 && bigPumpkinInNenekHand) {
        bigPumpkinInNenekHand = false;
        bigPumpkinInBawangMerahHand = true;
      }
    } else {
      nenekGiveBigPumpkinProgress = 1.0;
      bigPumpkinInNenekHand = false;
      bigPumpkinInBawangMerahHand = true;
      interactionState = 9;
      bawangMerahMoving = true;  
    }
  }
  else if (interactionState == 9) {
    if (bawangMerahX < -400) {  
      interactionState = 10;  
      clearDialog();
      bigPumpkinInBawangMerahHand = false;  
      bawangMerahMoving = false;  
      playSubtitle(narasi15);
    }
  }
  else if (interactionState == 10) {
    if (nenekX > width + 200 && isSubtitleFinished) {
      activeSubtitle = null;
    }
  }
}

// ==================================================================
// == Fungsi Pengelola Subtitle Baru
// ==================================================================

void playSubtitle(TimedSubtitle sub) {
  if (sub != null) {
    activeSubtitle = sub;
    activeSubtitle.play();
  }
}

void updateActiveSubtitle() {
  if (activeSubtitle != null) {
    activeSubtitle.update();
  }
}

void drawSubtitleBox() {
  if (activeSubtitle == null || !activeSubtitle.isPlaying) {
    return;
  }

  String speakerName = activeSubtitle.getSpeakerName();
  String textToShow = activeSubtitle.getDisplayedText();
  
  pushStyle();
  textFont(msGothic);
  
  fill(245, 245, 240, 230); 
  noStroke();
  rectMode(CORNER);
  float boxHeight = 95;
  float yPos = height - boxHeight;
  rect(0, yPos, width, boxHeight);

  textSize(18);
  float labelPadding = 8;
  float labelWidth = textWidth(speakerName) + labelPadding * 2;
  float labelHeight = 26;
  float labelX = 35;
  float labelY = yPos - labelHeight;
  
  color nameTagColor = color(60, 60, 60);
  if (speakerName.equals("Nenek")) {
    nameTagColor = color(139, 195, 74);
  } else if (speakerName.equals("Putih")) {
    nameTagColor = color(120, 180, 220);
  } else if (speakerName.equals("Merah")) {
    nameTagColor = color(219, 112, 147);
  }
  
  fill(nameTagColor); 
  rect(labelX, labelY, labelWidth, labelHeight, 5, 5, 0, 0);

  fill(255);
  textAlign(CENTER, CENTER);
  text(speakerName, labelX + labelWidth / 2, labelY + labelHeight / 2);

  fill(20, 20, 20); 
  textAlign(LEFT, TOP);
  textSize(24);
  text(textToShow, 40, yPos + 20, width - 80, boxHeight - 30);
  
  popStyle();
}


// ==================================================================
// == Fungsi Dialog Bubble (Telah Diubah)
// ==================================================================

void setDialog(String text, int speaker) {
  if (dialogSpeaker != speaker) {
    dialogAlpha = 0;
  }
  currentDialog = text;
  dialogSpeaker = speaker;
}

void clearDialog() {
  dialogSpeaker = 0;
}

void drawBubbleChat() {
  if (dialogSpeaker != 0) {  
    if (dialogAlpha < 255) {
      dialogAlpha += 25;
      if (dialogAlpha > 255) dialogAlpha = 255;
    }
  } else {  
    if (dialogAlpha > 0) {
      dialogAlpha -= 25;
      if (dialogAlpha < 0) {
        dialogAlpha = 0;
        currentDialog = "";  
      }
    }
  }

  if (dialogAlpha > 0 && currentDialog.length() > 0) {
    float charX = 0;
    float headTopY = 0;
    String speakerName = "";
    color nameTagColor = color(0);

    switch (dialogSpeaker) {
      case 1: // Nenek
        charX = nenekX;
        headTopY = (600 - 480) + (300 - 150);
        speakerName = "Nenek";
        nameTagColor = color(139, 195, 74);
        break;
      case 2: // Bawang Putih
        charX = bawangPutihX;
        headTopY = (600 - 480) + (300 - 135);
        speakerName = "Putih";
        nameTagColor = color(120, 180, 220);
        break;
      case 3: // Bawang Merah
        charX = bawangMerahX;
        float bawangMerahBottomY = getGrassHeightAt(320) - 45 + (480 * 0.6);
        headTopY = ((bawangMerahBottomY - 480) + bawangMerahYOffset) + (300 - 135);
        speakerName = "Merah";
        nameTagColor = color(219, 112, 147);
        break;
      default:
        return;
    }

    textFont(msGothic);
    float cornerRadius = 10;

    textSize(18); 
    float hPadding = 20;
    float vPadding = 15;
    float textWidthVal = textWidth(currentDialog);
    float bubbleWidth = textWidthVal + hPadding * 2;
    float bubbleHeight = 20 + vPadding * 2;

    textSize(16);
    float nameTagWidth = textWidth(speakerName) + 20;
    float nameTagHeight = 28;

    float bubbleY = headTopY - (bubbleHeight / 2) - 10;
    float bubbleX = charX;
    
    float nameTagX = bubbleX - (bubbleWidth / 2) + (nameTagWidth / 2);
    float nameTagY = bubbleY - (bubbleHeight / 2) - (nameTagHeight / 2) + 5;

    pushStyle();
    
    fill(255, 255, 255, dialogAlpha);
    stroke(200, 200, 200, dialogAlpha);
    strokeWeight(2);
    rectMode(CENTER);
    rect(bubbleX, bubbleY, bubbleWidth, bubbleHeight, cornerRadius);

    noStroke();
    fill(255, 255, 255, dialogAlpha);
    float tailBaseY = bubbleY + bubbleHeight / 2;
    beginShape();
    vertex(bubbleX - 10, tailBaseY);
    vertex(bubbleX + 10, tailBaseY);
    vertex(bubbleX, tailBaseY + 10);
    endShape(CLOSE);
    
    stroke(200, 200, 200, dialogAlpha);
    strokeWeight(2);
    line(bubbleX - 10, tailBaseY, bubbleX + 10, tailBaseY);
    
    fill(nameTagColor, dialogAlpha);
    noStroke();
    rect(nameTagX, nameTagY, nameTagWidth, nameTagHeight, cornerRadius);

    fill(255, dialogAlpha);
    textSize(16);
    textAlign(CENTER, CENTER);
    text(speakerName, nameTagX, nameTagY);
    
    fill(20, 20, 20, dialogAlpha);
    textSize(18);
    textAlign(LEFT, CENTER);
    text(currentDialog, bubbleX - (bubbleWidth/2) + hPadding, bubbleY);
    
    popStyle();
  }
}


// ==================================================================
// == SISA KODE GAMBAR KARAKTER & LATAR BELAKANG (TIDAK DIUBAH)
// ==================================================================

void drawBackgroundLayer() {
  drawSkyWithLighting();
  drawForestLayers();
  drawNaturalGrassLayer();
  drawStaticSoilLayer();
  drawStaticFlowerLayer();
  drawStaticDecorations();
}

void drawNenekLayer() {
  float roadEndY = 600;
  float nenekBottomY = roadEndY;

  pushMatrix();
  translate(nenekX - 200, nenekBottomY - 480);
  scale(0.8);
  drawNenek(nenekMoving, interactionState);
  popMatrix();
}

void drawNenek(boolean isMoving, int currentState) {
  float cx = 200, cy = 300;
  float currentArmX = cx + 25;
  float currentArmY = cy + 45;
  float currentArmRotation = -PI / 9;
  float nenekBodyLean = 0;
  float nenekEyeShiftX = 0;
  float offerPush = 0;
  
  float struggleBob = 0;
  float struggleSway = 0;

  if (isMoving && currentState == 0) {
      struggleBob = sin(time * 6) * 2;
      struggleSway = cos(time * 4) * 3;
  }

  float legOffset = 0;
  if (isMoving && currentState <= 0) {
    float amplitude = 15;
    float frequency = 15;
    legOffset = amplitude * sin(time * frequency);
  } else if (currentState == 10) {
    float amplitude = 15;
    float frequency = 15;
    legOffset = amplitude * sin(time * frequency);
  }

  if (currentState >= 1) {
    nenekEyeShiftX = 4;
    
    if (currentState == 2) {
      offerPush = easeInOutSine(offerProgress) * 45;
    } else if (currentState == 3) {
      offerPush = 45; 
    }  
    else if (currentState == 4 || currentState == 45 || currentState == 46 || currentState == 47 || currentState == 48) {
      float handoverEased = easeInOutSine(handoverProgress);
      float normalArmX = cx + 25;
      float normalArmY = cy + 45;
      float normalArmRotation = -PI / 9;
      float extendedArmX = cx + 25 + 35;
      float extendedArmY = cy + 45 - 8;
      float extendedArmRotation = -PI / 12;

      if (handoverProgress <= 0.5) {
        float progress = map(handoverProgress, 0.0, 0.5, 0.0, 1.0);
        float easedProgress = easeInOutSine(progress);
        currentArmX = lerp(normalArmX, extendedArmX, easedProgress);
        currentArmY = lerp(normalArmY, extendedArmY, easedProgress);
        currentArmRotation = lerp(normalArmRotation, extendedArmRotation, easedProgress);
        nenekBodyLean = lerp(0, 5, easedProgress);
      } else {
        float progress = map(handoverProgress, 0.5, 1.0, 0.0, 1.0);
        float easedProgress = easeInOutSine(progress);
        currentArmX = lerp(extendedArmX, normalArmX, easedProgress);
        currentArmY = lerp(extendedArmY, normalArmY, easedProgress);
        currentArmRotation = lerp(extendedArmRotation, normalArmRotation, easedProgress);
        nenekBodyLean = lerp(5, 0, easedProgress);
      }
      
      float tremorStrength = (1.0 - abs(handoverProgress - 0.5) * 2);
      float tremor = sin(time * 25) * 1 * tremorStrength;
      currentArmX += tremor;
      currentArmY += tremor * 0.5;

    } else if (currentState == 8) {
      float giveBigEased = easeInOutSine(nenekGiveBigPumpkinProgress);
      float normalArmX = cx + 25;
      float normalArmY = cy + 45;
      float normalArmRotation = -PI / 9;
      float extendedArmX = cx + 25 + 20;
      float extendedArmY = cy + 45 - 5;
      float extendedArmRotation = -PI / 10;

      if (nenekGiveBigPumpkinProgress <= 0.5) {
        float progress = map(nenekGiveBigPumpkinProgress, 0.0, 0.5, 0.0, 1.0);
        float easedProgress = easeInOutSine(progress);
        currentArmX = lerp(normalArmX, extendedArmX, easedProgress);
        currentArmY = lerp(normalArmY, extendedArmY, easedProgress);
        currentArmRotation = lerp(normalArmRotation, extendedArmRotation, easedProgress);
        nenekBodyLean = lerp(0, 3, easedProgress);
      } else {
        float progress = map(nenekGiveBigPumpkinProgress, 0.5, 1.0, 0.0, 1.0);
        float easedProgress = easeInOutSine(progress);
        currentArmX = lerp(extendedArmX, normalArmX, easedProgress);
        currentArmY = lerp(extendedArmY, normalArmY, easedProgress);
        currentArmRotation = lerp(extendedArmRotation, normalArmRotation, easedProgress);
        nenekBodyLean = lerp(3, 0, easedProgress);
      }
    }
  }

  pushMatrix(); 
  translate(struggleSway, struggleBob);

  fill(220, 220, 220, 100);
  noStroke();
  ellipse(cx, cy + 180, 140, 30);
  fill(255, 220, 190);
  stroke(139, 69, 19);
  strokeWeight(3);
  ellipse(cx - 30 + legOffset, cy + 160, 30, 40);
  ellipse(cx + 30 - legOffset, cy + 160, 30, 40);

  pushMatrix();
  translate(nenekBodyLean, 0);
  fill(139, 195, 74);
  stroke(76, 175, 80);
  strokeWeight(4);
  beginShape();
  vertex(cx, cy + 20);
  bezierVertex(cx + 80, cy + 25, cx + 90, cy + 70, cx + 85, cy + 110);
  bezierVertex(cx + 75, cy + 135, cx + 55, cy + 145, cx + 25, cy + 150);
  bezierVertex(cx + 8, cy + 153, cx - 8, cy + 153, cx - 25, cy + 150);
  bezierVertex(cx - 55, cy + 145, cx - 75, cy + 135, cx - 85, cy + 110);
  bezierVertex(cx - 90, cy + 70, cx - 80, cy + 25, cx, cy + 20);
  endShape(CLOSE);
  stroke(56, 142, 60);
  strokeWeight(2);
  noFill();
  line(cx, cy + 25, cx, cy + 145);
  beginShape();
  vertex(cx - 22, cy + 27);
  bezierVertex(cx - 50, cy + 45, cx - 60, cy + 80, cx - 55, cy + 120);
  bezierVertex(cx - 50, cy + 135, cx - 35, cy + 145, cx - 22, cy + 145);
  endShape();
  beginShape();
  vertex(cx + 22, cy + 27);
  bezierVertex(cx + 50, cy + 45, cx + 60, cy + 80, cx + 55, cy + 120);
  bezierVertex(cx + 50, cy + 135, cx + 35, cy + 145, cx + 22, cy + 145);
  endShape();
  beginShape();
  vertex(cx - 10, cy + 26);
  bezierVertex(cx - 28, cy + 40, cx - 32, cy + 75, cx - 28, cy + 115);
  bezierVertex(cx - 25, cy + 135, cx - 18, cy + 145, cx - 10, cy + 145);
  endShape();
  beginShape();
  vertex(cx + 10, cy + 26);
  bezierVertex(cx + 28, cy + 40, cx + 32, cy + 75, cx + 28, cy + 115);
  bezierVertex(cx + 25, cy + 135, cx + 18, cy + 145, cx + 10, cy + 145);
  endShape();
  popMatrix();

  pushMatrix();
  if (currentState == 4 || currentState == 45 || currentState == 46 || currentState == 47 || currentState == 48) {
    translate(currentArmX, currentArmY);
    rotate(currentArmRotation);
    if (handoverProgress < 0.8) {
      drawLenganNenekMenyerahkan(0, 0, false);
    } else {
      drawLenganNenek(0, 0, false);
    }
  } else if (currentState == 8) {
    translate(currentArmX, currentArmY);
    rotate(currentArmRotation);
    if (nenekGiveBigPumpkinProgress < 0.8) {
      drawLenganNenekMenyerahkan(0, 0, false);
    } else {
      drawLenganNenek(0, 0, false);
    }
  } else {
    translate(offerPush, 0);
    translate(cx + 25, cy + 45);
    rotate(-PI / 9);
    drawLenganNenek(0, 0, false);
  }
  popMatrix();
  
  pushMatrix();
  translate(offerPush, 0);  
  translate(cx - 25, cy + 45);
  rotate(PI / 9);
  drawLenganNenek(0, 0, true);
  popMatrix();

  pushMatrix();
  translate(nenekBodyLean, 0);
  fill(139, 195, 74);
  stroke(76, 175, 80);
  strokeWeight(4);
  beginShape();
  vertex(cx, cy + 25);
  bezierVertex(cx + 110, cy + 25, cx + 100, cy - 70, cx, cy - 150);
  bezierVertex(cx - 100, cy - 70, cx - 110, cy + 25, cx, cy + 25);
  endShape(CLOSE);
  stroke(56, 142, 60);
  strokeWeight(2);
  bezierLineNenek(cx, cy + 20, cx, cy - 70, cx, cy - 145);
  bezierLineNenek(cx - 25, cy + 22, cx - 40, cy - 50, cx - 15, cy - 125);
  bezierLineNenek(cx + 25, cy + 22, cx + 40, cy - 50, cx + 15, cy - 125);
  bezierLineNenek(cx - 35, cy + 23, cx - 75, cy - 40, cx - 35, cy - 110);
  bezierLineNenek(cx + 35, cy + 23, cx + 75, cy - 40, cx + 35, cy - 110);

  fill(255, 220, 190);
  stroke(139, 69, 19);
  strokeWeight(4);
  beginShape();
  vertex(cx, cy - 85);
  bezierVertex(cx + 42, cy - 88, cx + 55, cy - 45, cx + 53, cy - 15);
  bezierVertex(cx + 50, cy + 5, cx + 25, cy + 15, cx, cy + 15);
  bezierVertex(cx - 25, cy + 15, cx - 50, cy + 5, cx - 53, cy - 15);
  bezierVertex(cx - 55, cy - 45, cx - 42, cy - 88, cx, cy - 85);  
  endShape(CLOSE);

  fill(245, 245, 245);
  stroke(180, 180, 180);
  strokeWeight(1.5);
  ellipse(cx - 35, cy - 72, 18, 22);
  ellipse(cx - 42, cy - 62, 15, 18);
  ellipse(cx - 38, cy - 50, 12, 15);
  ellipse(cx - 45, cy - 55, 14, 16);
  ellipse(cx - 32, cy - 58, 10, 12);
  ellipse(cx - 28, cy - 68, 13, 16);
  ellipse(cx - 48, cy - 68, 12, 14);
  ellipse(cx + 35, cy - 72, 18, 22);
  ellipse(cx + 42, cy + 62, 15, 18);
  ellipse(cx + 38, cy - 50, 12, 15);
  ellipse(cx + 45, cy - 55, 14, 16);
  ellipse(cx + 32, cy - 58, 10, 12);
  ellipse(cx + 28, cy - 68, 13, 16);
  ellipse(cx + 48, cy - 68, 12, 14);
  ellipse(cx - 15, cy - 80, 12, 15);
  ellipse(cx + 15, cy - 80, 12, 15);
  ellipse(cx, cy - 84, 16, 12);
  ellipse(cx - 8, cy - 76, 10, 12);
  ellipse(cx + 8, cy - 76, 10, 12);
  ellipse(cx - 22, cy - 75, 11, 13);
  ellipse(cx + 22, cy - 75, 11, 13);
  ellipse(cx - 25, cy - 82, 9, 11);
  ellipse(cx + 25, cy - 82, 9, 11);
  ellipse(cx - 12, cy - 85, 8, 10);
  ellipse(cx + 12, cy - 85, 8, 10);
  ellipse(cx - 50, cy - 58, 11, 13);
  ellipse(cx + 50, cy - 58, 11, 13);
  ellipse(cx - 44, cy - 72, 9, 11);
  ellipse(cx + 44, cy - 72, 9, 11);

  stroke(200, 160, 120);
  strokeWeight(0.8);
  line(cx - 15, cy - 65, cx - 5, cy - 67);
  line(cx + 5, cy - 67, cx + 15, cy - 65);
  line(cx - 32, cy - 58, cx - 28, cy - 54);
  line(cx + 32, cy - 58, cx + 28, cy - 54);
  fill(255);
  stroke(139, 69, 19);
  strokeWeight(3);
  ellipse(cx - 18, cy - 55, 35, 30);
  ellipse(cx + 18, cy - 55, 35, 30);
  fill(255, 255, 255, 200);
  noStroke();
  ellipse(cx - 18, cy - 55, 31, 26);
  ellipse(cx + 18, cy - 55, 31, 26);
  fill(255);
  noStroke();
  ellipse(cx - 18, cy - 55, 20, 16);
  ellipse(cx + 18, cy - 55, 20, 16);
  fill(80, 60, 40);
  ellipse(cx - 18 + nenekEyeShiftX, cy - 55, 8, 6);
  ellipse(cx + 18 + nenekEyeShiftX, cy - 55, 8, 6);
  fill(255);
  ellipse(cx - 16 + nenekEyeShiftX, cy - 57, 2, 2);
  ellipse(cx + 20 + nenekEyeShiftX, cy - 57, 2, 2);
  stroke(139, 69, 19);
  strokeWeight(3);
  line(cx - 2, cy - 55, cx + 2, cy - 55);
  line(cx - 36, cy - 55, cx - 42, cy - 53);
  line(cx + 36, cy - 55, cx + 42, cy - 53);
  stroke(220, 220, 220);
  strokeWeight(2);
  noFill();
  arc(cx - 18, cy - 65, 20, 6, 0, PI);
  arc(cx + 18, cy - 65, 20, 6, 0, PI);
  fill(255, 182, 193, 150);
  noStroke();
  ellipse(cx - 30, cy - 35, 24, 18);
  ellipse(cx + 30, cy - 35, 24, 18);
  noFill();
  stroke(160, 90, 90);
  strokeWeight(1.5);
  
  if (currentState == 1) { 
    arc(cx, cy - 25, 20, 12, 0, PI);
  } else if (currentState == 4 || currentState == 45 || currentState == 46 || currentState == 47 || currentState == 48) {
    arc(cx, cy - 25, 15, 8, 0, PI);
  } else if (currentState == 7 || currentState == 75) {
    ellipse(cx, cy - 22, 10, 10);
  } else if (currentState == 8 || currentState == 9 || currentState == 10) {
    line(cx - 6, cy - 25, cx + 6, cy - 25);
  } else {
    arc(cx, cy - 25, 12, 8, 0, PI);
  }
  
  strokeWeight(0.8);
  stroke(200, 160, 120);
  arc(cx - 22, cy - 28, 6, 4, 0, PI);
  arc(cx + 22, cy - 28, 6, 4, 0, PI);

  fill(154, 205, 50);
  stroke(107, 142, 35);
  strokeWeight(3);
  drawDaunNenek(cx, cy - 145);
  popMatrix();

  pushMatrix();
  translate(offerPush, 0);

  if (currentState == 8 || currentState == 9 || currentState == 10) {
    drawKeranjangKosong(cx, cy + 75);
  }
  else if (currentState < 4) {
    drawKeranjangDanLabu(cx, cy + 75);
  }
  else {
    drawKeranjangDanLabuSetelahPenyerahan(cx, cy + 75);
  }
  
  popMatrix();
  
  if (currentState == 4 && handoverProgress < 0.5) {
    pushMatrix();
    translate(currentArmX, currentArmY);
    rotate(currentArmRotation);
    drawLabuKecilDiTangan(8, 20);
    popMatrix();
  }

  if (bigPumpkinInNenekHand) {
      pushMatrix();
      float pumpkinStartLocalX = cx;
      float pumpkinStartLocalY = cy + 50;
      float pumpkinTargetLocalX = currentArmX + 8;
      float pumpkinTargetLocalY = currentArmY + 20;
      float currentPumpkinX = 0;
      float currentPumpkinY = 0;

      if (nenekGiveBigPumpkinProgress < 0.5) {
          float progress = map(nenekGiveBigPumpkinProgress, 0.3, 0.5, 0.0, 1.0);
          progress = constrain(progress, 0, 1);
          currentPumpkinX = lerp(pumpkinStartLocalX, pumpkinTargetLocalX, easeInOutSine(progress));
          currentPumpkinY = lerp(pumpkinStartLocalY, pumpkinTargetLocalY, easeInOutSine(progress));
      } else {
          currentPumpkinX = pumpkinTargetLocalX;
          currentPumpkinY = pumpkinTargetLocalY;
      }

      translate(currentPumpkinX, currentPumpkinY);
      rotate(currentArmRotation);
      drawLabu(0, 0, 70, 255);
      popMatrix();
  }
  popMatrix(); 
}

void drawLenganNenekMenyerahkan(float x, float y, boolean kiri) {
  fill(255, 220, 190);
  stroke(139, 69, 19);
  beginShape();
  vertex(x, y);
  bezierVertex(x + (kiri ? -25 : 25), y - 5, x + (kiri ? -35 : 35), y + 8, x + (kiri ? -30 : 30), y + 25);
  bezierVertex(x + (kiri ? -30 : 30), y + 40, x + (kiri ? -25 : 25), y + 50, x + (kiri ? -12 : 12), y + 48);
  bezierVertex(x + (kiri ? -6 : 6), y + 42, x, y + 25, x, y);
  endShape(CLOSE);
}

void drawLabuKecilDiTangan(float x, float y) {
  pushMatrix();
  translate(x, y);
  drawLabu(0, 0, 35, 255);
  popMatrix();
}

void drawKeranjangDanLabuSetelahPenyerahan(float cx, float cy) {
  float itemX = cx;
  float itemY = cy;
  drawBibirKeranjang(itemX, itemY - 15);
  drawLabu(itemX, itemY - 25, 70, 255);
  drawBadanKeranjang(itemX, itemY - 15);
}

void drawKeranjangKosong(float cx, float cy) {
  float itemX = cx;
  float itemY = cy;
  drawBibirKeranjang(itemX, itemY - 15);
  drawBadanKeranjang(itemX, itemY - 15);
}


void drawKeranjangDanLabu(float cx, float cy) {
  float itemX = cx;
  float itemY = cy;
  drawBibirKeranjang(itemX, itemY - 15);
  drawLabu(itemX, itemY - 25, 70, 255);
  drawBadanKeranjang(itemX, itemY - 15);
  drawLabu(itemX, itemY - 55, 45, 255);
}

void drawBawangPutihLayer(boolean isMoving, int currentState) {
  float roadEndY = 600;
  float charBottomY = roadEndY;
  pushMatrix();
  translate(bawangPutihX - 200, charBottomY - 480);
  scale(0.8);
  drawBawangPutih(isMoving, currentState);
  popMatrix();
}

void drawBawangPutih(boolean isMoving, int currentState) {
  float cx = 200, cy = 300;
  float legOffset = 0;
  if ((isMoving && currentState == 0) || currentState == 5) {
    float amplitude = 15;
    float frequency = 15;
    legOffset = amplitude * sin(time * frequency);
  }

  float thankArmOffset = 0;
  if (currentState == 45) {
    float thankEased = easeInOutSine(bawangPutihThankProgress);
    thankArmOffset = lerp(0, 5, thankEased);  
  }

  fill(220, 220, 220, 100);
  noStroke();
  ellipse(cx, cy + 180, 140, 30);
  fill(255, 220, 190);
  stroke(139, 69, 19);
  strokeWeight(3);
  ellipse(cx - 30 + legOffset, cy + 160, 35, 45);
  ellipse(cx + 30 - legOffset, cy + 160, 35, 45);
  
  pushMatrix();
  translate(cx, cy);  

  fill(245, 245, 235);
  stroke(160, 140, 120);
  strokeWeight(4);
  beginShape();
  vertex(0, 20);
  bezierVertex(90, 30, 100, 80, 95, 120);
  bezierVertex(85, 140, 60, 150, 30, 155);
  bezierVertex(10, 158, -10, 158, -30, 155);
  bezierVertex(-60, 150, -85, 140, -95, 120);
  bezierVertex(-100, 80, -90, 30, 0, 20);
  endShape(CLOSE);
  stroke(190, 180, 160);
  strokeWeight(2);
  noFill();
  line(0, 25, 0, 155);
  beginShape();
  vertex(-25, 30);
  bezierVertex(-60, 50, -70, 90, -65, 130);
  bezierVertex(-60, 145, -40, 150, -25, 155);
  endShape();
  beginShape();
  vertex(25, 30);
  bezierVertex(60, 50, 70, 90, 65, 130);
  bezierVertex(60, 145, 40, 150, 25, 155);
  endShape();
  beginShape();
  vertex(-12, 28);
  bezierVertex(-35, 45, -40, 85, -35, 125);
  bezierVertex(-30, 145, -20, 150, -12, 155);
  endShape();
  beginShape();
  vertex(12, 28);
  bezierVertex(35, 45, 40, 85, 35, 125);
  bezierVertex(30, 145, 20, 150, 12, 155);
  endShape();

  fill(255, 220, 190);
  stroke(139, 69, 19);
  
  if (currentState == 4 || currentState == 45 || currentState == 46 || currentState == 47 || currentState == 48) {
    pushMatrix();
    translate(60, 50 + thankArmOffset);
    rotate(-PI / 6);
    drawLenganMenerima(0, 0, false);
    popMatrix();
  } else {
    drawLengan(60, 50, false);  
  }

  if (currentState == 3) {  
    pushMatrix();
    translate(-60, 50);  
    rotate(PI / 1.8);  
    drawLenganMenunjuk(0, 0, true);  
    popMatrix();
  } else if (currentState == 4 || currentState == 45 || currentState == 46 || currentState == 47 || currentState == 48 || currentState == 5) {  
    pushMatrix();
    translate(-60, 50 + thankArmOffset);  
    rotate(PI / 9);
    drawLengan(0, 0, true);  
    popMatrix();
  } else {
    drawLengan(-60, 50, true);  
  }

  fill(245, 245, 235);
  stroke(160, 140, 120);
  strokeWeight(4);
  beginShape();
  vertex(0, 30);
  bezierVertex(130, 30, 120, -60, 0, -135);
  bezierVertex(-120, -60, -130, 30, 0, 30);
  endShape(CLOSE);
  stroke(190, 180, 160);
  strokeWeight(2);
  bezierLineBawang(0, 25, 0, -60, 0, -130);
  bezierLineBawang(-30, 25, -50, -40, -18, -120);
  bezierLineBawang(30, 25, 50, -40, 18, -120);
  bezierLineBawang(-40, 28, -90, -30, -45, -100);
  bezierLineBawang(40, 28, 90, -30, 45, -100);

  pushMatrix();
  translate(0, 0);
  fill(255, 240, 220);
  stroke(160, 140, 120);
  strokeWeight(4);
  beginShape();
  vertex(0, -80);
  bezierVertex(50, -85, 70, -40, 65, -10);
  bezierVertex(60, 10, 30, 20, 0, 20);
  bezierVertex(-30, 20, -60, 10, -65, -10);
  bezierVertex(-70, -40, -50, -85, 0, -80);
  endShape(CLOSE);

  float eyeShiftX = 0;
  float eyeShiftY = 0;  
  
  boolean isSad = (currentState < 2) || (currentState == 2 && activeSubtitle == narasi3);

  if (!isSad) {
    eyeShiftX = -4;
  }
  
  if (isMoving && currentState == 0) {
    eyeShiftY = 2;
  }
  
  noStroke();
  fill(101, 67, 33);
  ellipse(-22 + eyeShiftX, -50 + eyeShiftY, 8, 10);
  ellipse(22 + eyeShiftX, -50 + eyeShiftY, 8, 10);

  if (isSad) {
    stroke(101, 67, 33);
    strokeWeight(2);
    line(-15, -58, -28, -55);
    line(15, -58, 28, -55);
    noFill();
    stroke(139, 69, 19);
    strokeWeight(2);
    arc(0, -25, 25, 12, PI, TWO_PI);
  } else {
    stroke(101, 67, 33);
    strokeWeight(2);
    line(-15, -58, -28, -58);
    line(15, -58, 28, -58);
    
    noFill();
    stroke(139, 69, 19);
    strokeWeight(2);
    switch (currentState) {
      case 2:  
        arc(0, -22, 15, 10, PI * 0.2, PI * 0.8);  
        break;
      case 3:  
        arc(0, -25, 25, 15, 0, PI);  
        break;
      case 4:  
        arc(0, -25, 30, 18, 0, PI);  
        break;
      case 45:  
      case 46:  
      case 47:  
      case 48:  
        arc(0, -25, 30, 18, 0, PI);
        break;
      case 5:  
        arc(0, -25, 25, 12, 0, PI);  
        break;
      default:  
        line(-12, -20, 12, -20);
        break;
    }
  }
  
  noStroke();
  fill(255, 182, 193, 150);
  ellipse(-35, -35, 20, 12);
  ellipse(35, -35, 20, 12);

  popMatrix();  
  popMatrix();  

  fill(154, 205, 50);
  stroke(107, 142, 35);
  strokeWeight(3);
  drawDaun(cx, cy - 130);
  
  if ((currentState == 4 || currentState == 45 || currentState == 46 || currentState == 47 || currentState == 48 || currentState == 5) && smallPumpkinInBawangPutihHand) {
    pushMatrix();
    translate(cx - 60, cy + 50 + thankArmOffset);  
    rotate(PI / 9);  
    drawLabuKecilDiTanganBawangPutih(5, 18);  
    popMatrix();
  }
}

void drawLenganMenerima(float x, float y, boolean kiri) {
  beginShape();
  vertex(x, y);
  bezierVertex(x + (kiri ? -25 : 25), y - 8, x + (kiri ? -35 : 35), y + 5, x + (kiri ? -30 : 30), y + 22);
  bezierVertex(x + (kiri ? -32 : 32), y + 38, x + (kiri ? -28 : 28), y + 48, x + (kiri ? -15 : 15), y + 50);
  bezierVertex(x + (kiri ? -8 : 8), y + 45, x, y + 25, x, y);
  endShape(CLOSE);
}

void drawLabuKecilDiTanganBawangPutih(float x, float y) {
  pushMatrix();
  translate(x, y);
  drawLabu(0, 0, 30, 255);  
  popMatrix();
}


void drawBawangMerahLayer(boolean isMoving, int currentState) {
  float treeX = 320;
  float bawangMerahBottomY = getGrassHeightAt(treeX) - 45 + (480 * 0.6);
  pushMatrix();
  translate(bawangMerahX, (bawangMerahBottomY - 480) + bawangMerahYOffset);
  scale(bawangMerahScale);
  drawBawangMerah(isMoving, currentState);
  popMatrix();
}

void drawBawangMerah(boolean isMoving, int currentState) {
  float cx = 200, cy = 300;  
  float bodyBob = 0, legYOffset = 0, legXOffset = 0;
  
  boolean isWalkingHorizontally = isMoving && (currentState < 6 || currentState == 6 || currentState == 9);

  if (isWalkingHorizontally) {
      if (currentState < 6) { // Menyelinap
          float sneakCycle = sin(time * 6.0);
          legXOffset = sneakCycle * 6;
          bodyBob = map(sin(time * 6.0 + PI/2), -1, 1, 0, 3);
      } else { // Berjalan (state 6 dan 9)
          float moveCycle = sin(time * 8.0);
          legYOffset = map(moveCycle, -1, 1, -5, 10);
          legXOffset = moveCycle * 8;
          bodyBob = map(sin(time * 8.0 + PI/2), -1, 1, 0, 5);
      }
  }

  float eyeShiftX = 0;
  if (currentState < 7) {  
    int timeSegment = int(time * 2) % 10;
    if (timeSegment < 4) eyeShiftX = -3;
    else if (timeSegment < 8) eyeShiftX = 3;
  } else if (currentState == 7 || currentState == 75) {  
    eyeShiftX = -4;  
  }

  pushMatrix();
  translate(cx, cy);

  fill(220, 220, 220, 100);
  noStroke();
  ellipse(0, 180, 140, 30);  
  fill(255, 220, 190);
  stroke(139, 69, 19);
  strokeWeight(3);
  ellipse(-30 - legXOffset, 160 + legYOffset, 35, 45);
  ellipse(30 + legXOffset, 160 + legYOffset - (legYOffset/2), 35, 45);
  
  pushMatrix();
  translate(0, bodyBob);  
  
  // ==================================================================
  // == PERBAIKAN KODE: ROTASI BADAN BAWANG MERAH
  // ==================================================================
  // Efek rotasi (condong) pada badan Bawang Merah dihilangkan sesuai permintaan.
  if ((currentState == 6 && isMoving) || currentState == 75) {
      float leanAmount = 15;  
      translate(leanAmount, 0);  
      // rotate(radians(leanAmount/2)); // Baris ini dinonaktifkan
  }
  // ==================================================================
  // == AKHIR PERBAIKAN KODE
  // ==================================================================

  fill(216, 112, 147);
  stroke(139, 69, 19);
  strokeWeight(4);
  beginShape();
  vertex(0, 20);  
  bezierVertex(90, 30, 100, 80, 95, 120);
  bezierVertex(85, 140, 60, 150, 30, 155);
  bezierVertex(10, 158, -10, 158, -30, 155);
  bezierVertex(-60, 150, -85, 140, -95, 120);
  bezierVertex(-100, 80, -90, 30, 0, 20);
  endShape(CLOSE);
  stroke(180, 80, 115);
  strokeWeight(2);
  noFill();
  line(0, 25, 0, 155);
  beginShape();
  vertex(-25, 30);
  bezierVertex(-60, 50, -70, 90, -65, 130);
  bezierVertex(-60, 145, -40, 150, -25, 155);
  endShape();
  beginShape();
  vertex(25, 30);
  bezierVertex(60, 50, 70, 90, 65, 130);
  bezierVertex(60, 145, 40, 150, 25, 155);
  endShape();
  beginShape();
  vertex(-12, 28);
  bezierVertex(-35, 45, -40, 85, -35, 125);
  bezierVertex(-30, 145, -20, 150, -12, 155);
  endShape();
  beginShape();
  vertex(12, 28);
  bezierVertex(35, 45, 40, 85, 35, 125);
  bezierVertex(30, 145, 20, 150, 12, 155);
  endShape();
  popMatrix();  

  fill(255, 220, 190);
  stroke(139, 69, 19);

  if (currentState == 8) {
      pushMatrix();
      translate(-60, 50);  
      float receiveProgress = map(nenekGiveBigPumpkinProgress, 0.7, 1.0, 0.0, 1.0);
      receiveProgress = constrain(receiveProgress, 0, 1);
      float armRotation = lerp(PI/9, PI/4, easeInOutSine(receiveProgress));  
      float armYOffset = lerp(0, 10, easeInOutSine(receiveProgress));  
      
      translate(0, armYOffset);
      rotate(armRotation);
      drawLenganMerahMenerima(0, 0, true);  
      popMatrix();
  } else {
      drawLenganMerah(-60, 50, true);
  }

  if (currentState == 8) {
      pushMatrix();
      translate(60, 50);  
      float receiveProgress = map(nenekGiveBigPumpkinProgress, 0.7, 1.0, 0.0, 1.0);
      receiveProgress = constrain(receiveProgress, 0, 1);
      float armRotation = lerp(-PI/9, -PI/4, easeInOutSine(receiveProgress));  
      float armYOffset = lerp(0, 10, easeInOutSine(receiveProgress));  
      
      translate(0, armYOffset);
      rotate(armRotation);
      drawLenganMerahMenerima(0, 0, false);  
      popMatrix();
  } else {
      drawLenganMerah(60, 50, false);
  }
  
  fill(216, 112, 147);
  stroke(139, 69, 19);
  strokeWeight(4);
  beginShape();
  vertex(0, 30);
  bezierVertex(130, 30, 120, -60, 0, -135);
  bezierVertex(-120, -60, -130, 30, 0, 30);
  endShape(CLOSE);
  stroke(180, 80, 115);
  strokeWeight(2);
  noFill();
  bezierLineMerah(0, 25, 0, -60, 0, -130);
  bezierLineMerah(-30, 25, -50, -40, -18, -120);
  bezierLineMerah(30, 25, 50, -40, 18, -120);
  bezierLineMerah(-40, 28, -90, -30, -45, -100);
  
  fill(255, 220, 190);
  stroke(139, 69, 19);
  strokeWeight(4);
  beginShape();
  vertex(0, -80);
  bezierVertex(50, -85, 70, -40, 65, -10);
  bezierVertex(60, 10, 30, 20, 0, 20);
  bezierVertex(-30, 20, -60, 10, -65, -10);
  bezierVertex(-70, -40, -50, -85, 0, -80);
  endShape(CLOSE);
  
  noStroke();
  fill(101, 67, 33);
  ellipse(-22 + eyeShiftX, -50, 6, 8);
  ellipse(22 + eyeShiftX, -50, 6, 8);
  stroke(101, 67, 33);
  strokeWeight(3);
  line(-30, -60, -18, -55);
  line(18, -55, 30, -60);
  noFill();
  stroke(139, 69, 19);
  strokeWeight(2);

  if (currentState == 7 || currentState == 75) {  
    arc(0, -25, 20, 10, PI, TWO_PI);
  } else if (currentState == 9) {  
    arc(0, -25, 25, 15, 0, PI);
  } else {  
    beginShape();
    vertex(-10, -22);
    bezierVertex(0, -28, 10, -22, 15, -22);
    endShape();
  }

  fill(154, 205, 50);
  stroke(107, 142, 35);
  strokeWeight(3);
  drawDaunMerah(0, -130);  
  popMatrix();  

  if (bigPumpkinInBawangMerahHand) {
      pushMatrix();
      float pumpkinReceiveX = cx;  
      float pumpkinReceiveY = cy + 50 + 15;  

      float transferProgress = map(nenekGiveBigPumpkinProgress, 0.7, 1.0, 0.0, 1.0);
      transferProgress = constrain(transferProgress, 0, 1);

      float currentSize = lerp(0, 70, easeInOutSine(transferProgress));
      float currentAlpha = lerp(0, 255, easeInOutSine(transferProgress));

      translate(pumpkinReceiveX, pumpkinReceiveY);
      float bob = sin(time * 10) * 1;
      translate(0, bob);
      drawLabu(0, 0, currentSize, currentAlpha);  
      popMatrix();
  }
}

void drawLenganMerahMenerima(float x, float y, boolean kiri) {
  beginShape();
  vertex(x, y);
  bezierVertex(x + (kiri ? -30 : 30), y - 8, x + (kiri ? -45 : 45), y + 10, x + (kiri ? -40 : 40), y + 30);
  bezierVertex(x + (kiri ? -42 : 42), y + 45, x + (kiri ? -35 : 35), y + 55, x + (kiri ? -20 : 20), y + 50);
  bezierVertex(x + (kiri ? -10 : 10), y + 40, x, y + 25, x, y);
  endShape(CLOSE);
}

void bezierLineNenek(float x1, float y1, float x2, float y2, float x3, float y3) {
  noFill();
  beginShape();
  vertex(x1, y1);
  bezierVertex(x2, y2, x2, y2 + 40, x3, y3);
  endShape();
}

void bezierLineBawang(float x1, float y1, float x2, float y2, float x3, float y3) {
  noFill();
  beginShape();
  vertex(x1, y1);
  bezierVertex(x2, y2, x2, y2 + 40, x3, y3);
  endShape();
}

void bezierLineMerah(float x1, float y1, float x2, float y2, float x3, float y3) {
  noFill();
  beginShape();
  vertex(x1, y1);
  bezierVertex(x2, y2, x2, y2 + 40, x3, y3);
  endShape();
}

void drawLengan(float x, float y, boolean kiri) {
  beginShape();
  vertex(x, y);
  bezierVertex(x + (kiri ? -20 : 20), y - 5, x + (kiri ? -30 : 30), y + 5, x + (kiri ? -25 : 25), y + 20);
  bezierVertex(x + (kiri ? -25 : 25), y + 35, x + (kiri ? -20 : 20), y + 45, x + (kiri ? -10 : 10), y + 40);
  bezierVertex(x + (kiri ? -5 : 5), y + 35, x, y + 20, x, y);
  endShape(CLOSE);
}

void drawLenganMenunjuk(float x, float y, boolean kiri) {
  beginShape();
  vertex(x, y);
  bezierVertex(x + (kiri ? -20 : 20), y - 5, x + (kiri ? -30 : 30), y + 5, x + (kiri ? -25 : 25), y + 20);
  bezierVertex(x + (kiri ? -28 : 28), y + 35, x + (kiri ? -25 : 25), y + 50, x + (kiri ? -15 : 15), y + 55);  
  bezierVertex(x + (kiri ? -5 : 5), y + 35, x, y + 20, x, y);
  endShape(CLOSE);
}

void drawDaun(float x, float y) {
  stroke(107, 142, 30);
  strokeWeight(4);
  line(x, y, x, y - 50);
  noStroke();
  fill(154, 205, 50);
  beginShape();
  vertex(x, y - 40);
  bezierVertex(x - 10, y - 55, x - 25, y - 60, x - 30, y - 45);
  bezierVertex(x - 20, y - 50, x - 10, y - 45, x, y - 40);
  endShape(CLOSE);
  beginShape();
  vertex(x, y - 40);
  bezierVertex(x + 10, y - 55, x + 25, y - 60, x + 30, y - 45);
  bezierVertex(x + 20, y - 50, x + 10, y - 45, x, y - 40);
  endShape(CLOSE);
}

void drawLenganNenek(float x, float y, boolean kiri) {
  fill(255, 220, 190);  
  stroke(139, 69, 19);  
  beginShape();
  vertex(x, y);
  bezierVertex(x + (kiri ? -18 : 18), y - 3, x + (kiri ? -25 : 25), y + 8, x + (kiri ? -22 : 22), y + 22);
  bezierVertex(x + (kiri ? -22 : 22), y + 32, x + (kiri ? -18 : 18), y + 40, x + (kiri ? -8 : 8), y + 38);
  bezierVertex(x + (kiri ? -4 : 4), y + 32, x, y + 18, x, y);
  endShape(CLOSE);
}

void drawLenganMerah(float x, float y, boolean kiri) {
  beginShape();
  vertex(x, y);
  bezierVertex(x + (kiri ? -20 : 20), y - 5, x + (kiri ? -30 : 30), y + 5, x + (kiri ? -25 : 25), y + 20);
  bezierVertex(x + (kiri ? -25 : 25), y + 35, x + (kiri ? -20 : 20), y + 45, x + (kiri ? -10 : 10), y + 40);
  bezierVertex(x + (kiri ? -5 : 5), y + 35, x, y + 20, x, y);
  endShape(CLOSE);
}

void drawDaunMerah(float x, float y) {
  stroke(107, 142, 30);
  strokeWeight(4);
  line(x, y, x, y - 50);
  noStroke();
  fill(154, 205, 50);
  beginShape();
  vertex(x, y - 40);
  bezierVertex(x - 10, y - 55, x - 25, y - 60, x - 30, y - 45);
  bezierVertex(x - 20, y - 50, x - 10, y - 45, x, y - 40);
  endShape(CLOSE);
  beginShape();
  vertex(x, y - 40);
  bezierVertex(x + 10, y - 55, x + 25, y - 60, x + 30, y - 45);
  bezierVertex(x + 20, y - 50, x + 10, y - 45, x, y - 40);
  endShape(CLOSE);
}

void drawDaunNenek(float x, float y) {
  stroke(76, 100, 25);
  strokeWeight(5);
  line(x, y, x, y - 40);
  noStroke();
  fill(120, 180, 40);
  beginShape();
  vertex(x, y - 30);
  bezierVertex(x - 8, y - 50, x - 15, y - 70, x - 12, y - 85);
  bezierVertex(x - 8, y - 95, x - 4, y - 100, x - 2, y - 105);
  bezierVertex(x - 1, y - 100, x - 3, y - 95, x - 5, y - 85);
  bezierVertex(x + 8, y - 70, x + 4, y - 50, x, y - 30);
  endShape(CLOSE);
  beginShape();
  vertex(x, y - 30);
  bezierVertex(x + 8, y - 50, x + 15, y - 70, x + 12, y - 85);
  bezierVertex(x + 8, y - 95, x + 4, y - 100, x + 2, y - 105);
  bezierVertex(x + 1, y - 100, x + 3, y - 95, x + 5, y - 85);
  bezierVertex(x + 8, y - 70, x + 4, y - 50, x, y - 30);
  endShape(CLOSE);
  beginShape();
  vertex(x, y - 35);
  bezierVertex(x - 3, y - 60, x - 5, y - 80, x - 3, y - 100);
  bezierVertex(x - 1, y - 110, x + 1, y - 110, x + 3, y - 100);
  bezierVertex(x + 5, y - 80, x + 3, y - 60, x, y - 35);
  endShape(CLOSE);
  stroke(90, 140, 30);
  strokeWeight(1);
  line(x - 6, y - 45, x - 8, y - 85);
  line(x - 3, y - 50, x - 4, y - 95);
  line(x + 6, y - 45, x + 8, y - 85);
  line(x + 3, y - 50, x + 4, y - 95);
  line(x, y - 40, x, y - 105);
}

void drawBadanKeranjang(float x, float y) {
  pushMatrix();
  translate(x, y);
  color keranjangFill = color(126, 87, 194);
  color keranjangStroke = color(94, 65, 156);
  strokeWeight(4);
  stroke(keranjangStroke);
  fill(keranjangFill);
  beginShape();
  vertex(-55, -10);
  bezierVertex(-50, 40, 50, 40, 55, -10);
  quadraticVertex(0, 10, -55, -10);
  endShape();
  popMatrix();
}

void drawBibirKeranjang(float x, float y) {
  pushMatrix();
  translate(x, y);
  color keranjangFill = color(126, 87, 194);
  color keranjangStroke = color(94, 65, 156);
  strokeWeight(4);
  stroke(keranjangStroke);
  fill(keranjangFill);
  ellipse(0, -10, 114, 22);
  popMatrix();
}

void drawLabu(float x, float y, float size, float alpha) {  
  pushMatrix();
  translate(x, y);
  color labuFill = color(255, 140, 0, alpha);  
  color labuStroke = color(220, 100, 0, alpha);  
  strokeWeight(2.5);
  stroke(labuStroke);
  fill(labuFill);
  ellipse(0, 0, size, size * 0.9);
  noFill();
  strokeWeight(2);
  arc(0, 0, size * 0.7, size * 0.9, -HALF_PI, HALF_PI);
  arc(0, 0, size * 0.7, size * 0.9, HALF_PI, PI + HALF_PI);
  arc(0, 0, size * 0.3, size * 0.9, -HALF_PI, HALF_PI);
  arc(0, 0, size * 0.3, size * 0.9, HALF_PI, PI + HALF_PI);
  fill(34, 139, 34, alpha);  
  stroke(20, 80, 20, alpha);  
  strokeWeight(1.5);
  rectMode(CENTER);
  rect(0, -size * 0.45, size * 0.1, size * 0.15);
  rectMode(CORNER);
  popMatrix();
}

void drawSkyWithLighting() {
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    color c = lerpColor(color(180, 220, 160), color(120, 180, 120), inter);
    stroke(c);
    line(0, y, width, y);
  }
  for (int i = 0; i < 200; i++) {
    float x = random(0, width * 0.6);
    float y = random(0, height * 0.4);
    float alpha = random(20, 60);
    fill(255, 255, 200, alpha);
    noStroke();
    ellipse(x, y, random(5, 15), random(5, 15));
  }
  for (int i = 0; i < 50; i++) {
    float x = random(0, width * 0.4);
    float y = random(0, height * 0.3);
    float alpha = random(10, 30);
    fill(255, 255, 180, alpha);
    ellipse(x, y, random(20, 40), random(20, 40));
  }
}

void drawForestLayers() {
  fill(25, 70, 50);
  noStroke();
  beginShape();
  vertex(0, 280);
  for (int x = 0; x <= width; x += 20) {
    float y = 280 + sin(x * 0.01) * 30 + random(-20, 20);
    vertex(x, y);
  }
  vertex(width, 0);
  vertex(0, 0);
  endShape(CLOSE);
  fill(35, 85, 60);
  beginShape();
  vertex(0, 320);
  for (int x = 0; x <= width; x += 15) {
    float y = 320 + sin(x * 0.008) * 25 + cos(x * 0.012) * 15 + random(-15, 15);
    vertex(x, y);
  }
  vertex(width, 0);
  vertex(0, 0);
  endShape(CLOSE);
  drawIndividualTrees();
}

void drawIndividualTrees() {
  drawAnimatedTreeWithClouds(150, getGrassHeightAt(150), 1.6, 0.5);
  drawAnimatedTreeWithClouds(520, getGrassHeightAt(520), 1.7, -0.2);
  drawAnimatedTreeWithClouds(800, getGrassHeightAt(800), 1.5, 0.8);
  drawAnimatedTreeWithClouds(980, getGrassHeightAt(980), 1.9, 0.1);
  drawAnimatedTreeWithClouds(1150, getGrassHeightAt(1150), 1.4, -0.5);
}

void drawAnimatedTreeWithClouds(float x, float y, float scale, float timeOffset) {
  pushMatrix();
  translate(x, y);
  float swayAngle = sin((time * 0.6) + timeOffset) * 0.02;
  rotate(swayAngle);
  scale(scale);
  noStroke(); // Menghilangkan outline dari pohon
  fill(40, 25, 15);
  beginShape();
  vertex(-12, 0);
  vertex(-9, -25);
  vertex(-6, -50);
  vertex(-4, -75);
  vertex(-3, -100);
  vertex(3, -100);
  vertex(4, -75);
  vertex(6, -50);
  vertex(9, -25);
  vertex(12, 0);
  endShape(CLOSE);
  fill(45, 30, 20);
  ellipse(-18, -50, 9, 4);
  ellipse(15, -55, 8, 4);
  ellipse(-12, -70, 6, 3);
  ellipse(10, -75, 6, 3);
  ellipse(-8, -85, 5, 2);
  ellipse(6, -90, 5, 2);
  drawAnimatedCloudyLeaves(0, -120, 1.3, timeOffset);
  popMatrix();
}

void drawCoveringTree() {
  float treeX = 320;
  float treeY = 380;
  pushMatrix();
  translate(treeX, treeY);
  float swayAngle = sin((time * 0.6) + 1.0) * 0.025;
  rotate(swayAngle);
  scale(1.8, 2.2);
  noStroke(); // Menghilangkan outline dari pohon
  fill(40, 25, 15);
  beginShape();
  vertex(-15, 0);
  vertex(-12, -30);
  vertex(-10, -60);
  vertex(-8, -90);
  vertex(-5, -120);
  vertex(5, -120);
  vertex(8, -90);
  vertex(10, -60);
  vertex(12, -30);
  vertex(15, 0);
  endShape(CLOSE);
  drawAnimatedCloudyLeaves(0, -130, 1.2, 1.0);
  popMatrix();
}

void drawAnimatedCloudyLeaves(float centerX, float centerY, float leafScale, float timeOffset) {
  float windX = sin((time * 1.5) + timeOffset) * 4;
  float windY = cos((time * 2.0) + timeOffset) * 2;
  pushMatrix();
  translate(windX, windY);
  fill(25, 70, 35);
  drawCloudShape(centerX, centerY + 8, 100 * leafScale, 80 * leafScale);
  fill(40, 90, 50);
  drawCloudShape(centerX - 15, centerY, 90 * leafScale, 70 * leafScale);
  drawCloudShape(centerX + 12, centerY - 8, 85 * leafScale, 65 * leafScale);
  fill(60, 120, 70);
  drawCloudShape(centerX - 8, centerY - 12, 70 * leafScale, 55 * leafScale);
  drawCloudShape(centerX + 18, centerY - 15, 65 * leafScale, 50 * leafScale);
  fill(80, 140, 90);
  drawCloudShape(centerX + 8, centerY - 22, 45 * leafScale, 35 * leafScale);
  drawCloudShape(centerX - 22, centerY - 18, 40 * leafScale, 30 * leafScale);
  fill(70, 130, 80);
  drawCloudShape(centerX + 25, centerY - 5, 35 * leafScale, 28 * leafScale);
  drawCloudShape(centerX - 30, centerY + 2, 38 * leafScale, 30 * leafScale);
  drawCloudShape(centerX, centerY - 28, 42 * leafScale, 32 * leafScale);
  popMatrix();
}

void drawCloudShape(float x, float y, float w, float h) {
  pushMatrix();
  translate(x, y);
  ellipse(0, 0, w * 0.6, h * 0.6);
  ellipse(-w * 0.25, h * 0.1, w * 0.5, h * 0.5);
  ellipse(w * 0.25, h * 0.1, w * 0.5, h * 0.5);
  ellipse(-w * 0.15, -h * 0.2, w * 0.4, h * 0.4);
  ellipse(w * 0.15, -h * 0.2, w * 0.4, h * 0.4);
  ellipse(0, -h * 0.25, w * 0.45, h * 0.45);
  ellipse(-w * 0.2, h * 0.25, w * 0.35, h * 0.35);
  ellipse(w * 0.2, h * 0.25, w * 0.35, h * 0.35);
  popMatrix();
}

float getGrassHeightAt(float x) {
  return 350 + sin(x * 0.005) * 20 + cos(x * 0.008) * 15 + sin(x * 0.003) * 10;
}

void drawNaturalGrassLayer() {
  fill(85, 150, 60);
  noStroke();
  beginShape();
  vertex(0, height);
  vertex(0, 450);
  for (int x = 0; x <= width; x += 10) {
    float y = 350 + sin(x * 0.005) * 20 + cos(x * 0.008) * 15 + sin(x * 0.003) * 10;
    vertex(x, y);
  }
  vertex(width, 450);
  vertex(width, height);
  endShape(CLOSE);
  fill(100, 170, 75);
  beginShape();
  vertex(0, height);
  vertex(0, 460);
  for (int x = 0; x <= width; x += 10) {
    float y = 360 + sin(x * 0.005) * 18 + cos(x * 0.008) * 12 + sin(x * 0.003) * 8;
    vertex(x, y);
  }
  vertex(width, 460);
  vertex(width, height);
  endShape(CLOSE);
  drawStaticGrassTexture();
}

void drawStaticGrassTexture() {
  for (int i = 0; i < 100; i++) {
    float x = (i * 47 + 123) % width;
    float baseY = 350 + sin(x * 0.005) * 20 + cos(x * 0.008) * 15 + sin(x * 0.003) * 10;
    if (i % 4 == 0) {
      fill(70, 130, 50);
    } else if (i % 4 == 1) {
      fill(90, 150, 65);
    } else if (i % 4 == 2) {
      fill(110, 170, 80);
    } else {
      fill(80, 140, 55);
    }
    float h = (i * 13 + 67) % 20 + 15;
    drawStaticGrassBlade(x, baseY, h);
  }
}

void drawStaticGrassBlade(float x, float y, float h) {
  strokeWeight((int)(x + h) % 3 + 1);
  stroke(90, 150, 70);
  noFill();
  float bend1 = sin(x * 0.01) * 2;
  float bend2 = cos(x * 0.008) * 3;
  float bend3 = sin(x * 0.006) * 4;
  beginShape();
  vertex(x, y);
  bezierVertex(x + bend1, y - h * 0.3,
               x + bend2, y - h * 0.7,
               x + bend3, y - h);
  endShape();
  noStroke();
}

void drawStaticSoilLayer() {
  fill(120, 85, 45);
  noStroke();
  rect(0, 430, width, 170);
  fill(140, 100, 60);
  for (int i = 0; i < 60; i++) {
    float x = (i * 123 + 456) % width;
    float y = 430 + ((i * 78 + 234) % 170);
    float size = (i * 34 + 123) % 20 + 5;
    ellipse(x, y, size, size * 0.6);
  }
  fill(100, 70, 35);
  for (int i = 0; i < 80; i++) {
    float x = (i * 87 + 345) % width;
    float y = 430 + ((i * 56 + 189) % 170);
    float size = (i * 23 + 78) % 9 + 3;
    ellipse(x, y, size, size * 0.8);
  }
  stroke(90, 60, 30);
  strokeWeight(0.5);
  for (int i = 0; i < 17; i++) {
    float y = 430 + i * 10;
    for (int x = 0; x < width; x += 20) {
      float nextX = x + 20;
      float nextY = y + sin(x * 0.01 + i) * 1;
      line(x, y, nextX, nextY);
      y = nextY;
    }
  }
  noStroke();
}

void drawStaticFlowerLayer() {
  fill(40, 80, 35);
  noStroke();
  beginShape();
  vertex(0, height);
  vertex(0, 580);
  for (int x = 0; x <= width; x += 8) {
    float y = 580 + sin(x * 0.02) * 5;
    vertex(x, y);
  }
  vertex(width, height);
  endShape(CLOSE);
  drawStaticNaturalFlowers();
  drawStaticSmallGrass();
}

void drawStaticNaturalFlowers() {
  randomSeed(0);
  for (int i = 0; i < 15; i++) {
    float x = random(50, width - 50);
    float y = random(590, 660);
    drawDetailedFlower(x, y, color(255, 255, 255), color(255, 255, 100), 6);
  }
  for (int i = 0; i < 10; i++) {
    float x = random(50, width - 50);
    float y = random(595, 665);
    drawDetailedFlower(x, y, color(255, 80, 80), color(255, 200, 100), 5);
  }
  for (int i = 0; i < 8; i++) {
    float x = random(50, width - 50);
    float y = random(600, 670);
    drawDetailedFlower(x, y, color(80, 150, 255), color(255, 255, 200), 4);
  }
  fill(255, 220, 80);
  for (int i = 0; i < 20; i++) {
    float x = random(50, width - 50);
    float y = random(595, 665);
    float size = random(2, 5);
    ellipse(x, y, size, size);
  }
}

void drawDetailedFlower(float x, float y, color petalColor, color centerColor, int numPetals) {
  fill(petalColor);
  for (int i = 0; i < numPetals; i++) {
    float angle = i * TWO_PI / numPetals;
    float petalSize = 6 + (i % 4) + 1;
    pushMatrix();
    translate(x, y);
    rotate(angle);
    beginShape();
    vertex(0, 0);
    bezierVertex(-petalSize/3, -petalSize/2, -petalSize/4, -petalSize, 0, -petalSize);
    bezierVertex(petalSize/4, -petalSize, petalSize/3, -petalSize/2, 0, 0);
    endShape(CLOSE);
    popMatrix();
  }
  fill(centerColor);
  float centerSize = 3 + (int)(x + y) % 3;
  ellipse(x, y, centerSize, centerSize);
}

void drawStaticSmallGrass() {
  for (int i = 0; i < 150; i++) {
    float x = (i * 67 + 234) % width;
    float y = 580 + ((i * 89 + 345) % 100);
    fill(50, 90, 40, 180);
    strokeWeight(1);
    stroke(50, 90, 40);
    noFill();
    float h = 8 + (i % 12) + 1;
    float bend1 = sin(x * 0.01) * 2;
    float bend2 = cos(x * 0.008) * 3;
    float bend3 = sin(x * 0.006) * 4;
    beginShape();
    vertex(x, y);
    bezierVertex(x + bend1, y - h * 0.3,
                 x + bend2, y - h * 0.7,
                 x + bend3, y - h);
    endShape();
  }
  noStroke();
}

void drawStaticDecorations() {
  drawStaticNaturalRocks();
  drawStaticNaturalLogs();
}

void drawStaticNaturalRocks() {
  float leftGrassY1 = getGrassHeightAt(150);
  float leftGrassY2 = getGrassHeightAt(170);
  float leftGrassY3 = getGrassHeightAt(130);
  fill(120, 120, 130);
  drawStaticNaturalRock(150, leftGrassY1 + 15, 40, 25);
  drawStaticNaturalRock(170, leftGrassY2 + 12, 35, 20);
  drawStaticNaturalRock(130, leftGrassY3 + 18, 30, 18);
  float rightGrassY1 = getGrassHeightAt(1100);
  float rightGrassY2 = getGrassHeightAt(1130);
  float rightGrassY3 = getGrassHeightAt(1080);
  drawStaticNaturalRock(1100, rightGrassY1 + 14, 45, 28);
  drawStaticNaturalRock(1130, rightGrassY2 + 16, 38, 22);
  drawStaticNaturalRock(1080, rightGrassY3 + 20, 32, 20);
}

void drawStaticNaturalRock(float x, float y, float w, float h) {
  fill(100, 100, 110);
  beginShape();
  for (int i = 0; i < 12; i++) {
    float angle = i * TWO_PI / 12;
    float radius = (w + h) / 4;
    float variation = 0.7 + ((i * 37 + (int)x + (int)y) % 60) / 100.0;
    float px = x + cos(angle) * radius * variation;
    float py = y + sin(angle) * radius * variation * 0.6;
    vertex(px, py);
  }
  endShape(CLOSE);
  fill(140, 140, 150);
  ellipse(x - w/6, y - h/4, w/3, h/4);
  fill(80, 80, 90);
  ellipse(x + w/6, y + h/4, w/4, h/6);
}

void drawStaticNaturalLogs( ) {
  float leftLogY = getGrassHeightAt(200);
  drawStaticNaturalLog(200, leftLogY + 20, 80, 15);
  float rightLogY = getGrassHeightAt(1000);
  drawStaticNaturalLog(1000, rightLogY + 25, 75, 18);
}

void drawStaticNaturalLog(float x, float y, float w, float h) {
  fill(100, 65, 35);
  beginShape();
  vertex(x - w/2, y - h/2);
  bezierVertex(x - w/3, y - h/2 - 2, x - w/6, y - h/2 - 1, x, y - h/2);
  bezierVertex(x + w/6, y - h/2 - 1, x + w/3, y + h/2 - 2, x + w/2, y - h/2);
  vertex(x + w/2, y + h/2);
  bezierVertex(x + w/3, y + h/2 + 2, x + w/6, y + h/2 + 1, x, y + h/2);
  bezierVertex(x - w/6, y + h/2 + 1, x - w/3, y + h/2 + 2, x - w/2, y + h/2);
  endShape(CLOSE);
  fill(85, 55, 30);
  for (int i = 0; i < 5; i++) {
    float ringX = x + (((i * 23 + (int)x) % 40) - 20) * w/60;
    ellipse(ringX, y, w * 0.8, h * 0.6);
  }
  stroke(70, 45, 25);
  strokeWeight(0.5);
  for (int i = 0; i < 3; i++) {
    float ringSize = (w - i * 15) * 0.8;
    ellipse(x, y, ringSize, h * 0.4);
  }
  noStroke();
  fill(120, 85, 55);
  ellipse(x - w/4, y - h/3, w/3, h/4);
}
