// SCENE 5 - Animasi Bawang Merah dengan Dialog dan Narasi

// Import Timer untuk delay dialog
import java.util.Timer;
import java.util.TimerTask;

// ===== AUDIO SYSTEM =====
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
// Buat HashMap untuk menyimpan multiple audio files
HashMap<String, AudioPlayer> audioFiles;
AudioPlayer currentNarration;
AudioPlayer currentDialog;
AudioPlayer soundEffectAudio;
AudioPlayer backgroundMusic;

// =========================================================================
// === PENGATURAN UTAMA (UBAH NILAI DI SINI) ===
// =========================================================================

// === PENGATURAN DURASI (DALAM MILIDETIK) ===
// --- Durasi Narasi ---
int DURASI_NARASI_PEMBUKA_1 = 15000; // "Setelah Merah mendapatkan..." (12 detik)
int DURASI_NARASI_PEMBUKA_2 = 8000; // "Sesampainya di rumah..." (8 detik)
int DURASI_NARASI_PENUTUP_1 = 12000; // "Alih-alih hadiah..." (8 detik)
int DURASI_NARASI_PENUTUP_2 = 19000; // "Merah dan ibunya ketakutan..." (15 detik)

// --- Durasi Tiap Dialog ---
int DURASI_DIALOG_MERAH_1 = 5000;     // "Ibu! Lihat!..."
int DURASI_DIALOG_IBU_1 = 5000;       // "Wah, kita mendapatkan..."
int DURASI_DIALOG_IBU_2 = 4000;       // "Ayo kita buka!..."
int DURASI_DIALOG_MERAH_2 = 6000;     // "Iya bu! Pasti ada..."
int DURASI_DIALOG_MERAH_KAGET = 6000; // "GYAAAAA!..."
int DURASI_DIALOG_IBU_KAGET = 5000;   // "AKHHHH!..."

// --- Durasi Aksi & Adegan ---
int DURASI_ADEGAN_JALAN = 6000;    // Total waktu karakter berjalan (5 detik)
int DURASI_ADEGAN_PERSIAPAN = DURASI_DIALOG_IBU_1 + DURASI_DIALOG_IBU_2 + DURASI_DIALOG_MERAH_2 + 500; // Waktu untuk dialog sebelum memotong (6 detik)
int DURASI_ADEGAN_MEMOTONG = 3000;  // Waktu dari pisau muncul sampai labu terbelah (3.5 detik)
int DURASI_ADEGAN_KAGET = 12000;     // Total waktu adegan kaget (7 detik)
int DURASI_ADEGAN_PENUTUP = 32000;  // Total waktu untuk narasi penutup (43 detik)
int DURASI_FADE_OUT = 2000;         // Waktu untuk layar menghitam (2 detik)

// ===== PENGATURAN VOLUME AUDIO (UBAH DI SINI) =====
// Atur level volume. 0.0 = normal, angka negatif = lebih pelan, angka positif = lebih keras.
float LEVEL_VOLUME = 20; // Default: sedikit lebih keras
float LEVEL_VOLUME_NARASI = 20;
float LEVEL_VOLUME_SFX = 15;

// ===== PENGATURAN KECEPATAN ANIMASI =====
float WALKING_SPEED = 1.0;          // Kecepatan jalan (1.0 = normal, 0.5 = lambat, 2.0 = cepat)
float CUTTING_SPEED = 1.0;          // Kecepatan memotong labu
float INSECT_EMERGENCE_SPEED = 1.0; // Kecepatan kemunculan serangga

// Variabel baru untuk kecepatan ketik
// Angka lebih KECIL = lebih CEPAT. Contoh: 1 = sangat cepat, 5 = lambat.
int KECEPATAN_KETIK_NARASI = 2;

// VOICE OVER
boolean leftFootStepped = false;

void setupAudio() {
  minim = new Minim(this);
  audioFiles = new HashMap<String, AudioPlayer>();
  
  // Load semua audio files dengan error handling
  try {
    // Narasi files
    loadAudioFile("narasiMerah-setelah merah mendapatkan.mp3");
    loadAudioFile("narasiMerah-sesampainya di rumah.mp3");
    loadAudioFile("narasiMerah-alih alih hadiah.mp3");
    loadAudioFile("narasiMerah-Merah dan ibunya ketakutan.mp3");
    
    // Dialog files
    loadAudioFile("Merah_5.1.mp3");
    loadAudioFile("IBU - 5.1.mp3");
    loadAudioFile("IBU - 5.2.mp3");
    loadAudioFile("Merah_5.2.mp3");
    loadAudioFile("Merah_5.3.mp3");
    loadAudioFile("IBU - 5.3.mp3");
    
    // Sound effects
    println("Loading sound effects...");
    loadAudioFile("langkah_kaki.mp3");
    loadAudioFile("pisau_memotong.mp3");
    loadAudioFile("serangga.mp3");
    loadAudioFile("Suara Ular.mp3");
    
    println("Audio system initialized successfully!");
  } catch (Exception e) {
    println("Error loading audio files: " + e.getMessage());
  }
}

void loadAudioFile(String filename) {
  try {
    AudioPlayer player = minim.loadFile(filename);
    if (player != null) {
      // HAPUS player.setGain(LEVEL_VOLUME); DARI SINI
      // agar volume diatur saat akan diputar saja
      audioFiles.put(filename, player);
      println("Loaded: " + filename);
    } else {
      println("Failed to load: " + filename);
    }
  } catch (Exception e) {
    println("Error loading " + filename + ": " + e.getMessage());
  }
}

void playNarrationAudio(String audioFile) {
  // Stop current narration if playing
  if (currentNarration != null && currentNarration.isPlaying()) {
    currentNarration.pause();
    currentNarration.rewind();
  }
  
  // Play new narration
  AudioPlayer player = audioFiles.get(audioFile);
  if (player != null) {
    // PERBAIKAN: Mengatur volume khusus untuk narasi saat diputar
    player.setGain(LEVEL_VOLUME_NARASI);
    
    currentNarration = player;
    currentNarration.rewind();
    currentNarration.play();
    println("Playing narration: " + audioFile);
  } else {
    println("Narration audio not found: " + audioFile);
  }
}

void playDialogAudio(String audioFile) {
  if (currentDialog != null && currentDialog.isPlaying()) {
    currentDialog.pause();
    currentDialog.rewind();
  }
  
  AudioPlayer player = audioFiles.get(audioFile);
  if (player != null) {
    player.setGain(LEVEL_VOLUME);
    
    currentDialog = player;
    currentDialog.rewind();
    currentDialog.play();
    println("Playing dialog: " + audioFile);
  } else {
    println("Dialog audio not found: " + audioFile);
  }
}

void playSoundEffect(String audioFile) {
  AudioPlayer player = audioFiles.get(audioFile);
  if (player != null) {
    // Menerapkan volume khusus SFX
    player.setGain(LEVEL_VOLUME_SFX);
    player.rewind();
    player.play();
    println("Playing sound effect: " + audioFile);
  } else {
    println("Sound effect not found: " + audioFile);
  }
}

// === FONT VARIABLES ===
PFont fontDialog;
PFont fontNarasi;
PFont fontNamaKarakter;

// === VARIABEL DIALOG DAN NARASI ===
boolean showDialog = false;
boolean showNarration = false;
String dialogText = "";
String narrationText = "";
float dialogOpacity = 0;
float narrationOpacity = 0;
int dialogStartTime = 0;
int narrationStartTime = 0;
float dialogBubbleScale = 0;
int narrationSubState = 0;
String displayedNarration = "";
int narrationCharIndex = 0;
float fadeOpacity = 0;
int currentDialogDuration = 0;
int currentNarrationDuration = 0;

// Status animasi
int animationState = 0;
// 0: Background saja + Narasi pembuka
// 1: Karakter jalan dari kanan bawa labu DAN PISAU + Dialog 1
// 2: Taruh labu di lantai + Dialog 2 & 3
// 3: Pisau memotong labu dengan gerakan AYUNAN SANTAI tangan KIRI Ibu Bawang Merah + Dialog 4 + Sound Effect
// 4: Serangga keluar menyebar, karakter kaget + Dialog 5 & 6
// 5: Pisau ditaruh di lantai, state akhir + Narasi penutup
// 6: fade out
int stateTimer = 0;

