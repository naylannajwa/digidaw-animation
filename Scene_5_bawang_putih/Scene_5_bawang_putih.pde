// SCENE 5 - Animasi Bawang Putih dengan Dialog dan Narasi + Voice Over

// ===== VOICE-OVER IMPORT SECTION =====
import ddf.minim.*;
Minim minim;

// =========================================================================
// ⚙️ BAGIAN PENGATURAN UTAMA (UBAH NILAI DI SINI)
// =========================================================================

// === PENGATURAN SUARA ===
// Atur level volume di sini. Angka negatif = lebih pelan, 0 = normal, angka positif = lebih keras.
float LEVEL_VOLUME = 55.0;
float LEVEL_SFX = 15.0;

// === PENGATURAN KECEPATAN KETIKAN ===
// Angka LEBIH KECIL = LEBIH CEPAT. Contoh: 1 = sangat cepat, 5 = lambat.
int KECEPATAN_KETIK_NARASI = 2;

// === PENGATURAN KECEPATAN ANIMASI ===
// Nilai LEBIH KECIL = LEBIH CEPAT
// Nilai LEBIH BESAR = LEBIH LAMBAT
float KECEPATAN_BERJALAN     = 140.0; // Kecepatan Bawang Putih berjalan
float KECEPATAN_TARUH_LABU   = 60.0;  // Kecepatan menaruh labu
float KECEPATAN_MEMOTONG     = 80.0;  // Kecepatan memotong labu
float KECEPATAN_KOIN_JATUH   = 100.0; // Kecepatan koin jatuh
float KECEPATAN_KAGUM        = 90.0;  // Durasi ekspresi kagum
float KECEPATAN_PISAU_TURUN  = 40.0;  // Kecepatan pisau turun
float KECEPATAN_FADE_OUT = 120.0;

// === TIMING PERGANTIAN ADEGAN / VOICE-OVER ===
// Sesuaikan dengan durasi file audio (dalam frame, 60fps = 60 frame per detik)
int DURASI_NARASI_AWAL      = 360; // 6 detik - "Sesampainya di rumah..."
int DELAY_MULAI_BERJALAN    = 120; // 2 detik delay sebelum mulai berjalan
int DURASI_NARASI_MEMOTONG  = 240; // 4 detik - "Dengan hati-hati..."
int DURASI_NARASI_BERHAMBURAN = 400; // 5 detik - koin berhamburan
int DURASI_NARASI_CAHAYA    = 500; // 11 detik - "Seketika, cahaya keemasan..."
int DELAY_DIALOG_KAGUM      = 60;  // 1 detik delay sebelum dialog muncul
int DURASI_DIALOG_KAGUM     = 120; // 2 detik - "Wahhhhhh!! Isinya emasss!"
int DURASI_NARASI_AKHIR     = 360; // 6 detik - "Sejak hari itu..."

// =========================================================================
// AKHIR BAGIAN PENGATURAN
// =========================================================================

// === VOICE-OVER FILES ===
AudioPlayer voNarasi1;
AudioPlayer voNarasi2;
AudioPlayer voNarasi3;
AudioPlayer voDialog1;
AudioPlayer voNarasi4;
AudioPlayer sfxLangkahKaki, sfxMemotong;
AudioPlayer sfxKoin;
AudioPlayer sfxHappyEnding;

// === VOICE-OVER & SFX CONTROL ===
boolean voiceOverEnabled = true;
boolean audioLibraryLoaded = false;
float fadeOutAlpha = 0;
boolean[] voicePlayed = new boolean[5];
boolean isWalkingSoundPlaying = false;

// === FONT VARIABLES ===
PFont fontDialog;
PFont fontNarasi;

// --- Variabel Global untuk karakter dan labu ---
float bawangPutihCenterX;
float bawangPutihCenterY;
float labuEmasCenterX;
float labuEmasCenterY;
float PUMPKIN_SCALE = 0.8;

// === VARIABEL DIALOG DAN NARASI ===
boolean showDialog = false;
boolean showNarration = false;
String currentDialog = "";
String currentNarration = "";
float dialogOpacity = 0;
float narrationOpacity = 0;
int dialogStartTime = 0;
int narrationStartTime = 0;
float dialogBubbleScale = 0;

// Variabel untuk Efek Ketik Narasi
String displayedNarration = "";
int narrationCharIndex = 0;

// Variabel untuk tahapan animasi
int tahapanAnimasi = 0;
int timerTahapan = 0;
float progressBerjalan = 0;
float progressTaruhLabu = 0;
float progressMemotong = 0;
float progressKoinJatuh = 0;
float progressKagum = 0;
float progressPisauTurun = 0;

