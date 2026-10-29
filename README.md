# YouTube Sound Downloader untuk Windows

Aplikasi GUI Windows PowerShell untuk meminta metadata video dari API yang dikonfigurasi dan mengunduh audio **hanya jika API menyediakan URL stream langsung yang dapat diakses**. Gunakan untuk konten yang Anda miliki atau yang Anda punya izin untuk unduh. Aplikasi ini tidak melewati DRM, login, paywall, atau proteksi akses.

## Status penting

- Base URL bawaan: `https://edge-1.nusantaracode.com`.
- Endpoint metadata yang sudah diuji: `GET /youtube/video-detail?vid_id=VIDEO_ID`.
- Uji respons endpoint menemukan format audio di `data.streamingData.adaptiveFormats`, tetapi format yang dikembalikan **tidak menyertakan `url`, `signatureCipher`, atau `cipher`**.
- Akibatnya, EXE/GUI bisa dibuat, tetapi proses mengunduh audio belum dapat dinyatakan berfungsi dengan API saat ini. API perlu menyediakan endpoint unduhan yang sah atau URL stream langsung yang dapat dipakai. Aplikasi menampilkan error yang menjelaskan keterbatasan ini; tidak membuat-buat URL.

## Cara mendapatkan EXE

Build berjalan otomatis pada GitHub Actions setiap kali ada push ke branch `main`.

1. Buka tab **Actions** pada repositori: https://github.com/rahadiana/youtube-sound-downloader-windows/actions
2. Pilih workflow **Build Windows EXE**.
3. Buka run terbaru yang selesai dengan status hijau.
4. Pada bagian **Artifacts**, unduh `YouTube-Sound-Downloader-Windows`.
5. Ekstrak ZIP, lalu jalankan `YouTube-Sound-Downloader.exe` di Windows.

Workflow juga bisa dijalankan manual melalui **Actions → Build Windows EXE → Run workflow**. Artifact disimpan selama 30 hari. Build menggunakan runner Windows GitHub Actions; EXE tidak dibangun atau diuji pada host Linux pengembangan.

## Cara menjalankan dari source

Persyaratan: Windows PowerShell 5.1 atau PowerShell 7 dengan Windows Forms tersedia.

1. Unduh/clone repositori.
2. Jalankan `Launch-GUI.bat`, atau buka PowerShell pada folder repositori dan jalankan:

```powershell
.\Download-YouTubeSound-GUI.ps1
```

GUI berisi kolom URL/ID video, Base URL API, folder output, dan tombol **Ambil File Sound**.

## Cara kerja

1. Aplikasi menerima ID video YouTube 11 karakter atau URL YouTube yang dikenali.
2. Aplikasi meminta detail melalui `GET {BaseUrl}/youtube/video-detail?vid_id={VIDEO_ID}`.
3. Aplikasi mencari format audio dengan MIME type `audio/*` dan URL langsung.
4. Jika URL tersedia, format `audio/mp4` diprioritaskan; file disimpan ke folder output. Jika URL tidak tersedia, aplikasi berhenti dengan pesan yang menjelaskan bahwa API belum menyediakan URL stream yang didukung.

## Troubleshooting

- **API tidak bisa dihubungi:** periksa koneksi, Base URL, sertifikat TLS, dan status layanan.
- **Tidak ada URL stream langsung:** ini sesuai dengan respons API yang diuji saat dokumentasi dibuat. Perlu endpoint unduhan/stream resmi dari sisi API; mengganti nama endpoint tanpa bukti tidak akan menyelesaikannya.
- **Windows menampilkan peringatan saat EXE dibuka:** EXE hasil build tidak ditandatangani secara digital. Pastikan file berasal dari workflow/repo yang benar sebelum menjalankannya.
- **Artifact belum muncul:** periksa apakah run Actions berhasil; jika gagal, buka log langkah build.

## File utama

- `Download-YouTubeSound-GUI.ps1` — antarmuka Windows Forms.
- `Download-YouTubeSound.ps1` — permintaan metadata dan logika unduhan.
- `Launch-GUI.bat` — launcher dari source.
- `.github/workflows/build-windows.yml` — build EXE otomatis di runner Windows dan unggah artifact.

## Catatan build dan verifikasi

Workflow mengemas kedua skrip ke dalam launcher lalu mengompilasinya dengan PS2EXE agar pengguna tidak perlu menaruh file PS1 terpisah untuk menjalankan GUI. Keberhasilan build harus dikonfirmasi dari status GitHub Actions. Kompilasi EXE **tidak** berarti jalur unduh audio API telah berhasil diuji; keterbatasan endpoint di atas tetap berlaku.