int[] baseDuration = {
  DURASI_NARASI_PEMBUKA_1 + DURASI_NARASI_PEMBUKA_2, // State 0: Total narasi pembuka
  DURASI_ADEGAN_JALAN,       // State 1
  DURASI_ADEGAN_PERSIAPAN,   // State 2
  DURASI_ADEGAN_MEMOTONG,    // State 3
  DURASI_ADEGAN_KAGET,       // State 4
  DURASI_ADEGAN_PENUTUP,     // State 5
  DURASI_FADE_OUT            // State 6
};

// Posisi karakter untuk animasi jalan
float currentIbuX = 1400; // Mulai dari luar layar kanan
float currentBamerX = 1350;
float targetIbuX = 960; // Posisi akhir ibu
float targetBamerX = 448; // Posisi akhir bawang merah

// Variabel animasi jalan kaki
float walkCycle = 0; // Untuk animasi langkah kaki
float stepHeight = 8; // Tinggi langkah kaki

// Variabel animasi labu
boolean pumpkinCarried = true;
boolean pumpkinOnFloor = false;
boolean knifeCarried = true; // Ibu bawa pisau saat masuk
float pumpkinCutProgress = 0;
float insectEmergenceProgress = 0;
boolean knifeVisible = false;
boolean knifeOnFloor = false;

// Variabel global untuk skala labu dan elemen terkait
float PUMPKIN_DRAW_SCALE = 0.9;

// Variabel global untuk posisi labu
float pumpkinX = 700;
float pumpkinY = 450;

// Variabel global untuk skala karakter
float IBU_BAMER_DRAW_SCALE = 1;
float BAMER_DRAW_SCALE = 0.9;
float IBU_BAMER_OFFSET_X = 0;
float IBU_BAMER_OFFSET_Y = 120;
float BAMER_OFFSET_X = 0;
float BAMER_OFFSET_Y = 90;

// Variabel untuk mengontrol animasi ekspresi kaget
float shockAnimationProgress = 0;
float shockAnimationTime = 0;

void setup() {
  size(1280, 720);
  
  // === SETUP FONTS ===
  // Menggunakan font Arial seperti sebelumnya, namun bisa diganti jika perlu
  fontDialog = createFont("MS Gothic", 18, true);
  fontNarasi = createFont("MS Gothic", 22, false); 
  fontNamaKarakter = createFont("MS Gothic", 20, true);
  
  stateTimer = millis();
  
  // === SETUP AUDIO ===
  setupAudio();
}

// Fungsi ini diupdate untuk mereset variabel ketik
void resetNarasi() {
  showNarration = false;
  displayedNarration = "";
  narrationCharIndex = 0;
}

void activateDialogsForState(int state) {
    showDialog = false;
    if (state != 5) resetNarasi();

    switch(state) {
        case 1: // Adegan Jalan
            new Timer().schedule(new TimerTask() { public void run() {
                showDialog = true; dialogText = "Ibu! Lihat! Aku juga dapat labu dari nenek tua itu!";
                dialogStartTime = millis(); playDialogAudio("Merah_5.1.mp3");
                currentDialogDuration = DURASI_DIALOG_MERAH_1;
            }}, 1000); // Muncul setelah 1 detik
            break;
            
        case 2: // Adegan Persiapan Memotong
            // Dialog 1 (Ibu)
            showDialog = true; 
            dialogText = "Wah, kita mendapatkan labu yang lebih besar dari si putih!";
            dialogStartTime = millis(); 
            playDialogAudio("IBU - 5.1.mp3");
            currentDialogDuration = DURASI_DIALOG_IBU_1;
            
            // Dialog 2 (Ibu) - Muncul setelah dialog 1 selesai
            new Timer().schedule(new TimerTask() { 
              public void run() {
                showDialog = true; 
                dialogText = "Ayo kita buka! Ibu penasaran nih isinya apa.";
                dialogStartTime = millis(); 
                playDialogAudio("IBU - 5.2.mp3");
                currentDialogDuration = DURASI_DIALOG_IBU_2;
            }
          }, DURASI_DIALOG_IBU_1); // Delay = durasi dialog sebelumnya
            
            // Dialog 3 (Merah) - Muncul setelah dialog 2 selesai
            new Timer().schedule(new TimerTask() { 
              public void run() {
                showDialog = true; 
                dialogText = "Iya bu! Pasti ada sesuatu yang bagus di dalamnya!";
                dialogStartTime = millis(); 
                playDialogAudio("Merah_5.2.mp3");
                currentDialogDuration = DURASI_DIALOG_MERAH_2;
            }
          }, DURASI_DIALOG_IBU_1 + DURASI_DIALOG_IBU_2); // Delay = total durasi 2 dialog sebelumnya
            break;
            
        case 3: // Adegan Memotong
            playSoundEffect("pisau_memotong.mp3");
            break;
            
        case 4: // Adegan Kaget
            playSoundEffect("serangga.mp3");
            playSoundEffect("Suara Ular.mp3");
            
            // Dialog 1 (Merah Kaget)
            new Timer().schedule(new TimerTask() { public void run() {
                showDialog = true; dialogText = "GYAAAAA! IBU! ADA ULAR! ADA KALAJENGKING! TOLONG!";
                dialogStartTime = millis(); playDialogAudio("Merah_5.3.mp3");
                currentDialogDuration = DURASI_DIALOG_MERAH_KAGET;
            }}, 500); // Muncul setelah 0.5 detik
            
            // Dialog 2 (Ibu Kaget) - Muncul setelah dialog Merah selesai
            new Timer().schedule(new TimerTask() { public void run() {
                showDialog = true; dialogText = "AKHHHH! SERANGGA-SERANGGA MERAH! KENAPA ISINYA BEGINI SIH?!";
                dialogStartTime = millis(); playDialogAudio("IBU - 5.3.mp3");
                currentDialogDuration = DURASI_DIALOG_IBU_KAGET;
            }}, DURASI_DIALOG_MERAH_KAGET + 800); // Delay = durasi dialog merah + jeda
            break;
            
        case 5: // Adegan Narasi Penutup
            // Narasi 1
            showNarration = true; narrationText = "Alih-alih hadiah yang indah, yang keluar dari labu adalah gerombolan serangga berbisa dan ular-ular kecil yang menyebar ke seluruh ruangan.";
            narrationStartTime = millis(); displayedNarration = ""; narrationCharIndex = 0;
            playNarrationAudio("narasiMerah-alih alih hadiah.mp3");
            currentNarrationDuration = DURASI_NARASI_PENUTUP_1;
            
            // Narasi 2 - Muncul setelah narasi 1 selesai
            new Timer().schedule(new TimerTask() { public void run() {
                showNarration = true; narrationText = "Merah dan ibunya ketakutan, menyadari bahwa sikap kasar dan tidak sopan mereka pada nenek bijak telah mendatangkan balasan yang setimpal. Kehidupan mereka pun menjadi kacau balau akibat keserakahan dan kesombongan mereka.";
                narrationStartTime = millis(); displayedNarration = ""; narrationCharIndex = 0;
                playNarrationAudio("narasiMerah-Merah dan ibunya ketakutan.mp3");
                currentNarrationDuration = DURASI_NARASI_PENUTUP_2;
            }}, DURASI_NARASI_PENUTUP_1 + 500); // Delay = durasi narasi 1 + jeda
            break;
    }
}

