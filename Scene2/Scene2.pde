import ddf.minim.*;
Minim minim;
PFont font;

AudioPlayer suaraAngin; // audio latar (looping)
AudioPlayer aliranAir;

// === SISTEM DIALOG & AUDIO TERPADU ===
DialogueLine[] dialogueSequence; // Array utama yang menyimpan seluruh urutan cerita
AudioPlayer[] playlist; // audio urutan (playlist)
String[] namaFilePlaylist = {
  "narasi_scene2-1.mp3",
  "ikan_1.mp3",
  "putih_1.mp3",
  "ikan_2.mp3",
  "putih_2.mp3",
  "ikan_3.mp3",
  "putih_3.mp3",
  "ikan_4.mp3",
  "putih_4.mp3",
  "narasi_scene2-2.mp3"
};

// === PENGATURAN VOLUME & KECEPATAN ===
float[] volumePlaylist = { // volume (gain dalam dB, 0 normal, nilai negatif lebih pelan, positif lebih keras)
  10,  // narasi_scene2-1.mp3
  10,    // ikan_1.mp3
  10,    // putih_1.mp3
  10,    // ikan_2.mp3
  10,    // putih_2.mp3
  10,    // ikan_3.mp3
  10,    // putih_3.mp3
  10,    // ikan_4.mp3
  10,    // putih_4.mp3
  10     // narasi_scene2-2.mp3
};

// === PENGATURAN ANIMASI TEKS NARASI ===
String currentDisplayDialogue = ""; // teks yang ditampilkan saat ini
int typingIndex = 0; // indeks karakter selanjutnya
int frameCounter = 0; // penghitung frame
int typingSpeed = 2; // Jeda antar pengetikan (makin kecil, makin cepat jedanya)
int charsPerFrame =6; // Jumlah karakter yang muncul sekaligus per update
int indeksKalimat = 0; // Melacak kalimat mana dalam narasi yang sedang ditampilkan
String[] kalimatNarasi; // Array untuk menyimpan kalimat-kalimat dari satu blok narasi
boolean gantiKalimat = false; // Penanda untuk mengganti kalimat
long waktuGantiKalimat; // Timer untuk jeda antar kalimat

boolean audioHasStarted = false; // penanda audio sudah mulai atau belum
int trackSekarang = 0; // indeks untuk melacak lagu mana yang sedang diputar
boolean urutanSelesai = false; // penanda jika semua sound sudah selesai
boolean sedangJeda = false;       // Penanda jika kita sedang dalam masa jeda

// variabel kontrol jeda dan pause
long waktuJedaSelesai = 0; // menyimpan waktu kapan jeda harus berakhir
final long DURASI_JEDA = 10; // jeda 1 detik (dalam milidetik), bisa diubah

// === VARIABEL FADE ===
int fadeState = 0; // 0 untuk FADE_IN, 1 untuk NORMAL, 2 untuk FADE_OUT
final int FADE_IN = 0;
final int NORMAL = 1;
final int FADE_OUT = 2;
float fadeAlpha = 255; // nilai transparansi (0-255)
float fadeInSpeed = 20; // kecepatan untuk fade in (dibuat lebih lambat)
float fadeOutSpeed = 20; // kecepatan untuk fade out (dibuat lebih cepat)

float cloudX1, cloudX2, cloudX3, cloudX4;
float waterOffset = 0;
float waveOffset = 0;
float grassWindOffset = 0;
float offset = 0;
float armAngleOffset = 0;
float legAngleOffset = 0;
float treeOffset;
float sunRayOffset;
float sungaiY;
float[] birdX = new float[5];
float[] birdY = new float[5];
float[] birdSpeed = new float[5];
float[] birdWingOffset = new float[5];
float[] birdSize = new float[5];
float[] birdBaseY = new float[5];
float speed = 1;
float garlicX, garlicY;
float targetX,targetY;
boolean garlicIsShocked = false;
boolean isPermanentlyHappy = false;

// === VARIABEL IKAN ===
float fishX, fishY;
float fishJumpY = fishY;
float fishJumpSpeed = 0;
boolean fishIsJumping = false;
float fishTailOffset = 0;
float fishSize;
boolean fishVisible = false;
boolean fishHasJumped = false;
float garlicStopTimer = 0;

int numFlows = 50;
float[] startXList = new float[numFlows];
int[] lengthList = new int[numFlows];

class DialogueLine { // class untuk menyimpan satu baris dialog lengkap
  String speaker;
  String text;
  String audioFileName;

  DialogueLine(String speaker, String text, String audioFileName) {
    this.speaker = speaker;
    this.text = text;
    this.audioFileName = audioFileName;
  }
}

void setup() {
  size(1280, 720);
  frameRate(30);
  font = createFont("MS Gothic", 24); // Font Jepang
  
  // === MEMBUAT URUTAN CERITA ===
  dialogueSequence = new DialogueLine[] {
    new DialogueLine("Narasi", "Suatu hari, saat Putih sedang ingin mencuci baju di tepi sungai, hatinya terasa begitu pilu. Ia menatap arus air yang mengalir sambil mengingat kenangan bersama ayahnya. Tiba-tiba, dari dalam air muncul cahaya berkilau, dan muncullah seekor ikan mas berwarna keemasan. Ikan itu melompat ke permukaan dan berbicara.", "narasi_scene2-1.mp3"),
    new DialogueLine("Ikan", "Mengapa kamu bersedih, gadis kecil?", "ikan_1.mp3"),
    new DialogueLine("Putih", "Si... siapa kamu?! Kenapa kamu bisa bicara? Kamu... seekor ikan!", "putih_1.mp3"),
    new DialogueLine("Ikan", "Benar, aku memang ikan, tapi aku adalah ikan mas ajaib. Aku muncul karena aku bisa merasakan kesedihanmu.", "ikan_2.mp3"),
    new DialogueLine("Putih", "Oh uhm.. Aku hanya... rindu ayahku. Sejak ayahku tiada, semuanya berubah.", "putih_2.mp3"),
    new DialogueLine("Ikan", "Jangan bersedih, Putih. Aku tau kamu gadis yang baik dan sabar. Sekarang kamu tidak sendiri lagi. Aku akan menjadi temanmu!", "ikan_3.mp3"),
    new DialogueLine("Putih", "Kamu benar-benar ingin jadi temanku?", "putih_3.mp3"),
    new DialogueLine("Ikan", "Tentu. Aku akan menemanimu setiap kali kamu datang ke sungai ini.", "ikan_4.mp3"),
    new DialogueLine("Putih", "Terima kasih... aku senang sekali bisa punya teman seperti kamu.", "putih_4.mp3"),
    new DialogueLine("Narasi", "Setelah pertemuan itu, Putih dan ikan mas ajaib pun menjadi sahabat sejati yang selalu bertemu di sungai. Setiap kali Putih merasa sedih atau lelah, ikan itu akan muncul untuk menghiburnya. Putih sangat senang bisa bertemu dengan ikan ajaib tersebut.", "narasi_scene2-2.mp3")
  };

  // === INISIALISASI AUDIO BERDASARKAN URUTAN CERITA ===
  minim = new Minim(this);
  suaraAngin = minim.loadFile("suara_angin.mp3");  // muat audio latar (jangan diputar dulu)
  aliranAir = minim.loadFile("aliran_air.mp3");
  aliranAir.setGain(-20);
  suaraAngin.setGain(-10);
  
  playlist = new AudioPlayer[dialogueSequence.length]; // muat semua file audio dari urutan dialog
  for (int i = 0; i < dialogueSequence.length; i++) {
    String filename = dialogueSequence[i].audioFileName;
    playlist[i] = minim.loadFile(filename);
    if (playlist[i] == null) {
      println("ERROR: Gagal memuat file: " + filename);
      exit();
    }
  }
  
  cloudX1 = width * 0.1;
  cloudX2 = width * 0.7;
  cloudX3 = width * 1;
  cloudX4 = width * 1.4;
  waterOffset = 0;
  treeOffset = 0;
  sunRayOffset = 0;
  armAngleOffset = 0;
  garlicX = 1050; // posisi depan pintu rumah
  garlicY = 430;
  targetX = 570; // dekat sungai (550/395)
  targetY = 470;
  fishX = 400; // posisi x ikan
  fishY = 550; // posisi y ikan
  fishJumpY = fishY;
  fishSize = 2.2; // size ikan
  
  for (int i = 0; i < 5; i++) {
    birdX[i] = -200 * i; // jarak antar burung minimal 100px
    birdBaseY[i] = random(30, height * 0.3);
    birdY[i] = birdBaseY[i];
    birdSpeed[i] = random(1.0, 3.5);
    birdWingOffset[i] = random(0, TWO_PI);
    birdSize[i] = random(0.5, 1);
  }
    sungaiY = height / 2 + 50;

  for (int i = 0; i < numFlows; i++) { // posisi X acak tapi tidak terlalu berdekatan
    boolean valid = false;
    while (!valid) {
      float candidateX = random(10, width - 100);  // dari kanan agar tidak langsung keluar ke kiri
      valid = true;
      for (int j = 0; j < i; j++) {
        if (abs(candidateX - startXList[j]) < 15) {
          valid = false;
          break;
        }
      }
      if (valid) startXList[i] = candidateX;
    }

    lengthList[i] = int(random(1, 4));  // acak panjang 1, 2, 3
  }
  fadeState = FADE_IN; // inisialisasi status fade
  fadeAlpha = 255; // mulai dari layar hitam pekat
}

