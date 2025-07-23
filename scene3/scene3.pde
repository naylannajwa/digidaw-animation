import ddf.minim.*;
import processing.core.PFont;

//==================
//===== AUDIO =====
//==================
Minim minim;
AudioPlayer bgMusic;
AudioPlayer narasi_1;
AudioPlayer merah_1;
AudioPlayer narasi_2;
AudioPlayer putih_1;
AudioPlayer merah_2;
AudioPlayer putih_2;
AudioPlayer narasi_4; 
AudioPlayer merah_3;
AudioPlayer putih_3;
AudioPlayer merah_4;
AudioPlayer narasi_5;

//==================
//===== BUBBLE =====
//==================
String teksBubbleMerah = "";  
String teksBubblePutih = ""; 
PFont fontBubble;

color bubbleMerahFill, bubbleMerahStroke;
color bubblePutihFill, bubblePutihStroke;

//==================
//===== NARASI =====
//==================
PFont fontNarasi;

String teksNarasiSaatIni = "";
// Variabel untuk animasi teks per kalimat/potongan
String[] potonganNarasi_1;
long[] durasiTampil_1;

String[] potonganMerah_1; 
long[] durasiTampil_Merah_1;  

String[] potonganNarasi_2;
long[] durasiTampil_Narasi_2;   

String[] potonganPutih_1;   
long[] durasiTampil_Putih_1;  

String[] potonganMerah_2;
long[] durasiTampil_Merah_2;

String[] potonganPutih_2;
long[] durasiTampil_Putih_2;

String[] potonganNarasi_4;
long[] durasiTampil_Narasi_4;

String[] potonganMerah_3;
long[] durasiTampil_Merah_3;

String[] potonganPutih_3;
long[] durasiTampil_Putih_3;

String[] potonganMerah_4;
long[] durasiTampil_Merah_4;

String[] potonganNarasi_5;
long[] durasiTampil_Narasi_5;

int indeksPotonganTeks = 0;
long waktuUbahTeks = 0;
long durasiHilang = 500;
boolean tampilkanTeks = false;

// Ubah nama variabel ini agar lebih jelas
boolean animasiTeksAktif = false;
int modeNarasi = 0; // 0=diam, 1=narasi_1, 2=merah_1, 3=narasi_2

// Variabel untuk animasi teks mengetik
boolean animasiKetikAktif = false;
String teksLengkapUntukAnimasi = "";
int indeksKarakterAnimasi = 0;
long waktuKarakterTerakhir = 0;
int jedaKetik = 10;

float fadeInAlpha = 255; // Mulai dari hitam buram
float fadeInDuration = 2000; // Durasi fade-in dalam milidetik (misal 2 detik)
long sketchStartTime;

// Variabel untuk mengelola jeda dan status pemutaran
boolean merah1Played = false; // <-- PERHATIKAN: Ini seharusnya 'merah1Played' seperti yang sudah dibahas
boolean narasi1Finished = false;
long narasi1EndTime = 0;

boolean merah1Finished = false;
boolean narasi2Played = false;
long merah1EndTime = 0;

boolean narasi2Finished = false;
long narasi2EndTime = 0;

boolean putih1Played = false;
boolean putih1Finished = false;
long putih1EndTime = 0;

boolean merah2_played = false;
boolean merah2_finished = false;

boolean putih2_played = false;
boolean putih2_finished = false;
long putih2EndTime = 0;

boolean narasi4_played = false;
boolean narasi4_finished = false;
long narasi4EndTime = 0;

boolean merah3_played = false;
boolean merah3_finished = false; 

boolean putih3_played = false;
boolean putih3_finished = false;
// long putih3EndTime = 0;

boolean merah4_played = false;
boolean merah4_finished = false;
// long merah4EndTime = 0;

boolean narasi5_played = false;
boolean narasi5_finished = false;
long narasi5EndTime = 0; 

// --- BARU: Variabel untuk Fade Out ---
boolean fadeOutActive = false;
long fadeOutStartTime = 0;
float fadeOutDuration = 3000; // Durasi fade out dalam milidetik (misal 3 detik)

// --- BARU: Variabel untuk Asap Menggoreng ---
boolean showFryingSmoke = false;
int numSmokeParticles = 50;
float[] smokeX, smokeY, smokeSize, smokeAlpha;
float[] smokeSpeedY;
color smokeColor = color(200, 200, 200, 0); // Abu-abu terang, awalnya transparan

void settings() {
  size(1280, 720);
}

//===============================================================================
//=================================== SETUP =================================
//===============================================================================
void setup() {
  //==================
  //===== FONT =====
  //==================
  fontBubble = createFont("Ms Gothic", 14);
  textAlign(CENTER, CENTER);
  
  fontNarasi = createFont("Ms Gothic", 24); 
  textAlign(CENTER, CENTER);
  
  // Inisialisasi warna bubble
  bubbleMerahFill = color(255, 245, 245);       // Merah muda sangat pucat
  bubbleMerahStroke = color(216, 112, 147);      // Coklat tua
  bubblePutihFill = color(255);                // Putih bersih
  bubblePutihStroke = color(160, 140, 120);    // Abu kecoklatan (sesuai outline Putih)
  
  //==================
  //===== AUDIO =====
  //==================
  minim = new Minim(this);
  bgMusic = minim.loadFile("backsound.mp3", 2048);
  bgMusic.loop();
  bgMusic.setGain(-14.0);

  narasi_1 = minim.loadFile("narasi_1.mp3");
  narasi_1.setGain(20.0);
  narasi_1.play();
  narasi_1.setGain(8.0);

  merah_1 = minim.loadFile("merah_1.mp3");
  merah_1.setGain(8.0);
  
  narasi_2 = minim.loadFile("narasi_2.mp3");
  narasi_2.setGain(50.0);
  
  putih_1 = minim.loadFile("putih_1.mp3");
  putih_1.setGain(8.0);   
  
  merah_2 = minim.loadFile("merah_2.mp3"); 
  merah_2.setGain(8.0);
  
  putih_2 = minim.loadFile("putih_2.mp3");
  putih_2.setGain(8.0);  
  
  narasi_4 = minim.loadFile("narasi_4.mp3");
  narasi_4.setGain(50.0);
  
  merah_3 = minim.loadFile("merah_3.mp3");
  merah_3.setGain(8.0);
  
  putih_3 = minim.loadFile("putih_3.mp3");
  putih_3.setGain(8.0);
  
  merah_4 = minim.loadFile("merah_4.mp3");
  merah_4.setGain(8.0);
  
  narasi_5 = minim.loadFile("narasi_5.mp3");
  narasi_5.setGain(50.0); //YA ALLAH TERAKHIR AKHIRNYAAAAAAAAAAAAAAAAAA

  splatterY = new float[numSplatter];
  splatterXOffset = new float[numSplatter];
  splatterSpeed = new float[numSplatter];
  for (int i = 0; i < numSplatter; i++) {
    splatterY[i] = random(0, 50);
    splatterXOffset[i] = random(-10, 10);
    splatterSpeed[i] = random(0.5, 2.0);
  }

  // Inisialisasi warna ikan
  fishStartColor = color(255, 215, 0); // Kuning
  fishEndColor = color(139, 69, 19);    // Coklat
  colorAnimationStartTime = millis() / 2000.0; // Waktu mulai animasi (dalam detik)
  fishColorAnimating = true; // Mulai animasi saat program berjalan

  //bamer
  targetCharacterX = width * 0.3; // Define the target position
  characterX = targetCharacterX;    // Set the starting position to the target (no animation)

  // Inisialisasi variabel baru Bawang Merah
  bawangMerahAnimationState = 0;

  //baput
  bawangPutihStartX = width + 200;  // Tentukan posisi awal
  characterP = bawangPutihStartX;   // Atur karakter di posisi awal
  targetCharacterP = width - 270; // Target posisi tetap sama

  // Initialize new variables for Bawang Putih's animation
  startTime = millis(); // Record the sketch start time
  for (int i = 0; i < tearActive.length; i++) {
    tearActive[i] = false; // Ensure all tears are inactive at the start
  }

  // Initialize new variables for Bawang Putih's animation
  startTime = millis(); // Ini akan menjadi referensi waktu untuk fade-in juga
  sketchStartTime = millis(); // <-- Tambahkan ini untuk kejelasan, atau gunakan saja startTime
                              // Saya akan gunakan startTime yang sudah ada agar tidak terlalu banyak variabel

  for (int i = 0; i < tearActive.length; i++) {
    tearActive[i] = false;
  }
  
  // --- Inisialisasi Partikel Asap Menggoreng ---
  smokeX = new float[numSmokeParticles];
  smokeY = new float[numSmokeParticles];
  smokeSize = new float[numSmokeParticles];
  smokeAlpha = new float[numSmokeParticles];
  smokeSpeedY = new float[numSmokeParticles];
  
  for (int i = 0; i < numSmokeParticles; i++) {
    smokeX[i] = random(width * 0.45f, width * 0.55f); // Terpusat di atas kompor
    smokeY[i] = height * 0.45f; // Titik awal sedikit di atas kompor
    smokeSize[i] = random(10, 30);
    smokeAlpha[i] = 0; // Mulai tidak terlihat
    smokeSpeedY[i] = random(0.5f, 1.5f);
  }

  // Set initial alpha for fade-in
  fadeInAlpha = 255; // Pastikan dimulai dari buram penuh
  
  //===============================================================================
  //===================================NARASI DAN BUBBLE CHAT======================================
  //===============================================================================
  // --- Potongan Teks dan Durasi untuk NARASI 1 ---
  potonganNarasi_1 = new String[] {
    "Merah yang sering melihat Putih bermain riang dengan seekor ikan mas di sungai, mulai dipenuhi amarah.",
    "Hatinya membara melihat betapa bahagianya Putih bersama sahabat barunya itu.",
    "Kini, di dapur yang sunyi,",
    "Merah berdiri dengan senyum licik di wajahnya. Balas dendamnya telah terlaksana."
  };
  durasiTampil_1 = new long[] { 6500, 4500, 2500, 1000 };

  // --- Potongan Teks dan Durasi untuk MERAH 1 ---
  potonganMerah_1 = new String[] {
    "Huh, Dasar anak manja!",
    "Selalu saja main-main tidak berguna dengan ikan bodoh itu!",
    "Hehehehe...",
    "Tapi sekarang, ikan cantik ini akan jadi santapan lezat!",
    "Biar si Putih tahu rasanya kehilangan sahabat!"
  };
  durasiTampil_Merah_1 = new long[] { 3000, 3000, 1000, 3000, 4000 };

  // --- Potongan Teks dan Durasi untuk NARASI 2 ---
  potonganNarasi_2 = new String[] {
    "Putih berjalan masuk ke dapur dengan senyum bahagia di wajahnya.",
    "Dia tidak sabar ingin mengobrol dan bermain dengan ikan mas sahabatnya itu."
  };
  durasiTampil_Narasi_2 = new long[] { 4000, 3000 };
  
  // --- Potongan Teks dan Durasi untuk PUTIH 1 (Speech Bubble) ---
  potonganPutih_1 = new String[] {
    "Kak Merah!",
    "Aku izin main ke sungai dengan ikan mas kesayanganku, ya!",
    "Dia pasti sedang menungguku!"
  };
  durasiTampil_Putih_1 = new long[]{ 2500, 3500, 2500 };
  
  // --- Potongan Teks dan Durasi untuk MERAH 2 (Speech Bubble) ---
  potonganMerah_2 = new String[] {
    "Ohhhh... ikan mas yang ini? HAHAHAHA!",
    "Sudah jadi makan malam kita, nih, Putih!"
  };
  durasiTampil_Merah_2 = new long[]{ 5000, 3000 }; 
  
  // --- Potongan Teks dan Durasi untuk PUTIH 2 (BARU) ---
  potonganPutih_2 = new String[] {
    "Tidak! Tidak mungkin!",
    "Itu... itu kan sahabatku!"
  };
  durasiTampil_Putih_2 = new long[]{ 2500, 4000 };
  
  // TAMBAH INI setelah potonganPutih_2 dan durasiTampil_Putih_2
  potonganNarasi_4 = new String[] {
    "Air mata mulai mengalir di pipi Putih.",
    "Ia terdiam menangis melihat ikan mas sahabatnya yang sudah tidak bernyawa di dalam wajan."
  };
  durasiTampil_Narasi_4 = new long[]{ 4000, 5000 };
  
  // --- Potongan Teks dan Durasi untuk MERAH 3 (Speech Bubble BARU) ---
  potonganMerah_3 = new String[] {
    "HAHAHA! Iya! Ikan bodoh itu sudah menjadi hidangan lezat!",
    "Makanya jangan terlalu akrab sama binatang tidak jelas seperti itu, Putih!"
  };
  durasiTampil_Merah_3 = new long[]{ 4500, 4000 };
  
  // --- Potongan Teks dan Durasi untuk PUTIH 3 (Speech Bubble BARU) ---
  potonganPutih_3 = new String[] {
    "Huhuhu... Mengapa Kak Merah jahat sekali...",
    "Dia sahabat baikku...",
    "Dia tidak pernah berbuat jahat.."
  };
  durasiTampil_Putih_3 = new long[]{ 5500, 2500, 3000 };
  
  // --- Potongan Teks dan Durasi untuk MERAH 4 (Speech Bubble BARU) ---
  potonganMerah_4 = new String[] {
    "Rasakan!",
    "Biar kamu tahu betapa sakit hatinya aku selalu melihat kamu bahagia!"
  };
  durasiTampil_Merah_4 = new long[]{ 1800, 4500 };
  
  // --- Potongan Teks dan Durasi untuk NARASI 5 (BARU) ---
  potonganNarasi_5 = new String[] {
    "Putih terus menangis tersedu-sedu sambil berdiri,",
    "sementara Merah masih tertawa puas melihat kesedihan adik tirinya.",
    "Asap dari wajan masih mengepul,",
    "seolah menjadi saksi bisu kekejaman yang baru saja terjadi."
  };
  durasiTampil_Narasi_5 = new long[]{ 3500, 4000, 2000, 3500 };
}