void updateDialogNarasi() {
  if (showDialog) {
    dialogOpacity = min(255, dialogOpacity + 15);
    dialogBubbleScale = min(1.0, dialogBubbleScale + 0.08);
  } else {
    dialogOpacity = max(0, dialogOpacity - 15);
    dialogBubbleScale = max(0, dialogBubbleScale - 0.1);
  }
  
  if (showNarration) {
    narrationOpacity = min(255, narrationOpacity + 15);
    if (narrationCharIndex < narrationText.length() && frameCount % KECEPATAN_KETIK_NARASI == 0) {
      displayedNarration += narrationText.charAt(narrationCharIndex);
      narrationCharIndex++;
    }
  } else {
    narrationOpacity = max(0, narrationOpacity - 15);
  }
  
  // PERBAIKAN: Menggunakan durasi dinamis untuk menutup dialog dan narasi
  if (showDialog && currentDialogDuration > 0 && (millis() - dialogStartTime) > currentDialogDuration) { 
    showDialog = false; 
  }
  if (showNarration && currentNarrationDuration > 0 && (millis() - narrationStartTime) > currentNarrationDuration) { 
    resetNarasi(); 
  }
}


// === FUNGSI DIALOG BARU  ===
void gambarDialog() {
  if (dialogOpacity > 0 && showDialog) {
    pushMatrix();
    float bubbleX = 0, bubbleY = 180, anchorX = 0;
    String speakerName = "";
    
    boolean isSFX = dialogText.contains("KRETAK");
    
    if (isSFX) {
      anchorX = width / 2;
      bubbleY = height / 2;
    } else if (dialogText.contains("Wah") || dialogText.contains("Ayo kita buka") || dialogText.contains("AKHHHH")) {
      speakerName = "Ibu";
      anchorX = currentIbuX;
    } else {
      speakerName = "Merah";
      anchorX = currentBamerX;
    }
    
    float bubbleWidth = 320;
    bubbleX = anchorX - (bubbleWidth / 2);
    translate(bubbleX, bubbleY);
    scale(dialogBubbleScale);
    
    if (!isSFX) {
      float nameBoxHeight = 35;
      textFont(fontNamaKarakter);
      float nameBoxWidth = textWidth(speakerName) + 40;
      
      // PERBAIKAN: Menentukan warna kotak nama sesuai karakter
      if (speakerName.equals("Ibu")) {
        fill(220, 50, 50, dialogOpacity);    // Warna badan Ibu
        stroke(180, 30, 30, dialogOpacity); // Warna outline badan Ibu
      } else { // Jika pembicara adalah Merah
        fill(216, 112, 147, dialogOpacity); // Warna badan Merah
        stroke(139, 69, 19, dialogOpacity);   // Warna outline badan Merah
      }
      
      strokeWeight(2);
      rect(0, -(nameBoxHeight + 5), nameBoxWidth, nameBoxHeight, 8);
      
      // PERBAIKAN: Mengubah warna teks nama menjadi putih agar mudah dibaca
      fill(255, dialogOpacity);
      textAlign(CENTER, CENTER);
      text(speakerName, nameBoxWidth / 2, -(nameBoxHeight + 5) + (nameBoxHeight / 2));
    }
    
    textFont(fontDialog);
    float textH = textHeightForWidth(dialogText, bubbleWidth - 40) + 40;
    fill(0, 0, 0, dialogOpacity * 0.15); noStroke();
    rect(3, 3, bubbleWidth, textH, 30);
    fill(255, 255, 255, dialogOpacity); stroke(150, 150, 150, dialogOpacity); strokeWeight(2);
    rect(0, 0, bubbleWidth, textH, 30);
    fill(0, 0, 0, dialogOpacity); textAlign(LEFT, TOP);
    text(dialogText, 20, 20, bubbleWidth - 40, textH - 30);
    
    if (!isSFX) {
      noStroke(); fill(255, 255, 255, dialogOpacity);
      float tailBaseX = bubbleWidth / 2;
      triangle(tailBaseX - 15, textH, tailBaseX + 15, textH, tailBaseX, textH + 20);
      stroke(150, 150, 150, dialogOpacity); strokeWeight(2);
      line(tailBaseX - 15, textH, tailBaseX, textH + 20);
      line(tailBaseX + 15, textH, tailBaseX, textH + 20);
    }
    popMatrix();
    textAlign(CENTER, CENTER);
  }
}

// Fungsi helper untuk menghitung tinggi teks (SUDAH DIPERBAIKI)
float textHeightForWidth(String str, float width) {
  float lineSpacing = textAscent() + textDescent(); // Mendapatkan tinggi baris saat ini
  float h = lineSpacing; // Mulai dengan tinggi satu baris
  
  String[] words = str.split(" ");
  String currentLine = "";
  
  for(int i = 0; i < words.length; i++) {
    String testLine = currentLine + words[i] + " ";
    if (textWidth(testLine) > width && i > 0) {
      h += lineSpacing; // Tambah tinggi untuk setiap baris baru
      currentLine = words[i] + " ";
    } else {
      currentLine = testLine;
    }
  }
  return h;
}

// === FUNGSI NARASI BARU ===
void gambarNarasi() {
  if (narrationOpacity > 0 && showNarration) {
    float alphaNameBox = 150 * (narrationOpacity / 255.0);
    float alphaTextBox = 240 * (narrationOpacity / 255.0);
    float alphaBorder = 180 * (narrationOpacity / 255.0);
    float alphaText = 255 * (narrationOpacity / 255.0);

    // === KOTAK NAMA "NARASI" ===
    // Posisi di kiri bawah layar
    fill(0, alphaNameBox);
    noStroke();
    rect(50, height - 152, 140, 36, 8); 

    // Teks Nama
    fill(255, alphaText);
    textFont(fontNamaKarakter);
    textAlign(LEFT, CENTER);
    text("Narasi", 70, height - 134);

    // === KOTAK TEKS UTAMA ===
    fill(255, alphaTextBox); 
    stroke(180, alphaBorder);
    strokeWeight(2);
    rect(50, height - 120, width - 100, 100, 15); 

    // === TEKS NARASI ===
    fill(0, alphaText); 
    textFont(fontNarasi);
    textAlign(LEFT, TOP);
    text(displayedNarration, 70, height - 105, width - 140, 90);
    
    textAlign(CENTER, CENTER); // Reset alignment
  }
}

void updateAndDisplayDialogs() {
  gambarDialog();
  gambarNarasi();
}

// FUNGSI UTAMA ANIMASI 
void updateAnimationState() {
  int currentTime = millis();
  
  if (animationState < baseDuration.length -1) {
    if (currentTime - stateTimer > baseDuration[animationState]) {
      animationState++;
      stateTimer = currentTime;
      narrationSubState = 0;
      activateDialogsForState(animationState);
      switch (animationState) {
        case 2: pumpkinCarried = false; pumpkinOnFloor = true; knifeCarried = false; break;
        case 3: knifeVisible = true; break;
        case 5: knifeVisible = false; knifeOnFloor = true; break;
      }
    }
  }
  
  if (animationState == 0) {
    if (narrationSubState == 0 && (currentTime - stateTimer) >= 200) {
      showNarration = true; narrationText = "Setelah Merah mendapatkan labu dengan cara kasar dari nenek bijak, ia segera berlari pulang ke rumah bersama ibunya. Mereka tak sabar untuk membuka labu besar yang tampak menjanjikan itu.";
      narrationStartTime = millis(); displayedNarration = ""; narrationCharIndex = 0;
      playNarrationAudio("narasiMerah-setelah merah mendapatkan.mp3");
      currentNarrationDuration = DURASI_NARASI_PEMBUKA_1; // Atur durasi spesifik
      narrationSubState = 1;
    }
    if (narrationSubState == 1 && (currentTime - stateTimer) >= DURASI_NARASI_PEMBUKA_1) {
      showNarration = true; narrationText = "Sesampainya di rumah, mereka langsung membawa labu beserta pisau ke ruang tengah dan meletakkannya di lantai.";
      narrationStartTime = millis(); displayedNarration = ""; narrationCharIndex = 0;
      playNarrationAudio("narasiMerah-sesampainya di rumah.mp3");
      currentNarrationDuration = DURASI_NARASI_PEMBUKA_2; // Atur durasi spesifik
      narrationSubState = 2;
    }
  }
  
  if (animationState == 1) {
    float walkProgress = constrain((float)(currentTime - stateTimer) / (baseDuration[1] / WALKING_SPEED), 0, 1);
    currentIbuX = lerp(1400, targetIbuX, easeInOutQuad(walkProgress));
    currentBamerX = lerp(1350, targetBamerX, easeInOutQuad(walkProgress));
    walkCycle += 0.15 * WALKING_SPEED;
    if (sin(walkCycle) > 0.95 && !leftFootStepped) { playSoundEffect("langkah_kaki.mp3"); leftFootStepped = true; } 
    else if (sin(walkCycle) < -0.95 && leftFootStepped) { playSoundEffect("langkah_kaki.mp3"); leftFootStepped = false; }
  }
  
  if (animationState == 3) pumpkinCutProgress = constrain((float)(currentTime - stateTimer) / (baseDuration[3] / CUTTING_SPEED), 0, 1);
  if (animationState == 4) insectEmergenceProgress = constrain((float)(currentTime - stateTimer) / (baseDuration[4] / INSECT_EMERGENCE_SPEED), 0, 1);
  if (animationState >= 4) shockAnimationProgress = (sin(millis() * 0.002) + 1) / 2.0;
  else shockAnimationProgress = 0;
  
  if (animationState == 6) {
    fadeOpacity = lerp(0, 255, (float)(currentTime - stateTimer) / baseDuration[6]);
  }
}