void draw() {
  // === BACKGROUND LANGIT ===
  background(135, 206, 250);

  // === MATAHARI ===
  fill(255, 255, 0);
  noStroke();
  ellipse(150, 100, 80, 80); // lingkaran utama matahari

  fill(255, 255, 150, 100);  // gradient effect untuk matahari
  ellipse(150, 100, 65, 65);
  
  stroke(255, 255, 0); // sinar panjang (seperti pada gambar)
  strokeWeight(4);
  
  for (int i = 0; i < 16; i++) {
    float angle = TWO_PI / 16 * i + sunRayOffset;
    float rayLength = 25 + sin(angle * 3) * 3; // variasi panjang sinar
    float x1 = 150 + cos(angle) * 45; // titik awal sinar (dari tepi matahari)
    float y1 = 100 + sin(angle) * 45;
    float x2 = 150 + cos(angle) * (45 + rayLength); // titik akhir sinar
    float y2 = 100 + sin(angle) * (45 + rayLength);
    
    strokeWeight(6); // membuat sinar dengan efek meruncing
    stroke(255, 255, 0, 200);
    line(x1, y1, x2, y2);
    
    strokeWeight(2); // sinar kedua lebih tipis
    stroke(255, 255, 150, 150);
    line(x1, y1, x2, y2);
  }
  
  for (int i = 0; i < 16; i++) { // sinar tambahan yang lebih pendek di antara sinar utama
    float angle = TWO_PI / 16 * i + sunRayOffset + PI/16;
    
    float x1 = 150 + cos(angle) * 45;
    float y1 = 100 + sin(angle) * 45;
    float x2 = 150 + cos(angle) * 60;
    float y2 = 100 + sin(angle) * 60;
    
    strokeWeight(3);
    stroke(255, 255, 0, 120);
    line(x1, y1, x2, y2);
  }
  
  sunRayOffset += 0.03; // kecepatan rotasi sinar matahari
  fill(255, 255, 100); // lingkaran dalam matahari
  noStroke();
  ellipse(150, 100, 50, 50);
  fill(255, 255, 255, 100);  // highlight pada matahari
  ellipse(145, 95, 15, 15);
  
  // === BUKIT HUTAN ===
  fill(34, 95, 38);
  noStroke();
  beginShape();
  vertex(0, height / 2 - 50);
  bezierVertex(width * 0.05, height / 2 - 120, width * 0.10, height / 2 - 20, width * 0.15, height / 2 - 80);
  bezierVertex(width * 0.20, height / 2 - 140, width * 0.25, height / 2 - 70, width * 0.30, height / 2 - 50);
  bezierVertex(width * 0.35, height / 2 - 30, width * 0.40, height / 2 - 110, width * 0.45, height / 2 - 120);
  bezierVertex(width * 0.50, height / 2 - 140, width * 0.55, height / 2 - 30, width * 0.60, height / 2 - 40);
  bezierVertex(width * 0.65, height / 2 - 50, width * 0.70, height / 2 - 140, width * 0.75, height / 2 - 120);
  bezierVertex(width * 0.80, height / 2 - 100, width * 0.85, height / 2 - 40, width * 0.90, height / 2 - 90);
  bezierVertex(width * 0.95, height / 2 - 140, width, height / 2 - 60, width, height / 2 - 60);
  vertex(width, height / 2 + 50);
  vertex(0, height / 2 + 50);
  endShape(CLOSE);

  // === HIGHLIGHT BUKIT ===
  fill(76, 175, 80, 140);
  noStroke();
  beginShape();
  
  // === BAGIAN ATAS BUKIT ===
  vertex(0, height / 2 - 50);
  bezierVertex(width * 0.05, height / 2 - 120, width * 0.10, height / 2 - 20, width * 0.15, height / 2 - 80);
  bezierVertex(width * 0.20, height / 2 - 140, width * 0.25, height / 2 - 70, width * 0.30, height / 2 - 50);
  bezierVertex(width * 0.35, height / 2 - 30, width * 0.40, height / 2 - 110, width * 0.45, height / 2 - 120);
  bezierVertex(width * 0.50, height / 2 - 140, width * 0.55, height / 2 - 30, width * 0.60, height / 2 - 40);
  bezierVertex(width * 0.65, height / 2 - 50, width * 0.70, height / 2 - 140, width * 0.75, height / 2 - 120);
  bezierVertex(width * 0.80, height / 2 - 100, width * 0.85, height / 2 - 40, width * 0.90, height / 2 - 90);
  bezierVertex(width * 0.95, height / 2 - 140, width, height / 2 - 60, width, height / 2 - 60);
  
  // === BAGIAN BAWAH BUKIT ===
  bezierVertex(width * 0.95, height / 2 - 105, width * 0.90, height / 2 - 55, width * 0.90, height / 2 - 55);
  bezierVertex(width * 0.85, height / 2 - 5, width * 0.80, height / 2 - 65, width * 0.75, height / 2 - 85);
  bezierVertex(width * 0.70, height / 2 - 105, width * 0.65, height / 2 - 15, width * 0.60, height / 2 - 5);
  bezierVertex(width * 0.55, height / 2 - 5, width * 0.50, height / 2 - 105, width * 0.45, height / 2 - 85);
  bezierVertex(width * 0.40, height / 2 - 75, width * 0.35, height / 2 + 5, width * 0.30, height / 2 - 15);
  bezierVertex(width * 0.25, height / 2 - 45, width * 0.20, height / 2 - 70, width * 0.12, height / 2 - 20);
  bezierVertex(width * 0.10, height / 2 - 5, width * 0.05, height / 2 - 40, 0, height / 2 - 5);
  
  endShape(CLOSE);
  
  // === SUNGAI ===
  fill(30, 144, 255); // biru sungai
  noStroke();
  beginShape();
  vertex(0, height / 2 + 50);
  bezierVertex(width * 0.1, height / 2 + 50, width * 0.25, height / 2 + 50, width * 0.5, height / 2 + 50);
  vertex(width * 0.5, height);
  vertex(0, height);
  endShape(CLOSE);
  
  // === ANIMASI ALIRAN AIR ===
  for (int i = 0; i < numFlows; i++) {
    int size = lengthList[i];
    int segments = size == 1 ? 30 : size == 2 ? 60 : 100;
    drawFlowLine(startXList[i], 1.0, offset + i * 20, sungaiY, segments);
  }
  offset += 1.5;

  // === TANAH HIJAU ===
  drawGreenLand();

  // === 8 POHON ===
  draw8Trees();
  
  // === AWAN ===
  fill(255, 255, 255);
  noStroke();
  
  ellipse(cloudX1, 80, 100, 50); // awan 1
  ellipse(cloudX1 + 40, 90, 80, 40);
  ellipse(cloudX1 - 30, 90, 70, 35);
  ellipse(cloudX2, 120, 120, 60); // awan 2
  ellipse(cloudX2 + 50, 130, 90, 45);
  ellipse(cloudX2 - 40, 130, 80, 40);
  ellipse(cloudX3, 70, 90, 45); // awan 3
  ellipse(cloudX3 + 30, 80, 70, 35);
  ellipse(cloudX3 - 20, 80, 60, 30);
  ellipse(cloudX4, 100, 110, 55); // awan 4
  ellipse(cloudX4 + 45, 110, 85, 42);
  ellipse(cloudX4 - 35, 110, 75, 38);

  cloudX1 += 0.8;
  cloudX2 += 0.6;
  cloudX3 += 0.4;
  cloudX4 += 0.2;

  if (cloudX1 > width + 50) cloudX1 = -150;
  if (cloudX2 > width + 50) cloudX2 = -180;
  if (cloudX3 > width + 50) cloudX3 = -160;
  if (cloudX4 > width + 50) cloudX4 = -170;
  
  // === BURUNG ===
  drawBirds();
  
  // === JALAN RUMAH ===
  fill(139, 69, 19); // warna jalan
  noStroke();
  beginShape();
  vertex(width * 0.825, height / 2 + 50);
  bezierVertex(width * 0.80, height / 2 + 100, width * 0.75, height / 2 + 250, width * 0.695, height);
  vertex(width * 0.955, height);
  bezierVertex(width * 0.90, height / 2 + 250, width * 0.85, height / 2 + 100, width * 0.825, height / 2 + 50);
  endShape(CLOSE);
  
  drawRoadTexture();
  
  // === HIGHLIGHT KIRI JALAN ===
  fill(160, 100, 50); // sedikit lebih terang
  beginShape();
  vertex(width * 0.825, height / 2 + 50);
  bezierVertex(width * 0.81, height / 2 + 95, width * 0.77, height / 2 + 220, width * 0.715, height);
  vertex(width * 0.745, height);
  bezierVertex(width * 0.77, height / 2 + 230, width * 0.81, height / 2 + 100, width * 0.825, height / 2 + 50);
  endShape(CLOSE);

  // === SHADOW KANAN JALAN ===
  fill(90, 40, 15); // lebih gelap
  beginShape();
  vertex(width * 0.825, height / 2 + 50);
  bezierVertex(width * 0.835, height / 2 + 90, width * 0.87, height / 2 + 210, width * 0.915, height);
  vertex(width * 0.955, height);
  bezierVertex(width * 0.90, height / 2 + 250, width * 0.85, height / 2 + 100, width * 0.825, height / 2 + 50);
  endShape(CLOSE);

  // === RUMAH ===
  float houseX = width * 0.825;
  float houseY = height / 2 - 80;
  float houseScale = 1.5;
  
  // === BANGUNAN SAMPING KIRI dan KANAN ===
  float sideScale = houseScale * 1;
  float offsetX = 120 * houseScale; // jarak dari rumah utama

  for (int d = -1; d <= 1; d += 2) { // d = -1 (kiri), 1 (kanan)
    float sx = houseX + d * offsetX;
    float sy = houseY;
  
    fill(200, 200, 200);  // pondasi
    stroke(0);
    strokeWeight(2);
    rect(sx - 60 * sideScale, sy + 100 * sideScale, 120 * sideScale, 30 * sideScale);
  
    fill(255, 165, 0); // lantai 1
    rect(sx - 55 * sideScale, sy + 30 * sideScale, 110 * sideScale, 70 * sideScale);
    
    stroke(0);  // garis horizontal dinding
    strokeWeight(1);
    for (int i = 0; i < 7; i++) {
      float y = sy + (35 + i * 10) * sideScale;
      line(sx - 55 * sideScale, y, sx + 55 * sideScale, y);
    }

    fill(139, 69, 19);  // atap
    stroke(0);
    strokeWeight(2);
    beginShape();
    vertex(sx - 65 * sideScale, sy + 30 * sideScale);
    vertex(sx + 65 * sideScale, sy + 30 * sideScale);
    vertex(sx + 50 * sideScale, sy - 5 * sideScale);
    vertex(sx - 50 * sideScale, sy - 5 * sideScale);
    endShape(CLOSE);
    
    stroke(0); // garis genteng
    strokeWeight(1);
    for (int i = 0; i < 8; i++) {
      line(sx - (45 - i * 10) * sideScale, sy + 0 * sideScale, sx - (35 - i * 10) * sideScale, sy + 25 * sideScale);
      line(sx + (35 + i * 10) * sideScale, sy + 0 * sideScale, sx + (45 + i * 10) * sideScale, sy + 25 * sideScale);
    }
  
    fill(173, 216, 230); // jendela
    stroke(0);
    strokeWeight(2);
    rect(sx - 30 * sideScale, sy + 45 * sideScale, 20 * sideScale, 25 * sideScale);
    rect(sx + 10 * sideScale, sy + 45 * sideScale, 20 * sideScale, 25 * sideScale);
  }
  
  // === RUMAH UTAMA ===
  fill(200, 200, 200); // pondasi dasar rumah
  stroke(0);
  strokeWeight(2);
  rect(houseX - 80 * houseScale, houseY + 120 * houseScale, 160 * houseScale, 40 * houseScale);
  
  fill(180, 180, 180); // 3 tangga teras depan
  rect(houseX - 90 * houseScale, houseY + 130 * houseScale, 180 * houseScale, 15 * houseScale);
  rect(houseX - 85 * houseScale, houseY + 135 * houseScale, 170 * houseScale, 15 * houseScale);
  rect(houseX - 80 * houseScale, houseY + 140 * houseScale, 160 * houseScale, 15 * houseScale);
  
  fill(255, 165, 0); // lantai 1 rumah (warna oranye)
  stroke(0);
  strokeWeight(2);
  rect(houseX - 75 * houseScale, houseY + 40 * houseScale, 150 * houseScale, 80 * houseScale);
  
  stroke(0);  // garis horizontal dinding lantai 1
  strokeWeight(1);
  for (int i = 0; i < 8; i++) {
    line(houseX - 75 * houseScale, houseY + (45 + i * 10) * houseScale, houseX + 75 * houseScale, houseY + (45 + i * 10) * houseScale);
  }
  
  fill(70, 130, 150); // atap teras depan (warna biru-keabu)
  stroke(0);
  strokeWeight(2);
  beginShape();
  vertex(houseX - 90 * houseScale, houseY + 40 * houseScale);
  vertex(houseX + 90 * houseScale, houseY + 40 * houseScale);
  vertex(houseX + 85 * houseScale, houseY + 25 * houseScale);
  vertex(houseX - 85 * houseScale, houseY + 25 * houseScale);
  endShape(CLOSE);
  
  fill(255, 209, 123);  // pilar penyangga teras (warna putih)
  stroke(0);
  strokeWeight(1);
  rect(houseX - 70 * houseScale, houseY + 40 * houseScale, 8 * houseScale, 80 * houseScale);
  rect(houseX + 62 * houseScale, houseY + 40 * houseScale, 8 * houseScale, 80 * houseScale);
  
  fill(255, 165, 0); // lantai 2 rumah utama
  stroke(0);
  strokeWeight(2);
  rect(houseX - 70 * houseScale, houseY - 40 * houseScale, 140 * houseScale, 80 * houseScale);
  
  stroke(0);  // garis horizontal dinding lantai 2
  strokeWeight(1);
  for (int i = 0; i < 8; i++) {
    line(houseX - 70 * houseScale, houseY + (-35 + i * 10) * houseScale, houseX + 70 * houseScale, houseY + (-35 + i * 10) * houseScale);
  }
  
  fill(139, 69, 19); // atap utama (warna coklat)
  stroke(0);
  strokeWeight(2);
  beginShape();
  vertex(houseX - 85 * houseScale, houseY - 40 * houseScale);
  vertex(houseX + 85 * houseScale, houseY - 40 * houseScale);
  vertex(houseX + 75 * houseScale, houseY - 80 * houseScale);
  vertex(houseX - 75 * houseScale, houseY - 80 * houseScale);
  endShape(CLOSE);
  
  stroke(0); // garis genteng atap
  strokeWeight(1);
  for (int i = 0; i < 5; i++) {
    line(houseX - (75 - i * 10) * houseScale, houseY - 75 * houseScale, houseX - (65 - i * 10) * houseScale, houseY - 45 * houseScale);
    line(houseX - (25 - i * 10) * houseScale, houseY - 75 * houseScale, houseX - (15 - i * 10) * houseScale, houseY - 45 * houseScale);
    line(houseX + (25 + i * 10) * houseScale, houseY - 75 * houseScale, houseX + (35 + i * 10) * houseScale, houseY - 45 * houseScale);
  }
  
  fill(139, 69, 19); // cerobong asap
  stroke(0);
  strokeWeight(2);
  rect(houseX - 50 * houseScale, houseY - 95 * houseScale, 20 * houseScale, 35 * houseScale);
  
  fill(160, 82, 45); // penutup atas cerobong
  rect(houseX - 52 * houseScale, houseY - 100 * houseScale, 24 * houseScale, 8 * houseScale);
  
  fill(255, 165, 0); // jendela loteng kiri
  stroke(0);
  strokeWeight(2);
  beginShape();
  vertex(houseX - 55 * houseScale, houseY - 60 * houseScale);
  vertex(houseX - 25 * houseScale, houseY - 60 * houseScale);
  vertex(houseX - 25 * houseScale, houseY - 40 * houseScale);
  vertex(houseX - 55 * houseScale, houseY - 40 * houseScale);
  endShape(CLOSE);
  
  fill(139, 69, 19); // atap jendela loteng kiri
  beginShape();
  vertex(houseX - 60 * houseScale, houseY - 60 * houseScale);
  vertex(houseX - 20 * houseScale, houseY - 60 * houseScale);
  vertex(houseX - 40 * houseScale, houseY - 75 * houseScale);
  endShape(CLOSE);
  
  fill(255, 165, 0);  // jendela loteng kanan
  stroke(0);
  strokeWeight(2);
  beginShape();
  vertex(houseX + 25 * houseScale, houseY - 60 * houseScale);
  vertex(houseX + 55 * houseScale, houseY - 60 * houseScale);
  vertex(houseX + 55 * houseScale, houseY - 40 * houseScale);
  vertex(houseX + 25 * houseScale, houseY - 40 * houseScale);
  endShape(CLOSE);
  
  fill(139, 69, 19);  // atap jendela loteng kanan
  beginShape();
  vertex(houseX + 20 * houseScale, houseY - 60 * houseScale);
  vertex(houseX + 60 * houseScale, houseY - 60 * houseScale);
  vertex(houseX + 40 * houseScale, houseY - 75 * houseScale);
  endShape(CLOSE);
  
  fill(173, 216, 230);
  stroke(0);
  strokeWeight(2); // jendela lantai 1
  rect(houseX - 55 * houseScale, houseY + 55 * houseScale, 25 * houseScale, 30 * houseScale);
  rect(houseX + 30 * houseScale, houseY + 55 * houseScale, 25 * houseScale, 30 * houseScale);
  
  // jendela lantai 2
  rect(houseX - 55 * houseScale, houseY - 15 * houseScale, 25 * houseScale, 30 * houseScale);
  rect(houseX - 12.5 * houseScale, houseY - 15 * houseScale, 25 * houseScale, 30 * houseScale);
  rect(houseX + 30 * houseScale, houseY - 15 * houseScale, 25 * houseScale, 30 * houseScale);
  
  // jendela dormer (loteng)
  rect(houseX - 50 * houseScale, houseY - 55 * houseScale, 20 * houseScale, 15 * houseScale);
  rect(houseX + 30 * houseScale, houseY - 55 * houseScale, 20 * houseScale, 15 * houseScale);
  
  fill(139, 69, 19); // pintu depan (warna coklat)
  stroke(0);
  strokeWeight(2);
  rect(houseX - 20 * houseScale, houseY + 55 * houseScale, 40 * houseScale, 65 * houseScale);
  
  stroke(101, 67, 33); // panel pintu
  strokeWeight(1);
  rect(houseX - 10 * houseScale, houseY + 83 * houseScale, 8 * houseScale, 15 * houseScale);
  rect(houseX + 2 * houseScale, houseY + 83 * houseScale, 8 * houseScale, 15 * houseScale);
  rect(houseX - 10 * houseScale, houseY + 102 * houseScale, 8 * houseScale, 15 * houseScale);
  rect(houseX + 2 * houseScale, houseY + 102 * houseScale, 8 * houseScale, 15 * houseScale);
  
  fill(173, 216, 230); // kaca pintu
  stroke(0);
  strokeWeight(1);
  rect(houseX - 12 * houseScale, houseY + 60 * houseScale, 25 * houseScale, 20 * houseScale);
  
  fill(255, 215, 0); // gagang pintu (warna emas)
  noStroke();
  ellipse(houseX + 15 * houseScale, houseY + 90 * houseScale, 3 * houseScale, 3 * houseScale);

  // === 3 BATU ===
  drawRock(200, 460, 0.17); // kiri
  drawRock(280, 420, 0.3); // tengah
  drawRock(390, 540, 0.12); // kanan

  // === RUMPUT ===
  drawGrass(1240, 500, 1.3);
  drawGrass(1220, 570, 0.8);
  drawGrass(1170, 550, 1.5);
  drawGrass(1220, 650, 1.5);
  drawGrass(1240, 650, 1.5);
  drawGrass(700, 420, 1.1);
  drawGrass(750, 450, 0.6);
  drawGrass(800, 490, 0.6);
  drawGrass(870, 490, 1);
  drawGrass(880, 490, 0.9);
  drawGrass(650, 470, 1.5);
  drawGrass(620, 570, 0.7);
  drawGrass(750, 590, 0.7);
  drawGrass(720, 520, 1.3);
  drawGrass(870, 600, 1.7);
  drawGrass(800, 700, 2);
  drawGrass(540, 640, 1.8);
  drawGrass(650, 670, 1.2);
  drawGrass(480, 710, 1.4);
  
  // === BAWANG PUTIH ===
  if (fadeState != FADE_IN) { // bawang Putih hanya bergerak jika fade in selesai
  moveGarlic();
  }
  drawCurrentDialogue();
  drawBawangPutih(garlicX, garlicY, 0.8); // scale putih (0.8)
  checkGarlicStop();
  updateFish();
  drawFish();
  
  // panggil fungsi fade
  handleFade();  
  manageAudio();
}

