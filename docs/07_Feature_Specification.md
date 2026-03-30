# 07 Feature Specification

## 1. Auth

### Screen
- Splash
- Login

### Endpoint
- `POST /api/login`
- `POST /api/logout`
- `GET /api/me`

### Output
- login berhasil
- session tersimpan
- role terbaca
- route diarahkan sesuai role

## 2. Camera Permission

### Screen
- Camera Permission Screen atau on-demand prompt saat masuk step foto

### Kebutuhan
- tampil sekali di awal atau saat perlu
- jelaskan kenapa kamera dibutuhkan
- jika ditolak, arahkan user ke settings ketika masuk step foto

## 3. Petugas App Shell

### Bottom menu
- `Patroli`
- `Home`
- `Profile`

### Default tab
- `Patroli`

## 4. PIC App Shell

### Bottom menu
- `Home`
- `Finding`
- `Profile`

### Default tab
- `Home`

## 5. Home PIC

### Tujuan
Home PIC tidak boleh kosong. Halaman ini menjadi entry utama setelah PIC login manual.

### Isi utama
- greeting singkat
- summary ringan opsional
- list / grid card `areas` sesuai akses master

### Isi card area
- nama area
- code area optional
- building type
- count finding optional jika backend menyediakan
- CTA masuk ke finding area tersebut

### Rule
- area hanya tampil jika PIC punya akses
- data area tidak diinput dari frontend
- data area berasal dari backend master access

## 6. Finding PIC

### Tujuan
Menampilkan daftar report/finding yang menjadi tanggung jawab PIC.

### Kolom list utama
- `name`
- `status`
- `action icons`

### Action icons
- detail report
- buat follow up
- buat follow up lanjutan jika status `rejected`

### Rule
- jika status belum perlu follow up, icon follow up bisa disable
- finding list bisa difilter berdasarkan area atau status

## 7. Profile

### Berlaku untuk dua role
Isi minimal:
- nama user
- role
- nomor telepon / email jika ada
- logout button

## 8. Patrol History — Petugas HSE

### Tujuan
Menampilkan riwayat patroli / report yang pernah dibuat oleh Petugas.

### Screen
- Patrol History Screen
- Report Detail Screen

### Isi list item
- `name report`
- `status`
- `action icons`

### Action icons
- detail report
- `approved` follow up PIC
- `rejected` follow up PIC

### Rule
- aksi approve/reject hanya tampil jika ada follow up dari PIC yang menunggu review
- jika belum ada follow up, tampil detail saja

## 9. Create Report — Step by Step (Revamped 7-Step Wizard)

### Kebutuhan Ekstra
- **Auto-Generate Name**: Memanfaatkan integrasi `google_mlkit_text_recognition` untuk mengekstraksi tulisan/teks berharga dari jepretan foto, lalu memadukannya dengan string deskripsi/notes sebagai nama *Report* otomatis (meniadakan input "Name Laporan" manual di UI).
- **Share WhatsApp**: Menggunakan package `url_launcher` untuk membagikan isi summary laporan via tautan skema `whatsapp://send` tepat setelah submit sukses divalidasi.

### Step 1 — Building Type
- **UI**: 2 Card besar vertikal memajang teks (Atas & Bawah).
- **Behavior**: Tanpa tombol "Lanjutkan" / "Kembali". Seketika petugas menekan salah satu Card, form otomatis melompat ke Step 2 (tanpa validasi mandeg).

### Step 2 — Name Location (Area Master)
- **UI**: Select box / Dropdown (Data dari Master Area/Location).
- **Behavior**: Ada tombol "Lanjutkan" & "Kembali".
- **Validasi**: Indikator mandatory. Wajib terpilih lokasinya sebelum memicu fungsi tombol lanjut.