float easeInOutQuad(float t) {
  return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
}

void draw() {
  background(245, 235, 215);
  updateAnimationState();
  updateDialogNarasi();
  
  gambarLantai();
  gambarKarpet();
  gambarJendela();
  gambarLukisanDinding();
  gambarLampuGantung();
  
  float floorY = height * 0.6;
  
  if (animationState >= 2 && animationState < 6) {
    pushMatrix();
    translate(pumpkinX, pumpkinY);
    scale(0.9);
    if (animationState >= 3) drawPumpkinInternal();
    else drawWholePumpkin();
    if (animationState >= 4) {
      drawInsectsInternal();
      drawGlowInternal();
    }
    popMatrix();
  }
  
  // PERBAIKAN: Karakter tetap digambar sampai state 5 selesai
  if (animationState >= 1 && animationState <= 5) {
    drawIbuBawangMerah(currentIbuX, floorY - (180 * 1) + 120, 1, shockAnimationProgress);
    drawBawangMerah(currentBamerX, floorY - (180 * 0.9) + 90, 0.9, shockAnimationProgress);
    if (animationState == 1 && pumpkinCarried) {
      pushMatrix();
      translate(currentBamerX - 10, floorY - (180 * 0.9) + 150);
      scale(0.6);
      drawWholePumpkin();
      popMatrix();
    }
  }
  
  if (knifeVisible && !knifeOnFloor) {
    pushMatrix();
    translate(pumpkinX + 200, pumpkinY - 40);
    float armSwing = (animationState == 3) ? sin(millis() * 0.005 * CUTTING_SPEED) * 12 : 0;
    translate(armSwing, 0);
    rotate(radians(-180 + sin(millis() * 0.005 * CUTTING_SPEED) * 10));
    drawKnife(0, 0, 0.8);
    popMatrix();
  } else if (knifeOnFloor) {
    pushMatrix();
    translate(pumpkinX + 150, floorY - 10);
    rotate(radians(45));
    drawKnife(0, 0, 0.7);
    popMatrix();
  }
  
  updateAndDisplayDialogs();
  
  if (animationState == 6) {
    fill(0, fadeOpacity);
    noStroke();
    rect(0, 0, width, height);
  }
}

void restartAnimation() {
  animationState = 0;
  stateTimer = millis();
  narrationSubState = 0;
  fadeOpacity = 0;
  leftFootStepped = false;
  currentIbuX = 1400;
  currentBamerX = 1350;
  pumpkinCarried = true;
  pumpkinOnFloor = false;
  knifeCarried = true; // Reset pisau dibawa
  knifeVisible = false;
  knifeOnFloor = false;
  shockAnimationProgress = 0;
  pumpkinCutProgress = 0;
  insectEmergenceProgress = 0;
  walkCycle = 0;
  shockAnimationTime = 0;
  
  // Reset semua dialog
  resetNarasi();
  showDialog = false;
  showNarration = false;
  dialogOpacity = 0;
  narrationOpacity = 0;
  
  // === STOP ALL AUDIO ===
  if (currentNarration != null && currentNarration.isPlaying()) {
    currentNarration.pause();
    currentNarration.rewind();
  }
  if (currentDialog != null && currentDialog.isPlaying()) {
    currentDialog.pause();
    currentDialog.rewind();
  }
  if (soundEffectAudio != null && soundEffectAudio.isPlaying()) {
    soundEffectAudio.pause();
    soundEffectAudio.rewind();
  }
}

// Fungsi untuk menggambar labu utuh (sebelum dipotong)
void drawWholePumpkin() {
  // bayangan labu
  fill(0, 0, 0, 50);
  ellipse(5, 120, 350, 80);

  // SATU LABU BULAT UTUH
  fill(255, 140, 60);
  stroke(200, 100, 40);
  strokeWeight(3);
  ellipse(0, 0, 300, 200);

  // Garis vertikal MELENGKUNG untuk alur labu (ridge lines)
  stroke(220, 120, 50);
  strokeWeight(2);
  noFill();
  for (int i = -3; i <= 3; i++) {
    float centerX = i * 35;
    beginShape();
    for (int j = -20; j <= 20; j++) {
      float t = j / 20.0;
      float y = t * 95;
      float labuWidth = sqrt(1 - (y * y) / (95 * 95)) * 150;
      float ridgeOffset = (centerX / 150.0) * labuWidth;
      float x = ridgeOffset;
      float curve = sin(t * PI) * 5;
      x += curve * abs(centerX) / 105.0;
      vertex(x, y);
    }
    endShape();
  }

  // Tangkai labu
  fill(101, 67, 33);
  stroke(80, 50, 20);
  strokeWeight(2);
  rect(-10, -120, 20, 30, 5);

  // Detail tangkai
  fill(120, 80, 40);
  rect(-8, -110, 16, 15, 3);

  // Daun kecil di tangkai
  fill(34, 139, 34);
  ellipse(-15, -105, 20, 8);
  ellipse(15, -108, 18, 7);
}

// Fungsi restart manual (tekan 'r')
void keyPressed() {
  if (key == 'r' || key == 'R') {
    restartAnimation();
  }
}

// --- Fungsi-fungsi Background ---
void gambarLantai() {
  pushMatrix();
  translate(0, height * 0.6);
  fill(139, 101, 52);
  rect(0, 0, width, height * 0.4);
  stroke(120, 85, 45);
  strokeWeight(1);
  for (int i = 0; i < 12; i++) {
    float y = (height * 0.4 / 12) * i;
    line(0, y, width, y);
  }
  popMatrix();
}

void gambarKarpet() {
  pushMatrix();
  translate(width * 0.6, height * 0.8);
  // KARPET TETAP UKURAN ASLI SEPERTI YANG DIMINTA
  float karpetLebar = 450;
  float karpetTinggi = 200;
  noStroke();
  fill(255, 160, 140);
  ellipse(0, 0, karpetLebar + 20, karpetTinggi + 20);
  stroke(255, 140, 120);
  strokeWeight(1);
  for (int i = 0; i < 60; i++) {
    float sudut = (TWO_PI / 60) * i;
    float x1 = cos(sudut) * (karpetLebar / 2 + 5);
    float y1 = sin(sudut) * (karpetTinggi / 2 + 5);
    float x2 = cos(sudut) * (karpetLebar / 2 + 15);
    float y2 = sin(sudut) * (karpetTinggi / 2 + 15);
    line(x1, y1, x2, y2);
  }
  noStroke();
  fill(255, 180, 160);
  ellipse(0, 0, karpetLebar, karpetTinggi);
  fill(255, 200, 180);
  ellipse(0, 0, karpetLebar * 0.7, karpetTinggi * 0.7);
  popMatrix();
}