//===============================================================================
//===================================DRAW========================================
//===============================================================================
void draw() {
  println("Mode saat ini: " + modeNarasi);
  background(180, 150, 110);

  // Gambar semua elemen dapur dan karakter terlebih dahulu
  drawEnhancedKitchen();
  
  if (showFryingSmoke) {
    drawFryingSmoke();
  }

    // Urutan yang Benar: Update logika dulu, baru gambar hasilnya
    updateTeksTerpotong();
    updateAnimasiKetik();
    drawNarrationText(); // Ini untuk narasi di bawah
    
    // --- BARU: Gambar Bubble Chat setelah semua elemen kitchen dan lampu digambar ---
    /// Gunakan posisi karakter Merah dan Putih
  if (!teksBubbleMerah.isEmpty()) {
    // Sesuaikan posisi Y ini agar gelembung muncul di atas kepala Merah dan tidak tertimpa lampu
    drawSpeechBubble("Merah", teksBubbleMerah, characterX, height * 0.45f); // Naikkan posisi Y
  }
  if (!teksBubblePutih.isEmpty()) {
    // Sesuaikan posisi Y ini agar gelembung muncul di atas kepala Putih dan tidak tertimpa lampu
    drawSpeechBubble("Putih", teksBubblePutih, characterP -170, height * 0.45f); // Naikkan posisi Y
  }

  // Gradual expression change (smoother)
  if (abs(currentExpression - targetExpression) > 0.001) {
    if (currentExpression < targetExpression) {
      currentExpression += expressionSpeed;
      if (currentExpression > targetExpression) {
        currentExpression = targetExpression;
      }
    } else if (currentExpression > targetExpression) {
      currentExpression -= expressionSpeed;
      if (currentExpression < targetExpression) {
        currentExpression = targetExpression;
      }
    }
  }

  // Gradual pupil movement (smoother)
  if (abs(pupilOffsetX - targetPupilOffsetX) > 0.05) {
    if (pupilOffsetX < targetPupilOffsetX) {
      pupilOffsetX += pupilSpeed;
      if (pupilOffsetX > targetPupilOffsetX) {
        pupilOffsetX = targetPupilOffsetX;
      }
    } else if (pupilOffsetX > targetPupilOffsetX) {
      pupilOffsetX -= pupilSpeed;
      if (pupilOffsetX < targetPupilOffsetX) {
        pupilOffsetX = targetPupilOffsetX;
      }
    }
  }


    // === LOGIKA PEMUTARAN AUDIO BERURUTAN DENGAN JEDA ===

  // Mulai animasi teks untuk narasi_1
  if (narasi_1.isPlaying() && !animasiTeksAktif && modeNarasi == 0) {
    mulaiAnimasi(1);
  }
  // Deteksi jika narasi_1 selesai
  if (!narasi_1.isPlaying() && !narasi1Finished) {
    narasi1Finished = true;
    narasi1EndTime = millis();
    animasiTeksAktif = false;
  }

  // Putar merah_1 setelah narasi_1 selesai + jeda
  // KOREKSI PENTING: Gunakan 'merah1Played' di sini, bukan 'merah2Played'
  // Pastikan Anda sudah mendeklarasikan boolean merah1Played di atas.
  if (narasi1Finished && (millis() - narasi1EndTime > 500) && !merah1Played) {
    merah_1.play();
    merah1Played = true;
    mulaiAnimasi(2);
    // Saat Merah 1 dimulai, asap penggorengan muncul
    showFryingSmoke = true; // <--- TAMBAHKAN BARIS INI
  }
  // Deteksi jika merah_1 selesai
  // KOREKSI PENTING: Gunakan 'merah1Played' di sini juga.
  if (merah1Played && !merah_1.isPlaying() && !merah1Finished) { // Menggunakan merah1Played
    merah1Finished = true;
    merah1EndTime = millis();
    animasiTeksAktif = false;
    teksBubbleMerah = "";
  }

  // Putar narasi_2 setelah merah_1 selesai + jeda
  if (merah1Finished && (millis() - merah1EndTime > 500) && !narasi2Played) {
    narasi_2.play();
    narasi2Played = true;
    mulaiAnimasi(3);
    bawangPutihAnimationState = 1;
  }
  // Deteksi jika narasi_2 selesai
  if (narasi2Played && !narasi_2.isPlaying() && !narasi2Finished) {
    narasi2Finished = true;
    narasi2EndTime = millis();
    animasiTeksAktif = false;
  }

  // Putar putih_1 setelah narasi_2 selesai + jeda
  if (narasi2Finished && (millis() - narasi2EndTime > 500) && !putih1Played) {
    putih_1.play();
    putih1Played = true;
    mulaiAnimasi(4);
  }
  // Deteksi jika putih_1 selesai
  if (putih1Played && !putih_1.isPlaying() && !putih1Finished) {
    putih1Finished = true;
    animasiTeksAktif = false;
    teksBubblePutih = "";
    putih1EndTime = millis(); // Penting: catat waktu selesai putih_1
  }

  // Putar merah_2 setelah putih_1 selesai + jeda
  if (putih1Finished && (millis() - putih1EndTime > 500) && !merah2_played) {
    merah_2.play();
    merah2_played = true;
    mulaiAnimasi(5);
  }

  // Deteksi jika merah_2 sudah selesai
  if (merah2_played && !merah_2.isPlaying() && !merah2_finished) {
    merah2_finished = true;
    // stateChangeTime = millis(); // Ini tidak relevan untuk audio chain, bisa dihapus atau pindah ke logika karakter
    teksBubbleMerah = ""; // Kosongkan bubble Merah
  }

  // Putar putih_2 setelah merah_2 selesai + jeda
  // KOREKSI JEDA: Pastikan ini menggunakan waktu selesai merah_2.
  // Jika Anda memiliki `long merah2EndTime = 0;` dan mengaturnya saat `merah2_finished = true;`, itu lebih baik.
  // Untuk saat ini, kita akan asumsikan Anda ingin jeda 3.5 detik setelah merah2_finished.
  // if (merah2_finished && (millis() - stateChangeTime > 3500) && !putih2_played) { // stateChangeTime di sini ambigu
  if (merah2_finished && (millis() - merah1EndTime > 3500) && !putih2_played) { // Menggunakan merah1EndTime sebagai patokan (sementara jika merah2EndTime belum ada)
      // IDEALNYA: if (merah2_finished && (millis() - merah2EndTime > 3500) && !putih2_played) {
      putih_2.play();
      putih2_played = true;
      mulaiAnimasi(6);
  }
  
  // Deteksi jika putih_2 selesai
  if (putih2_played && !putih_2.isPlaying() && !putih2_finished) {
    putih2_finished = true;
    animasiTeksAktif = false;
    teksBubblePutih = "";
    putih2EndTime = millis(); // Simpan waktu selesainya putih_2
  }

  // Putar narasi_4 setelah putih_2 selesai + jeda
  if (putih2_finished && (millis() - putih2EndTime > 500) && !narasi4_played) { // Jeda 500ms
    narasi_4.play();
    narasi4_played = true;
    mulaiAnimasi(7); // Mode 7 untuk narasi_4
    // Tambahan: Aktifkan animasi menangis Putih di sini jika ini pemicunya
    // bawangPutihAnimationState = 5;
  }

  // Deteksi jika narasi_4 selesai
  if (narasi4_played && !narasi_4.isPlaying() && !narasi4_finished) {
    narasi4_finished = true;
    animasiTeksAktif = false;
    narasi4EndTime = millis(); // Catat waktu narasi_4 selesai
    // Air mata tetap aktif setelah narasi selesai (jika bawangPutihAnimationState sudah 5)
  }

  // === TAMBAHAN: LOGIKA UNTUK MERAH_3 SETELAH NARASI_4 SELESAI ===
  if (narasi4_finished && (millis() - narasi4EndTime > 500) && !merah3_played) { // Jeda 500ms setelah narasi_4 selesai
    merah_3.play();
    merah3_played = true;
    mulaiAnimasi(8); // Mode 8 untuk Merah 3
  }

  // Deteksi jika merah_3 selesai
  if (merah3_played && !merah_3.isPlaying() && !merah3_finished) {
    merah3_finished = true;
    animasiTeksAktif = false;
    teksBubbleMerah = ""; // Kosongkan bubble Merah setelah selesai
  }
  
  if (merah3_finished && !putih3_played) { // Pemicu langsung setelah merah_3 selesai
    putih_3.play();
    putih3_played = true;
    mulaiAnimasi(9); // Mode BARU: 9 untuk Putih 3
    bawangPutihAnimationState = 5; // Pastikan Putih tetap menangis
  }

  // Deteksi jika putih_3 selesai
  if (putih3_played && !putih_3.isPlaying() && !putih3_finished) {
    putih3_finished = true;
    animasiTeksAktif = false;
    teksBubblePutih = ""; // Kosongkan bubble Putih setelah selesai
  }
  
   if (putih3_finished && !merah4_played) { // Pemicu langsung setelah putih_3 selesai
      merah_4.play();
      merah4_played = true;
      mulaiAnimasi(10); // Mode BARU: 10 untuk Merah 4
      // Perbarui ekspresi Bawang Merah jika perlu, misalnya kembali ke ekspresi licik/jahat
      // bawangMerahAnimationState = X; // Sesuaikan state Bawang Merah
  }
  
  // Deteksi jika merah_4 selesai
  if (merah4_played && !merah_4.isPlaying() && !merah4_finished) {
    merah4_finished = true;
    animasiTeksAktif = false;
    teksBubbleMerah = ""; // Kosongkan bubble Merah setelah selesai
    // merah4EndTime = millis(); // Catat waktu merah_4 selesai jika ada dialog/event setelahnya
  }
  
  if (merah4_finished && !narasi5_played) { // Pemicu langsung setelah merah_4 selesai
    narasi_5.play();
    narasi5_played = true;
    mulaiAnimasi(11); // Mode BARU: 11 untuk Narasi 5
    // Tidak perlu mengubah ekspresi karakter secara spesifik di sini,
    // karena narasi menjelaskan kondisi mereka.
  }
  
  // Di blok 'narasi5_finished':
   if (narasi5_played && !narasi_5.isPlaying() && !narasi5_finished) {
    narasi5_finished = true;
    narasi5EndTime = millis();
    animasiTeksAktif = false;
    
    // --- BARU: Picu fade out dan hentikan backsound ---
    if (bgMusic.isPlaying()) {
      bgMusic.close();
    }
    showFryingSmoke = false; // <--- TAMBAHKAN BARIS INI untuk mematikan asap
    fadeOutActive = true; // Mulai fade-out
    fadeOutStartTime = millis();
  }
  // === AKHIR LOGIKA AUDIO BERURUTAN ===

  // === LOGIKA BAWANG MERAH (STATE MACHINE BARU YANG REAKTIF) ===
  long currentTime = millis() - startTime;

  // State 0: Ekspresi awal, melihat ke bawah
  if (bawangMerahAnimationState == 0) {
    targetPupilOffsetX = 3;
    targetPupilOffsetY_Merah = 3;
    targetExpression = 0;
    if (currentTime > 19000) { // Transisi ke senyum licik (masih berbasis waktu)
      bawangMerahAnimationState = 1;
      bawangMerahStateChangeTime = millis();
    }
  } 
  // State 1: Senyum licik
  else if (bawangMerahAnimationState == 1) {
    targetPupilOffsetX = 0; 
    targetPupilOffsetY_Merah = 3;
    targetExpression = 1;
    if (millis() - bawangMerahStateChangeTime > 5000) { // Transisi ke tertawa jahat
      bawangMerahAnimationState = 2;
      bawangMerahStateChangeTime = millis();
    }
  } 
  // State 2: Tertawa jahat, menunggu Putih datang
  else if (bawangMerahAnimationState == 2) {
    targetPupilOffsetX = 3; 
    targetPupilOffsetY_Merah = 3;
    targetExpression = 2;
    
    // PERUBAHAN KUNCI: Pemicu baru berdasarkan audio Putih
    // Jika audio putih_1 sudah mulai diputar, ganti state menjadi 3 (melirik)
    if (putih1Played) {
      bawangMerahAnimationState = 3; 
    }
  }
  // State 3 (BARU): Melirik ke arah Putih
  else if (bawangMerahAnimationState == 3) {
    targetPupilOffsetX = 6;     // Pupil mata bergerak jauh ke samping (kanan)
    targetPupilOffsetY_Merah = 0; // Pandangan lurus ke depan
    targetExpression = 2;     // Tetap dengan ekspresi tertawa jahat
  }
  
  pupilOffsetY_Merah = lerp(pupilOffsetY_Merah, targetPupilOffsetY_Merah, pupilSpeed);
  // === AKHIR LOGIKA BAWANG MERAH ===

  //===============================================================================
  //====================== LOGIKA BAWANG PUTIH (DIPERBARUI) =======================
  //===============================================================================
  // State 1: Karakter bergerak masuk
  if (bawangPutihAnimationState == 1) {
    if (narasi_2.isPlaying()) {
      float progress = (float)narasi_2.position() / narasi_2.length();
      characterP = lerp(bawangPutihStartX, targetCharacterP, progress);
    } else {
      characterP = targetCharacterP;
      bawangPutihAnimationState = 2;
      stateChangeTime = millis();
    }
  }
  // State 2: Diam sejenak setelah sampai
  if (bawangPutihAnimationState == 2) {
    targetPupilOffsetY = 5; // Melihat ke bawah
    // Pemicu: Transisi ke state KAGET HANYA JIKA audio merah_2 sudah selesai
    if (merah2_finished) {
      bawangPutihAnimationState = 3; // Lanjut ke ekspresi kaget
      stateChangeTime = millis(); // Mulai timer untuk durasi kaget
    }
  }
  // State 3: KAGET (mulut 'O')
  else if (bawangPutihAnimationState == 3) {
    targetPupilOffsetY = 0; // Pandangan lurus ke depan
    
    // Tahan ekspresi kaget ini selama 1.5 detik
    if (millis() - stateChangeTime > 1800) {
      bawangPutihAnimationState = 4; // Setelah 1.5 detik, transisi ke state SEDIH
    }
  }
  // State 4: SEDIH (alis dan mulut berubah, tanpa air mata)
  else if (bawangPutihAnimationState == 4) {
    // PERUBAHAN: Langsung ubah ekspresi menjadi sedih secara instan
    currentExpressionP = 1;
    targetExpressionP = 1; // Samakan targetnya agar stabil dan tidak ada transisi
    // Tidak ada pemanggilan updateTears(), jadi tidak akan menangis
  }
  
  // TAMBAH State 5 setelah State 4 di logika Bawang Putih
  else if (bawangPutihAnimationState == 5) {
    currentExpressionP = 1; // Ekspresi sedih (alis menurun)
    targetExpressionP = 1;
    updateTears(); // Panggil fungsi update air mata
  }
  
  // TAMBAH BLOK INI - Transisi Putih ke state menangis saat narasi_4 dimulai
  if (narasi4_played && narasi_4.isPlaying() && bawangPutihAnimationState == 4) {
    bawangPutihAnimationState = 5; // Ubah ke state menangis
  }
  
  // Interpolasi pupil agar gerakannya mulus
  pupilOffsetY = lerp(pupilOffsetY, targetPupilOffsetY, pupilSpeedP);
  // Interpolasi ekspresi HANYA jika tidak di state 4
  if (bawangPutihAnimationState != 4 && bawangPutihAnimationState != 5) {
    currentExpressionP = lerp(currentExpressionP, targetExpressionP, expressionSpeedP);
  }
  
  // --- EFEK FADE-IN HITAM ---
  long elapsedTime = millis() - sketchStartTime;
  if (elapsedTime < fadeInDuration) {
    fadeInAlpha = map(elapsedTime, 0, fadeInDuration, 255, 0);
  } else {
    fadeInAlpha = 0;
  }
  if (fadeInAlpha > 0) {
    noStroke();
    fill(0, fadeInAlpha);
    rect(0, 0, width, height);
  }

  // --- BARU: Efek Fade Out di bagian paling akhir ---
  // Pastikan ini ada di SINI, di akhir draw()
  if (fadeOutActive) {
    long fadeElapsedTime = millis() - fadeOutStartTime;
    float currentFadeOutAlpha = map(fadeElapsedTime, 0, fadeOutDuration, 0, 255);
    currentFadeOutAlpha = constrain(currentFadeOutAlpha, 0, 255);

    noStroke();
    fill(0, currentFadeOutAlpha);
    rect(0, 0, width, height);

    if (fadeElapsedTime >= fadeOutDuration) {
      // exit(); // Ini akan menutup sketsa Processing setelah fade out selesai
    }
  }
}

