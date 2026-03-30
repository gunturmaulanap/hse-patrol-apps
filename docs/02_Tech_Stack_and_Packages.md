# 02 Tech Stack and Packages

## Stack utama yang direkomendasikan

### Flutter SDK
Gunakan Flutter stable terbaru yang kompatibel dengan tim.

### State Management
Gunakan **Riverpod**.

Alasan:
- modern
- aman untuk scaling
- mudah dipahami AI agent
- cocok untuk async state
- mudah dipakai bersama repository pattern

### Routing
Gunakan **go_router**.

Alasan:
- declarative
- cocok untuk auth flow
- deep link lebih mudah
- lebih rapi daripada navigator manual untuk proyek ini

### HTTP Client
Gunakan **dio**.

Alasan:
- interceptors
- error handling lebih baik
- multipart upload mudah
- logging request/response lebih nyaman

### Model Serialization
Gunakan:
- `freezed`
- `json_serializable`
- `build_runner`

Alasan:
- model immutable
- parsing API lebih aman
- mudah dipakai di AI-assisted workflow

### Local Secure Storage
Gunakan `flutter_secure_storage`.

Alasan:
- token login harus aman
- lebih baik daripada shared_preferences untuk access token

### Kamera
Gunakan `camera`.

Alasan:
- kita ingin **camera only**
- lebih terkontrol daripada image_picker
- bisa buat custom camera screen modern

### Utility Tambahan
- `intl` → formatting tanggal
- `google_fonts` → tipografi modern
- `flutter_svg` → icon/logo svg
- `gap` → spacing yang konsisten
- `cached_network_image` → preview image dari server
- `permission_handler` → permission management
- `logger` → debug log terstruktur
- `equatable` opsional jika tidak full Freezed

## Package list yang direkomendasikan
```yaml
flutter_riverpod:
go_router:
dio:
pretty_dio_logger:
freezed_annotation:
json_annotation:
flutter_secure_storage:
camera:
permission_handler:
intl:
google_fonts:
flutter_svg:
gap:
cached_network_image:
logger:
```

## Dev dependencies
```yaml
build_runner:
freezed:
json_serializable:
flutter_lints:
```

## Package yang sengaja tidak dipakai dulu
Agar proyek tetap sederhana, hindari dulu:
- bloc / cubit jika tim belum terbiasa
- auto_route jika belum diperlukan
- image_picker untuk flow foto utama
- package animation yang berat
- package UI kit terlalu banyak

## Arsitektur teknis yang dipilih
Gunakan kombinasi:
- feature-first folder structure
- simple layered architecture per feature

Setiap feature minimal punya:
- `data`
- `domain`
- `presentation`

Untuk proyek ini, `application` layer boleh disederhanakan menjadi providers/usecases jika belum ingin terlalu berat.

## Modern UI resources yang direkomendasikan
Untuk referensi visual dan component modern:
- Material 3 guidelines
- Mobbin untuk referensi flow mobile
- Dribbble untuk referensi visual style
- Figma Community untuk UI inspiration
- Google Fonts untuk typography pairing

## Prinsip memilih component modern
Pilih component yang:
- besar dan mudah disentuh
- sederhana
- konsisten
- tidak terlalu ornamental
- mendukung penggunaan lapangan

## Komponen modern yang sebaiknya dipakai
- large cards
- segmented filter sederhana
- sticky bottom action bar
- rounded button
- outlined text field modern
- section header dengan spacing lega
- icon dan label yang jelas
