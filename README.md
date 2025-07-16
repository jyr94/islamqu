# 📱 Islamqu

**Islamqu** adalah aplikasi Flutter ringan yang menyediakan fitur-fitur Islami seperti Al-Quran digital, jadwal sholat, arah kiblat, dan kumpulan doa — tanpa perlu backend. Semua data diolah langsung dari sumber terbuka.

![Islamqu On playstore]([https://your-screenshot-link.com](https://play.google.com/store/apps/details?id=islam.qu.islamqu)) <!-- opsional -->

---

## ✨ Fitur Utama

- 📖 **Al-Qur'an Per Ayat**  
  Menampilkan ayat demi ayat dalam tampilan yang mudah dibaca dan user-friendly.  
  Data bersumber dari:  
  👉 [Al-Quran JSON Indonesia Kemenag](https://github.com/jyr94/Al-Quran-JSON-Indonesia-Kemenag)

- 🕋 **Jadwal Sholat Harian**  
  Jadwal sholat berdasarkan lokasi pengguna, lengkap dari Subuh hingga Isya.

- 🔔 **Notifikasi Jadwal Sholat**  
  Pengingat otomatis menjelang waktu sholat.

- 🧭 **Penunjuk Arah Kiblat**  
  Menggunakan sensor perangkat untuk menunjukkan arah kiblat secara akurat.

- 🙏 **Pencarian Doa-doa Harian**  
  Kumpulan doa lengkap dan mudah dicari berdasarkan kata kunci.

---

## 🚀 Teknologi

- Flutter 3.x
- Tanpa backend (semua data disimpan lokal atau dari sumber terbuka)
- Permission: GPS (untuk arah kiblat & lokasi jadwal sholat)
- Push Notification (jadwal sholat)

---

## 📦 Instalasi

```bash
git clone https://github.com/username/islamqu.git
cd islamqu
flutter pub get
flutter run