// Variabel animasi karakter
float knifeAngle = 0;
float knifeYOffset = 0;
float glowIntensity = 0;
float leftArmRotation = 0;
float eyeSquint = 0;
float smileAnimationOffset = 0;

// === VARIABEL ANIMASI BERJALAN ===
float langkahKaki = 0;
float bobbing = 0;
float armSwing = 0;

// Variabel labu dan koin
float labuY = 0;
boolean labuTerpotong = false;
boolean labuSudahDitaruh = false;
ArrayList<Koin> daftarKoin;
ArrayList<Kilauan> daftarKilauan;

// Class untuk koin yang jatuh
class Koin {
    float x, y, vx, vy, rotasi, kecepatanRotasi;
    boolean terlihat;

    Koin(float startX, float startY) {
        x = startX + random(-30, 30);
        y = startY - 50;
        vx = random(-3, 3);
        vy = random(-8, -3);
        rotasi = 0;
        kecepatanRotasi = random(-0.2, 0.2);
        terlihat = false;
    }

    void update() {
        if (terlihat) {
            x += vx;
            y += vy;
            vy += 0.3;
            rotasi += kecepatanRotasi;
            if (y > height * 0.78) {
                y = height * 0.78;
                vy *= -0.6;
                vx *= 0.8;
            }
        }
    }

    void tampilkan() {
        if (terlihat) {
            pushMatrix();
            translate(x, y);
            rotate(rotasi);
            drawCoin(0, 0, 1);
            popMatrix();
        }
    }
}

// Class untuk efek kilauan
class Kilauan {
    float x, y, vx, vy, kehidupan;
    boolean terlihat;

    Kilauan(float startX, float startY) {
        x = startX;
        y = startY;
        vx = random(-2, 2);
        vy = random(-4, -1);
        kehidupan = 255;
        terlihat = false;
    }

    void update() {
        if (terlihat) {
            x += vx;
            y += vy;
            kehidupan -= 3;
            if (kehidupan <= 0) terlihat = false;
        }
    }

    void tampilkan() {
        if (terlihat) {
            pushMatrix();
            translate(x, y);
            fill(255, 255, 0, kehidupan);
            noStroke();
            gambarBintang(0, 0, 3, 6, 5);
            popMatrix();
        }
    }
}

void setup() {
    size(1280, 720);
    frameRate(60);

    // === SETUP VOICE-OVER ===
    try {
        minim = new Minim(this);
        audioLibraryLoaded = true;
        try {
            voNarasi1 = minim.loadFile("narasiPutih-sesampainya di rumah.mp3");
            voNarasi2 = minim.loadFile("narasiPutih-Dengan hati2.mp3");
            voNarasi3 = minim.loadFile("narasiPutih-seketika cahaya.mp3");
            voDialog1 = minim.loadFile("putih-wahh emas.mp3");
            voNarasi4 = minim.loadFile("narasiPutih-sejak hari itu.mp3");
            sfxLangkahKaki = minim.loadFile("langkah_kaki.mp3"); 
            sfxMemotong = minim.loadFile("pisau_memotong.mp3");
            sfxKoin = minim.loadFile("koin_jatuh.mp3");
            sfxHappyEnding = minim.loadFile("happy-ending.mp3");
            
            // Mengatur volume untuk semua file audio (DIKEMBALIKAN)
            if (voNarasi1 != null) voNarasi1.setGain(LEVEL_VOLUME);
            if (voNarasi2 != null) voNarasi2.setGain(LEVEL_VOLUME);
            if (voNarasi3 != null) voNarasi3.setGain(LEVEL_VOLUME);
            if (voDialog1 != null) voDialog1.setGain(LEVEL_VOLUME);
            if (voNarasi4 != null) voNarasi4.setGain(LEVEL_VOLUME);
            if (sfxLangkahKaki != null) sfxLangkahKaki.setGain(LEVEL_SFX);
            if (sfxMemotong != null) sfxMemotong.setGain(LEVEL_SFX);
            if (sfxKoin != null) sfxKoin.setGain(LEVEL_SFX);
            if (sfxHappyEnding != null) sfxHappyEnding.setGain(LEVEL_SFX);
            
            println("✅ Voice-over & SFX files loaded successfully!");
        } catch (Exception e) {
            println("⚠️ Voice-over files not found, animation will work without audio");
            voiceOverEnabled = false;
        }
    } catch (Exception e) {
        println("❌ Minim library not found! Install via Tools > Manage Tools > Libraries");
        audioLibraryLoaded = false;
        voiceOverEnabled = false;
    }

    // === SETUP FONTS ===
    fontDialog = createFont("MS Gothic", 18, true);
    fontNarasi = createFont("MS Gothic", 18, true);

    bawangPutihCenterX = -100;
    bawangPutihCenterY = height * 0.78 - 180;
    labuEmasCenterX = width * 0.52;
    labuEmasCenterY = height * 0.85 - (120 * PUMPKIN_SCALE);

    daftarKoin = new ArrayList<Koin>();
    for (int i = 0; i < 15; i++) daftarKoin.add(new Koin(labuEmasCenterX, labuEmasCenterY));

    daftarKilauan = new ArrayList<Kilauan>();
    for (int i = 0; i < 20; i++) daftarKilauan.add(new Kilauan(labuEmasCenterX, labuEmasCenterY));

    for (int i = 0; i < voicePlayed.length; i++) voicePlayed[i] = false;
}