void gambarJendela() {
  pushMatrix();
  translate(860, 50);
  fill(218, 165, 32);
  rect(0, 0, 300, 280);
  fill(184, 134, 11);
  rect(0, 0, 300, 15);
  rect(0, 265, 300, 15);
  rect(0, 0, 15, 280);
  rect(285, 0, 15, 280);
  rect(145, 0, 10, 280);
  rect(0, 135, 300, 10);
  fill(25, 45, 85);
  rect(15, 15, 125, 115);
  rect(150, 15, 125, 115);
  rect(15, 150, 125, 115);
  rect(150, 150, 125, 115);
  fill(255, 255, 150);
  noStroke();
  ellipse(60, 50, 40, 40);
  fill(25, 45, 85);
  ellipse(65, 50, 35, 35);
  float brightness = 150 + 105 * sin(millis() * 0.01);
  fill(255, 255, brightness);
  ellipse(90, 35, 8, 8);
  brightness = 150 + 105 * sin(millis() * 0.008 + 1);
  fill(255, 255, brightness);
  ellipse(240, 40, 6, 6);
  brightness = 150 + 105 * sin(millis() * 0.012 + 2);
  fill(255, 255, brightness);
  ellipse(190, 60, 8, 8);
  brightness = 150 + 105 * sin(millis() * 0.009 + 3);
  fill(255, 255, brightness);
  ellipse(260, 70, 6, 6);
  brightness = 150 + 105 * sin(millis() * 0.011 + 4);
  fill(255, 255, brightness);
  ellipse(30, 80, 6, 6);
  brightness = 150 + 105 * sin(millis() * 0.007 + 5);
  fill(255, 255, brightness);
  ellipse(60, 200, 8, 8);
  brightness = 150 + 105 * sin(millis() * 0.013 + 6);
  fill(255, 255, brightness);
  ellipse(220, 190, 6, 6);
  brightness = 150 + 105 * sin(millis() * 0.006 + 7);
  fill(255, 255, brightness);
  ellipse(250, 210, 8, 8);
  stroke(255, 255, 255);
  strokeWeight(1);
  line(86, 35, 94, 35);
  line(90, 31, 90, 39);
  line(236, 40, 244, 40);
  line(240, 36, 240, 44);
  line(186, 60, 194, 60);
  line(190, 56, 190, 64);
  noStroke();
  fill(139, 69, 19);
  rect(160, 230, 40, 35);
  float swayOffset = 3 * sin(millis() * 0.003);
  fill(34, 139, 34);
  ellipse(180 + swayOffset, 220, 30, 20);
  fill(255, 255, 255);
  ellipse(175 + swayOffset * 0.8, 215, 6, 6);
  ellipse(180 + swayOffset, 213, 7, 7);
  ellipse(185 + swayOffset * 0.6, 217, 5, 5);
  ellipse(182 + swayOffset * 0.7, 219, 6, 6);
  fill(255, 255, 200);
  ellipse(175 + swayOffset * 0.8, 215, 2, 2);
  ellipse(180 + swayOffset, 213, 3, 3);
  ellipse(185 + swayOffset * 0.6, 217, 2, 2);
  ellipse(182 + swayOffset * 0.7, 219, 2, 2);
  fill(184, 134, 11);
  rect(0, 280, 300, 20);
  popMatrix();
}

void gambarLukisanDinding() {
  pushMatrix();
  translate(280, 70);
  noStroke();
  fill(184, 134, 11);
  rect(0, 0, 140, 180);
  fill(255, 248, 220);
  rect(20, 20, 100, 140);
  stroke(34, 139, 34);
  strokeWeight(3);
  line(50, 140, 50, 100);
  line(70, 140, 70, 90);
  line(90, 140, 90, 105);
  noStroke();
  fill(255, 20, 147);
  ellipse(50, 100, 20, 20);
  fill(255, 105, 180);
  ellipse(70, 90, 18, 18);
  fill(255, 20, 147);
  ellipse(90, 105, 16, 16);
  fill(255, 255, 0);
  ellipse(50, 100, 8, 8);
  ellipse(70, 90, 6, 6);
  ellipse(90, 105, 6, 6);
  fill(34, 139, 34);
  ellipse(45, 120, 12, 8);
  ellipse(55, 115, 10, 6);
  ellipse(65, 110, 8, 5);
  ellipse(75, 105, 10, 6);
  ellipse(85, 125, 12, 8);
  ellipse(95, 120, 8, 5);
  popMatrix();
}

void gambarLampuGantung() {
  pushMatrix();
  translate(width * 0.5, height * 0.2);
  float swayOffset = 0.5 * sin(millis() * 0.001) * cos(millis() * 0.0008);
  translate(swayOffset, 0);
  stroke(100, 100, 100);
  strokeWeight(2);
  line(0, -height * 0.2, 0, -30);
  fill(0, 128, 128);
  noStroke();
  ellipse(0, 0, 80, 50);
  fill(0, 100, 100);
  ellipse(0, 15, 85, 15);
  fill(255, 215, 0);
  ellipse(0, 25, 20, 10);
  float timeBase = millis() * 0.001;
  // Flicker lebih halus dan intensitas lebih rendah
  float lightFlicker = 0.9 + 0.05 * sin(timeBase * 10) + 0.02 * sin(timeBase * 20);  
  float lightIntensity = 50 * lightFlicker;  
  fill(255, 255, 200, lightIntensity * 0.4);
  ellipse(0, 35, 280, 180); // Area cahaya lebih besar
  fill(255, 255, 220, lightIntensity * 0.6);
  ellipse(0, 35, 200, 120);
  fill(255, 255, 240, lightIntensity * 0.8);
  ellipse(0, 35, 140, 84);
  fill(255, 255, 255, lightIntensity);
  ellipse(0, 35, 90, 54);
  popMatrix();
}

// --- Fungsi-fungsi Labu dan Serangga ---
void drawPumpkinInternal() {
  // bayangan labu
  fill(0, 0, 0, 50);
  ellipse(5, 120, 350, 80);

  // SATU LABU BULAT UTUH
  fill(255, 140, 60);
  stroke(200, 100, 40);
  strokeWeight(3);
  ellipse(0, 0, 300, 200);

  // Garis vertikal MELENGKUNG untuk alur labu (ridge lines)
  stroke(220, 120, 50);
  strokeWeight(2);
  noFill();
  for (int i = -3; i <= 3; i++) {
    float centerX = i * 35;
    beginShape();
    for (int j = -20; j <= 20; j++) {
      float t = j / 20.0;
      float y = t * 95;
      float labuWidth = sqrt(1 - (y * y) / (95 * 95)) * 150;
      float ridgeOffset = (centerX / 150.0) * labuWidth;
      float x = ridgeOffset;
      float curve = sin(t * PI) * 5;
      x += curve * abs(centerX) / 105.0;
      vertex(x, y);
    }
    endShape();
  }

  // EFEK TERBELAH DI TENGAH -- area gelap
  fill(180, 100, 40);
  stroke(150, 80, 30);
  strokeWeight(2);
  beginShape();
  vertex(-10, -90);
  vertex(10, -90);
  vertex(25, -60);
  vertex(25, 60);
  vertex(10, 90);
  vertex(-10, 90);
  vertex(-25, 60);
  vertex(-25, -60);
  endShape(CLOSE);

  // Efek bayangan dalam lebih gelap
  fill(120, 60, 20);
  noStroke();
  ellipse(0, 0, 35, 160);

  // Tepi dalam yang kasar
  stroke(100, 50, 15);
  strokeWeight(1);
  for (int i = 0; i < 10; i++) {
    float y = -80 + i * 16;
    line(-15, y, -20, y + 5);
    line(15, y, 20, y + 5);
  }

  // Tangkai labu
  fill(101, 67, 33);
  stroke(80, 50, 20);
  strokeWeight(2);
  rect(-10, -120, 20, 30, 5);

  // Detail tangkai
  fill(120, 80, 40);
  rect(-8, -110, 16, 15, 3);

  // Daun kecil di tangkai
  fill(34, 139, 34);
  ellipse(-15, -105, 20, 8);
  ellipse(15, -108, 18, 7);
}