void drawEnhancedKitchen() {
  // Dinding dengan pola grid dan highlight
  fill(240, 235, 210);
  rect(0, 0, width, height * 0.7f);

  // Highlight dinding dari cahaya
  fill(255, 255, 255, 20);
  rect(0, 0, width, height * 0.1f);

  // Shadow dinding bawah
  fill(0, 0, 0, 15);
  rect(0, height * 0.6f, width, height * 0.1f);

  stroke(180, 150, 110);
  strokeWeight(1);
  for (int y = 0; y < height * 0.7f; y += 40) line(0, y, width, y);
  for (int x = 0; x < width; x += 40) line(x, 0, x, height * 0.7f);

  // Kabinet atas dengan depth dan lighting
  drawUpperCabinets();

  // Kulkas dengan highlight dan shadow
  drawFridge();

  // Gantungan alat dengan enhanced lighting
  float rackY = height * 0.37f;
  float rackX_end = width * 0.3f + width * 0.665f;
  float rackX_start = rackX_end - 120 - 10;

  drawUtensilRackCircle(rackX_start - 150, rackY);
  drawUtensilRackMixed(rackX_start, rackY);

  //bamer
  pushMatrix();
  translate(characterX - width * 0.3, 0); // Adjust translation based on characterX
  drawBawangMerah();
  popMatrix();

  //baput
  pushMatrix();
  translate(characterP - (width - 100), 0); // Adjust translation based on characterX
  drawBawangPutih();
  popMatrix();

  // Lantai dengan gradient
  noStroke();
  // Shadow lantai
  fill(140, 100, 60);
  rect(0, height * 0.6f, width, height * 0.1f);
  // Lantai utama
  fill(164, 116, 73);
  rect(0, height * 0.6f + 5, width, height * 0.1f - 5);
  // Highlight lantai
  fill(200, 150, 100, 100);
  rect(0, height * 0.6f + 5, width, 20);

  // Lantai bawah dengan shadow dan highlight
  fill(190, 160, 120);
  rect(0, height * 0.7f, width, height * 0.2f);
  fill(230, 200, 160, 80);
  rect(0, height * 0.7f, width, 15);
  fill(0, 0, 0, 20);
  rect(0, height * 0.88f, width, height * 0.02f);

  // Kabinet bawah dengan depth dan lighting
  drawLowerCabinets();

  // Lampu animasi dengan enhanced glow
  drawAnimatedLight();

  // Bayangan dasar keseluruhan
  fill(0, 0, 0, 15);
  rect(0, height * 0.9f, width, height * 0.01f);

  // Kompor dengan enhanced lighting
  drawStove(width * 0.4f, true);
  drawStove(width * 0.5f, false);
}

void stop() {
    super.stop();
    bgMusic.close();
    narasi_1.close();
    merah_1.close();
    narasi_2.close();
    putih_1.close();
    merah_2.close();
    putih_2.close(); 
    narasi_4.close();
    merah_3.close();
    putih_3.close();
    merah_4.close();
    narasi_5.close();
    minim.stop();
}




//// Fungsi untuk MEMULAI animasi ketik
//void mulaiAnimasiKetik(String teksLengkap) {
//  teksLengkapUntukAnimasi = teksLengkap;
//  indeksKarakterAnimasi = 0;
//  animasiKetikAktif = true;
//  waktuKarakterTerakhir = millis();
//  teksNarasiSaatIni = ""; // Kosongkan narasi awal
//}

//// Fungsi untuk MENJALANKAN animasi ketik setiap frame
//void updateAnimasiKetik() {
//  if (!animasiKetikAktif) return;

//  if (millis() - waktuKarakterTerakhir > jedaKetik) {
//    indeksKarakterAnimasi++;
    
//    if (indeksKarakterAnimasi > teksLengkapUntukAnimasi.length()) {
//      indeksKarakterAnimasi = teksLengkapUntukAnimasi.length();
//      animasiKetikAktif = false;
//    }
    
//    // Animasi ini HANYA akan mengisi variabel teksNarasiSaatIni
//    teksNarasiSaatIni = teksLengkapUntukAnimasi.substring(0, indeksKarakterAnimasi);
    
//    waktuKarakterTerakhir = millis();
//  }
//}

// --- BARU: Fungsi untuk menggambar asap penggorengan ---
void drawFryingSmoke() {
  pushStyle();
  noStroke(); // Tidak ada garis tepi untuk partikel asap
  for (int i = 0; i < numSmokeParticles; i++) {
    // Perbarui posisi
    smokeY[i] -= smokeSpeedY[i]; // Bergerak ke atas
    smokeSize[i] += 0.2; // Membesar
    smokeAlpha[i] -= 0.5; // Memudar

    // Reset partikel jika sudah keluar layar atau terlalu transparan
    if (smokeY[i] < height * 0.2 || smokeAlpha[i] <= 0) {
      smokeX[i] = random(width * 0.4f, width * 0.6f); // Reset x di atas kompor
      smokeY[i] = height * 0.45f; // Reset y ke posisi sedikit di atas kompor
      smokeSize[i] = random(10, 30);
      smokeAlpha[i] = random(100, 200); // Reset dengan opasitas awal
      smokeSpeedY[i] = random(0.5f, 1.5f);
    }

    fill(smokeColor, smokeAlpha[i]);
    ellipse(smokeX[i], smokeY[i], smokeSize[i], smokeSize[i] * 0.8f); // Bentuk sedikit oval untuk efek asap
  }
  popStyle();
}