void draw() {
    background(245, 235, 215);

    gambarLantai();
    gambarKarpet();
    gambarJendela();
    gambarLukisanDinding();
    gambarLampuGantung();

    updateAnimasi();
    updateDialogNarasi();

    if (tahapanAnimasi >= 1) drawBawangPutih(bawangPutihCenterX, bawangPutihCenterY);
    if (labuSudahDitaruh || (tahapanAnimasi >= 2 && tahapanAnimasi < 6)) gambarLabuDalamCerita();
    if (tahapanAnimasi >= 4) gambarKoinDanKilauan();

    gambarDialog();
    gambarNarasi();
    
    if (fadeOutAlpha > 0) {
        fill(0, fadeOutAlpha);
        noStroke();
        rect(0, 0, width, height);
    }

    timerTahapan++;
}

void playSFX(AudioPlayer sfx) {
    if (audioLibraryLoaded && voiceOverEnabled && sfx != null) {
        sfx.rewind();
        sfx.play();
    }
}

void playVoiceOver(AudioPlayer audio, int index) {
    if (audioLibraryLoaded && voiceOverEnabled && audio != null && !voicePlayed[index]) {
        audio.rewind();
        audio.play();
        voicePlayed[index] = true;
        println("🎵 Playing voice-over " + (index + 1));
    }
}

void stopAllVoiceOver() {
    if (audioLibraryLoaded && voiceOverEnabled) {
        if (voNarasi1 != null) voNarasi1.pause();
        if (voNarasi2 != null) voNarasi2.pause();
        if (voNarasi3 != null) voNarasi3.pause();
        if (voDialog1 != null) voDialog1.pause();
        if (voNarasi4 != null) voNarasi4.pause();
    }
}

void updateDialogNarasi() {
    if (showDialog) {
        dialogOpacity = min(255, dialogOpacity + 15);
        dialogBubbleScale = min(1.0, dialogBubbleScale + 0.05); // Kecepatan pop-up bubble
    } else {
        dialogOpacity = max(0, dialogOpacity - 15);
        dialogBubbleScale = max(0, dialogBubbleScale - 0.05);
    }

    if (showNarration) {
        narrationOpacity = min(255, narrationOpacity + 10);
        // Update efek ketik
        if (narrationCharIndex < currentNarration.length() && frameCount % KECEPATAN_KETIK_NARASI == 0) {
            displayedNarration += currentNarration.charAt(narrationCharIndex);
            narrationCharIndex++;
        }
    } else {
        narrationOpacity = max(0, narrationOpacity - 10);
    }
}