// ========================== //
// === BATAS SEMUA FUNGSI === //
// ========================== //

void bezierLine(float x1, float y1, float x2, float y2, float x3, float y3) {
  noFill();
  beginShape();
  vertex(x1, y1);
  bezierVertex(x2, y2, x2, y2 + 40, x3, y3);
  endShape();
}
  
// === FUNGSI TANGAN BAWANG PUTIH ===
void drawLengan(float x, float y, boolean kiri) {
  fill(245, 245, 235);
  stroke(160, 140, 120);
  strokeWeight(2);
  beginShape();
  vertex(x, y);
  bezierVertex(x + (kiri ? -20 : 20), y - 5, x + (kiri ? -30 : 30), y + 5, x + (kiri ? -25 : 25), y + 20);
  bezierVertex(x + (kiri ? -25 : 25), y + 35, x + (kiri ? -20 : 20), y + 45, x + (kiri ? -10 : 10), y + 40);
  bezierVertex(x + (kiri ? -5 : 5), y + 35, x, y + 20, x, y);
  endShape(CLOSE);
}
  
// === FUNGSI KAKI BAWANG PUTIH ===
void drawKaki(float x, float y, float scale, boolean isKiri) {
  fill(255, 220, 190); // warna kaki
  stroke(139, 69, 19); // garis tepi coklat
  strokeWeight(1.5);
  
  float baseOffsetX = isKiri ? -20 * scale : 20 * scale; // posisi kaki kiri atau kanan (tanpa animasi)
  ellipse(x + baseOffsetX, y, 25 * scale, 35 * scale);
}
  
