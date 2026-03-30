# 01 Product Context — HSE Aksamala

## Ringkasan produk
HSE Aksamala adalah aplikasi patroli untuk pelaporan kerusakan bangunan di PT Aksamala Adi Andana.

Aplikasi ini dipakai oleh dua role utama:

- **Petugas Patroli HSE**
- **PIC Tindak Lanjut**

## Tujuan bisnis
Aplikasi dibuat untuk:

- mempercepat pelaporan kerusakan
- memastikan laporan memiliki bukti foto sebelum dan sesudah perbaikan
- mempermudah PIC menerima area tanggung jawab dan finding yang harus ditindaklanjuti
- membuat alur pelaporan, follow up, dan review lebih rapi, terdokumentasi, dan mudah dilacak

## Keputusan produk terbaru
1. tabel `locations` diganti menjadi `areas`
2. Petugas tidak boleh menambahkan area baru dari mobile app
3. menu Petugas hanya: `Patroli` dan `Profile`
4. menu PIC: `Home`, `Finding`, dan `Profile`
5. PIC `Home` menampilkan card area sesuai akses master
6. PIC `Finding` menampilkan daftar finding/report
7. Petugas dapat melakukan review follow up PIC dengan aksi `approved` atau `rejected`

## Role

### 1. Petugas Patroli HSE
Tugas:
- login
- masuk ke menu `Patroli`
- melihat riwayat patroli / report yang pernah dibuat
- membuat report baru
- memilih building type
- memilih area dari master area
- memilih tingkat risiko
- ambil foto kerusakan
- isi notes
- isi root cause
- submit laporan
- melihat follow up dari PIC
- menyetujui follow up (`approved`) atau menolak follow up (`rejected`)

### 2. PIC Tindak Lanjut
Tugas:
- login atau masuk dari link token
- masuk ke `Home` untuk melihat area yang menjadi aksesnya
- masuk ke `Finding` untuk melihat daftar finding/report
- melihat detail report
- membuat follow up pertama atau follow up lanjutan
- ambil foto setelah perbaikan
- isi action
- isi notes
- submit follow up

## Flow utama aplikasi

### Flow Petugas Patroli HSE
1. Splash
2. Login
3. Permission Camera
4. Masuk ke tab `Patroli`
5. Lihat list riwayat patroli
6. Buka detail report atau buat report baru
7. Pilih building type
8. Pilih area dari master area
9. Pilih risiko
10. Ambil sampai 3 foto kerusakan
11. Isi notes
12. Isi root cause
13. Review
14. Submit
15. Kembali ke list patroli
16. Saat ada follow up PIC, Petugas bisa `approved` atau `rejected`

### Flow PIC
1. Buka link dari WhatsApp atau login manual
2. Jika belum login → login
3. Jika login manual → masuk ke tab `Home`
4. `Home` menampilkan card area berdasarkan akses master
5. `Finding` menampilkan daftar report/finding
6. PIC buka detail report
7. PIC buat follow up
8. Ambil sampai 3 foto setelah perbaikan
9. Isi action
10. Isi notes
11. Submit follow up
12. Jika follow up ditolak Petugas, PIC bisa buat follow up lanjutan

## Backend final yang harus diikuti frontend

### Table `areas`
- id
- code
- name
- building_type

### Table `hse_reports`
- id
- code
- user_id
- area_id
- name
- risk_level
- root_cause
- notes
- status
- pic_token

### Table `hse_report_details`
- id
- hse_report_id
- photo1
- photo2
- photo3

### Table `hse_report_followups`
- id
- hse_report_id
- action
- notes
- photo1
- photo2
- photo3
- follow_up_by

## Catatan penting tentang `name` report
Field `name` pada `hse_reports` disarankan **disimpan di backend**.

### Rekomendasi implementasi
- `name` report dibuat dari hasil ringkasan `notes`
- generation utama sebaiknya dilakukan di backend agar konsisten
- frontend boleh menampilkan preview name report, tetapi backend tetap sumber kebenaran

### Catatan ML Kit
**Google ML Kit Text Recognition tidak cocok untuk mengubah text input menjadi name report.**
ML Kit OCR cocok untuk membaca teks dari **gambar/foto**, bukan untuk meringkas teks yang sudah diketik user.

Jika sumber `name` adalah field `notes` yang diketik user, gunakan salah satu pendekatan berikut:
- backend generate `name` dari kalimat pertama / keyword utama dari `notes`
- frontend kirim `notes`, lalu backend otomatis mengisi `name`
- jika ingin ada preview di frontend, gunakan rule sederhana, bukan OCR

## Status report yang disarankan
- `submitted`
- `waiting_pic`
- `in_progress`
- `waiting_petugas_review`
- `approved`
- `rejected`

## Risk level yang dipakai
- `merah`
- `kuning`
- `hijau`
- `biru`

## Prinsip UX yang wajib dijaga
- home role PIC tidak boleh kosong
- satu halaman satu tujuan
- field jangan terlalu banyak dalam satu layar
- tombol besar dan mudah ditekan
- validasi jelas
- ada feedback loading, error, success
- proses step-by-step terlihat jelas
- bottom navigation harus jelas dan ringan