void updateAnimasi() {
    switch(tahapanAnimasi) {
        case 0: // Narasi Pembuka
            if (timerTahapan == 30) {
                showNarration = true;
                currentNarration = "Sesampainya di rumah, Putih membawa labu serta pisau dan meletakkan labu di lantai.";
                displayedNarration = ""; 
                narrationCharIndex = 0;
                playVoiceOver(voNarasi1, 0);
            }
            if (timerTahapan > DELAY_MULAI_BERJALAN + DURASI_NARASI_AWAL) {
                showNarration = false;
                tahapanAnimasi = 1;
                timerTahapan = 0;
            }
            break;

        case 1: // Bawang Putih Berjalan (dengan suara loop)
            progressBerjalan = min(1, timerTahapan / KECEPATAN_BERJALAN);
            bawangPutihCenterX = lerp(-100, width * 0.39, easeInOut(progressBerjalan));

            if (progressBerjalan > 0 && progressBerjalan < 1) {
                if (!isWalkingSoundPlaying) {
                    if (sfxLangkahKaki != null) sfxLangkahKaki.loop();
                    isWalkingSoundPlaying = true;
                }
                langkahKaki = sin(timerTahapan * 0.15) * 15;
                bobbing = abs(sin(timerTahapan * 0.15)) * 8;
                armSwing = sin(timerTahapan * 0.05) * 0.3;
            } else {
                if (isWalkingSoundPlaying) {
                    if (sfxLangkahKaki != null) sfxLangkahKaki.pause();
                    isWalkingSoundPlaying = false;
                }
                langkahKaki = 0;
                bobbing = 0;
                armSwing = 0;
            }
            
            if (progressBerjalan >= 1) {
                tahapanAnimasi = 2;
                timerTahapan = 0;
            }
            break;

        case 2: // Narasi Memotong Labu
            progressTaruhLabu = min(1, timerTahapan / KECEPATAN_TARUH_LABU);
            labuY = lerp(-50, 0, easeInOut(progressTaruhLabu));
            if (timerTahapan == 30 && !showNarration) {
                showNarration = true;
                currentNarration = "Dengan hati-hati, dia mulai memotongnya dengan pisau.";
                displayedNarration = ""; 
                narrationCharIndex = 0;
                playVoiceOver(voNarasi2, 1);
            }
            if (progressTaruhLabu >= 1 && timerTahapan > DURASI_NARASI_MEMOTONG) {
                labuSudahDitaruh = true;
                tahapanAnimasi = 3;
                timerTahapan = 0;
                showNarration = false;
            }
            break;

        case 3: // Aksi Labu Terbelah
            progressMemotong = min(1, timerTahapan / KECEPATAN_MEMOTONG);
            if (progressMemotong > 0.5 && progressMemotong < 0.9 && frameCount % 15 == 0) {
                 playSFX(sfxMemotong);
            }
            if (progressMemotong >= 0.8 && !labuTerpotong) {
                labuTerpotong = true;
                for (Koin koin : daftarKoin) koin.terlihat = true;
                for (Kilauan kilauan : daftarKilauan) kilauan.terlihat = true;
            }
            if (progressMemotong >= 1) {
                tahapanAnimasi = 4; // Pindah ke case narasi berhamburan
                timerTahapan = 0;
            }
            break;

        case 4: // Narasi Koin Berhamburan (KUNCI SOLUSINYA DI SINI)
            if (timerTahapan == 1) {
                showNarration = true;
                currentNarration = "Seketika, cahaya keemasan menyembur keluar! Koin emas berkilau dan permata warna-warni berhamburan memenuhi lantai rumah dengan bunyi gemerincing koin!";
                displayedNarration = "";
                narrationCharIndex = 0;
                playVoiceOver(voNarasi3, 2);
                playSFX(sfxKoin);
            }
            for (Koin koin : daftarKoin) koin.update();
            for (Kilauan kilauan : daftarKilauan) kilauan.update();
            
            // Narasi akan tetap tampil selama durasi ini
            if (timerTahapan > DURASI_NARASI_BERHAMBURAN) {
                showNarration = false;
                tahapanAnimasi = 5; // Baru pindah ke dialog setelah durasi selesai
                timerTahapan = 0;
            }
            break;

        case 5: // Dialog Putih
            for (Koin koin : daftarKoin) koin.update();
            for (Kilauan kilauan : daftarKilauan) kilauan.update();
            if (timerTahapan == DELAY_DIALOG_KAGUM && !showDialog) {
                showDialog = true;
                currentDialog = "Wahhhhhh!! Isinya emasss!";
                dialogStartTime = timerTahapan;
                playVoiceOver(voDialog1, 3);
            }
            if (showDialog && (timerTahapan - dialogStartTime) > DURASI_DIALOG_KAGUM) {
                showDialog = false;
            }
            if (timerTahapan > DURASI_DIALOG_KAGUM + DELAY_DIALOG_KAGUM + 60) {
                tahapanAnimasi = 6;
                timerTahapan = 0;
            }
            break;

        case 6: // Narasi Akhir
            if (timerTahapan == 60) {
                showNarration = true;
                currentNarration = "Sejak hari itu, Putih hidup bahagia dan tetap menjadi gadis yang baik hati seperti sebelumnya.";
                displayedNarration = "";
                narrationCharIndex = 0;
                playVoiceOver(voNarasi4, 4);
            }
            if (timerTahapan == DURASI_NARASI_AKHIR - 60) {
                playSFX(sfxHappyEnding); // Mainkan musik happy ending
            }
        
            if (timerTahapan > DURASI_NARASI_AKHIR) {
                tahapanAnimasi = 7;
                timerTahapan = 0;
                showNarration = false;
            }
            break;

        case 7: // State Akhir sebelum Fade Out
            progressPisauTurun = min(1, timerTahapan / KECEPATAN_PISAU_TURUN);
            if (progressPisauTurun >= 1) {
                tahapanAnimasi = 8; // Pindah ke case fade out
                timerTahapan = 0;
            }
            break;
            
        case 8: // Transisi Fade Out
            float progressFade = min(1, timerTahapan / KECEPATAN_FADE_OUT);
            fadeOutAlpha = lerp(0, 255, progressFade);
            break;
    }
    if (labuTerpotong) {
        // Ekspresi kagum (mata berbinar lebih cepat, senyum lebih lebar)
        eyeSquint = abs(sin(millis() * 0.008)) * 0.5;
        smileAnimationOffset = sin(millis() * 0.01) * 5;
    } else {
        // Ekspresi normal
        eyeSquint = abs(sin(millis() * 0.003)) * 0.3;
        smileAnimationOffset = sin(millis() * 0.005) * 3;
    }
}