// FUNGSI DAUN BAWANG PUTIH ===
void drawDaun(float x, float y, float s) {
  stroke(107, 142, 30);
  strokeWeight(3 * s);
  line(x, y, x, y - 35 * s);

  noStroke();
  fill(154, 205, 50);
  beginShape();
  vertex(x, y - 28 * s);
  bezierVertex(x - 7 * s, y - 39 * s, x - 18 * s, y - 42 * s, x - 21 * s, y - 32 * s);
  bezierVertex(x - 14 * s, y - 35 * s, x - 7 * s, y - 32 * s, x, y - 28 * s);
  endShape(CLOSE);

  beginShape();
  vertex(x, y - 28 * s);
  bezierVertex(x + 7 * s, y - 39 * s, x + 18 * s, y - 42 * s, x + 21 * s, y - 32 * s);
  bezierVertex(x + 14 * s, y - 35 * s, x + 7 * s, y - 32 * s, x, y - 28 * s);
  endShape(CLOSE);
}

// === FUNGSI 8 POHON ===
void draw8Trees() {
  drawTreeWithClouds(80, getHillHeightAt(80), 0.8, 0.3);
  drawTreeWithClouds(220, getHillHeightAt(220), 1.1, 0.5);
  drawTreeWithClouds(380, getHillHeightAt(380), 0.9, 0.4);
  drawTreeWithClouds(520, getHillHeightAt(520), 1.3, 0.6);
  drawTreeWithClouds(680, getHillHeightAt(680), 1.0, 0.2);
  drawTreeWithClouds(850, getHillHeightAt(850), 1.2, 0.4);
  drawTreeWithClouds(1100, getHillHeightAt(1100), 1.1, 0.3);
  drawTreeWithClouds(1280, getHillHeightAt(1280), 0.9, 0.5);
}
  
// === FUNGSI UNTUK MENGGAMBAR SATU POHON ===
void drawTreeWithClouds(float x, float y, float scale, float windIntensity) {
  pushMatrix();
  translate(x, y);
  scale(scale);
  
  float windEffectTop = sin(millis() * 0.005 + x * 0.008) * windIntensity * 1.5;
  
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

  pushMatrix();
  translate(windEffectTop * 0.8, windEffectTop * 0.3);
  rotate(windEffectTop * 0.05);
  drawCloudyLeaves(0, -120, 1.3, windIntensity, x);
  popMatrix();
  
  popMatrix();
}
  