void drawInsectsInternal() {
  pushMatrix();
  translate(0, 20); // Relatif terhadap origin labu
  // SERANGGA MENYEBAR LEBIH LUAS
  drawCrawlingInsects(-30, -90, 60, 180, false); // Area lebih luas
  drawCrawlingInsects(-80, 60, 160, 120, true); // Area tumpah lebih luas
  popMatrix();
}

void drawCrawlingInsects(float x, float y, float w, float h, boolean spilled) {
  // randomSeed(123); // Dihapus untuk gerakan dinamis
  int numItems = spilled ? 35 : 45; // Lebih banyak serangga
  for (int i = 0; i < numItems; i++) {
    float itemX = x + random(w);
    float itemY = y + random(h);

    // Tambahkan gerakan sinusoidal kecil yang lebih lambat dan jangkauan lebih kecil
    itemX += sin(millis() * 0.0001 + i * 0.1) * 0.2; // Gerakan lebih besar
    itemY += cos(millis() * 0.0001 + i * 0.1) * 0.2;  

    float randNum = random(1);
    if (randNum < 0.4) {
      drawSnake(itemX, itemY, random(0.5) + 0.5);
    } else if (randNum < 0.55) {
      drawLongSnake(itemX, itemY, random(0.6) + 0.4);
    } else if (randNum < 0.7) {
      drawScorpion(itemX, itemY, random(0.4) + 0.6);
    } else if (randNum < 0.8) {
      drawSpider(itemX, itemY, random(0.3) + 0.7);
    } else if (randNum < 0.9) {
      drawCockroach(itemX, itemY, random(0.4) + 0.6);
    } else {
      drawWorm(itemX, itemY, random(0.5) + 0.5);
    }
  }
}

void drawSnake(float x, float y, float scale) {
  pushMatrix();
  translate(x, y);
  scale(scale);
  fill(0, 0, 0, 30);
  ellipse(2, 2, 35, 8);
  fill(50, 80, 30);
  stroke(30, 60, 20);
  strokeWeight(1);
  for (int i = 0; i < 6; i++) {
    float segX = i * 5 - 12;
    float segY = sin(i * 0.8) * 3;
    ellipse(segX, segY, 8, 6);
  }
  fill(40, 70, 25);
  ellipse(15, 0, 10, 8);
  fill(255, 0, 0);
  ellipse(17, -2, 2, 2);
  ellipse(17, 2, 2, 2);
  stroke(255, 0, 100);
  strokeWeight(1);
  line(20, 0, 23, -1);
  line(23, -1, 24, -2);
  line(23, -1, 24, 0);
  popMatrix();
}

void drawScorpion(float x, float y, float scale) {
  pushMatrix();
  translate(x, y);
  scale(scale);
  fill(0, 0, 0, 40);
  ellipse(2, 2, 25, 15);
  fill(80, 50, 30);
  stroke(60, 35, 20);
  strokeWeight(1);
  ellipse(0, 0, 20, 10);
  fill(70, 40, 25);
  ellipse(-10, -5, 8, 6);
  ellipse(-10, 5, 8, 6);
  stroke(50, 30, 15);
  strokeWeight(1);
  for (int i = 0; i < 4; i++) {
    float legY = -6 + i * 4;
    line(-8, legY, -12, legY - 2);
    line(8, legY, 12, legY - 2);
  }
  stroke(80, 50, 30);
  strokeWeight(2);
  noFill();
  beginShape();
  vertex(10, 0);
  vertex(15, -3);
  vertex(18, -8);
  vertex(16, -12);
  endShape();
  fill(255, 0, 0);
  ellipse(16, -12, 3, 3);
  popMatrix();
}

void drawSpider(float x, float y, float scale) {
  pushMatrix();
  translate(x, y);
  scale(scale);
  fill(0, 0, 0, 35);
  ellipse(2, 2, 20, 20);
  stroke(20, 20, 20);
  strokeWeight(2);
  for (int i = 0; i < 8; i++) {
    float angle = i * PI / 4;
    float legX = cos(angle) * 12;
    float legY = sin(angle) * 12;
    line(0, 0, legX, legY);
    line(legX, legY, legX + cos(angle) * 6, legY + sin(angle) * 6);
  }
  fill(40, 20, 20);
  stroke(20, 10, 10);
  strokeWeight(1);
  ellipse(0, 0, 15, 15);
  fill(50, 25, 25);
  ellipse(0, 6, 12, 18);
  fill(255, 0, 0);
  ellipse(-3, -4, 2, 2);
  ellipse(3, -4, 2, 2);
  ellipse(-1, -6, 1, 1);
  ellipse(1, -6, 1, 1);
  popMatrix();
}

void drawCockroach(float x, float y, float scale) {
  pushMatrix();
  translate(x, y);
  scale(scale);
  fill(0, 0, 0, 30);
  ellipse(2, 2, 25, 12);
  fill(60, 40, 20);
  stroke(40, 25, 15);
  strokeWeight(1);
  ellipse(0, 0, 22, 10);
  fill(50, 30, 15);
  ellipse(-12, 0, 8, 6);
  stroke(30, 20, 10);
  strokeWeight(1);
  line(-16, -2, -20, -5);
  line(-16, 2, -20, 5);
  stroke(40, 25, 15);
  strokeWeight(1);
  for (int i = 0; i < 3; i++) {
    float legX = -8 + i * 8;
    line(legX, -5, legX - 2, -8);
    line(legX, 5, legX - 2, 8);
  }
  stroke(30, 20, 10);
  strokeWeight(1);
  line(-5, -3, 8, -3);
  line(-5, 3, 8, 3);
  popMatrix();
}

void drawLongSnake(float x, float y, float scale) {
  pushMatrix();
  translate(x, y);
  scale(scale);
  fill(0, 0, 0, 30);
  ellipse(2, 2, 45, 12);
  fill(30, 60, 20);
  stroke(20, 40, 15);
  strokeWeight(1);
  for (int i = 0; i < 10; i++) {
    float segX = i * 4 - 18;
    float segY = sin(i * 0.6) * 4;
    ellipse(segX, segY, 7, 5);
    fill(50, 80, 30);
    ellipse(segX, segY, 4, 3);
    fill(30, 60, 20);
  }
  fill(25, 50, 15);
  ellipse(22, 0, 12, 9);
  fill(255, 255, 0);
  ellipse(25, -2, 3, 3);
  ellipse(25, 2, 3, 3);
  fill(0, 0, 0);
  ellipse(25, -2, 1, 2);
  ellipse(25, 2, 1, 2);
  stroke(255, 50, 50);
  strokeWeight(1);
  line(28, 0, 32, -1);
  line(32, -1, 33, -2);
  line(32, -1, 33, 0);
  popMatrix();
}

void drawWorm(float x, float y, float scale) {
  pushMatrix();
  translate(x, y);
  scale(scale);
  fill(0, 0, 0, 25);
  ellipse(2, 2, 30, 6);
  fill(120, 80, 60);
  stroke(90, 60, 45);
  strokeWeight(1);
  for (int i = 0; i < 8; i++) {
    float segX = i * 3 - 12;
    float segY = sin(i * 0.6) * 2;
    ellipse(segX, segY, 6, 4);
  }
  fill(100, 70, 50);
  ellipse(12, 0, 7, 5);
  stroke(80, 50, 35);
  strokeWeight(0.5);
  for (int i = 0; i < 7; i++) {
    float segX = i * 3 - 9;
    line(segX, -2, segX, 2);
  }
  popMatrix();
}

void drawGlowInternal() {
  // Magical glow around labu
  float timeBase = millis() * 0.001;
  float glowFlicker = 0.8 + 0.2 * sin(timeBase * 10) + 0.1 * sin(timeBase * 25); // Flicker lebih dinamis
  float currentGlowAlpha = 255 * glowFlicker;

  fill(100, 50, 20, currentGlowAlpha * 0.15); // Alpha disesuaikan
  noStroke();
  ellipse(0, 10, 380, 220);
  fill(100, 50, 20, currentGlowAlpha * 0.12);
  ellipse(0, 10, 420, 250);
  fill(100, 50, 20, currentGlowAlpha * 0.09);
  ellipse(0, 10, 460, 280);

  // Insect glow (efek menyeramkan)
  fill(80, 40, 20, currentGlowAlpha * 0.25);
  ellipse(0, 50, 200, 120);
}