void keyPressed() {
    if (key == 'm' || key == 'M') {
        voiceOverEnabled = !voiceOverEnabled;
        if (!voiceOverEnabled) stopAllVoiceOver();
        println("Voice-over " + (voiceOverEnabled ? "ENABLED" : "DISABLED"));
    }
    if (key == 'r' || key == 'R') {
        tahapanAnimasi = 0;
        timerTahapan = 0;
        fadeOutAlpha = 0;
        stopAllVoiceOver();
        if (sfxLangkahKaki != null) sfxLangkahKaki.pause(); // <<< TAMBAHKAN INI
        isWalkingSoundPlaying = false;
        for (int i = 0; i < voicePlayed.length; i++) voicePlayed[i] = false;
        println("Animation RESET");
    }
    if (key == 's' || key == 'S') {
        stopAllVoiceOver();
        println("All voice-over STOPPED");
    }
}

// === DIALOG BUBBLE ===
void gambarDialog() {
    if (dialogOpacity > 0) {
        pushMatrix();
        
        // Posisi TOP-LEFT dari bubble utama.
        float bubbleX = bawangPutihCenterX - 80;
        // <<< DIUBAH: Nilai Y dikurangi lagi agar posisi bubble turun
        float bubbleY = bawangPutihCenterY - 160; 

        translate(bubbleX, bubbleY);
        scale(dialogBubbleScale); // Menerapkan animasi pop-up

        // === KOTAK NAMA "Putih" (Posisi Kiri Atas) ===
        float nameBoxHeight = 35;
        float nameBoxWidth = 110;
        float nameBoxSpacing = 5;
        
        fill(220, 220, 220, dialogOpacity);
        stroke(255, 255, 255, dialogOpacity);
        strokeWeight(2);
        rect(0, -(nameBoxHeight + nameBoxSpacing), nameBoxWidth, nameBoxHeight, 8);

        // Teks Nama
        fill(50, 50, 50, dialogOpacity);
        textFont(fontDialog);
        textSize(18);
        textAlign(CENTER, CENTER);
        text("Putih", nameBoxWidth / 2, -(nameBoxHeight + nameBoxSpacing) + (nameBoxHeight / 2));

        // === GELEMBUNG UTAMA ===
        float bubbleWidth = 320;
        float bubbleHeight = 60;
        
        // Bayangan
        fill(0, 0, 0, dialogOpacity * 0.10);
        noStroke();
        rect(3, 3, bubbleWidth, bubbleHeight, 30);

        // Gelembung
        fill(255, 255, 255, dialogOpacity);
        stroke(150, 150, 150, dialogOpacity);
        strokeWeight(2);
        rect(0, 0, bubbleWidth, bubbleHeight, 30);

        // Ekor Gelembung (posisinya akan ikut turun secara otomatis)
        noStroke();
        fill(255, 255, 255, dialogOpacity);
        triangle(40, bubbleHeight, 60, bubbleHeight, 50, bubbleHeight + 20); 
        
        stroke(150, 150, 150, dialogOpacity);
        strokeWeight(2);
        noFill();
        line(40, bubbleHeight, 50, bubbleHeight + 20);
        line(60, bubbleHeight, 50, bubbleHeight + 20);

        // Teks Dialog
        fill(0, 0, 0, dialogOpacity);
        textSize(22);
        textAlign(LEFT, TOP);
        text(currentDialog, 15, 10, bubbleWidth - 30, bubbleHeight - 20); 

        popMatrix();
    }
}

// === NARRATION BOX (Dengan Efek Ketik) ===
void gambarNarasi() {
    if (narrationOpacity > 0) {
        float alphaNameBox = 150 * (narrationOpacity / 255.0);
        float alphaTextBox = 240 * (narrationOpacity / 255.0);
        float alphaBorder = 255 * (narrationOpacity / 255.0);
        float alphaText = 255 * (narrationOpacity / 255.0);

        // Kotak Nama "Narasi"
        fill(0, alphaNameBox);
        noStroke();
        rect(50, 555, 140, 36, 8);

        // Teks Nama
        fill(255, alphaText);
        textFont(fontNarasi);
        textSize(20);
        textAlign(LEFT, TOP);
        text("Narasi", 70, 561);

        // Kotak Teks Utama
        fill(255, alphaTextBox);
        stroke(180, alphaBorder);
        strokeWeight(2);
        rect(50, 600, 1180, 100, 15);

        // Teks Narasi (dengan efek ketik)
        fill(0, alphaText);
        noStroke();
        textSize(22);
        textAlign(LEFT, TOP);
        textLeading(28);
        text(displayedNarration, 70, 615, 1140, 90);

        textAlign(CENTER, CENTER); // Reset alignment
    }
}