// === FUNGSI UNTUK MENGGAMBAR DAUN BERLAPIS ===
void drawCloudyLeaves(float centerX, float centerY, float leafScale, float windIntensity, float treeX) {
  float leafWind1 = sin(millis() * 0.004 + treeX * 0.01) * windIntensity;
  float leafWind2 = cos(millis() * 0.006 + treeX * 0.008) * windIntensity * 0.8;
  float leafWind3 = sin(millis() * 0.007 + treeX * 0.012) * windIntensity * 1.2;
  
  fill(25, 70, 35);
  pushMatrix();
  translate(leafWind1 * 2, leafWind1 * 0.5);
  drawCloudShape(centerX, centerY + 8, 100 * leafScale, 80 * leafScale);
  popMatrix();

  fill(40, 90, 50);
  pushMatrix();
  translate(leafWind2 * 3, leafWind2 * 0.8);
  drawCloudShape(centerX - 15, centerY, 90 * leafScale, 70 * leafScale);
  drawCloudShape(centerX + 12, centerY - 8, 85 * leafScale, 65 * leafScale);
  popMatrix();

  fill(60, 120, 70);
  pushMatrix();
  translate(leafWind3 * 2.5, leafWind3 * 0.6);
  drawCloudShape(centerX - 8, centerY - 12, 70 * leafScale, 55 * leafScale);
  drawCloudShape(centerX + 18, centerY - 15, 65 * leafScale, 50 * leafScale);
  popMatrix();

  fill(80, 140, 90);
  pushMatrix();
  translate(leafWind1 * 3.5, leafWind1 * 1.2);
  drawCloudShape(centerX + 8, centerY - 22, 45 * leafScale, 35 * leafScale);
  drawCloudShape(centerX - 22, centerY - 18, 40 * leafScale, 30 * leafScale);
  popMatrix();

  fill(70, 130, 80);
  pushMatrix();
  translate(leafWind2 * 4, leafWind2 * 1.5);
  drawCloudShape(centerX + 25, centerY - 5, 35 * leafScale, 28 * leafScale);
  drawCloudShape(centerX - 30, centerY + 2, 38 * leafScale, 30 * leafScale);
  drawCloudShape(centerX, centerY - 28, 42 * leafScale, 32 * leafScale);
  popMatrix();
}
  
// === FUNGSI UNTUK MENGGAMBAR BENTUK AWAN ===
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
  
// === FUNGSI HELPER UNTUK KETINGGIAN BUKIT ===
float getHillHeightAt(float x) {
  return height / 2 + 50;
}
  
// === FUNGSI JALAN ===
void drawRoadTexture() {
  stroke(90, 50, 15);
  strokeWeight(0.5);

  for (int layerIndex = 0; layerIndex < 25; layerIndex++) {
    float y = height / 2 + 50 + layerIndex * 15;
    if (y >= height) break;

    float leftEdge = getRoadLeftEdge(y);
    float rightEdge = getRoadRightEdge(y);

    noFill();
    beginShape();
    for (float x = leftEdge + 10; x < rightEdge - 10; x += 10) {
      float wave = sin(x * 0.1 + layerIndex * 3) * 2;
      vertex(x, y + wave);
    }
    endShape();
  }

  noStroke();
  fill(200, 150, 90, 70);
  drawHighlightDots(35, 3, 12);
  fill(200, 150, 90, 40);
  drawHighlightDots(20, 5, 20);
}

// === FUNGSI DOT HIGHLIGHT JALAN ===
void drawHighlightDots(int count, float minSize, float maxSize) {
  for (int i = 0; i < count; i++) {
    randomSeed(i * 1000);

    float normalizedY = random(0.1, 0.9);
    float roadY = lerp(height / 2 + 60, height - 20, normalizedY);

    float leftEdge = getRoadLeftEdge(roadY);
    float rightEdge = getRoadRightEdge(roadY);

    float x = random(leftEdge + 10, rightEdge - 10);
    float size = random(minSize, maxSize);

    ellipse(x, roadY, size, size * 0.7);
  }
  randomSeed((int)millis());
}
  
float getRoadLeftEdge(float y) {
  float t = (y - height / 2 - 50) / (height / 2 - 50);
  t = constrain(t, 0, 1);

  float startX = width * 0.825;
  float endX = width * 0.695;
  float controlX1 = width * 0.80;
  float controlX2 = width * 0.75;

  return pow(1-t, 3) * startX +
         3 * pow(1-t, 2) * t * controlX1 +
         3 * (1-t) * pow(t, 2) * controlX2 +
         pow(t, 3) * endX;
}
  
float getRoadRightEdge(float y) {
  float t = (y - height / 2 - 50) / (height / 2 - 50);
  t = constrain(t, 0, 1);

  float startX = width * 0.825;
  float endX = width * 0.955;
  float controlX1 = width * 0.85;
  float controlX2 = width * 0.90;

  return pow(1-t, 3) * startX +
         3 * pow(1-t, 2) * t * controlX1 +
         3 * (1-t) * pow(t, 2) * controlX2 +
         pow(t, 3) * endX;
}

// === FUNGSI KETINGGIAN BURUNG ===
void drawBirds() {
  for (int i = 0; i < 5; i++) {
    drawBird(birdX[i], birdY[i], birdSize[i], birdWingOffset[i]);
    
    birdX[i] += birdSpeed[i];
    birdWingOffset[i] += 0.3;

    birdY[i] = birdBaseY[i] + sin(birdWingOffset[i] * 0.1) * 5;
    
    if (birdX[i] > width + 50) {
      birdX[i] = -50;
      birdBaseY[i] = random(30, height * 0.3);
      birdY[i] = birdBaseY[i];
      birdSpeed[i] = random(1.0, 3.5);
    }
  }
}
  
// === FUNGSI BURUNG ===
void drawBird(float x, float y, float scale, float wingOffset) {
  pushMatrix();
  translate(x, y);
  scale(scale);
  
  fill(50, 50, 50);
  noStroke();
  ellipse(0, 0, 12, 8);
  
  pushMatrix();
  rotate(sin(wingOffset) * 0.5);
  ellipse(-8, -3, 16, 6);
  popMatrix();
  
  pushMatrix();
  rotate(-sin(wingOffset) * 0.5);
  ellipse(8, -3, 16, 6);
  popMatrix();
  ellipse(-10, 2, 8, 4);
  ellipse(7, -2, 6, 6);
  fill(255, 150, 0);
  triangle(9, -2, 12, -2, 10, 0);
  
  popMatrix();
}
  
// === FUNGSI BATU ===
void drawRock(float x, float y, float s) {
  pushMatrix();
  translate(x, y);
  scale(s);
  fill(122, 109, 94);
  noStroke();
  beginShape();
  vertex(200, 400);
  vertex(250, 300);
  vertex(350, 250);
  vertex(500, 280);
  vertex(600, 350);
  vertex(580, 450);
  vertex(450, 500);
  vertex(300, 500);
  vertex(220, 480);
  endShape(CLOSE);

  beginShape();
  vertex(300, 280);
  vertex(400, 220);
  vertex(500, 230);
  vertex(520, 280);
  endShape(CLOSE);

  fill(150, 135, 120);
  beginShape();
  vertex(250, 300);
  vertex(300, 280);
  vertex(350, 250);
  vertex(380, 270);
  vertex(300, 320);
  endShape(CLOSE);

  beginShape();
  vertex(400, 220);
  vertex(450, 210);
  vertex(500, 230);
  vertex(480, 250);
  endShape(CLOSE);

  beginShape();
  vertex(500, 280);
  vertex(550, 290);
  vertex(580, 350);
  vertex(550, 380);
  vertex(520, 320);
  endShape(CLOSE);

  beginShape();
  vertex(450, 500);
  vertex(480, 480);
  vertex(500, 450);
  vertex(470, 430);
  vertex(420, 450);
  endShape(CLOSE);

  fill(90, 80, 70);
  beginShape();
  vertex(200, 400);
  vertex(220, 480);
  vertex(300, 500);
  vertex(280, 450);
  vertex(230, 420);
  endShape(CLOSE);

  beginShape();
  vertex(580, 450);
  vertex(600, 350);
  vertex(550, 380);
  vertex(560, 420);
  endShape(CLOSE);

  beginShape();
  vertex(350, 250);
  vertex(300, 280);
  vertex(320, 308);
  vertex(380, 270);
  endShape(CLOSE);

  beginShape();
  vertex(500, 230);
  vertex(520, 280);
  vertex(500, 300);
  vertex(480, 250);
  endShape(CLOSE);
  
  popMatrix();
}

// FUNGSI TANAH HIJAU ===
void drawGreenLand() {
  noStroke();
  fill(80, 160, 80);
  beginShape();
  vertex(width * 0.5, height / 2 + 50);
  bezierVertex(width * 0.6, height / 2 + 50, width * 0.8, height / 2 + 50, width, height / 2 + 50);
  vertex(width, height);
  vertex(width * 0.3, height);
  endShape(CLOSE);
  
  noStroke();
  fill(120, 230, 120, 80);
  beginShape();
  vertex(width * 0.5, height / 2 + 50);
  bezierVertex(width * 0.7, height / 2 + 50, width * 0.8, height / 2 + 20, width, height / 2 + 390);
  vertex(width, height);
  vertex(width * 0.3, height);
  endShape(CLOSE);
}