// --- Fungsi-fungsi Karakter ---
void drawIbuBawangMerah(float cx, float cy, float characterScale, float shockProgress) {
  pushMatrix();
  translate(cx, cy);
  scale(characterScale);
  fill(220, 220, 220, 100);
  noStroke();
  ellipse(0, 180, 140, 30);
  float leftFootOffset = (animationState == 1) ? sin(walkCycle) * stepHeight : 0;
  float rightFootOffset = (animationState == 1) ? sin(walkCycle + PI) * stepHeight : 0;
  fill(255, 220, 190);
  stroke(120, 60, 30);
  strokeWeight(3);
  ellipse(-20, 160 + leftFootOffset, 30, 45);
  ellipse(20, 160 + rightFootOffset, 30, 45);
  
  fill(220, 50, 50);
  stroke(180, 30, 30);
  strokeWeight(4);
  beginShape();
  vertex(0, -125);
  bezierVertex(15, -125, 40, -120, 65, -95);
  bezierVertex(100, -60, 85, -10, 80, 40);
  bezierVertex(75, 80, 60, 120, 40, 150);
  bezierVertex(25, 170, 10, 175, 0, 175);
  bezierVertex(-10, 175, -25, 170, -40, 150);
  bezierVertex(-60, 120, -75, 80, -80, 40);
  bezierVertex(-85, -10, -100, -60, -65, -95);
  bezierVertex(-40, -120, -15, -125, 0, -125);
  endShape(CLOSE);
  
  // PERBAIKAN: Memanggil drawLenganIbu tanpa parameter shockProgress
  drawLenganIbu(-70, 20, true);
  drawLenganIbu(70, 20, false);
  
  fill(255, 228, 196);
  stroke(139, 69, 19);
  strokeWeight(4);
  beginShape();
  vertex(0, -85);
  bezierVertex(50, -85, 70, -40, 65, -10);
  bezierVertex(60, 10, 30, 20, 0, 20);
  bezierVertex(-30, 20, -60, 10, -65, -10);
  bezierVertex(-70, -40, -50, -85, 0, -85);
  endShape(CLOSE);
  
  drawWajah(0, -30, shockProgress);
  
  fill(80, 40, 20);
  noStroke();
  beginShape();
  vertex(0, -85);
  bezierVertex(-20, -85, -50, -80, -65, -30);
  bezierVertex(-63, -15, -55, -5, -45, 5);
  bezierVertex(-35, 10, -28, -5, -28, -20);
  bezierVertex(-30, -50, -18, -70, 0, -80);
  endShape(CLOSE);
  beginShape();
  vertex(0, -85);
  bezierVertex(20, -85, 50, -80, 65, -30);
  bezierVertex(63, -15, 55, -5, 45, 5);
  bezierVertex(35, 10, 28, -5, 28, -20);
  bezierVertex(30, -50, 18, -70, 0, -80);
  endShape(CLOSE);
  
  drawTangkai(0, -120);
  popMatrix();
}


// PERBAIKAN UTAMA: Fungsi drawLenganIbu - TANGAN SELALU TERLIHAT
void drawLenganIbu(float x, float y, boolean kiri) {
  fill(255, 220, 190);
  stroke(120, 60, 30);
  strokeWeight(3);
  
  if (kiri) {
    float armSwing = (animationState == 3) ? sin(millis() * 0.005 * CUTTING_SPEED) * 8 : 0;
    beginShape();
    vertex(x + armSwing, y);
    bezierVertex(x - 25 + armSwing, y + 5, x - 35 + armSwing, y + 25, x - 30 + armSwing, y + 45);
    bezierVertex(x - 25 + armSwing, y + 55, x - 15 + armSwing, y + 50, x - 10 + armSwing, y + 40);
    bezierVertex(x - 5 + armSwing, y + 25, x + 5 + armSwing, y + 10, x + armSwing, y);
    endShape(CLOSE);
    
    if (animationState == 1 && knifeCarried) {
      pushMatrix();
      translate(x - 20, y + 30);
      rotate(radians(45));
      drawKnife(0, 0, 0.6);
      popMatrix();
    }
  } else {
    beginShape();
    vertex(x, y);
    bezierVertex(x + 25, y + 5, x + 35, y + 25, x + 30, y + 45);
    bezierVertex(x + 25, y + 55, x + 15, y + 50, x + 10, y + 40);
    bezierVertex(x + 5, y + 25, x - 5, y + 10, x, y);
    endShape(CLOSE);
  }
}

void drawTangkai(float x, float y) {
  fill(100, 180, 80);
  stroke(60, 140, 60);
  strokeWeight(3);
  beginShape();
  vertex(x - 30, y + 5);
  bezierVertex(x - 20, y + 10, x - 10, y + 10, x - 5, y + 5);
  bezierVertex(x, y, x + 10, y, x + 15, y + 5);
  bezierVertex(x + 20, y + 10, x + 30, y + 10, x + 35, y + 5);
  bezierVertex(x + 38, y - 10, x + 25, y - 65, x - 2, y - 95);
  bezierVertex(x - 18, y - 105, x - 25, y - 95, x - 20, y - 80);
  bezierVertex(x - 15, y - 60, x - 15, y - 30, x - 30, y + 5);
  endShape(CLOSE);
}

void drawWajah(float x, float y, float shockProgress) {
  // Mata kaget (lebih lebar, pupil kecil) - TERUS BERANIMASI
  noStroke();
  fill(255); // Warna putih mata
  float eyeWidth = lerp(6, 9, shockProgress);  
  float eyeHeight = lerp(6, 8, shockProgress);  
  float pupilSize = lerp(6, 4, shockProgress); // Pupil lebih kecil saat kaget

  ellipse(x - 20, y, eyeWidth, eyeHeight); // Mata kiri
  ellipse(x + 20, y, eyeWidth, eyeHeight); // Mata kanan
  fill(0); // Pupil
  ellipse(x - 20, y, pupilSize, pupilSize);
  ellipse(x + 20, y, pupilSize, pupilSize);

  // Alis kaget (terangkat) - TERUS BERANIMASI
  stroke(80, 40, 20);
  strokeWeight(3);
  noFill();
  float eyebrowYOffset = lerp(0, -4, shockProgress); // Alis terangkat lebih tinggi
  arc(x - 20, y - 10 + eyebrowYOffset, 25, 10, PI + QUARTER_PI, TWO_PI); // Alis kiri
  arc(x + 20, y - 10 + eyebrowYOffset, 25, 10, PI, PI + HALF_PI); // Alis kanan

  // Mulut kaget (terbuka 'O') - TERUS BERANIMASI
  stroke(120, 60, 30);
  strokeWeight(2);
  fill(200, 100, 100); // Warna dalam mulut
  float mouthWidth = lerp(25, 30, shockProgress);  
  float mouthHeight = lerp(15, 25, shockProgress); // Mulut lebih terbuka
  float mouthYOffset = lerp(30, 30, shockProgress);  

  ellipse(x, y + mouthYOffset, mouthWidth, mouthHeight); // Bentuk 'O'

  // Kerutan dahi kecil, lebih dekat ke alis, 2 gelombang horizontal
  stroke(139, 69, 19);
  strokeWeight(1.1);
  noFill();
  beginShape();
  vertex(x - 20, y - 25);
  bezierVertex(x - 18, y - 31, x - 10, y - 26, x - 4, y - 25);
  bezierVertex(x + 2, y - 31, x + 10, y - 26, x + 16, y - 25);
  endShape();
  beginShape();
  vertex(x - 20, y - 30);
  bezierVertex(x - 18, y - 36, x - 10, y - 31, x - 4, y - 30);
  bezierVertex(x + 2, y - 36, x + 10, y - 31, x + 16, y - 30);
  endShape();
}

