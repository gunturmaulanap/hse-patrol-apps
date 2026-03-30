# 17 Project Bootstrap Files

## Tujuan
Dokumen ini menjelaskan file awal yang wajib dibuat agar project Flutter **HSE Aksamala** bisa langsung berjalan dengan fondasi yang rapi, konsisten, dan mudah dipahami AI agent di VS Code.

Dokumen ini tidak menuliskan seluruh source code final, tetapi memberikan **blueprint file awal** yang harus dibuat oleh agent.

---

## Prinsip bootstrap
Saat membuat project awal, jangan langsung membuat semua fitur sekaligus.

Urutan yang benar:
1. buat fondasi app
2. buat konfigurasi environment
3. buat routing dasar
4. buat theme dasar
5. buat API layer dasar
6. buat auth/session dasar
7. baru lanjut ke feature

---

## File dasar yang wajib ada

### Root project
- `pubspec.yaml`
- `.gitignore`
- `analysis_options.yaml`
- `.env.dev`
- `.env.staging`
- `.env.prod`
- `README.md`

### Folder `lib/`
- `main.dart`
- `app/app.dart`
- `app/bootstrap.dart`
- `app/env/app_env.dart`
- `app/router/app_router.dart`
- `app/router/route_names.dart`
- `app/theme/app_theme.dart`
- `app/theme/app_colors.dart`
- `app/theme/app_spacing.dart`
- `app/theme/app_radius.dart`
- `app/theme/app_text_styles.dart`

### Folder `lib/core/`
- `constants/app_constants.dart`
- `constants/storage_keys.dart`
- `network/dio_client.dart`
- `network/api_exception.dart`
- `network/api_response.dart`
- `storage/secure_storage_service.dart`
- `utils/result.dart`
- `utils/date_formatter.dart`
- `utils/validators.dart`
- `utils/logger.dart`
- `models/app_user.dart`

### Folder `lib/shared/`
- `widgets/app_button.dart`
- `widgets/app_text_field.dart`
- `widgets/app_text_area.dart`
- `widgets/app_card.dart`
- `widgets/app_image_preview.dart`
- `widgets/app_empty_state.dart`
- `widgets/app_loading_overlay.dart`
- `widgets/app_error_view.dart`
- `widgets/app_status_chip.dart`
- `widgets/app_section_title.dart`
- `widgets/app_scaffold.dart`
- `extensions/context_extension.dart`

### Folder feature awal
- `features/auth/...`
- `features/splash/...`
- `features/home/...`

---

## Isi minimal setiap file bootstrap

## 1. `main.dart`
Tugas:
- memanggil bootstrap app
- memastikan binding Flutter diinisialisasi
- menjalankan `ProviderScope`

### Tanggung jawab
- jangan simpan logic bisnis di `main.dart`
- file ini hanya sebagai entry point

---

## 2. `app/bootstrap.dart`
Tugas:
- load environment
- inisialisasi service global
- konfigurasi logger
- menyiapkan dependency dasar

### Tanggung jawab
- environment loader
- service setup awal
- place untuk future app initialization

---

## 3. `app/app.dart`
Tugas:
- membangun `MaterialApp.router`
- menghubungkan theme
- menghubungkan router
- mematikan debug banner

### Tanggung jawab
- hanya konfigurasi root widget
- tidak berisi logic feature

---

## 4. `app/env/app_env.dart`
Tugas:
- memuat base URL backend
- memuat app flavor
- memuat timeout request

### Contoh nilai
- `baseUrl`
- `appName`
- `flavor`
- `connectTimeout`
- `receiveTimeout`

---

## 5. `app/router/route_names.dart`
Tugas:
- menampung semua nama route sebagai konstanta

### Contoh route
- splash
- login
- home
- myReports
- createReportBuildingType
- createReportLocation
- createReportRisk
- createReportPhotos
- createReportNotes
- createReportRootCause
- createReportReview
- reportDetail
- picTaskList
- picReportDetail
- picFollowUpPhotos
- picFollowUpForm