// === CLEANUP ===
void stop() {
    if (audioLibraryLoaded) {
        if (voNarasi1 != null) voNarasi1.close();
        if (voNarasi2 != null) voNarasi2.close();
        if (voNarasi3 != null) voNarasi3.close();
        if (voDialog1 != null) voDialog1.close();
        if (voNarasi4 != null) voNarasi4.close();
        if (sfxLangkahKaki != null) sfxLangkahKaki.close();
        if (sfxMemotong != null) sfxMemotong.close();
        if (sfxKoin != null) sfxKoin.close();
        if (minim != null) minim.stop();
    }
    super.stop();
}

// === FUNGSI UTILITAS & GAMBAR LAINNYA (TIDAK DIUBAH) ===
float easeInOut(float t) {
    return t * t * (3 - 2 * t);
}

void gambarLabuDalamCerita() {
    pushMatrix();
    translate(labuEmasCenterX, labuEmasCenterY + labuY);
    scale(PUMPKIN_SCALE);
    if (labuTerpotong) {
        drawPumpkin();
        drawTreasure();
        drawGlow();
    } else {
        gambarLabuUtuh();
    }
    popMatrix();
}

void gambarLabuUtuh() {
    if (labuSudahDitaruh || tahapanAnimasi >= 2) {
        fill(0, 0, 0, 50);
        ellipse(5, 120, 350, 80);
    }
    fill(255, 140, 60);
    stroke(200, 100, 40);
    strokeWeight(3);
    ellipse(0, 0, 300, 200);
    stroke(220, 120, 50);
    strokeWeight(2);
    noFill();
    for (int i = -3; i <= 3; i++) {
        float centerX = i * 35;
        beginShape();
        for (int j = -20; j <= 20; j++) {
            float t = j / 20.0;
            float y_val = t * 95;
            float labuWidth = sqrt(1 - (y_val * y_val) / (95 * 95)) * 150;
            float ridgeOffset = (centerX / 150.0) * labuWidth;
            float x_val = ridgeOffset;
            float curve = sin(t * PI) * 5;
            x_val += curve * abs(centerX) / 105.0;
            vertex(x_val, y_val);
        }
        endShape();
    }
    fill(101, 67, 33);
    stroke(80, 50, 20);
    strokeWeight(2);
    rect(-10, -120, 20, 30, 5);
    fill(120, 80, 40);
    rect(-8, -110, 16, 15, 3);
    fill(34, 139, 34);
    ellipse(-15, -105, 20, 8);
    ellipse(15, -108, 18, 7);
}

void gambarKoinDanKilauan() {
    for (Koin koin : daftarKoin) koin.tampilkan();
    for (Kilauan kilauan : daftarKilauan) kilauan.tampilkan();
}

void gambarBintang(float x, float y, float radius1, float radius2, int npoints) {
    float angle = TWO_PI / npoints;
    float halfAngle = angle / 2.0;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
        float sx = x + cos(a) * radius2;
        float sy = y + sin(a) * radius2;
        vertex(sx, sy);
        sx = x + cos(a + halfAngle) * radius1;
        sy = y + sin(a + halfAngle) * radius1;
        vertex(sx, sy);
    }
    endShape(CLOSE);
}

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
    float swayOffset = 0.5 * sin(millis() * 0.008) * cos(millis() * 0.0008);
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
    float lightFlicker = 0.9 + 0.1 * sin(timeBase * 15) + 0.05 * sin(timeBase * 27) + 0.03 * sin(timeBase * 41);
    float lightIntensity = 60 * lightFlicker;
    fill(255, 255, 200, lightIntensity * 0.4);
    ellipse(0, 35, 250, 150);
    fill(255, 255, 220, lightIntensity * 0.6);
    ellipse(0, 35, 180, 108);
    fill(255, 255, 240, lightIntensity * 0.8);
    ellipse(0, 35, 120, 72);
    fill(255, 255, 255, lightIntensity);
    ellipse(0, 35, 80, 48);
    popMatrix();
}

