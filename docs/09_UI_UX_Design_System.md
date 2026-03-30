# 09 UI UX Design System

## Tujuan desain
UI harus terasa:
- modern
- bersih
- mudah dipakai di lapangan
- nyaman dibaca
- tidak kosong
- jelas per role

## Prinsip visual utama
1. Material 3 sebagai fondasi
2. rounded corner modern
3. shadow ringan
4. spacing lega
5. warna tidak berlebihan
6. typografi jelas
7. CTA mudah terlihat
8. home role PIC harus berisi card-card area
9. tab bar bawah harus sederhana dan konsisten

## Warna
Gunakan palet sederhana:
- warna utama brand HSE: teal / hijau kebiruan / biru gelap
- warna latar netral terang
- warna risiko:
  - merah
  - kuning
  - hijau
  - biru

Catatan:
warna risiko **harus selalu ditemani teks**, jangan mengandalkan warna saja.

## Typography
Gunakan `Google Fonts`.
Rekomendasi final: **Plus Jakarta Sans** atau **Inter**.

## Component guidelines

### App Bar
- title jelas
- back button sederhana
- tidak terlalu ramai

### Bottom Navigation Bar
Harus dibedakan per role.

#### Petugas
- Patroli
- Profile

#### PIC
- Home
- Finding
- Profile

### Card
- radius 16–20
- padding lega
- informasi paling penting di atas
- gunakan variasi card area, card report, dan card summary

### Button
- tinggi minimal 48
- full width untuk aksi utama
- sticky bottom bar untuk flow step-by-step

### Input Field
- gunakan outlined text field
- error message jelas
- placeholder membantu

### Photo Slot Card
Setiap slot foto berisi:
- preview
- label Foto 1 / 2 / 3
- tombol Ambil Foto / Ambil Ulang / Hapus

### Empty State
- icon atau ilustrasi sederhana
- 1 judul
- 1 subjudul
- 1 CTA

## Layout guidelines
- gunakan single-column layout
- hindari layar terlalu padat
- gunakan section spacing konsisten
- pada step form, tampilkan progress header
- gunakan dashboard feel ringan untuk Home PIC

## Screen-specific recommendations

### Login Screen
- logo
- app name
- card login modern
- input username/email
- input password
- tombol masuk besar

### PIC Home Screen
- greeting singkat
- ringkasan pendek, jangan penuh angka jika backend belum siap
- tampilkan card `areas` dengan visual yang menarik
- gunakan grid 2 kolom jika card pendek, atau list jika konten panjang
- card area harus mudah ditekan

### PIC Finding Screen
- list modern dengan information hierarchy jelas
- kolom utama: `name`, `status`, `actions`
- action icon harus ringkas dan mudah dimengerti
- tambahkan filter area/status di atas jika perlu

### Petugas Patrol Screen
- list riwayat patroli tidak boleh kosong secara visual
- tiap item tampil minimal: `name`, `status`, `action icons`
- jika ada follow up menunggu review, tampilkan CTA approve/reject lebih menonjol

### Create Report Screens
- satu step satu tujuan
- sticky bottom actions
- progress step di atas
- validasi inline
- area dipilih dari list existing saja

### Detail Report
- gunakan section per blok:
  - informasi utama
  - foto kerusakan
  - akar masalah
  - status
  - history follow up PIC
  - review actions jika user Petugas

### PIC Follow Up
- foto dulu, lalu action dan notes
- hindari campur terlalu banyak field

## Rule modern UI untuk AI agent
AI agent harus:
- menggunakan Material 3
- menjaga spacing yang lega
- menggunakan reusable widget
- menghindari layout yang padat
- menghindari terlalu banyak warna dalam satu layar
- memastikan tombol utama paling menonjol
- memastikan home PIC terisi card area berdasarkan akses