### Rule
- semua nama route harus terkumpul di satu file
- jangan hardcode string route di banyak tempat

---

## 6. `app/router/app_router.dart`
Tugas:
- mendefinisikan `go_router`
- menyiapkan route tree
- menyiapkan redirect sederhana berdasarkan session

### Redirect minimal
- jika belum login dan membuka halaman private → arahkan ke login
- jika sudah login dan membuka splash → arahkan ke home sesuai role
- jika membuka route PIC by token → validasi parameter route

---

## 7. Theme files

### `app/theme/app_colors.dart`
Berisi warna inti aplikasi.

### `app/theme/app_spacing.dart`
Berisi token spacing:
- xs
- sm
- md
- lg
- xl
- xxl

### `app/theme/app_radius.dart`
Berisi token border radius.

### `app/theme/app_text_styles.dart`
Berisi style typography inti.

### `app/theme/app_theme.dart`
Menyusun `ThemeData` final dengan Material 3.

---

## 8. `core/network/dio_client.dart`
Tugas:
- membuat instance Dio tunggal
- menambahkan header default
- inject token bearer
- logging request/response di debug mode

### Rule
- semua request API harus lewat satu client ini
- jangan membuat Dio baru di setiap repository

---

## 9. `core/storage/secure_storage_service.dart`
Tugas:
- menyimpan token
- membaca token
- menghapus token saat logout
- optional menyimpan role user sederhana

---

## 10. `core/utils/result.dart`
Tugas:
- membungkus hasil operasi agar konsisten

### Bentuk sederhana
- success
- failure

Tujuan:
- repository dan use case lebih konsisten saat mengembalikan hasil

---

## 11. `shared/widgets/*`
Tugas:
- menampung widget reusable yang dipakai lintas fitur

Rule:
- widget reusable tidak boleh bergantung ke feature tertentu
- widget reusable harus netral dan mudah dipakai ulang

---

## Struktur folder feature awal

## `features/splash/`
Minimal file:
- `presentation/pages/splash_page.dart`
- `presentation/controllers/splash_controller.dart`

Tugas:
- cek session
- cek role
- tentukan arah halaman awal

## `features/auth/`
Minimal file:
- `data/datasources/auth_remote_data_source.dart`
- `data/models/login_request.dart`
- `data/models/login_response.dart`
- `data/repositories/auth_repository_impl.dart`
- `domain/repositories/auth_repository.dart`
- `domain/usecases/login_usecase.dart`
- `domain/usecases/logout_usecase.dart`
- `presentation/controllers/auth_controller.dart`
- `presentation/pages/login_page.dart`

## `features/home/`
Minimal file:
- `presentation/pages/home_page.dart`

Tugas:
- menjadi halaman pengarah berdasarkan role

---

## Urutan pembuatan bootstrap file untuk AI agent
1. buat `pubspec.yaml`
2. buat folder `lib/app`, `lib/core`, `lib/shared`, `lib/features`
3. buat `main.dart`
4. buat `app.dart`
5. buat environment config
6. buat theme dasar
7. buat router dasar
8. buat network client
9. buat secure storage service
10. buat reusable widgets inti
11. buat splash page
12. buat login page
13. pastikan app bisa run tanpa error

---

## Definition of done bootstrap
Bootstrap dianggap selesai jika:
- project bisa di-run di emulator/device
- splash page tampil
- login page bisa diakses
- route sudah aktif
- theme global sudah aktif
- API client sudah siap dipakai
- secure storage service sudah tersedia
- reusable widget dasar sudah tersedia
- tidak ada error analyzer besar

---

## Rule penting untuk AI agent
- jangan membuat seluruh fitur sekaligus sebelum bootstrap selesai
- jangan mengisi UI detail feature sebelum router dan theme siap
- jangan membuat package/service duplikat
- jangan menaruh reusable widget ke folder feature
- setiap file bootstrap harus punya tanggung jawab tunggal