// Fungsi untuk menggambar teks narasi dengan gaya visual novel
void drawNarrationText() {
  // Hanya gambar jika ada teks narasi yang aktif
  if (!teksNarasiSaatIni.isEmpty()) {
    
    // --- 1. Gambar Kotak Label "Narasi" di Kiri Atas ---
    
    // Tentukan properti kotak label
    float labelBoxWidth = 100;
    float labelBoxHeight = 30;
    float labelBoxX = 40; // Jarak dari kiri
    float labelBoxY = height - 120; // Posisi dari bawah
    float cornerRadius = 10;
    
    // Gambar kotak label
    rectMode(CORNER); // Gunakan mode CORNER agar posisi X,Y dari pojok kiri atas
    noStroke();
    fill(0, 180); // Latar hitam
    rect(labelBoxX, labelBoxY, labelBoxWidth, labelBoxHeight, cornerRadius);
    
   // Gambar teks "Narasi"
    textFont(fontNarasi);
    textAlign(CENTER, CENTER);
    fill(255);
    textSize(16);
    text("Narasi", labelBoxX + labelBoxWidth / 2, labelBoxY + labelBoxHeight / 2);

    // --- 2. Gambar Kotak Utama untuk Isi Narasi ---
    
    // Tentukan properti kotak utama
    float mainBoxX = 40;
    float mainBoxY = height - 80;
    float mainBoxWidth = width - 80; // Lebar layar dikurangi padding kiri-kanan
    float mainBoxHeight = 50;
    
    // Gambar kotak utama
    stroke(0); // Garis tepi (stroke) hitam
    strokeWeight(1); // Ketebalan garis 1 piksel
    fill(255); // Latar putih
    rect(mainBoxX, mainBoxY, mainBoxWidth, mainBoxHeight, cornerRadius);
    
    // --- 3. Gambar Teks Narasi di Dalam Kotak Utama ---
    
    // Muat font "MS Gothic". Pastikan font ini sudah di-install di komputer Anda
    // atau letakkan file .ttf di dalam folder "data" pada sketch Anda.
    PFont msGothic = createFont("MS Gothic", 20);
    textFont(msGothic);
    
    textAlign(LEFT, CENTER); // Ratakan teks dari kiri atas
    noStroke();
    fill(0); // Teks hitam
    // Beri sedikit padding agar teks tidak menempel di tepi kotak
    text(teksNarasiSaatIni, mainBoxX + 20, mainBoxY + mainBoxHeight / 2, mainBoxWidth - 40);
  }
}

// Fungsi untuk menggambar gelembung ucapan (Posisi dan Font Disesuaikan)
// Fungsi untuk menggambar gelembung ucapan (Posisi dan Font Disesuaikan)
void drawSpeechBubble(String speakerName, String teks, float cx, float cy) {
  if (!teks.isEmpty()) {
    pushStyle();

    // --- Pengaturan Umum ---
    float cornerRadius = 30;
    textFont(fontNarasi);

    // --- 1. Kotak Utama untuk Isi Dialog ---
    float mainBoxWidth = 450;
    float mainBoxHeight = 80;
    float mainBoxX = cx - mainBoxWidth / 2;
    // PERUBAHAN DI SINI: Naikkan posisi Y agar gelembung muncul lebih tinggi
    // Sesuaikan nilai 'X' ini sampai Anda merasa pas di atas karakter
    float mainBoxY = cy - 230; 

    fill(255);
    stroke(200);
    strokeWeight(2);
    rect(mainBoxX, mainBoxY, mainBoxWidth, mainBoxHeight, cornerRadius);

    fill(0);
    noStroke();
    textAlign(LEFT, TOP);
    textSize(20);
    text(teks, mainBoxX + 20, mainBoxY + 15, mainBoxWidth - 40, mainBoxHeight - 30);

    // --- 2. Kotak Label Nama
    float labelBoxWidth = textWidth(speakerName) + 40;
    float labelBoxHeight = 40;
    float labelBoxX = mainBoxX;
    float gap = 5;
    float labelBoxY = mainBoxY - labelBoxHeight - gap;

    if (speakerName.equals("Merah")) {
      fill(216, 112, 147);
    } else if (speakerName.equals("Putih")) {
      fill(180);
    } else {
      fill(40, 80, 150);
    }

    stroke(255);
    strokeWeight(2);
    rect(labelBoxX, labelBoxY, labelBoxWidth, labelBoxHeight, cornerRadius);

    fill(255);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(18);
    text(speakerName, labelBoxX + labelBoxWidth / 2, labelBoxY + labelBoxHeight / 2);

    // --- 3. Ekor Segitiga ---
    fill(255);
    stroke(200);
    strokeWeight(2);
    float tailX = cx;
    float tailY = mainBoxY + mainBoxHeight;
    triangle(tailX - 15, tailY, tailX + 15, tailY, tailX, tailY + 15);

    popStyle();
  }
}

// Fungsi untuk memulai animasi teks (dengan perbaikan)
void mulaiAnimasi(int mode) {
  modeNarasi = mode;
  animasiTeksAktif = true;
  indeksPotonganTeks = 0;
  waktuUbahTeks = millis();
  
  // Reset semua teks terlebih dahulu
  teksNarasiSaatIni = "";
  teksBubbleMerah = "";
  teksBubblePutih = "";
  
  // Logika untuk menampilkan kalimat pertama
  if (mode == 1) {
    // Mode narasi_1 - gunakan animasi ketik
    mulaiAnimasiKetik(potonganNarasi_1[0]);
  } else if (mode == 2) {
    // Mode merah_1 - bubble chat
    teksBubbleMerah = potonganMerah_1[0];
  } else if (mode == 3) {
    // Mode narasi_2 - gunakan animasi ketik
    mulaiAnimasiKetik(potonganNarasi_2[0]);
  } else if (mode == 4) {
    // Mode putih_1 - bubble chat
    teksBubblePutih = potonganPutih_1[0];
  } else if (mode == 5) {
    // Mode merah_2 - bubble chat
    teksBubbleMerah = potonganMerah_2[0];
  } else if (mode == 6) {
    // Mode putih_2 - bubble chat
    teksBubblePutih = potonganPutih_2[0];
  } else if (mode == 7) {
    // Mode narasi_4 - gunakan animasi ketik
    mulaiAnimasiKetik(potonganNarasi_4[0]);
  } else if (mode == 8) {
    // Mode merah_3 - bubble chat
    teksBubbleMerah = potonganMerah_3[0];
  } else if (mode == 9) {
    // Mode putih_3 - bubble chat
    teksBubblePutih = potonganPutih_3[0];
  } else if (mode == 10) {
    // Mode merah_4 - bubble chat
    teksBubbleMerah = potonganMerah_4[0];
  } else if (mode == 11) {
    // Mode narasi_5 - gunakan animasi ketik
    mulaiAnimasiKetik(potonganNarasi_5[0]);
  }
  
  
}

// Fungsi untuk menjalankan logika animasi teks terpotong
void updateTeksTerpotong() {
  if (!animasiTeksAktif) {
    return;
  }

  String[] potonganAktif = {};
  long[] durasiAktif = {};

  // Pilih array yang sesuai dengan mode
  if (modeNarasi == 1) {
    potonganAktif = potonganNarasi_1;
    durasiAktif = durasiTampil_1;
  } else if (modeNarasi == 2) {
    potonganAktif = potonganMerah_1;
    durasiAktif = durasiTampil_Merah_1;
  } else if (modeNarasi == 3) {
    potonganAktif = potonganNarasi_2;
    durasiAktif = durasiTampil_Narasi_2;
  } else if (modeNarasi == 4) {
    potonganAktif = potonganPutih_1; 
    durasiAktif = durasiTampil_Putih_1;
  } else if (modeNarasi == 5) {
    potonganAktif = potonganMerah_2; 
    durasiAktif = durasiTampil_Merah_2;
  } else if (modeNarasi == 6) { 
    potonganAktif = potonganPutih_2; 
    durasiAktif = durasiTampil_Putih_2;
  } else if (modeNarasi == 7) {
    potonganAktif = potonganNarasi_4;
    durasiAktif = durasiTampil_Narasi_4;
  } else if (modeNarasi == 8) {
    potonganAktif = potonganMerah_3;
    durasiAktif = durasiTampil_Merah_3;
  } else if (modeNarasi == 9) {
    potonganAktif = potonganPutih_3;
    durasiAktif = durasiTampil_Putih_3;
  } else if (modeNarasi == 10) {
    potonganAktif = potonganMerah_4;
    durasiAktif = durasiTampil_Merah_4;
  } else if (modeNarasi == 11) {
    potonganAktif = potonganNarasi_5;
    durasiAktif = durasiTampil_Narasi_5;
  }

  if (potonganAktif.length == 0 || indeksPotonganTeks >= potonganAktif.length) {
    animasiTeksAktif = false;
    return;
  }

  // Cek apakah sudah waktunya untuk teks berikutnya
  if (millis() - waktuUbahTeks > durasiAktif[indeksPotonganTeks]) {
    indeksPotonganTeks++;
    
    if (indeksPotonganTeks < potonganAktif.length) {
      // Masih ada teks berikutnya
      String teksBerikutnya = potonganAktif[indeksPotonganTeks];
      
      // Tentukan jenis teks berdasarkan mode
      if (modeNarasi == 1 || modeNarasi == 3 || modeNarasi == 7 || modeNarasi == 11) {
        // Mode narasi - gunakan animasi ketik
        mulaiAnimasiKetik(teksBerikutnya);
      } else if (modeNarasi == 2 || modeNarasi == 5 || modeNarasi == 8 || modeNarasi == 10) {
        // Mode bubble Merah
        teksBubbleMerah = teksBerikutnya;
      } else if (modeNarasi == 4 || modeNarasi == 6 || modeNarasi == 9) {
        // Mode bubble Putih
        teksBubblePutih = teksBerikutnya;
      }
      
      waktuUbahTeks = millis();
    } else {
      // Semua teks sudah selesai
      animasiTeksAktif = false;
      
      // Bersihkan teks bubble jika bukan narasi
      if (modeNarasi != 1 && modeNarasi != 3 && modeNarasi != 7) { // Tambahkan mode 8 di sini
        if (modeNarasi == 2 || modeNarasi == 5 || modeNarasi == 8 || modeNarasi == 10) { // Tambahkan mode 8
          teksBubbleMerah = "";
        } else if (modeNarasi == 4 || modeNarasi == 6 || modeNarasi == 9) {
          teksBubblePutih = "";
        }
      }
    }
  }
}

// Fungsi untuk memulai animasi ketik (untuk narasi)
void mulaiAnimasiKetik(String teksLengkap) {
  animasiKetikAktif = true;
  teksLengkapUntukAnimasi = teksLengkap;
  indeksKarakterAnimasi = 0;
  teksNarasiSaatIni = ""; // Mulai dengan teks kosong
  waktuKarakterTerakhir = millis();
}

// Fungsi untuk update animasi ketik
void updateAnimasiKetik() {
  if (!animasiKetikAktif) {
    return;
  }
  
  if (millis() - waktuKarakterTerakhir > jedaKetik) {
    if (indeksKarakterAnimasi < teksLengkapUntukAnimasi.length()) {
      teksNarasiSaatIni += teksLengkapUntukAnimasi.charAt(indeksKarakterAnimasi);
      indeksKarakterAnimasi++;
      waktuKarakterTerakhir = millis();
    } else {
      animasiKetikAktif = false;
    }
  }
}




