# 🌿 Magloop Ecologistik - Green Logistics for Circular Economy

[![Build Status](https://img.shields.io/badge/Build-Success-brightgreen)](https://github.com/riyandimuhamad/magloop-ecologistik)
[![Flutter](https://img.shields.io/badge/Framework-Flutter%203.x-blue)](https://flutter.dev)
[![Gemini AI](https://img.shields.io/badge/AI-Gemini%201.5%20Flash-orange)](https://ai.google.dev)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-yellow)](https://firebase.google.com)

**Magloop Ecologistik** adalah platform manajemen logistik pintar yang menghubungkan sektor kuliner (HOREKA), logistik, dan pertanian melalui ekosistem **Maggot BSF**. Aplikasi ini dirancang untuk memaksimalkan nilai ekonomi sampah organik sekaligus mendigitalkan rantai pasok pupuk hayati (Kasgot).

---

## 🌟 Fitur Unggulan (The 4-Pillar Ecosystem)

### 1. 🤖 AI Quality Control (Mitra Penyedia Sampah)
Mitra dapat menggunakan kamera bertenaga **Gemini AI** untuk menganalisis kualitas sampah organik secara real-time. AI akan mendeteksi kontaminasi (plastik/logam) untuk memastikan pakan maggot tetap berkualitas tinggi.

### 2. 📱 Smart Logistics (Driver)
Sistem penjemputan berbasis **QR Verification** dan integrasi **Google Maps**. Driver mendapatkan insentif koin (GreenCoin) yang setara dengan Mitra untuk setiap kilogram sampah yang berhasil dikelola.

### 3. 🚜 Fertilizer Supply Chain (Mitra Petani)
Role baru yang memungkinkan petani memesan **Pupuk Kasgot** (Bekas Maggot) langsung dari aplikasi. Menciptakan siklus sirkular dari Dapur ➡️ Magloop ➡️ Lahan Pertanian.

### 4. 📊 Audit & Ledger (Admin)
Dashboard terpusat untuk memantau sirkulasi koin, stok pupuk, dan efektivitas pengelolaan sampah di seluruh wilayah.

---

## 🚀 Teknologi yang Digunakan
*   **Frontend**: Flutter (Web, Android, iOS) - Responsive & Premium UI.
*   **Intelligence**: Google Gemini 1.5 Flash API (Multimodal Vision).
*   **Backend**: Firebase (Cloud Firestore for real-time ledger).
*   **DevOps**: Google Cloud Build & Cloud Run (Automated CI/CD).
*   **Tools**: Mobile Scanner (QR), URL Launcher (Maps), Image Picker.

---

## 🏗️ Struktur Proyek
```text
lib/
├── core/            # Theme, Config, & Global Styles
├── features/        # Modul per Role (Mitra, Driver, Admin, Petani)
│   ├── auth/        # Role Wrapper & Login Logic
│   ├── mitra/       # AI QC & Waste Deposit
│   ├── driver/      # Logistics & QR Scanner
│   ├── petani/      # Fertilizer Ordering
│   └── admin/       # Dashboard Audit
├── services/        # Firebase & AI Service Integrations
└── main.dart        # Entry point & Global State
```

---

## 📈 Sistem Sirkular Ekonomi
1.  **Input**: Mitra menyetor sampah organik (1 Kg = 10 GC).
2.  **Logistics**: Driver menjemput & mengantar (Upah = 10 GC/Kg).
3.  **Process**: Maggot mengubah sampah menjadi Pupuk Kasgot.
4.  **Output**: Petani memesan pupuk untuk lahan pertanian berkelanjutan.

---

## 👨‍💻 Cara Instalasi (Lokal)
1. Clone repositori:
   ```bash
   git clone https://github.com/riyandimuhamad/magloop-ecologistik.git
   ```
2. Jalankan perintah:
   ```bash
   cd magloop_ecologistik
   flutter pub get
   flutter run -d chrome
   ```

---

## 📝 Lisensi
Proyek ini dikembangkan untuk kompetisi **Juara Vibe Coding 2026**. Seluruh hak cipta dilindungi oleh tim pengembang Magloop.

---
*Dibuat dengan ❤️ untuk Bumi yang lebih hijau.*