void drawBawangPutih(float cx, float cy) {
    pushMatrix();
    translate(cx, cy + bobbing);
    fill(220, 220, 220, 100);
    noStroke();
    ellipse(0, 180, 140, 30);
    fill(255, 220, 190);
    stroke(139, 69, 19);
    strokeWeight(3);
    ellipse(-30 - langkahKaki, 160, 35, 45);
    ellipse(30 + langkahKaki, 160, 35, 45);
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
    pushMatrix();
    translate(-60, 50);
    rotate(leftArmRotation - armSwing);
    drawLengan(0, 0, true);
    popMatrix();
    pushMatrix();
    translate(60, 50);
    rotate(armSwing);
    drawLengan(0, 0, false);
    popMatrix();
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
    bezierLine(0, 25, 0, -60, 0, -130);
    bezierLine(-30, 25, -50, -40, -18, -120);
    bezierLine(30, 25, 50, -40, 18, -120);
    bezierLine(-40, 28, -90, -30, -45, -100);
    bezierLine(40, 28, 90, -30, 45, -100);
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
    if (tahapanAnimasi == 1) {
        pushMatrix();
        translate(10, 70 + bobbing * 0.5);
        scale(0.5);
        gambarLabuUtuhTanpaBayangan();
        popMatrix();
    }
    if (tahapanAnimasi >= 1) {
        pushMatrix();
        translate(-30, 70 + knifeYOffset);
        if (tahapanAnimasi == 1 || tahapanAnimasi == 2) {
            rotate(PI / 2 + armSwing * 0.5);
        } else if (tahapanAnimasi == 3) {
            rotate(PI / 2 + knifeAngle + sin(progressMemotong * PI * 4) * 0.3);
        } else if (tahapanAnimasi >= 4) {
            float targetAngle = PI / 2 + PI / 4;
            rotate(targetAngle);
            translate(20, -15 + knifeYOffset);
        }
        drawKnife();
        popMatrix();
    }
    noStroke();
    fill(101, 67, 33);
    ellipse(-22, -50, 8, 10 * (1 - eyeSquint));
    ellipse(22, -50, 8, 10 * (1 - eyeSquint));
    stroke(101, 67, 33);
    strokeWeight(2);
    noFill();
    arc(-22, -58 - (eyeSquint * 5), 15, 6, PI, TWO_PI);
    arc(22, -58 - (eyeSquint * 5), 15, 6, PI, TWO_PI);
    noStroke();
    fill(255, 182, 193, 150 + (eyeSquint * 50));
    ellipse(-35, -35, 20, 12);
    ellipse(35, -35, 20, 12);
    noFill();
    stroke(139, 69, 19);
    strokeWeight(2);
    arc(0, -20, 40, 20 + smileAnimationOffset, 0, PI);
    fill(154, 205, 50);
    stroke(107, 142, 35);
    strokeWeight(3);
    drawDaun(0, -130);
    popMatrix();
}

void gambarLabuUtuhTanpaBayangan() {
    fill(255, 140, 60);
    stroke(200, 100, 40);
    strokeWeight(3);
    ellipse(0, 0, 300, 200);
    stroke(220, 120, 50);
    strokeWeight(2);
    noFill();
    for (int i = -3; i <= 3; i++) {
        float centerX = i * 35;
        beginShape();
        for (int j = -20; j <= 20; j++) {
            float t = j / 20.0;
            float y_val = t * 95;
            float labuWidth = sqrt(1 - (y_val * y_val) / (95 * 95)) * 150;
            float ridgeOffset = (centerX / 150.0) * labuWidth;
            float x_val = ridgeOffset;
            float curve = sin(t * PI) * 5;
            x_val += curve * abs(centerX) / 105.0;
            vertex(x_val, y_val);
        }
        endShape();
    }
    fill(101, 67, 33);
    stroke(80, 50, 20);
    strokeWeight(2);
    rect(-10, -120, 20, 30, 5);
    fill(120, 80, 40);
    rect(-8, -110, 16, 15, 3);
    fill(34, 139, 34);
    ellipse(-15, -105, 20, 8);
    ellipse(15, -108, 18, 7);
}