// --- Fungsi-fungsi Bawang Merah (SAMA SEPERTI SEBELUMNYA) ---
void drawBawangMerah(float cx, float cy, float characterScale, float shockProgress) {
  pushMatrix();
  translate(cx, cy);
  scale(characterScale); // Terapkan skala untuk seluruh karakter

  // bayangan
  fill(220, 220, 220, 100);
  noStroke();
  ellipse(0, 180, 140, 30);

  // Animasi kaki saat jalan (hanya saat state 1)
  float leftFootOffset = 0;
  float rightFootOffset = 0;
  if (animationState == 1) {
    leftFootOffset = sin(walkCycle + 0.5) * stepHeight; // Sedikit berbeda dari ibu
    rightFootOffset = sin(walkCycle + 0.5 + PI) * stepHeight;
  }

  // kaki dengan animasi langkah
  fill(255, 220, 190);
  stroke(139, 69, 19);
  strokeWeight(3);
  ellipse(-30, 160 + leftFootOffset, 35, 45);
  ellipse(30, 160 + rightFootOffset, 35, 45);

  // === BADAN BAWANG ===
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

  // === GARIS-GARIS VERTIKAL BADAN ===
  stroke(180, 80, 115);
  strokeWeight(2);
  noFill();
  line(0, 25, 0, 155);
  bezierLine(-25, 30, -60, 50, -25, 155);
  bezierLine(25, 30, 60, 50, 25, 155);
  bezierLine(-12, 28, -35, 45, -12, 155);
  bezierLine(12, 28, 35, 45, 12, 155);

  // lengan
  fill(255, 220, 190);
  stroke(139, 69, 19);
  drawLenganBawangMerah(-60, 50, true);
  drawLenganBawangMerah(60, 50, false);

  // topi bawang
  fill(216, 112, 147);
  stroke(139, 69, 19);
  strokeWeight(4);
  beginShape();
  vertex(0, 30);
  bezierVertex(130, 30, 120, -60, 0, -135);
  bezierVertex(-120, -60, -130, 30, 0, 30);
  endShape(CLOSE);

  // === GARIS-GARIS TOPI ===
  stroke(180, 80, 115);
  strokeWeight(2);
  bezierLine(0, 25, 0, -60, 0, -130);
  bezierLine(-30, 25, -50, -40, -18, -120);
  bezierLine(30, 25, 50, -40, 18, -120);
  bezierLine(-40, 28, -90, -30, -45, -100);
  bezierLine(40, 28, 90, -30, 45, -100);

  // kepala
  fill(255, 228, 196);
  stroke(139, 69, 19);
  strokeWeight(4);
  beginShape();
  vertex(0, -80);
  bezierVertex(50, -85, 70, -40, 65, -10);
  bezierVertex(60, 10, 30, 20, 0, 20);
  bezierVertex(-30, 20, -60, 10, -65, -10);
  bezierVertex(-70, -40, -50, -85, 0, -80); // Titik akhir disesuaikan agar menyatu dengan titik awal
  endShape(CLOSE);

  // === MATA (kaget) - TERUS BERANIMASI ===
  noStroke();
  fill(255); // Warna putih mata
  float eyeWidthBamer = lerp(6, 9, shockProgress);
  float eyeHeightBamer = lerp(8, 9, shockProgress);
  float pupilSizeBamer = lerp(6, 4, shockProgress); // Pupil lebih kecil saat kaget

  ellipse(-22, -50, eyeWidthBamer, eyeHeightBamer); // kiri
  ellipse(22, -50, eyeWidthBamer, eyeHeightBamer); // kanan
  fill(0); // Pupil
  ellipse(-22, -50, pupilSizeBamer, pupilSizeBamer);
  ellipse(22, -50, pupilSizeBamer, pupilSizeBamer);

  // === ALIS (kaget) - TERUS BERANIMASI ===
  stroke(101, 67, 33);
  strokeWeight(3);
  float eyebrowYOffsetBamer = lerp(0, -4, shockProgress); // Alis terangkat lebih tinggi
  line(-30, -60 + eyebrowYOffsetBamer, -18, -55 + eyebrowYOffsetBamer); // alis kiri
  line(18, -55 + eyebrowYOffsetBamer, 30, -60 + eyebrowYOffsetBamer); // alis kanan

  // === MULUT (kaget) - TERUS BERANIMASI ===
  noFill();
  stroke(139, 69, 19);
  strokeWeight(2);
  fill(200, 100, 100); // Warna dalam mulut
  float mouthWidthBamer = lerp(20, 25, shockProgress);
  float mouthHeightBamer = lerp(10, 25, shockProgress); // Mulut lebih terbuka
  float mouthYOffsetBamer = lerp(-10, -10, shockProgress);  

  ellipse(0, mouthYOffsetBamer, mouthWidthBamer, mouthHeightBamer); // Bentuk 'O'

  // daun
  fill(154, 205, 50);
  stroke(107, 142, 35);
  strokeWeight(3);
  drawDaun(0, -130);

  popMatrix();
}

// utility: gambar garis lengkung badan
void bezierLine(float x1, float y1, float x2, float y2, float x3, float y3) {
  noFill();
  beginShape();
  vertex(x1, y1);
  bezierVertex(x2, y2, x2, y2 + 40, x3, y3);
  endShape();
}

// utility: gambar lengan (untuk Bawang Merah)
void drawLenganBawangMerah(float x, float y, boolean kiri) {
  beginShape();
  vertex(x, y);
  bezierVertex(x + (kiri ? -20 : 20), y - 5, x + (kiri ? -30 : 30), y + 5, x + (kiri ? -25 : 25), y + 20);
  bezierVertex(x + (kiri ? -25 : 25), y + 35, x + (kiri ? -20 : 20), y + 45, x + (kiri ? -10 : 10), y + 40);
  bezierVertex(x + (kiri ? -5 : 5), y + 35, x, y + 20, x, y);
  endShape(CLOSE);
}

// utility: gambar daun atas
void drawDaun(float x, float y) {
  // batang utama (runcing ke atas)
  stroke(107, 142, 30);
  strokeWeight(4);
  line(x, y, x, y - 50);

  // daun kiri (lancip)
  noStroke();
  fill(154, 205, 50);
  beginShape();
  vertex(x, y - 40);
  bezierVertex(x - 10, y - 55, x - 25, y - 60, x - 30, y - 45);
  bezierVertex(x - 20, y - 50, x - 10, y - 45, x, y - 40);
  endShape(CLOSE);

  // daun kanan (lancip)
  beginShape();
  vertex(x, y - 40);
  bezierVertex(x + 10, y - 55, x + 25, y - 60, x + 30, y - 45);
  bezierVertex(x + 20, y - 50, x + 10, y - 45, x, y - 40);
  endShape(CLOSE);
}

// Fungsi untuk menggambar pisau sesuai gambar yang diberikan
void drawKnife(float x, float y, float knifeScale) {
  pushMatrix();
  translate(x, y);
  scale(knifeScale);

  // Handle
  fill(139, 69, 19); // Coklat
  stroke(0);
  strokeWeight(2);
  rect(-5, -10, 80, 20, 5); // Handle utama, pegangan

  // Rivet
  fill(150);
  ellipse(5, 0, 5, 5);

  // Blade
  fill(190, 200, 210); // Abu-abu terang untuk bilah
  stroke(0);
  strokeWeight(2);
  beginShape();
  vertex(75, -20); // Ujung handle
  vertex(75, 10);  // Ujung handle
  vertex(210, 10); // Ujung bilah bawah
  vertex(200, -10);  // Ujung bilah runcing
  vertex(200, -10); // Ujung bilah atas
  endShape(CLOSE);

  // Refleksi pada bilah
  noStroke();
  fill(255, 255, 255, 100); // Putih transparan
  beginShape();
  vertex(85, -8);
  vertex(200, -8);
  vertex(190, -2);
  vertex(80, -2);
  endShape(CLOSE);

  fill(150, 160, 170, 100); // Abu-abu gelap transparan
  beginShape();
  vertex(90, 5);
  vertex(220, 5);
  vertex(210, 1);
  vertex(80, 1);
  endShape(CLOSE);

  popMatrix();
}
