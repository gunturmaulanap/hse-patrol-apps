# 16 Modern UI Component Sources

## Tujuan
Dokumen ini membantu tim menemukan referensi komponen UI modern untuk Flutter tanpa membuat desain aplikasi menjadi acak.

## Prinsip utama
Untuk aplikasi HSE Aksamala, gunakan pendekatan berikut:
1. mulai dari Material 3 sebagai dasar utama
2. buat komponen reusable internal untuk konsistensi
3. ambil inspirasi dari library dan showcase, bukan menyalin mentah
4. prioritaskan UI yang mudah dipakai di lapangan dibanding dekorasi berlebihan

---

# 1. Sumber utama yang direkomendasikan

## A. Flutter Material 3 official
Gunakan ini sebagai referensi utama untuk:
- button
- text field
- card
- navigation bar
- dialog
- snack bar
- segmented button
- bottom sheet

Kenapa dipilih:
- paling stabil untuk Flutter
- paling cocok untuk aplikasi produksi
- sudah menjadi default modern design language di Flutter

Yang perlu dipelajari:
- color scheme
- typography
- spacing
- elevation
- state layer
- component theming

---

## B. Material 3 official design site
Gunakan untuk melihat:
- contoh visual komponen modern
- layout mobile yang rapi
- hierarchy antar komponen
- tone warna dan penggunaan surface

Gunakan situs ini untuk inspirasi desain, lalu implementasikan dengan widget Flutter.

---

## C. Widgetbook
Gunakan Widgetbook untuk:
- membuat katalog komponen internal proyek
- melihat komponen dalam state loading/error/filled/disabled
- memudahkan review UI dengan tim

Ini sangat berguna saat proyek mulai besar dan reusable widget sudah banyak.

---

# 2. Library Flutter yang layak dipakai

## A. flex_color_scheme
Gunakan jika ingin membuat theme Material 3 yang lebih rapi dan cepat.

Cocok untuk:
- membuat light theme konsisten
- mengatur radius dan component theming lebih mudah
- mempercepat pencarian kombinasi warna modern

Rule:
- pakai jika tim ingin theme yang lebih matang dari ThemeData standar
- jangan pakai berlebihan sampai theme terlalu rumit

## B. flutter_animate
Gunakan untuk animasi ringan seperti:
- fade in
- slide in
- scale in
- shimmer ringan

Rule:
- gunakan hanya untuk memperhalus UX
- jangan berlebihan karena aplikasi ini dipakai untuk kerja lapangan

## C. phosphor_flutter atau icon set sejenis
Gunakan untuk icon yang lebih modern jika Material Icons terasa terlalu standar.

Cocok untuk:
- action icon
- empty state
- status badge
- section icon

Rule:
- tetap pilih satu library icon utama
- jangan campur banyak gaya icon

---

# 3. Komponen internal yang wajib dibuat sendiri
Walaupun ada banyak referensi, untuk proyek ini komponen berikut sebaiknya dibuat sendiri agar konsisten:

- AppPrimaryButton
- AppSecondaryButton
- AppTextField
- AppTextAreaField
- AppCard
- AppEmptyState
- AppErrorState
- AppSectionHeader
- AppStatusBadge
- RiskLevelCard
- PhotoSlotCard
- BottomActionBar
- StepProgressHeader
- ReportCard

Alasan:
- memudahkan AI agent
- memudahkan maintenance
- mengurangi tampilan campur aduk

---

# 4. Referensi visual yang cocok untuk HSE Aksamala

## Karakter UI yang disarankan
UI aplikasi harus:
- modern
- bersih
- mudah dibaca
- tombol besar
- spacing lega
- cocok dipakai satu tangan
- fokus pada kecepatan input

## Gaya visual yang cocok
- card dengan radius sedang
- warna utama tegas tapi tidak terlalu mencolok
- status badge jelas
- icon sederhana
- layout vertical mobile-first
- sticky bottom action bar untuk tombol utama

## Gaya visual yang tidak disarankan
- terlalu banyak gradient mencolok
- terlalu banyak animasi
- terlalu banyak warna dalam satu screen
- layout padat dan sulit disentuh
- teks terlalu kecil

---

# 5. Komponen modern yang disarankan per screen

## Login
- logo sederhana
- form card ringan
- button utama penuh lebar
- bantuan pesan error jelas

## My Reports
- report card modern
- filter ringan jika perlu
- status chip/badge
- pull to refresh

## Create Report Step-by-Step
- progress header
- pilihan berbasis card
- list lokasi modern
- text area luas
- 3 slot foto jelas
- sticky submit button

## Detail Report
- section per blok informasi
- gallery preview untuk photo1-photo3
- badge status dan badge risk level
- timeline sederhana jika nanti diperlukan

## Follow Up PIC
- tampilan konteks report di atas
- slot foto after
- field action dan notes
- tombol submit besar di bawah

---

# 6. Tempat mencari inspirasi tanpa merusak konsistensi
Cari inspirasi dari:
- dokumentasi resmi Flutter Material
- Material 3 official components
- showcase UI di Dribbble atau Behance hanya untuk inspirasi visual
- package showcase di pub.dev untuk melihat contoh implementasi

Rule penting:
- jangan copy desain mentah dari banyak sumber sekaligus
- pilih satu arah visual lalu konsistenkan di seluruh aplikasi

---

# 7. Rekomendasi praktis untuk proyek ini
Untuk HSE Aksamala, saya sarankan:

## Minimum modern stack
- Material 3 bawaan Flutter
- theme internal sendiri
- komponen reusable sendiri
- flutter_animate hanya untuk animasi ringan
- satu icon library tambahan bila dibutuhkan

## Jika tim ingin lebih matang
Tambahkan:
- flex_color_scheme untuk theming
- Widgetbook untuk dokumentasi komponen internal

---

# 8. Checklist keputusan UI sebelum mulai coding
Sebelum membuat banyak screen, putuskan dulu:
- [ ] warna utama aplikasi
- [ ] radius default card dan input
- [ ] spacing scale
- [ ] typography scale
- [ ] icon library utama
- [ ] style button utama dan sekunder
- [ ] style status badge
- [ ] style risk level card
- [ ] style photo slot card

---

# 9. Output yang disarankan untuk AI agent
Minta AI agent membuat file berikut lebih dulu:
- `app_colors.dart`
- `app_spacing.dart`
- `app_radius.dart`
- `app_text_styles.dart`
- `app_theme.dart`
- reusable widgets utama

Setelah itu baru lanjut ke screen-screen aplikasi.