void drawUtensilRackCircle(float rackX, float rackY) {
  // Enhanced shadow rack
  fill(0, 0, 0, 30);
  rect(rackX - 10, rackY - 10, 135, 70);
  
  // Tiang vertikal dengan enhanced gradient
  fill(100, 100, 100);
  rect(rackX - 10, rackY - 10, 10, 60);
  rect(rackX + 120, rackY - 10, 10, 60);
  
  // Highlight tiang
  fill(200, 200, 200);
  rect(rackX - 10, rackY - 10, 3, 60);
  rect(rackX + 120, rackY - 10, 3, 60);
  
  // Shadow tiang
  fill(0, 0, 0, 40);
  rect(rackX - 7, rackY - 10, 3, 60);
  rect(rackX + 123, rackY - 10, 3, 60);
  
  // Gagang utama dengan depth
  fill(60, 60, 60);
  rect(rackX, rackY, 120, 6);
  
  // Highlight gagang
  fill(160, 160, 160);
  rect(rackX, rackY, 120, 2);
  
  // Shadow gagang
  fill(0, 0, 0, 60);
  rect(rackX, rackY + 4, 120, 2);

  for (int i = 0; i < 4; i++) {
    float hookX = rackX + 20 + i * 25;
    drawEnhancedHook(hookX, rackY, i, true);
  }
}

void drawUtensilRackMixed(float rackX, float rackY) {
  // Enhanced shadow rack
  fill(0, 0, 0, 30);
  rect(rackX - 10, rackY - 10, 135, 70);
  
  // Tiang vertikal dengan enhanced gradient
  fill(100, 100, 100);
  rect(rackX - 10, rackY - 10, 10, 60);
  rect(rackX + 120, rackY - 10, 10, 60);
  
  // Highlight tiang
  fill(200, 200, 200);
  rect(rackX - 10, rackY - 10, 3, 60);
  rect(rackX + 120, rackY - 10, 3, 60);
  
  // Shadow tiang
  fill(0, 0, 0, 40);
  rect(rackX - 7, rackY - 10, 3, 60);
  rect(rackX + 123, rackY - 10, 3, 60);
  
  // Gagang utama dengan depth
  fill(60, 60, 60);
  rect(rackX, rackY, 120, 6);
  
  // Highlight gagang
  fill(160, 160, 160);
  rect(rackX, rackY, 120, 2);
  
  // Shadow gagang
  fill(0, 0, 0, 60);
  rect(rackX, rackY + 4, 120, 2);

  for (int i = 0; i < 4; i++) {
    float hookX = rackX + 20 + i * 25;
    drawEnhancedHook(hookX, rackY, i, false);
  }
}

void drawEnhancedHook(float hookX, float rackY, int toolType, boolean isCircleRack) {
  // Enhanced shadow hook
  fill(0, 0, 0, 50);
  line(hookX + 2, rackY + 2, hookX + 2, rackY + 17);
  
  // Hook dengan enhanced detail
  stroke(80, 80, 80);
  strokeWeight(4);
  line(hookX, rackY, hookX, rackY + 15);
  arc(hookX, rackY + 15, 10, 10, 0, PI);
  
  // Highlight hook
  stroke(160, 160, 160);
  strokeWeight(1);
  line(hookX - 1, rackY, hookX - 1, rackY + 15);
  
  // Shadow hook curve
  stroke(40, 40, 40);
  strokeWeight(2);
  arc(hookX + 1, rackY + 16, 8, 8, 0, PI);

  // Enhanced shadow handle
  fill(0, 0, 0, 40);
  rect(hookX - 2, rackY + 18, 8, 32);
  
  // Handle kayu dengan enhanced woodgrain
  fill(139, 69, 19);
  noStroke();
  rect(hookX - 3, rackY + 15, 6, 30);
  
  // Woodgrain lines dengan variasi
  stroke(100, 50, 19, 200);
  strokeWeight(1);
  for (int j = 0; j < 4; j++) {
    line(hookX - 2, rackY + 18 + j * 6, hookX + 2, rackY + 18 + j * 6);
  }
  
  // Additional wood texture
  stroke(80, 40, 15, 100);
  strokeWeight(1);
  line(hookX - 1, rackY + 15, hookX - 1, rackY + 45);
  line(hookX + 1, rackY + 15, hookX + 1, rackY + 45);

  // Enhanced highlight handle
  fill(200, 140, 80);
  noStroke();
  rect(hookX - 2, rackY + 15, 2, 30);
  
  // Wood shine
  fill(255, 200, 150, 100);
  rect(hookX - 2, rackY + 15, 1, 30);

  // Kepala alat dengan enhanced shadows dan highlights
  float headY = rackY + 50;
  
  // Shadow kepala alat
  fill(0, 0, 0, 60);
  noStroke();
  
  if (isCircleRack) {
    switch (toolType) {
      case 0: // Spatula bulat
        ellipse(hookX + 1, headY + 1, 22, 22);
        break;
      case 1: // Spatula persegi
        rect(hookX - 7, headY - 4, 18, 12);
        break;
      case 2: // Sendok oval
        ellipse(hookX + 1, headY + 1, 17, 32);
        break;
      case 3: // Garpu segitiga
        triangle(hookX + 1, headY - 9, hookX - 9, headY + 11, hookX + 11, headY + 11);
        break;
    }
  } else {
    switch (toolType) {
      case 0: // Pisau
        rect(hookX - 2, headY - 4, 10, 22);
        break;
      case 1: // Centong
        ellipse(hookX + 1, headY + 1, 20, 27);
        break;
      case 2: // Sendok garpu
        rect(hookX - 3, headY - 4, 12, 22);
        break;
      case 3: // Whisk - shadow for wires
        for (int w = 0; w < 5; w++) {
          stroke(0, 0, 0, 80);
          strokeWeight(3);
          line(hookX - 6 + w * 3 + 1, headY - 4, hookX - 6 + w * 3 + 1, headY + 16);
        }
        break;
    }
  }
  
  // Kepala alat utama
  fill(60, 60, 60);
  noStroke();
  
  if (isCircleRack) {
    switch (toolType) {
      case 0: // Spatula bulat
        ellipse(hookX, headY, 20, 20);
        // Highlight spatula
        fill(120, 120, 120);
        ellipse(hookX - 3, headY - 3, 12, 12);
        break;
      case 1: // Spatula persegi
        rect(hookX - 8, headY - 5, 16, 10);
        // Highlight spatula
        fill(120, 120, 120);
        rect(hookX - 8, headY - 5, 16, 3);
        break;
      case 2: // Sendok oval
        ellipse(hookX, headY, 15, 30);
        // Highlight sendok
        fill(120, 120, 120);
        ellipse(hookX - 2, headY - 5, 10, 20);
        break;
      case 3: // Garpu segitiga
        triangle(hookX, headY - 10, hookX - 10, headY + 10, hookX + 10, headY + 10);
        // Highlight garpu
        fill(120, 120, 120);
        triangle(hookX, headY - 10, hookX - 5, headY + 5, hookX + 5, headY + 5);
        break;
    }
  } else {
    switch (toolType) {
      case 0: // Pisau
        rect(hookX - 3, headY - 5, 8, 20);
        // Highlight pisau
        fill(140, 140, 140);
        rect(hookX - 3, headY - 5, 2, 20);
        // Blade edge
        fill(200, 200, 200);
        rect(hookX - 1, headY - 5, 1, 20);
        break;
      case 1: // Centong
        ellipse(hookX, headY, 18, 25);
        // Highlight centong
        fill(120, 120, 120);
        ellipse(hookX - 3, headY - 3, 12, 18);
        break;
      case 2: // Sendok garpu
        rect(hookX - 4, headY - 5, 10, 20);
        // Highlight sendok garpu
        fill(120, 120, 120);
        rect(hookX - 4, headY - 5, 10, 6);
        // Prongs
        fill(60, 60, 60);
        for (int p = 0; p < 3; p++) {
          rect(hookX - 2 + p * 2, headY + 1, 1, 14);
        }
        break;
      case 3: // Whisk
        for (int w = 0; w < 5; w++) {
          // Wire shadows
          stroke(0, 0, 0, 60);
          strokeWeight(3);
          line(hookX - 6 + w * 3 + 1, headY - 4, hookX - 6 + w * 3 + 1, headY + 16);
          
          // Main wires
          stroke(60, 60, 60);
          strokeWeight(2);
          line(hookX - 6 + w * 3, headY - 5, hookX - 6 + w * 3, headY + 15);
          
          // Wire highlights
          stroke(120, 120, 120);
          strokeWeight(1);
          line(hookX - 6 + w * 3, headY - 5, hookX - 6 + w * 3, headY + 15);
        }
        break;
    }
  }
}




//BAWANG MERAH
float characterX; // posisi chara abmer
float targetCharacterX; // target posisi bamer
float entranceSpeed = 20.0; // Speed bamer

float currentExpression = 0; // 0: default, 1: sinister smile -> ini nanti default - sinis - tertawa jahat
float targetExpression = 0;
float expressionSpeed = 0.008; // Speed of expression change

float pupilOffsetX = 0; // Offset for pupil movement
float targetPupilOffsetX = 0; // Target pupil offset
float pupilSpeed = 0.08; // Speed of pupil movement

float armAngle = 0; // Angle for arm movement
float armSpeed = 0.05; // Speed of arm movement

String[] speechBubbles = {"HAHAHAHAHAHA", "Lihat ini Putih!", "Ikan mas goreng ini terlihat sangat lezat!"};
int currentBubble = -1; // -1: no bubble, 0: first bubble, etc.
int bubbleDisplayTime = 120; // How long each bubble stays (frames)
int bubbleTimer = 0; // Timer for bubble display

// Variabel baru untuk State Machine Bawang Merah
int bawangMerahAnimationState = 0; // 0: awal, 1: lihat depan, 2: senyum licik, 3: tertawa jahat
long bawangMerahStateChangeTime;

// Variabel baru untuk menggerakkan pupil mata Bawang Merah ke atas/bawah
float pupilOffsetY_Merah = 0;
float targetPupilOffsetY_Merah = 0;