// === FUNGS RUMPUT ===
void drawGrass(float x, float y, float scaleFactor) {
  pushMatrix();
  translate(x, y);
  scale(scaleFactor);
  noStroke();
  fill(90, 200, 90);

  float swayLeft = radians(sin(grassWindOffset + x * 0.01) * 5);
  float swayCenter = radians(sin(grassWindOffset + x * 0.01 + 2) * 3);
  float swayRight = radians(sin(grassWindOffset + x * 0.01 + 4) * 5);

  pushMatrix();
  rotate(swayLeft);
  beginShape();
  vertex(0, 0);
  vertex(-10, -30);
  vertex(-5, 0);
  endShape(CLOSE);
  popMatrix();

  pushMatrix();
  rotate(swayCenter);
  beginShape();
  vertex(0, 0);
  vertex(0, -40);
  vertex(5, 0);
  endShape(CLOSE);
  popMatrix();

  pushMatrix();
  rotate(swayRight);
  beginShape();
  vertex(0, 0);
  vertex(10, -30);
  vertex(15, 0);
  endShape(CLOSE);
  popMatrix();
  popMatrix();
  grassWindOffset += 0.05;
}

// === FUNGSI ALIRAN SUNGAI ===
void drawFlowLine(float startX, float scaleFactor, float localOffset, float startY, int lengthSegments) {
  stroke(255, 255, 255, 180);
  strokeWeight(2);
  noFill();

  beginShape();
  float prevY = -999;
  for (int i = 0; i < lengthSegments; i++) {
    float t = i + localOffset;
    float x = startX + sin(t * 0.1) * 10 * scaleFactor - i * 0.5;
    float y = startY + (t % (height - startY));

    if (prevY != -999 && abs(y - prevY) > 30) {
      endShape();
      beginShape();
    }
    vertex(x, y);
    prevY = y;
  }
  endShape();
}
  
// === FUNGSI BAWANG PUTIH ===
void drawBawangPutih(float cx, float cy, float scale) {
  fill(220, 220, 220, 100); // bayangan
  noStroke();
  ellipse(cx, cy + 140 * scale, 100 * scale, 20 * scale);
  
  fill(245, 245, 235); // badan
  stroke(160, 140, 120);
  strokeWeight(3);
    
  beginShape();
  vertex(cx, cy + 15 * scale);
  bezierVertex(cx + 65 * scale, cy + 22 * scale, cx + 70 * scale, cy + 56 * scale, cx + 67 * scale, cy + 84 * scale);
  bezierVertex(cx + 60 * scale, cy + 98 * scale, cx + 42 * scale, cy + 105 * scale, cx + 21 * scale, cy + 109 * scale);
  bezierVertex(cx + 7 * scale, cy + 111 * scale, cx - 7 * scale, cy + 111 * scale, cx - 21 * scale, cy + 109 * scale);
  bezierVertex(cx - 42 * scale, cy + 105 * scale, cx - 60 * scale, cy + 98 * scale, cx - 67 * scale, cy + 84 * scale);
  bezierVertex(cx - 70 * scale, cy + 56 * scale, cx - 65 * scale, cy + 22 * scale, cx, cy + 15 * scale);
  endShape(CLOSE);
  
stroke(190, 180, 160); // garis badan
  strokeWeight(1);
  noFill();
  line(cx, cy + 18 * scale, cx, cy + 109 * scale); // garis tengah

  beginShape(); // garis kiri dalam
  vertex(cx - 12 * scale, cy + 20 * scale);
  bezierVertex(cx - 30 * scale, cy + 45 * scale, cx - 35 * scale, cy + 80 * scale, cx - 15 * scale, cy + 109 * scale);
  endShape();
 
  beginShape(); // garis kanan dalam
  vertex(cx + 12 * scale, cy + 20 * scale);
  bezierVertex(cx + 30 * scale, cy + 45 * scale, cx + 35 * scale, cy + 80 * scale, cx + 15 * scale, cy + 109 * scale);
  endShape();

  beginShape(); // garis kiri luar
  vertex(cx - 25 * scale, cy + 22 * scale);
  bezierVertex(cx - 50 * scale, cy + 50 * scale, cx - 55 * scale, cy + 85 * scale, cx - 30 * scale, cy + 109 * scale);
  endShape();
  
  beginShape(); // garis kanan luar
  vertex(cx + 25 * scale, cy + 22 * scale);
  bezierVertex(cx + 50 * scale, cy + 50 * scale, cx + 55 * scale, cy + 85 * scale, cx + 30 * scale, cy + 109 * scale);
  endShape();
  
  // === ANIMASI TANGAN BAWANG PUTIH ===
  pushMatrix();  
  translate(cx - 42 * scale, cy + 35 * scale);
  rotate(sin(armAngleOffset) * 0.2);
  scale(scale);
  drawLengan(0, 0, true);
  popMatrix();
  pushMatrix();
  translate(cx + 42 * scale, cy + 35 * scale);
  rotate(-sin(armAngleOffset) * 0.2);
  scale(scale);
  drawLengan(0, 0, false);
  popMatrix();
  armAngleOffset += 0.5;
    
  // === ANIMASI KAKI BAWANG PUTIH ===
  float kakiGerakX = sin(legAngleOffset) * 3; // gerakan kanan-kiri kecil
    
  pushMatrix();
  translate(cx + kakiGerakX, cy + 120 * scale);
  drawKaki(0, 0, scale, true);  // kaki kiri
  popMatrix();
    
  pushMatrix();
  translate(cx - kakiGerakX, cy + 120 * scale);
  drawKaki(0, 0, scale, false); // kaki kanan
  popMatrix();
  legAngleOffset += 0.5;
  
  fill(245, 245, 235); // topi
  stroke(160, 140, 120);
  strokeWeight(3);
  beginShape();
  vertex(cx, cy + 21 * scale);
  bezierVertex(cx + 91 * scale, cy + 21 * scale, cx + 84 * scale, cy - 42 * scale, cx, cy - 95 * scale);
  bezierVertex(cx - 84 * scale, cy - 42 * scale, cx - 91 * scale, cy + 21 * scale, cx, cy + 21 * scale);
  endShape(CLOSE);
  
 stroke(190, 180, 160); // garis topi
  strokeWeight(1.5);
  bezierLine(cx, cy + 18 * scale, cx, cy - 42 * scale, cx, cy - 91 * scale); // garis tengah
  bezierLine(cx - 17 * scale, cy + 18 * scale, cx - 35 * scale, cy - 30 * scale, cx - 15 * scale, cy - 82 * scale); // garis kiri dalam
  bezierLine(cx + 17 * scale, cy + 18 * scale, cx + 35 * scale, cy - 30 * scale, cx + 15 * scale, cy - 82 * scale); // garis kanan dalam
  bezierLine(cx - 26 * scale, cy + 17 * scale, cx - 60 * scale, cy - 20 * scale, cx - 35 * scale, cy - 65 * scale); // garis kiri luar 
  bezierLine(cx + 26 * scale, cy + 17 * scale, cx + 60 * scale, cy - 20 * scale, cx + 35 * scale, cy - 65 * scale); // garis kanan luar
  
  fill(255, 240, 220); // kepala
  stroke(160, 140, 120);
  strokeWeight(3);
  beginShape();
  vertex(cx, cy - 56 * scale);
  bezierVertex(cx + 35 * scale, cy - 60 * scale, cx + 49 * scale, cy - 28 * scale, cx + 46 * scale, cy - 7 * scale);
  bezierVertex(cx + 42 * scale, cy + 7 * scale, cx + 21 * scale, cy + 14 * scale, cx, cy + 14 * scale);
  bezierVertex(cx - 21 * scale, cy + 14 * scale, cx - 42 * scale, cy + 7 * scale, cx - 46 * scale, cy - 7 * scale);
  bezierVertex(cx - 49 * scale, cy - 28 * scale, cx - 35 * scale, cy - 60 * scale, cx, cy - 56 * scale);
  endShape(CLOSE);
  
  // === LOGIKA EKSPRESI WAJAH (DENGAN SENYUM PERMANEN) ===
  if (garlicIsShocked) {
    // --- EKSPRESI KAGET ---
    noStroke();
    fill(101, 67, 33); // mata
    ellipse(cx - 15 * scale, cy - 30 * scale, 6 * scale, 8 * scale);
    ellipse(cx + 15 * scale, cy - 30 * scale, 6 * scale, 8 * scale);
    
    stroke(101, 67, 33); // alis
    strokeWeight(2);
    line(cx - 20 * scale, cy - 48 * scale, cx - 10 * scale, cy - 46 * scale);
    line(cx + 10 * scale, cy - 46 * scale, cx + 20 * scale, cy - 48 * scale);
    
    noFill();
    stroke(50, 25, 10); // mulut
    strokeWeight(2);
    ellipse(cx, cy - 5 * scale, 14 * scale, 18 * scale);
      
  } else if (isPermanentlyHappy || trackSekarang == 6 || trackSekarang == 7 || trackSekarang == 8 || trackSekarang == 9) {
    // --- EKSPRESI TERSENYUM ---
    isPermanentlyHappy = true; // kunci ekspresi senyum agar permanen
    
    noStroke(); // mata
    fill(101, 67, 33);
    ellipse(cx - 15 * scale, cy - 35 * scale, 6 * scale, 7 * scale);
    ellipse(cx + 15 * scale, cy - 35 * scale, 6 * scale, 7 * scale);
    
    stroke(101, 67, 33); // alis
    strokeWeight(1.5);
    noFill();
    arc(cx - 15 * scale, cy - 41 * scale, 11 * scale, 4 * scale, PI, TWO_PI);
    arc(cx + 15 * scale, cy - 41 * scale, 11 * scale, 4 * scale, PI, TWO_PI);
  
    noStroke(); // blush
    fill(255, 182, 193, 150);
    ellipse(cx - 25 * scale, cy - 25 * scale, 14 * scale, 8 * scale);
    ellipse(cx + 25 * scale, cy - 25 * scale, 14 * scale, 8 * scale);
  
    noFill(); // mulut
    stroke(139, 69, 19);
    strokeWeight(1.5);
    arc(cx, cy - 14 * scale, 21 * scale, 11 * scale, 0, PI);
  
    
  } else {
    // --- EKSPRESI SEDIH (DEFAULT) ---
    noStroke();
    fill(101, 67, 33); // mulut
    ellipse(cx - 15 * scale, cy - 35 * scale, 6 * scale, 7 * scale);
    ellipse(cx + 15 * scale, cy - 35 * scale, 6 * scale, 7 * scale);
    
    stroke(101, 67, 33); // alis
    strokeWeight(1.5);
    noFill();
    arc(cx - 15 * scale, cy - 42 * scale, 11 * scale, 4 * scale, 0, PI);
    arc(cx + 15 * scale, cy - 42 * scale, 11 * scale, 4 * scale, 0, PI);
    
    noFill(); // mulut
    stroke(139, 69, 19);
    strokeWeight(1.5);
    arc(cx, cy - 8 * scale, 21 * scale, 11 * scale, PI, TWO_PI);
    
    noStroke(); // air mata
    fill(0, 191, 255, 200);
    ellipse(cx - 15 * scale, cy - 28 * scale, 4 * scale, 8 * scale);
    ellipse(cx + 15 * scale, cy - 28 * scale, 4 * scale, 8 * scale);
  }
  
  fill(154, 205, 50); // daun ahoge
  stroke(107, 142, 35);
  strokeWeight(2);
  drawDaun(cx, cy - 91 * scale, scale);
  
  fill(186, 108, 43); // wadah
  stroke(0);
  strokeWeight(1.5);
  beginShape();
  vertex(cx - 36 * scale, cy + 70 * scale);   // kiri atas
  vertex(cx - 28 * scale, cy + 125 * scale);  // kiri bawah
  vertex(cx + 28 * scale, cy + 125 * scale);  // kanan bawah
  vertex(cx + 36 * scale, cy + 70 * scale);   // kanan atas
  endShape(CLOSE);
  
  fill(186, 108, 43); // bibir ember
  stroke(0);
  strokeWeight(1.5);
  ellipse(cx, cy + 70 * scale, 72 * scale, 18 * scale); // bibir ember
    
  noStroke(); // baju 3 lapis
  fill(255, 0, 0); // merah
  ellipse(cx, cy + 68 * scale, 60 * scale, 10 * scale);
  fill(0, 255, 0); // hijau
  ellipse(cx, cy + 70 * scale, 60 * scale, 7 * scale);
  fill(128, 0, 128); // biru
  ellipse(cx, cy + 74 * scale, 60 * scale, 8 * scale);
    
  stroke(180); // gagang wadah
  strokeWeight(2);
  noFill();
  beginShape();
  vertex(cx - 33 * scale, cy + 70 * scale);
  bezierVertex(cx - 25 * scale, cy + 40 * scale, cx + 25 * scale, cy + 40 * scale, cx + 33 * scale, cy + 70 * scale);
  endShape();
    
  stroke(255, 150, 50); // pegangan oranye
  strokeWeight(4);
  line(cx - 12 * scale, cy + 48 * scale, cx + 12 * scale, cy + 48 * scale);
}
  
  // === FUNGSI BAWANG PUTIH ANIMASI ===
  void moveGarlic() {
  float speed = 5.0; // kecepatan bawang putih
  float dx = targetX - garlicX;
  float dy = targetY - garlicY;
  float dist = sqrt(dx*dx + dy*dy);

  if (dist > speed) {
    garlicX += dx/dist * speed;
    garlicY += dy/dist * speed;
  } else {
    garlicX = targetX;
    garlicY = targetY;
    armAngleOffset = 0;
    legAngleOffset = 0;
  }
}

