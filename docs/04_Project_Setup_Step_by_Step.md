# 04 Project Setup Step by Step

## Tujuan
Dokumen ini menjelaskan langkah dari nol sampai project siap dikoding.

## Step 1 — Install kebutuhan dasar
Pastikan tersedia:
- Flutter SDK
- Android Studio atau SDK Android saja
- VS Code
- extension Flutter dan Dart di VS Code
- emulator atau device Android fisik
- Git

## Step 2 — Create project baru
```bash
flutter create hse_aksamala
```

## Step 3 — Masuk ke project
```bash
cd hse_aksamala
```

## Step 4 — Rapikan struktur awal
Hapus dan rapikan file default yang tidak diperlukan.

Minimal siapkan:
- `lib/main.dart`
- `lib/app/`
- `lib/core/`
- `lib/features/`
- `lib/shared/`

## Step 5 — Tambahkan dependencies
Edit `pubspec.yaml`, lalu tambahkan package yang sudah ditentukan.

Kemudian jalankan:
```bash
flutter pub get
```

## Step 6 — Setup lints
Tambahkan lints yang tegas tapi masih nyaman.

Gunakan `flutter_lints` sebagai dasar.

Buat file `analysis_options.yaml` dan atur rule sederhana.

## Step 7 — Setup theme dasar
Buat file:
- `app/theme/app_colors.dart`
- `app/theme/app_text_styles.dart`
- `app/theme/app_theme.dart`

Target awal:
- Material 3 aktif
- font modern
- warna brand sederhana
- input field modern
- card modern
- button modern

## Step 8 — Setup router dasar
Buat:
- `app/router/route_names.dart`
- `app/router/app_router.dart`

Minimal route awal:
- splash
- login
- camera permission
- my reports
- report detail
- create report step pages
- pic tasks
- pic report detail
- follow up pages

## Step 9 — Setup secure storage
Buat service untuk simpan:
- access token
- refresh token jika ada
- user role
- optional last session data

## Step 10 — Setup API client
Buat `Dio` instance.

Tambahkan:
- base url
- timeout
- auth interceptor
- logging interceptor
- response error mapping

## Step 11 — Setup folder feature auth
Mulai dari auth karena itu entry point semua flow.

Yang dibuat dulu:
- login request model
- login response model
- auth remote datasource
- auth repository
- auth provider
- login screen
- splash screen

## Step 12 — Setup enum dan constants
Buat enum di `shared/enums/`:
- `UserRole`
- `ReportStatus`
- `RiskLevel`
- `BuildingType`

## Step 13 — Jalankan build_runner
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Step 14 — Setup flavor/env sederhana
Minimal siapkan environment config untuk:
- dev
- staging
- production

Kalau belum mau pakai flavor penuh, mulai dari file config sederhana.

## Step 15 — Buat reusable widgets paling dasar
Sebelum masuk fitur, buat dulu:
- app button
- app text field
- loading state
- empty state
- error state
- app card
- photo slot card

## Step 16 — Mulai implement fitur sesuai roadmap
Urutan terbaik:
1. auth
2. session check
3. camera permission
4. report list
5. create report step by step
6. detail report
7. PIC flow via token
8. PIC follow up
9. polishing
10. testing

## Kesalahan setup yang harus dihindari
- langsung coding semua screen tanpa router rapi
- model API ditulis manual terus-menerus tanpa generator
- widget besar semua ditaruh dalam satu file
- belum ada secure storage tapi auth flow sudah dibuat
- belum ada folder architecture tapi feature sudah banyak