void drawBawangMerah() {
   float cx = characterX, cy = height / 2.5 + 50; 

  // bayangan
  fill(220, 220, 220, 100);
  noStroke();
  ellipse(cx, cy + 180, 140, 30);

  // kaki
  fill(255, 220, 190);
  stroke(139, 69, 19);
  strokeWeight(3);
  ellipse(cx - 30, cy + 160, 35, 45);
  ellipse(cx + 30, cy + 160, 35, 45);

  // === BADAN BAWANG ===
  fill(216, 112, 147);
  stroke(139, 69, 19);
  strokeWeight(4);

  beginShape();
  vertex(cx, cy + 20);
  bezierVertex(cx + 90, cy + 30, cx + 100, cy + 80, cx + 95, cy + 120);
  bezierVertex(cx + 85, cy + 140, cx + 60, cy + 150, cx + 30, cy + 155);
  bezierVertex(cx + 10, cy + 158, cx - 10, cy + 158, cx - 30, cy + 155);
  bezierVertex(cx - 60, cy + 150, cx - 85, cy + 140, cx - 95, cy + 120);
  bezierVertex(cx - 100, cy + 80, cx - 90, cy + 30, cx, cy + 20);
  endShape(CLOSE);

  // === GARIS-GARIS VERTIKAL BADAN ===
  stroke(180, 80, 115);
  strokeWeight(2);
  noFill();

  // tengah
  line(cx, cy + 25, cx, cy + 155);

  // kiri luar
  beginShape();
  vertex(cx - 25, cy + 30);
  bezierVertex(cx - 60, cy + 50, cx - 70, cy + 90, cx - 65, cy + 130);
  bezierVertex(cx - 60, cy + 145, cx - 40, cy + 150, cx - 25, cy + 155);
  endShape();

  // kanan luar
  beginShape();
  vertex(cx + 25, cy + 30);
  bezierVertex(cx + 60, cy + 50, cx + 70, cy + 90, cx + 65, cy + 130);
  bezierVertex(cx + 60, cy + 145, cx + 40, cy + 150, cx + 25, cy + 155);
  endShape();

  // kiri dalam
  beginShape();
  vertex(cx - 12, cy + 28);
  bezierVertex(cx - 35, cy + 45, cx - 40, cy + 85, cx - 35, cy + 125);
  bezierVertex(cx - 30, cy + 145, cx - 20, cy + 150, cx - 12, cy + 155);
  endShape();

  // kanan dalam
  beginShape();
  vertex(cx + 12, cy + 28);
  bezierVertex(cx + 35, cy + 45, cx + 40, cy + 85, cx + 35, cy + 125);
  bezierVertex(cx + 30, cy + 145, cx + 20, cy + 150, cx + 12, cy + 155);
  endShape();

  // lengan
  fill(255, 220, 190);
  stroke(139, 69, 19);
  
  // Left arm (original)
  pushMatrix();
  translate(cx - 60, cy + 50);
  drawLengan(0, 0, true);
  popMatrix();
  
  // Right arm (animated with chopsticks)
  pushMatrix();
  translate(cx + 60, cy + 50);
  rotate(sin(armAngle) * 0.3); // Rotate based on sine wave for up/down motion
  drawLengan(0, 0, false);
  
  // Draw chopsticks in the right hand
  drawChopsticks(25, 30); // Position relative to arm
  popMatrix();
  
  armAngle += armSpeed; // Update arm angle

  // topi bawang
  fill(216, 112, 147);
  stroke(139, 69, 19);
  strokeWeight(4);
  beginShape();
  vertex(cx, cy + 30);
  bezierVertex(cx + 130, cy + 30, cx + 120, cy - 60, cx, cy - 135);
  bezierVertex(cx - 120, cy - 60, cx - 130, cy + 30, cx, cy + 30);
  endShape(CLOSE);

  // === GARIS-GARIS TOPI ===
  stroke(180, 80, 115);
  strokeWeight(2);

  bezierLine(cx, cy + 25, cx, cy - 60, cx, cy - 130); // tengah
  bezierLine(cx - 30, cy + 25, cx - 50, cy - 40, cx - 18, cy - 120); // kiri dalam
  bezierLine(cx + 30, cy + 25, cx + 50, cy - 40, cx + 18, cy - 120); // kanan dalam
  bezierLine(cx - 40, cy + 28, cx - 90, cy - 30, cx - 45, cy - 100); // kiri luar
  bezierLine(cx + 40, cy + 28, cx + 90, cy - 30, cx + 45, cy - 100); // kanan luar

  // kepala
  fill(255, 228, 196);
  stroke(139, 69, 19);
  strokeWeight(4);
  beginShape();
  vertex(cx, cy - 80);
  bezierVertex(cx + 50, cy - 85, cx + 70, cy - 40, cx + 65, cy - 10);
  bezierVertex(cx + 60, cy + 10, cx + 30, cy + 20, cx, cy + 20);
  bezierVertex(cx - 30, cy + 20, cx - 60, cy + 10, cx - 65, cy - 10);
  bezierVertex(cx - 70, cy - 40, cx - 50, cy - 85, cx, cy - 80);
  endShape(CLOSE);

  // Putih mata
  fill(255);
  stroke(139, 69, 19);
  strokeWeight(2);
  ellipse(cx - 22, cy - 50, 20, 16); // kiri
  ellipse(cx + 22, cy - 50, 20, 16); // kanan

  // Pupils (DIPERBARUI dengan pupilOffsetY_Merah)
  noStroke();
  fill(101, 67, 33);
  float pupilSize = lerp(8, 6, currentExpression);
  ellipse(cx - 22 + pupilOffsetX, cy - 50 + pupilOffsetY_Merah, pupilSize, pupilSize + 2); // kiri
  ellipse(cx + 22 + pupilOffsetX, cy - 50 + pupilOffsetY_Merah, pupilSize, pupilSize + 2); // kanan
  
  // === ALIS ===
  stroke(101, 67, 33);
  strokeWeight(3);
  
  // More dramatic eyebrow movement for sinister expression
  float eyebrowOffset = lerp(0, -6, currentExpression); // Gradual eyebrow raise
  float eyebrowAngle = lerp(0, 0.4, currentExpression); // More dramatic angle change
  
  // alis kiri (angled more dramatically)
  line(cx - 30, cy - 60 + eyebrowOffset, cx - 15, cy - 52 + eyebrowOffset - eyebrowAngle * 8);
  // alis kanan (angled more dramatically)
  line(cx + 15, cy - 52 + eyebrowOffset - eyebrowAngle * 8, cx + 30, cy - 60 + eyebrowOffset);
  
  // === MULUT ===
  noFill();
  stroke(139, 69, 19);
  strokeWeight(2);
  
  float mouthWidth;
  float leftMouthY, rightMouthY, leftControlY, rightControlY;
  
  // Koordinat Y dasar untuk mulut, relatif terhadap pusat karakter
  float mouthBaseY = cy;
  
  // Transisi dari netral (0) ke senyum licik simetris (1)
  if (currentExpression <= 1) {
      float t = currentExpression; // t adalah progres dari 0 ke 1
      mouthWidth = lerp(8, 15, t);
      
      // Interpolasi posisi vertikal dan lekukan mulut secara simetris
      float mouthY = mouthBaseY + lerp(-8, -5, t);
      float mouthCurve = lerp(-9, 7, t);
  
      leftMouthY = mouthY;
      rightMouthY = mouthY;
      leftControlY = mouthY + mouthCurve;
      rightControlY = mouthY + mouthCurve;
  }
  // Transisi dari senyum licik simetris (1) ke seringai jahat tidak simetris (2)
  else {
      float t = currentExpression - 1; // Normalisasi t untuk transisi 1 -> 2
  
      // DIUBAH: Lebar senyum diperpendek dan diperkecil
      mouthWidth = lerp(15, 19, t); 
  
      // DIUBAH: Kurva senyum dibuat lebih subtil
      // Sisi kiri mulut (kiri layar) naik sedikit
      leftMouthY = mouthBaseY + lerp(-5, -9, t); 
      // Sisi kanan mulut (kanan layar) hampir tidak berubah
      rightMouthY = mouthBaseY + lerp(-5, -4, t);
  
      // Sesuaikan titik kontrol bezier untuk kurva yang lebih kecil
      leftControlY = mouthBaseY + lerp(2, 6, t);
      rightControlY = mouthBaseY + lerp(2, 4, t);
  }
  
  // Gambar bentuk mulut akhir menggunakan kurva bezier
  beginShape();
  vertex(cx - mouthWidth, leftMouthY);
  bezierVertex(cx - mouthWidth / 2, leftControlY, cx + mouthWidth / 2, rightControlY, cx + mouthWidth, rightMouthY);
  endShape();
  
  // daun
  fill(154, 205, 50);
  stroke(107, 142, 35);
  strokeWeight(3);
  drawDaun(cx, cy - 130);
}


// Draw chopsticks
void drawChopsticks(float x, float y) {
  stroke(139, 69, 19); // Brown color for wooden chopsticks
  strokeWeight(3);
  
  // First chopstick
  line(x, y, x + 20, y - 25);
  
  // Second chopstick (slightly separated)
  line(x + 3, y + 2, x + 23, y - 23);
  
  // Chopstick tips (darker)
  stroke(101, 67, 33);
  strokeWeight(2);
  line(x + 18, y - 23, x + 20, y - 25);
  line(x + 21, y - 21, x + 23, y - 23);
}

// utility: gambar garis lengkung badan
void bezierLine(float x1, float y1, float x2, float y2, float x3, float y3) {
  noFill();
  beginShape();
  vertex(x1, y1);
  bezierVertex(x2, y2, x2, y2 + 40, x3, y3);
  endShape();
}