// === FUNGSI ANIMASI GERAK BAWANG PUTIH ===
void checkGarlicStop() {
  if (abs(garlicX - targetX) < 1) { // bawang putih diam
    garlicStopTimer++;
    if (garlicStopTimer > 10 && !fishHasJumped) {
      fishVisible = true;
      fishIsJumping = true;
      garlicIsShocked = true; // <-- TAMBAHAN: Bawang putih menjadi kaget
      fishJumpSpeed = random(-10, -25);
      fishHasJumped = true;
    }
  } else {
    garlicStopTimer = 0;
    fishVisible = false;
    fishIsJumping = false;
    fishJumpY = fishY;
    fishHasJumped = false;
  }
}
  
// === FUNGSI UPDATE IKAN ===
void updateFish() {
  if (!fishVisible) return;

  fishTailOffset += 0.15;

  if (fishIsJumping) {
    fishJumpY += fishJumpSpeed;
    fishJumpSpeed += 0.5;
    if (fishJumpY >= fishY) {
      fishJumpY = fishY;
      fishIsJumping = false;
      fishJumpSpeed = 0;
      garlicIsShocked = false;  // bawang putih kembali normal
    }
  }
}
  
void drawFish() {
  if (!fishVisible) return;

  pushMatrix();
  translate(fishX, fishIsJumping ? fishJumpY : fishY);
  scale(fishSize);

  if (fishIsJumping) { // rotasi ikan saat melompat
    float jumpRotation = map(fishJumpSpeed, -12, 8, -0.3, 0.3);
    rotate(jumpRotation);
  }

  if (!fishIsJumping) { // bayangan ikan di air
    fill(0, 0, 139, 80);
    noStroke();
    ellipse(2, 8, 35, 15);
  }

  fill(255, 140, 0); // badan
  stroke(255, 100, 0); // orange
  strokeWeight(1);
  ellipse(0, 0, 30, 15);

  float tailWave = sin(fishTailOffset) * 0.3; // ekor ikan bergerak
  fill(255, 100, 0);
  noStroke();
  pushMatrix();
  translate(-15, 0);
  rotate(tailWave);
  beginShape();
  vertex(0, 0);
  vertex(-12, -8);
  vertex(-8, 0);
  vertex(-12, 8);
  endShape(CLOSE);
  popMatrix();

  fill(255, 120, 20); // sirip atas
  beginShape();
  vertex(-5, -7);
  vertex(5, -10);
  vertex(8, -5);
  vertex(0, -3);
  endShape(CLOSE);

  beginShape(); // sirip samping
  vertex(-8, 5);
  vertex(-5, 12);
  vertex(0, 8);
  vertex(-3, 3);
  endShape(CLOSE);

  stroke(200, 80, 0); // mulut
  strokeWeight(1);
  noFill();
  arc(12, 0, 4, 3, -PI/4, PI/4);

  stroke(255, 120, 20); // sisik (pola)
  strokeWeight(0.5);
  for (int j = 0; j < 3; j++) {
    arc(-8 + j * 6, -3, 5, 4, 0, PI);
    arc(-8 + j * 6, 3, 5, 4, PI, TWO_PI);
    
  }
  fill(255); // mata
  noStroke();
  ellipse(5, -2, 6, 6);
  fill(0);
  ellipse(6, -2, 3, 3);
  
  fill(255); // highlight mata
  ellipse(6.5, -2.5, 1, 1);
  popMatrix();
}
  