### Step 3 — Risk Level (Tingkat Risiko)
- **UI**: 4 Card berwarna cerah yang dilabeli representasi angka risiko: 1 (Merah/Kritis), 2 (Kuning/Berat), 3 (Hijau/Sedang), 4 (Biru/Ringan).*
- **Behavior**: Tanpa tombol "Lanjutkan". Seketika menekan salah satu kepingan warna/angka, aplikasi langsung merayap ke Step 4.

### Step 4 — Photos (Kamera)
- **UI**: 3 Slot kotak kosong penampung bingkai Foto. Wajib menggunakan jepret langsung dari kamera *Device*.
- **Behavior**: Ada tombol "Lanjutkan" & "Kembali".
- **Validasi**: Mandatory (Paling tidak slot foto ke-1 terisi sebelum lanjut diperbolehkan).

### Step 5 — Keterangan Photo (Notes)
- **UI**: Kotak teks (Text Area) panjang pengisian narasi inspeksi.
- **Behavior**: Ada tombol "Lanjutkan" & "Kembali".
- **Validasi**: Mandatory (Field Keterangan tidak dibiarkan bolong).

### Step 6 — Akar Masalah (Root Cause)
- **UI**: Kotak input penganalisa dugaan dari "Mengapa hal itu terjadi".
- **Behavior**: Ada tombol aksi bernama "Review" (alih-alih next biasa) & tombol "Kembali".
- **Validasi**: Mandatory. Tombol "Review" bertugas melontarkan transisi navigator komprehensif menuju halaman ringkasan final.

### Step 7 — Review & Submit
- **UI Halaman**: Merangkum rapi ke-6 input data di atas (Bangunan, Lokasi, Risiko, Deret Foto, Notes, Root Cause, serta label Name hasil Generate ML/Notes).
- **Behavior Tombol**:
  - Tombol "Edit": Memperkenankan petugas menyunting baris laporan manual secara serempak di form yang sama (atau membalikkan _State_ Wizard).
  - Tombol "Submit": Aksi eksekusi pengiriman payload menuju _Backend_.
- **Aturan Sesi (No Draft)**: Jika aplikasi tidak sengaja ter-*close* atau *back* sebelum submit selesai, sistem **TIDAK MENYIMPAN DRAFT**. Petugas diwajibkan menyusun *(realtime mandatory)* dari awal demi menjaga aktualitas data lapangan.
- **Post-Submit (Pop-up WhatsApp)**: Tampil interupsi dialog modal mengabarkan status kesuksesan, bertemankan tombol berlogo WhatsApp hijau.
- **Payload Broadcast WA**: (Format Laporan Terstruktur menyajikan: Judul Laporan (Generate), Bangunan Atas/Bawah, Titik Lokasi, Pelapor, Tingkat Risiko, Keterangan Notes, Root-course, dan referensi Image Link).

### Backend Data Requirements Validation
Data mentah yang dipacking dan disorongkan ke API berwujud sama:
- **hse_reports**: `name` (Auto), `user_id`, `location_id`, `risk_level`, `root_cause`, `notes`, `status` (Pending), `pic_token`.
- **hse_report_details**: `photo1`, `photo2`, `photo3`.

## 10. Report Detail

### Berlaku untuk Petugas dan PIC
Isi utama:
- name report
- code
- area
- building type
- risk level
- notes
- root cause
- status
- photo before 1–3
- follow up history

## 11. Follow Up PIC

### Step 1 — Foto setelah perbaikan
Field:
- `photo1`
- `photo2`
- `photo3`

### Step 2 — Action dan notes
Field:
- `action`
- `notes`

### Rules
- min 1 foto
- max 3 foto
- follow up pertama dan lanjutan memakai flow sama

## 12. Review Follow Up oleh Petugas

### Aksi
- `approved`
- `rejected`

### Tujuan
- `approved` berarti follow up PIC diterima
- `rejected` berarti follow up PIC belum sesuai dan PIC harus mengirim follow up lanjutan

### Rule
- review dilakukan dari detail report atau list patroli
- UI review harus cepat dan jelas