// utility: gambar lengan
void drawLengan(float x, float y, boolean kiri) {
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




//BAWANG PUTIH
float characterP; // posisi chara baput
float targetCharacterP; // target posisi baput
float bawangPutihStartX;

float currentExpressionP = 0; // 0: default/bahagia, 1: sedih menangis
float targetExpressionP = 0; // Target expression value
float expressionSpeedP = 0.008; // Speed of expression change

float pupilOffsetP = 0; // Offset for pupil movement
float targetPupilOffsetP = 0; // Target pupil offset
float pupilSpeedP = 0.08; // Speed of pupil movement

float armAngleP = 0; // Angle for arm movement
float armSpeedP = 0.05; // Speed of arm movement

// Variables untuk air mata
float[] tearDropsY = new float[6]; // posisi Y air mata
float[] tearDropsX = new float[6]; // posisi X air mata
boolean[] tearActive = new boolean[6]; // apakah air mata aktif
float tearSpeed = 2.0; // kecepatan jatuh air mata

String[] speechBubblesP = {"Selamat datang!", "Hihi...", "Aku di sini!"};
int currentBubbleP = -1; // -1: no bubble, 0: first bubble, etc.
int bubbleDisplayTimeP = 120; // How long each bubble stays (frames)
int bubbleTimerP = 0; // Timer for bubble display

// State machine and timing variables
int bawangPutihAnimationState = 0; // 0: waiting, 1: moving, 2: look down, 3: surprised, 4: crying
long startTime; // To track the initial 10-second delay
long stateChangeTime; // To time each state (like how long to look down)

// New variables for more expressive features
float pupilOffsetY = 0;
float targetPupilOffsetY = 0;

void updateTears() {
  float cx = characterP;
  float cy = height / 2.5 + 50;
  float eyeCenterY = cy - 50; // Posisi vertikal mata

  // Hanya munculkan air mata baru jika sedang dalam state menangis (state 5)
  if (bawangPutihAnimationState == 5 && random(1) < 0.15) { // 15% chance each frame
    for (int i = 0; i < tearDropsY.length; i++) {
      if (!tearActive[i]) {
        // PERUBAHAN: Tentukan posisi X dan Y air mata agar pas dengan mata
        tearDropsY[i] = eyeCenterY + 5; // Mulai dari bawah mata

        // Pilih secara acak antara mata kiri atau kanan
        if (random(1) < 0.5) {
          tearDropsX[i] = cx - 22; // Posisi X mata kiri
        } else {
          tearDropsX[i] = cx + 22; // Posisi X mata kanan
        }
        
        tearActive[i] = true;
        break; 
      }
    }
  }

  // Update posisi air mata yang aktif
  for (int i = 0; i < tearDropsY.length; i++) {
    if (tearActive[i]) {
      tearDropsY[i] += tearSpeed;
      if (tearDropsY[i] > height) {
        tearActive[i] = false;
      }
    }
  }
}

void drawBawangPutih() {
  float cx = characterP, cy = height / 2.5 + 50;

  // bayangan
  fill(220, 220, 220, 100);
  noStroke();
  ellipse(cx, cy + 180, 140, 30);

  // kaki
  fill(255, 220, 190);
  stroke(139, 69, 19);
  strokeWeight(3);
  ellipse(cx - 30, cy + 160, 35, 45);
  ellipse(cx + 30, cy + 160, 35, 45);

  // BADAN BAWANG PUTIH
  fill(245, 245, 235); //krem pucat
  stroke(160, 140, 120); //abu kecoklatan
  strokeWeight(4);

  beginShape();
  vertex(cx, cy + 20);
  bezierVertex(cx + 90, cy + 30, cx + 100, cy + 80, cx + 95, cy + 120);
  bezierVertex(cx + 85, cy + 140, cx + 60, cy + 150, cx + 30, cy + 155);
  bezierVertex(cx + 10, cy + 158, cx - 10, cy + 158, cx - 30, cy + 155);
  bezierVertex(cx - 60, cy + 150, cx - 85, cy + 140, cx - 95, cy + 120);
  bezierVertex(cx - 100, cy + 80, cx - 90, cy + 30, cx, cy + 20);
  endShape(CLOSE);

  // === GARIS-GARIS VERTIKAL BADAN ===
  stroke(190, 180, 160);
  strokeWeight(2);
  noFill();

  // tengah
  line(cx, cy + 25, cx, cy + 155);

  // kiri luar
  beginShape();
  vertex(cx - 25, cy + 30);
  bezierVertex(cx - 60, cy + 50, cx - 70, cy + 90, cx - 65, cy + 130);
  bezierVertex(cx - 60, cy + 145, cx - 40, cy + 150, cx - 25, cy + 155);
  endShape();

  // kanan luar
  beginShape();
  vertex(cx + 25, cy + 30);
  bezierVertex(cx + 60, cy + 50, cx + 70, cy + 90, cx + 65, cy + 130);
  bezierVertex(cx + 60, cy + 145, cx + 40, cy + 150, cx + 25, cy + 155);
  endShape();

  // kiri dalam
  beginShape();
  vertex(cx - 12, cy + 28);
  bezierVertex(cx - 35, cy + 45, cx - 40, cy + 85, cx - 35, cy + 125);
  bezierVertex(cx - 30, cy + 145, cx - 20, cy + 150, cx - 12, cy + 155);
  endShape();

  // kanan dalam
  beginShape();
  vertex(cx + 12, cy + 28);
  bezierVertex(cx + 35, cy + 45, cx + 40, cy + 85, cx + 35, cy + 125);
  bezierVertex(cx + 30, cy + 145, cx + 20, cy + 150, cx + 12, cy + 155);
  endShape();

  // lengan
  fill(255, 220, 190);
  stroke(139, 69, 19);
  // NOTE: You have drawLenganP but the provided code in the first block shows drawLengan.
  // Make sure you are using the correct function name. I'll use the name from the Merah code.
  drawLengan(cx - 60, cy + 50, true);
  drawLengan(cx + 60, cy + 50, false);

  // topi bawang
  fill(245, 245, 235);
  stroke(160, 140, 120);
  strokeWeight(4);
  beginShape();
  vertex(cx, cy + 30);
  bezierVertex(cx + 130, cy + 30, cx + 120, cy - 60, cx, cy - 135);
  bezierVertex(cx - 120, cy - 60, cx - 130, cy + 30, cx, cy + 30);
  endShape(CLOSE);

  // === GARIS-GARIS TOPI ===
  stroke(190, 180, 160);
  strokeWeight(2);
  // NOTE: Same as above, ensure you're using the correct function name like bezierLine
  bezierLine(cx, cy + 25, cx, cy - 60, cx, cy - 130); // tengah
  bezierLine(cx - 30, cy + 25, cx - 50, cy - 40, cx - 18, cy - 120); // kiri dalam
  bezierLine(cx + 30, cy + 25, cx + 50, cy - 40, cx + 18, cy - 120); // kanan dalam
  bezierLine(cx - 40, cy + 28, cx - 90, cy - 30, cx - 45, cy - 100); // kiri luar
  bezierLine(cx + 40, cy + 28, cx + 90, cy - 30, cx + 45, cy - 100); // kanan luar

  // --- (Head drawing code is the same) ---
  // kepala
  fill(255, 240, 220);
  stroke(160, 140, 120);
  strokeWeight(4);
  beginShape();
  vertex(cx, cy - 80);
  bezierVertex(cx + 50, cy - 85, cx + 70, cy - 40, cx + 65, cy - 10);
  bezierVertex(cx + 60, cy + 10, cx + 30, cy + 20, cx, cy + 20);
  bezierVertex(cx - 30, cy + 20, cx - 60, cy + 10, cx - 65, cy - 10);
  bezierVertex(cx - 70, cy - 40, cx - 50, cy - 85, cx, cy - 80);
  endShape(CLOSE);
  
  // === DYNAMIC FACE FEATURES START HERE ===

  // === MATA (pupils now move) ===
  noStroke();
  fill(101, 67, 33);
  // Use pupilOffsetY to control vertical movement
  ellipse(cx - 22, cy - 50 + pupilOffsetY, 8, 10); // kiri
  ellipse(cx + 22, cy - 50 + pupilOffsetY, 8, 10); // kanan
  
  // === ALIS (changes from happy to sad) ===
  stroke(101, 67, 33);
  strokeWeight(2);
  noFill();
  // Eyebrows droop as the expression value increases
  float eyebrowYOffset = lerp(0, 5, currentExpressionP);
  float eyebrowCurve = lerp(PI, 0, currentExpressionP); // lerp from U-shape to n-shape
  arc(cx - 22, cy - 61 + eyebrowYOffset, 15, 6, eyebrowCurve, eyebrowCurve + PI); // alis kiri
  arc(cx + 22, cy - 61 + eyebrowYOffset, 15, 6, eyebrowCurve, eyebrowCurve + PI); // alis kanan
  
  // === PIPI MERONA (blush) ===
  if (bawangPutihAnimationState != 3 && currentExpressionP < 0.5) {
  noStroke();
  fill(255, 182, 193, 150); // pink transparan
  ellipse(cx - 35, cy - 35, 20, 12); // pipi kiri
  ellipse(cx + 35, cy - 35, 20, 12); // pipi kanan
}

  // === MULUT (changes for surprised and sad) ===
  noFill();
  stroke(139, 69, 19);
  strokeWeight(2);
  
  if (bawangPutihAnimationState == 3) {
    // Surprised mouth: small circle
    fill(139, 69, 19);
    ellipse(cx, cy - 15, 10, 12);
  } else {
    // Mouth transitions from a smile to a frown
    float mouthY = lerp(cy - 20, cy - 15, currentExpressionP);
    float mouthCurveStart = lerp(0, PI, currentExpressionP);
    float mouthCurveEnd = lerp(PI, TWO_PI, currentExpressionP);
    arc(cx, mouthY, 30, 15, mouthCurveStart, mouthCurveEnd); 
  }

  // === AIR MATA (draws the active tears) ===
  if (currentExpressionP > 0.5) { // Only draw tears when visibly sad
    fill(100, 150, 255, lerp(0, 200, (currentExpressionP - 0.5) * 2)); // Fade in
    noStroke();
    for (int i = 0; i < tearDropsY.length; i++) {
      if (tearActive[i]) {
        ellipse(tearDropsX[i], tearDropsY[i], 5, 7);
      }
    }
  }

  // --- (daun drawing code remains the same) ---
  // daun
  fill(154, 205, 50);
  stroke(107, 142, 35);
  strokeWeight(3);
  // NOTE: Make sure you are using the correct function name.
  drawDaun(cx, cy - 130);
}




float[] splatterY, splatterXOffset, splatterSpeed;
int numSplatter = 20;

float lightAlpha = 255;
boolean lightDim = false;

color fishStartColor;
color fishEndColor;
float colorTransitionTime = 30.0; // durasi transisi warna ikan dalam detik
float colorAnimationStartTime;
boolean fishColorAnimating = false; // status animasi warna ikan

void drawFishWithSplatter(float fishX, float fishY) {
  // --- animasi warna ikan ---
  color currentFishColor;
  float t = 0; 

  if (fishColorAnimating) {
    float elapsedTime = (millis() / 1000.0) - colorAnimationStartTime;
    t = constrain(elapsedTime / colorTransitionTime, 0, 1); 

    currentFishColor = lerpColor(fishStartColor, fishEndColor, t);

    // reset animasi
    if (t >= 1) {
       fishColorAnimating = true; // animasi berhenti
      // kalo animasinya perlahan mengulang:
      //color temp = fishStartColor;
      //fishStartColor = fishEndColor;
      //fishEndColor = temp;
      //colorAnimationStartTime = millis() / 1000.0;
    }
  } else {
 
    currentFishColor = fishStartColor;
    t = 0; 
  }

  // Shadow ikan
  fill(0, 0, 0, 60);
  beginShape();
  vertex(fishX - 30 + 2, fishY + 2);
  bezierVertex(fishX - 20 + 2, fishY - 20 + 2, fishX + 20 + 2, fishY - 20 + 2, fishX + 30 + 2, fishY + 2);
  bezierVertex(fishX + 20 + 2, fishY + 20 + 2, fishX - 20 + 2, fishY + 20 + 2, fishX - 30 + 2, fishY + 2);
  vertex(fishX - 40 + 2, fishY - 10 + 2);
  vertex(fishX - 40 + 2, fishY + 10 + 2);
  endShape(CLOSE);

  // Ikan utama - gunakan currentFishColor
  fill(currentFishColor);
  beginShape();
  vertex(fishX - 30, fishY);
  bezierVertex(fishX - 20, fishY - 20, fishX + 20, fishY - 20, fishX + 30, fishY);
  bezierVertex(fishX + 20, fishY + 20, fishX - 20, fishY + 20, fishX - 30, fishY);
  vertex(fishX - 40, fishY - 10);
  vertex(fishX - 40, fishY + 10);
  endShape(CLOSE);

  // Highlight ikan - Menggunakan lerpColor untuk transisi highlight
  color highlightStartColor = color(255, 255, 150); // Kuning terang awal
  // Sesuaikan nilai RGB ini untuk mendapatkan highlight coklat yang Anda inginkan.
  // Ini adalah contoh coklat yang lebih terang dari warna ikan utama.
  color highlightEndColor = color(180, 100, 40); // Coklat terang untuk highlight

  color currentHighlightColor = lerpColor(highlightStartColor, highlightEndColor, t);
  fill(currentHighlightColor);

  beginShape();
  vertex(fishX - 25, fishY - 5);
  bezierVertex(fishX - 15, fishY - 15, fishX + 15, fishY - 15, fishX + 25, fishY - 5);
  bezierVertex(fishX + 15, fishY + 5, fishX - 15, fishY + 5, fishX - 25, fishY - 5);
  endShape(CLOSE);

  // Mata ikan
  fill(0);
  ellipse(fishX + 15, fishY - 5, 5, 5);
  fill(255);
  ellipse(fishX + 16, fishY - 6, 2, 2);

  // Garis masak dengan shadow
  stroke(80, 40, 0, 150);
  strokeWeight(2);
  line(fishX - 10 + 1, fishY - 8 + 1, fishX + 5 + 1, fishY + 8 + 1);
  line(fishX - 5 + 1, fishY - 10 + 1, fishX + 10 + 1, fishY + 5 + 1);

  stroke(100, 50, 0);
  strokeWeight(1);
  line(fishX - 10, fishY - 8, fishX + 5, fishY + 8);
  line(fishX - 5, fishY - 10, fishX + 10, fishY + 5);

  // Splatter dengan glow
  for (int i = 0; i < numSplatter; i++) {
    // Glow splatter
    fill(255, 200, 0, 50);
    noStroke();
    ellipse(fishX + splatterXOffset[i], fishY - splatterY[i], 8, 8);

    // Splatter utama
    fill(255, 200, 0, 180);
    ellipse(fishX + splatterXOffset[i], fishY - splatterY[i], 4, 4);

    // Highlight splatter
    fill(255, 255, 150, 200);
    ellipse(fishX + splatterXOffset[i] - 1, fishY - splatterY[i] - 1, 2, 2);

    splatterY[i] += splatterSpeed[i];
    splatterXOffset[i] += random(-0.5, 0.5);
    if (splatterY[i] > 50) {
      splatterY[i] = random(0, 10);
      splatterXOffset[i] = random(-20, 20);
      splatterSpeed[i] = random(0.5, 2.0);
    }
  }
}




void drawEnhancedFlame(float centerX, float flameY) {
  // Glow api
  for (int g = 0; g < 3; g++) {
    fill(255, 100, 0, 20 - g * 5);
    for (int i = -2; i <= 2; i++) {
      float fx = i * 12;
      ellipse(centerX + fx, flameY - 15, 40 + g * 10, 50 + g * 10);
    }
  }
  
  // Api utama 
  for (int i = -2; i <= 2; i++) {
    float fx = i * 12;
    float heightFlame = 35 + random(-5, 5);
    float widthFlame = 20 + random(-3, 3);
    
    // Shadow api
    fill(200, 80, 0, 100);
    noStroke();
    beginShape();
    vertex(centerX + fx - widthFlame / 2 + 2, flameY + 2);
    bezierVertex(centerX + fx - widthFlame / 3 + 4, flameY - heightFlame + 4,
                 centerX + fx + widthFlame / 3 + 4, flameY - heightFlame + 4,
                 centerX + fx + widthFlame / 2 + 4, flameY + 2);
    endShape(CLOSE);
    
    // Api utama - merah orange
    fill(255, 80 + random(-30, 30), 0, 200);
    beginShape();
    vertex(centerX + fx - widthFlame / 2, flameY);
    bezierVertex(centerX + fx - widthFlame / 3, flameY - heightFlame,
                 centerX + fx + widthFlame / 3, flameY - heightFlame,
                 centerX + fx + widthFlame / 2, flameY);
    endShape(CLOSE);
    
    // Highlight api - orange terang tanpa kuning
    fill(255, 150, 50, 150);
    beginShape();
    vertex(centerX + fx - widthFlame / 4, flameY);
    bezierVertex(centerX + fx - widthFlame / 6, flameY - heightFlame * 0.7,
                 centerX + fx + widthFlame / 6, flameY - heightFlame * 0.7,
                 centerX + fx + widthFlame / 4, flameY);
    endShape(CLOSE);
  }
}




void drawFridge() {
  float fridgeX = width * 0.04f;
  float fridgeY = height * 0.2f;
  float fridgeW = width * 0.15f;
  float fridgeH = height * 0.4f;
  
  // Shadow kulkas
  fill(0, 0, 0, 40);
  rect(fridgeX + 4, fridgeY + 4, fridgeW, fridgeH);
  
  // Kulkas utama - warna biru muda yang cocok
  fill(200, 220, 240); 
  noStroke();
  rect(fridgeX, fridgeY, fridgeW, fridgeH);
  
  // Highlight sisi kiri kulkas
  fill(255, 255, 255, 80);
  rect(fridgeX, fridgeY, 8, fridgeH);
  
  // Shadow sisi kanan kulkas
  fill(0, 0, 0, 15);
  rect(fridgeX + fridgeW - 8, fridgeY, 8, fridgeH);
  
  // Highlight atas kulkas
  fill(255, 255, 255, 60);
  rect(fridgeX, fridgeY, fridgeW, 8);
  
  // Garis pembagi dengan depth
  stroke(120, 140, 160); 
  strokeWeight(3);
  line(fridgeX, fridgeY + fridgeH * 0.625f, fridgeX + fridgeW, fridgeY + fridgeH * 0.625f);
  
  // Highlight garis pembagi
  stroke(220, 235, 250);
  strokeWeight(1);
  line(fridgeX, fridgeY + fridgeH * 0.625f + 1, fridgeX + fridgeW, fridgeY + fridgeH * 0.625f + 1);
  
  // Handle kulkas dengan shadow dan highlight
  noStroke();
  
  // Handle atas (freezer)
  float handleX = fridgeX + fridgeW - 10;
  float handleY1 = fridgeY + fridgeH * 0.125f;
  float handleH1 = fridgeH * 0.375f;
  
  // Shadow handle atas
  fill(0, 0, 0, 100);
  rect(handleX + 1, handleY1 + 1, 4, handleH1);
  
  // Handle atas utama
  fill(60, 60, 60);
  rect(handleX, handleY1, 4, handleH1);
  
  // Highlight handle atas
  fill(140, 140, 140);
  rect(handleX, handleY1, 1, handleH1);
  
  // Handle bawah (fridge)
  float handleY2 = fridgeY + fridgeH * 0.75f;
  float handleH2 = fridgeH * 0.125f;
  
  // Shadow handle bawah
  fill(0, 0, 0, 100);
  rect(handleX + 1, handleY2 + 1, 4, handleH2);
  
  // Handle bawah utama
  fill(60, 60, 60);
  rect(handleX, handleY2, 4, handleH2);
  
  // Highlight handle bawah
  fill(140, 140, 140);
  rect(handleX, handleY2, 1, handleH2);
}




void drawAnimatedLight() {
  float lampX = width * 0.5f;
  float lampY = height * 0.01f;
  
  // Shadow lampu
  fill(0, 0, 0, 40);
  ellipse(lampX + 2, lampY + 2, 30, 10);
  
  // Fixture lampu
  fill(80, 80, 80); 
  ellipse(lampX, lampY, 30, 10);
  
  // Highlight fixture
  fill(150, 150, 150);
  ellipse(lampX - 5, lampY - 2, 15, 5);
  
  // Cahaya utama dengan enhanced glow
  fill(255, 255, 150, lightAlpha);
  ellipse(lampX, lampY + 20, 50, 40);
  
  // Multiple glow layers
  noStroke();
  for (int i = 0; i < 8; i++) {
    float alpha = (30 - i * 3) + lightAlpha / 15;
    fill(255, 255, 150, alpha);
    ellipse(lampX, lampY + 20 + i * 8, 100 + i * 25, 80 + i * 20);
  }
  
  // Extra bright center
  fill(255, 255, 200, lightAlpha + 50);
  ellipse(lampX, lampY + 20, 30, 25);

  if (lightDim) lightAlpha -= 1.5;
  else lightAlpha += 1.5;
  if (lightAlpha > 255) { lightAlpha = 255; lightDim = true; }
  if (lightAlpha < 180) { lightAlpha = 180; lightDim = false; }
}




void drawLowerCabinets() {
  // Shadow kabinet bawah
  fill(0, 0, 0, 30);
  rect(5, height * 0.7f + 5, width - 5, height * 0.2f);
  
  // Kabinet utama
  fill(210, 180, 140); 
  rect(0, height * 0.7f, width, height * 0.2f);
  
  // Highlight atas kabinet
  fill(255, 255, 255, 60);
  rect(0, height * 0.7f, width, 8);
  
  // Shadow bawah kabinet
  fill(0, 0, 0, 40);
  rect(0, height * 0.87f, width, height * 0.03f);
  
  // Garis pembagi dengan depth
  stroke(160, 130, 100); 
  strokeWeight(2);
  for (int i = 1; i < 4; i++) {
    line(i * width / 4, height * 0.7f, i * width / 4, height * 0.9f);
  }
  
  // Highlight garis pembagi
  stroke(240, 220, 180);
  strokeWeight(1);
  for (int i = 1; i < 4; i++) {
    line(i * width / 4 + 1, height * 0.7f, i * width / 4 + 1, height * 0.9f);
  }
  
  // Garis horizontal dengan depth
  stroke(160, 130, 100);
  strokeWeight(2);
  line(0, height * 0.8f, width, height * 0.8f);
  stroke(240, 220, 180);
  strokeWeight(1);
  line(0, height * 0.8f + 1, width, height * 0.8f + 1);
  
  // Handle kabinet dengan shadow dan highlight
  noStroke();
  for (int i = 0; i < 4; i++) {
    float doorX = i * width / 4;
    float handleX = doorX + width / 8 - 10;
    float handleY = height * 0.77f - 15;
    
    // Shadow handle
    fill(0, 0, 0, 80);
    rect(handleX + 2, handleY + 2, 20, 6);
    
    // Handle utama
    fill(60, 60, 60);
    rect(handleX, handleY, 20, 6);
    
    // Highlight handle
    fill(140, 140, 140);
    rect(handleX, handleY, 20, 2);
  }
}




void drawStove(float stoveX, boolean withFlame) {
  float stoveY = height * 0.5f + 20;
  float stoveW = 100;
  float stoveH = 60;

  // Shadow kompor
  fill(0, 0, 0, 50);
  rect(stoveX + 3, stoveY + 3, stoveW, stoveH);
  
  // Badan kompor
  fill(40, 40, 40); 
  noStroke();
  rect(stoveX, stoveY, stoveW, stoveH);
  
  // Highlight atas kompor
  fill(100, 100, 100);
  rect(stoveX, stoveY, stoveW, 8);
  
  // Panel dalam kompor 
  fill(60, 60, 60); 
  rect(stoveX + 10, stoveY + 10, stoveW - 20, stoveH - 20);
  
  // Highlight panel dalam
  fill(90, 90, 90);
  rect(stoveX + 10, stoveY + 10, stoveW - 20, 5);

  // Wajan atau panci dengan enhanced lighting
  float centerX = stoveX + stoveW / 2;
  float panY = stoveY + stoveH / 4;
  
  if (withFlame) {
    // Shadow wajan
    fill(0, 0, 0, 80);
    ellipse(centerX + 2, panY + 2, 120, 20);
    
    // Wajan utama
    fill(60, 60, 60); 
    ellipse(centerX, panY, 120, 20);
    rect(centerX - 60, panY - 10, 120, 10);
    
    // Highlight wajan
    fill(120, 120, 120);
    ellipse(centerX - 10, panY - 3, 80, 12);
  
  } else {
    // Shadow panci
    fill(0, 0, 0, 80);
    ellipse(centerX + 2, panY + 2, 80, 30);
    
    // Panci utama
    fill(70, 70, 70); 
    ellipse(centerX, panY, 80, 30);
    
    // Highlight panci
    fill(130, 130, 130);
    ellipse(centerX - 5, panY - 5, 60, 20);
    
    // Bagian dalam panci
    fill(50, 50, 50); 
    rect(centerX - 30, panY - 15, 60, 10);
    
    // Highlight bagian dalam
    fill(100, 100, 100);
    rect(centerX - 30, panY - 15, 60, 3);
  }

  // Api dengan enhanced glow
  if (withFlame) {
    drawEnhancedFlame(centerX, stoveY + stoveH - 5);
    drawFishWithSplatter(centerX, panY - 10);
  }
}




void drawUpperCabinets() {
  // Tambahkan offset di sini
  float offsetX = 80; // Geser 50 piksel ke kanan
  float offsetY = -45; // Geser 30 piksel ke atas (nilai negatif untuk ke atas)

  // Shadow kabinet atas
  fill(0, 0, 0, 25);
  rect(width * 0.3f + offsetX + 3, height * 0.2f + offsetY + 3, width * 0.6f, height * 0.2f);

  // Kabinet utama
  fill(210, 180, 140);
  rect(width * 0.3f + offsetX, height * 0.2f + offsetY, width * 0.6f, height * 0.2f);

  // Highlight atas kabinet
  fill(255, 255, 255, 80);
  rect(width * 0.3f + offsetX, height * 0.2f + offsetY, width * 0.6f, 8);

  // Shadow bawah kabinet
  fill(0, 0, 0, 50);
  rect(width * 0.3f + offsetX, height * 0.38f + offsetY, width * 0.6f, height * 0.02f);

  // Garis pembagi dengan depth
  stroke(160, 130, 100);
  strokeWeight(2);
  for (int i = 1; i < 4; i++) {
    line(width * (0.3f + 0.15f * i) + offsetX, height * 0.2f + offsetY, width * (0.3f + 0.15f * i) + offsetX, height * 0.4f + offsetY);
  }

  // Highlight garis pembagi
  stroke(240, 220, 180);
  strokeWeight(1);
  for (int i = 1; i < 4; i++) {
    line(width * (0.3f + 0.15f * i) + offsetX + 1, height * 0.2f + offsetY, width * (0.3f + 0.15f * i) + offsetX + 1, height * 0.4f + offsetY);
  }

  // Handle kabinet dengan shadow dan highlight
  noStroke();
  for (int i = 0; i < 4; i++) {
    float handleX = width * (0.31f + 0.15f * i) - 3 + offsetX;
    float handleY = height * 0.3f - 10 + offsetY;

    // Shadow handle
    fill(0, 0, 0, 80);
    rect(handleX + 1, handleY + 1, 6, 20);

    // Handle utama
    fill(60, 60, 60);
    rect(handleX, handleY, 6, 20);

    // Highlight handle
    fill(140, 140, 140);
    rect(handleX, handleY, 2, 20);
  }
}