// === FUNGSI TEXT BOX DAN DIALOG (VERSI FINAL) ===
void drawCurrentDialogue() {
  if (urutanSelesai || !audioHasStarted) {
    return; // jangan gambar apa-apa jika cerita selesai atau belum mulai
  }

  DialogueLine currentLine = dialogueSequence[trackSekarang];
  String speaker = currentLine.speaker;
  String text = currentLine.text;

  if (speaker.equals("Narasi")) {
    // --- PENANGANAN ANIMASI MENGETIK (LOGIKA BARU) ---
    if (kalimatNarasi == null) {
      kalimatNarasi = text.split("\\. ");
      for (int i=0; i<kalimatNarasi.length-1; i++) {
        kalimatNarasi[i] += "."; 
      }
    }

    if (indeksKalimat < kalimatNarasi.length) {
      String kalimatPenuh = kalimatNarasi[indeksKalimat];
      
      frameCounter++; // 1. Tambah counter setiap frame
      
      // 2. Cek apakah sudah waktunya mengetik
      if (frameCounter >= typingSpeed) {
        frameCounter = 0; // Reset counter
        
        // 3. Loop untuk menambahkan beberapa karakter sekaligus
        for (int i = 0; i < charsPerFrame; i++) {
          if (typingIndex < kalimatPenuh.length()) {
            currentDisplayDialogue += kalimatPenuh.charAt(typingIndex);
            typingIndex++;
          }
        }
      }
      
      // Jika satu kalimat selesai diketik
      if (typingIndex >= kalimatPenuh.length() && !gantiKalimat) {
        gantiKalimat = true;
        waktuGantiKalimat = millis() + 1500;
      }
    }

    // Logika untuk ganti kalimat setelah jeda
    if (gantiKalimat && millis() > waktuGantiKalimat) {
      indeksKalimat++;
      if (indeksKalimat < kalimatNarasi.length) {
        typingIndex = 0;
        currentDisplayDialogue = "";
        gantiKalimat = false;
      }
    }
    
    // --- GAMBAR KOTAK NARASI ---
    fill(0, 150); 
    noStroke();
    rect(50, 555, 140, 36, 8);
    
    fill(255);
    textSize(20);
    text(speaker, 70, 580);
    
    fill(255, 240); 
    stroke(180);
    strokeWeight(2);
    rect(50, 600, 1200, 60, 20);  
    
    fill(0);
    textSize(22);
    textLeading(30);
    // Tampilkan teks yang sedang diketik
    text(currentDisplayDialogue, 70, 620, 1160, 90);
    
  } else if (speaker.equals("Putih") || speaker.equals("Ikan")) {
    // --- MENGGUNAKAN SPEECH BUBBLE VERSI ASLI (FIXED-SIZE) ---
    kalimatNarasi = null; // Reset narasi jika dialog beralih ke karakter
    float targetX = 0;
    float targetY = 0;
    
    if (speaker.equals("Putih")) {
      targetX = garlicX; 
      targetY = garlicY;
    } else if (speaker.equals("Ikan")) {
      targetX = fishX; 
      targetY = fishJumpY;
    }
    drawSpeechBubble(speaker, text, targetX, targetY);
  }
}

// === FUNGSI MENGGAMBAR SPEECH BUBBLE (VERSI FINAL - PALING STABIL) ===
void drawSpeechBubble(String speakerName, String teks, float cx, float cy) {
  if (teks == null || teks.isEmpty()) {
    return;
  }
  pushStyle();
  
  // --- Pengaturan ---
  float padding = 20;
  float bubbleMaxWidth = 400; // Lebar area teks
  float leading = 8;          // Jarak antar baris
  
  textFont(font);
  textSize(20);
  
  // --- Kalkulasi Ukuran Bubble Secara Manual ---
  String[] words = teks.split(" ");
  String currentLine = "";
  ArrayList<String> lines = new ArrayList<String>(); // Menyimpan setiap baris teks yang sudah jadi

  for (int i = 0; i < words.length; i++) {
    String testLine = currentLine.isEmpty() ? words[i] : currentLine + " " + words[i];
    if (textWidth(testLine) > bubbleMaxWidth && !currentLine.isEmpty()) {
      lines.add(currentLine);
      currentLine = words[i];
    } else {
      currentLine = testLine;
    }
  }
  lines.add(currentLine); // Tambahkan baris terakhir

  float textHeight = (lines.size() * (textAscent() + textDescent())) + ((lines.size() - 1) * leading);
  float bubbleWidth = bubbleMaxWidth + padding * 2;
  float bubbleHeight = textHeight + padding * 2;

  // --- Atur Posisi ---
  float bubbleX = cx - bubbleWidth / 2;
  float bubbleY = cy - 200 - bubbleHeight / 2;

  if (bubbleX < 10) bubbleX = 10;
  if (bubbleX + bubbleWidth > width - 10) bubbleX = width - 10 - bubbleWidth;

  // --- Gambar Komponen Bubble ---
  // Kotak Nama
  textSize(18);
  float labelBoxWidth = textWidth(speakerName) + 30;
  float labelBoxHeight = 35;
  float labelBoxY = bubbleY - labelBoxHeight - 5;
  
  if (speakerName.equals("Putih")) { fill(200, 200, 200); } 
  else if (speakerName.equals("Ikan")) { fill(255, 140, 0); }
  
  stroke(255);
  strokeWeight(2);
  rect(bubbleX, labelBoxY, labelBoxWidth, labelBoxHeight, 10);
  
  // Bubble Utama
  fill(255);
  stroke(180);
  rect(bubbleX, bubbleY, bubbleWidth, bubbleHeight, 15);
  
  // Ekor Bubble
  float tailX = cx;
  float tailY = bubbleY + bubbleHeight;
  triangle(tailX - 15, tailY, tailX + 15, tailY, tailX, tailY + 20);

  // --- Gambar Teks ---
  // Teks Nama
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(18);
  text(speakerName, bubbleX + labelBoxWidth / 2, labelBoxY + labelBoxHeight / 2);
  
  // Teks Dialog Utama (digambar baris per baris)
  fill(0); 
  textAlign(LEFT, TOP);
  textSize(20);
  float yPos = bubbleY + padding;
  for (String line : lines) {
    text(line, bubbleX + padding, yPos);
    yPos += textAscent() + textDescent() + leading; // Pindah ke baris selanjutnya
  }

  popStyle();
}
  
// === FUNGSI MANAGE AUDIO ===
void manageAudio() {
  if (fadeState == NORMAL && !audioHasStarted) { // blok 1: memulai audio pertama kali setelah fade in selesai
    audioHasStarted = true;
    println("Fade in selesai, audio dimulai.");
    suaraAngin.loop();
    aliranAir.loop();
    playlist[trackSekarang].setGain(volumePlaylist[trackSekarang]);
    playlist[trackSekarang].play();
  }
  if (!audioHasStarted || urutanSelesai) { // jangan lanjutkan jika audio belum mulai atau urutan sudah selesai
    return;
  }
  if (sedangJeda) { // blok 2: mengelola jeda
    if (millis() > waktuJedaSelesai) {
      sedangJeda = false; // jeda selesai, saatnya putar lagu berikutnya
      trackSekarang++; // pindah ke lagu selanjutnya
      
     // Reset variabel animasi teks narasi yang baru
      kalimatNarasi = null;
      indeksKalimat = 0;
      typingIndex = 0;
      currentDisplayDialogue = "";
      gantiKalimat = false;
      
      if (trackSekarang >= playlist.length) {
          urutanSelesai = true;
          suaraAngin.pause();
          aliranAir.pause();
          println("Urutan audio selesai, memulai fade out.");
          
          // --- TAMBAHKAN BARIS INI UNTUK MEMULAI FADE OUT ---
          fadeState = FADE_OUT; 
          
          return;
        
      }
      
      println("Memutar lagu: " + namaFilePlaylist[trackSekarang]);
      playlist[trackSekarang].setGain(volumePlaylist[trackSekarang]);
      playlist[trackSekarang].play();
    }
    return; // masih dalam masa jeda, keluar dari fungsi
  }
  if (!playlist[trackSekarang].isPlaying()) { // blok 3: Mendeteksi jika lagu selesai untuk memulai jeda
    println("Lagu selesai, memulai jeda " + DURASI_JEDA/1000 + " detik."); // lagu baru saja selesai, mulai periode jeda
    sedangJeda = true;  
    waktuJedaSelesai = millis() + DURASI_JEDA;
  }
}
  
void stop() {
  suaraAngin.close(); // selalu tutup semua file audio dan hentikan Minim
  aliranAir.close();
  for (int i = 0; i < playlist.length; i++) {
    playlist[i].close();
  }
  minim.stop();
  super.stop();
}

// === FUNGSI FADE ===
void handleFade() {
  if (fadeState == FADE_IN) {
    fadeAlpha -= fadeInSpeed; // gunakan kecepatan fade in
    if (fadeAlpha <= 0) {
      fadeAlpha = 0;
      fadeState = NORMAL;
    }
  } else if (fadeState == FADE_OUT) {
    fadeAlpha += fadeOutSpeed; // gunakan kecepatan fade out
    if (fadeAlpha >= 255) {
      fadeAlpha = 255;
      // noLoop();
    }
  }

  if (fadeAlpha > 0) { // bagian untuk menggambar persegi panjang tetap sama
    noStroke();
    fill(0, fadeAlpha);
    rect(0, 0, width, height);
  }
}