void bezierLine(float x1, float y1, float x2, float y2, float x3, float y3) {
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

void drawPumpkin() {
    fill(0, 0, 0, 50);
    ellipse(5, 120, 350, 80);
    fill(255, 140, 60);
    stroke(200, 100, 40);
    strokeWeight(3);
    ellipse(0, 0, 300, 200);
    stroke(220, 120, 50);
    strokeWeight(2);
    noFill();
    for (int i = -3; i <= 3; i++) {
        float centerX = i * 35;
        beginShape();
        for (int j = -20; j <= 20; j++) {
            float t = j / 20.0;
            float y_val = t * 95;
            float labuWidth = sqrt(1 - (y_val * y_val) / (95 * 95)) * 150;
            float ridgeOffset = (centerX / 150.0) * labuWidth;
            float x_val = ridgeOffset;
            float curve = sin(t * PI) * 5;
            x_val += curve * abs(centerX) / 105.0;
            vertex(x_val, y_val);
        }
        endShape();
    }
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
    fill(120, 60, 20);
    noStroke();
    ellipse(0, 0, 35, 160);
    stroke(100, 50, 15);
    strokeWeight(1);
    for (int i = 0; i < 10; i++) {
        float y_val = -80 + i * 16;
        line(-15, y_val, -20, y_val + 5);
        line(15, y_val, 20, y_val + 5);
    }
    fill(101, 67, 33);
    stroke(80, 50, 20);
    strokeWeight(2);
    rect(-10, -120, 20, 30, 5);
    fill(120, 80, 40);
    rect(-8, -110, 16, 15, 3);
    fill(34, 139, 34);
    ellipse(-15, -105, 20, 8);
    ellipse(15, -108, 18, 7);
}

void drawTreasure() {
    drawCoinsAndJewels(-15, -70 + 20, 30, 140, false);
    drawCoinsAndJewels(-50, 80 + 20, 100, 80, true);
}

void drawCoinsAndJewels(float x, float y, float w, float h, boolean spilled) {
    randomSeed(123);
    int numItems = spilled ? 25 : 35;
    for (int i = 0; i < numItems; i++) {
        float itemX = x + random(w);
        float itemY = y + random(h);
        if (random(1) < 0.7) {
            drawCoin(itemX, itemY, random(0.3) + 0.7);
        } else {
            drawJewel(itemX, itemY, random(0.4) + 0.6);
        }
    }
}

void drawCoin(float x, float y, float scale) {
    pushMatrix();
    translate(x, y);
    scale(scale);
    fill(0, 0, 0, 30);
    ellipse(2, 2, 25, 25);
    fill(255, 215, 0);
    stroke(200, 165, 0);
    strokeWeight(2);
    ellipse(0, 0, 22, 22);
    fill(255, 255, 150);
    noStroke();
    ellipse(-3, -3, 8, 8);
    stroke(180, 140, 0);
    strokeWeight(1);
    noFill();
    ellipse(0, 0, 15, 15);
    ellipse(0, 0, 10, 10);
    popMatrix();
}

void drawJewel(float x, float y, float scale) {
    pushMatrix();
    translate(x, y);
    scale(scale);
    fill(0, 0, 0, 40);
    ellipse(2, 2, 20, 15);
    color[] jewelColors = {
        color(255, 100, 100),
        color(100, 255, 100),
        color(100, 100, 255),
        color(255, 100, 255),
        color(100, 255, 255)
    };
    int colorIndex = (int)(random(jewelColors.length));
    fill(jewelColors[colorIndex]);
    stroke(red(jewelColors[colorIndex]) * 0.7, green(jewelColors[colorIndex]) * 0.7, blue(jewelColors[colorIndex]) * 0.7);
    strokeWeight(1);
    beginShape();
    vertex(0, -8);
    vertex(-6, -2);
    vertex(-4, 6);
    vertex(4, 6);
    vertex(6, -2);
    endShape(CLOSE);

    fill(255, 255, 255, 150);
    noStroke();
    beginShape();
    vertex(0, -8);
    vertex(-3, -4);
    vertex(0, 0);

    endShape(CLOSE);
    popMatrix();
}

void drawGlow() {
    for (int i = 0; i < 3; i++) {
        fill(255, 180, 50, (glowIntensity / 255.0) * (20 - i * 5));
        noStroke();
        ellipse(0, 10, 380 + i * 40, 220 + i * 30);
    }
    fill(255, 215, 0, (glowIntensity / 255.0) * 30);
    ellipse(0, 50, 200, 120);
}

void drawKnife() {
    scale(0.7);
    fill(139, 69, 19);
    stroke(80, 40, 10);
    strokeWeight(2);
    rect(-10, 0, 20, 80, 10);
    fill(150, 150, 150);
    noStroke();
    ellipse(0, 20, 5, 5);
    ellipse(0, 60, 5, 5);
    fill(100, 100, 100);
    stroke(50, 50, 50);
    strokeWeight(2);

    beginShape();
    vertex(-10, 0);
    vertex(-10, -140);
    vertex(10, -105);
    vertex(15, 0);
    endShape(CLOSE);

    fill(180, 180, 180);
    noStroke();

    beginShape();
    vertex(-8, -5);
    vertex(-8, -135);
    vertex(8, -100);
    vertex(12, -5);
    endShape(CLOSE);

    fill(255, 255, 255, 150);

    beginShape();
    vertex(-5, -90);
    vertex(0, -110);
    vertex(5, -90);
    vertex(0, -70);
    endShape(CLOSE);
}
