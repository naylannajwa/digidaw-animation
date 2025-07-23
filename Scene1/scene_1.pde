import ddf.minim.*;
Minim minim;
AudioPlayer narasi;
AudioPlayer aliranAir;
AudioPlayer suaraAngin;

boolean gameStarted = false;

// Kelas untuk menyimpan dialog dan durasi jedanya
class DialogueEntry {
  String characterName;
  String dialogue;
  int pauseDurationFrames; // Durasi jeda dalam frame

  DialogueEntry(String name, String text, int pause) {
    characterName = name;
    dialogue = text;
    pauseDurationFrames = pause;
  }
}

// Menggunakan array dari DialogueEntry
DialogueEntry[] dialogueEntries = {
  new DialogueEntry("Narasi", "Di sebuah desa yang tenang, hiduplah seorang janda bersama dua anak perempuannya yang cantik bernama—", 65), // 3 detik
  new DialogueEntry("Narasi", "Merah dan Putih.", 20), // 2 detik
  new DialogueEntry("Narasi", "Sejak ayahnya meninggal, kehidupan Putih mulai berubah.", 35),
  new DialogueEntry("Narasi", "Dahulu Putih hidup bahagia, kini Putih harus menanggung penderitaan.", 60),
  new DialogueEntry("Narasi", "Setiap hari, Putih dipaksa mengerjakan semua pekerjaan rumah—", 70),
  new DialogueEntry("Narasi", "mulai dari mencuci pakaian, memasak, menyapu, hingga membersihkan halaman.", 60),
  new DialogueEntry("Narasi", "Sementara itu, ibu tirinya dan Merah hanya duduk bersantai, memerintah ini dan itu.", 90)
};

int currentIndex = 0;

// variabel untuk animasi mengetik
String currentDisplayDialogue = ""; // teks yang ditampilkan saat ini
int typingIndex = 0; // indeks karakter selanjutnya
int frameCounter = 0;
int typingSpeed = 1; // kecepatan mengetik (semakin kecil, semakin cepat)
int charsPerFrame = 5; // menampilkan 2 karakter sekaligus per update

boolean isDialogueFinished = false; // status apakah kalimat sudah selesai
int pauseCounter = 0; // penghitung frame untuk jeda
// int pauseDuration; // Dihapus karena sekarang ada di DialogueEntry

boolean allDialoguesFinished = false;

float fadeOutAlpha = 0;
float fadeSpeed = 20; // kecepatan fade out

float cloudX1, cloudX2, cloudX3, cloudX4;
float waterOffset = 0;
float waveOffset = 0;
float grassWindOffset = 0;
float offset = 0;
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

int numFlows = 50;
float[] startXList = new float[numFlows];
int[] lengthList = new int[numFlows];

void setup() {
  size(1280, 720);
  frameRate(30);
  
  // === INISIALISASI MINIM & AUDIO ===
  minim = new Minim(this);
  
  // muat file audio dari folder 'data'
  narasi = minim.loadFile("narasi_scene1.mp3");
  aliranAir = minim.loadFile("aliran_air.mp3");
  suaraAngin = minim.loadFile("suara_angin.mp3");

  // atur volume (gain dalam desibel, 0 normal, <0 lebih pelan)
  narasi.setGain(15); // volume narasi normal
  aliranAir.setGain(-20); // volume aliran air lebih pelan
  suaraAngin.setGain(-10); // Volume angin sangat pelan

  //// putar suara
  //narasi.play(); // putar narasi sekali
  //aliranAir.loop(); // putar suara air berulang-ulang
  //suaraAngin.loop(); // putar suara angin berulang-ulang
  
  cloudX1 = width * 0.1;
  cloudX2 = width * 0.7;
  cloudX3 = width * 1;
  cloudX4 = width * 1.4;
  waterOffset = 0;
  treeOffset = 0;
  sunRayOffset = 0;
  textFont(createFont("MS Gothic", 24)); // Font Jepang
  smooth();
  
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
}

// === BACKGROUND LANGIT ===
void draw() {
    if (gameStarted) {
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
    
    // === ANIMASI DAN TEXTBOX ===
    if (!allDialoguesFinished) {
      // === LOGIKA ANIMASI & JEDA OTOMATIS ===
      if (!isDialogueFinished) {
        // --- FASE 1: MENGETIK ---
        frameCounter++;
        if (frameCounter >= typingSpeed) {
          for (int i = 0; i < charsPerFrame; i++) {
            if (typingIndex < dialogueEntries[currentIndex].dialogue.length()) {
              currentDisplayDialogue += dialogueEntries[currentIndex].dialogue.charAt(typingIndex);
              typingIndex++;
            } else {
              isDialogueFinished = true;
              break;
            }
          }
          frameCounter = 0;
        }
      } else {
        // --- FASE 2: JEDA ---
        pauseCounter++;
        if (pauseCounter >= dialogueEntries[currentIndex].pauseDurationFrames) { // Menggunakan durasi jeda dari objek
          if (currentIndex < dialogueEntries.length - 1) {
            currentIndex++;
            typingIndex = 0;
            currentDisplayDialogue = "";
            pauseCounter = 0;
            isDialogueFinished = false;
          } else {
            allDialoguesFinished = true;
            aliranAir.pause();
            suaraAngin.pause();
          }
        }
      }
      
      // === TEXT BOX ===
      fill(0, 150); // kotak nama
      noStroke();
      rect(50, 555, 140, 36, 8);
      
      textAlign(LEFT, TOP); // teks nama
      fill(255);
      textSize(20);
      text(dialogueEntries[currentIndex].characterName, 70, 565); // Menggunakan nama karakter dari objek
      
      fill(255, 240); // kotak narasi
      stroke(180);
      strokeWeight(2);
      rect(50, 600, 1200, 60, 20);
      
      textAlign(LEFT, TOP); // teks narasi
      fill(0);
      textSize(22);
      textLeading(30);
      text(currentDisplayDialogue, 70, 620, 1160, 40);
    }
    
    if (allDialoguesFinished) {
      fadeOutAlpha = min(fadeOutAlpha + fadeSpeed, 255);
      fill(0, fadeOutAlpha);
      noStroke();
      rect(0, 0, width, height);
    }
   } else {
    // === FASE 1: TAMPILKAN LAYAR JUDUL ===
    background(173, 216, 230); // warna background
    textAlign(CENTER, CENTER);
    
    textFont(createFont("MS Gothic", 50)); // judul utama
    fill(000); // warna teks
    text("Bawang Merah dan Bawang Putih", width/2, height/2 - 40);
    
    textFont(createFont("MS Gothic", 24)); // teks "klik untuk mulai" dengan efek berkedip
    float alpha = 128 + 127 * sin(millis() * 0.005); // efek alpha berkedip
    fill(000, alpha);
    text("klik untuk mulai", width/2, height/2 + 40);
  }
}

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
  
  void mousePressed() {
    if (!gameStarted) { // hanya jalankan jika game belum dimulai
      gameStarted = true;
      
      narasi.play(); // mulai mainkan suara saat game dimulai
      aliranAir.loop();
      suaraAngin.loop();
    }
  }
    void stop() {  // selalu hentikan dan tutup stream audio saat sketch berhenti
    narasi.close();
    aliranAir.close();
    suaraAngin.close();
    minim.stop();
    super.stop();
  }
