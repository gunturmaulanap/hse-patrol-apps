# 28. Implementasi Alur Deep Link & Validasi Akses PIC Token

## 1. Tujuan (Objective)
Menyediakan fitur di mana ketika sebuah link laporan dari WhatsApp (contoh: `https://mes.aksamala.co.id/share/report/2nkINJ...`) diklik oleh pengguna, aplikasi Flutter akan otomatis terbuka (Deep Link) dan menampilkan detail laporan, **dengan syarat** pengguna tersebut lolos otentikasi dan validasi hak akses berjenjang.

## 2. Alur Bisnis (User Flow)
1. **User Klik Link WA:** Aplikasi terbuka dengan *path* URL `/share/report/:token`.
2. **Cek Otentikasi (Auth Check):**
   - **Belum Login:** User diarahkan ke halaman Login. Sistem menyimpan informasi bahwa tujuan akhirnya adalah halaman `share/report/:token`.
   - **Sudah Login:** Lanjut ke tahap validasi.
3. **Validasi Role & Akses (Access Control):**
   Sistem mengambil data detail laporan berdasarkan token, dan mencocokkan dengan data `currentUser`.
   - **Supervisor:** Akses penuh (By-pass validasi). Tampilkan *AppToast*: `"Melanjutkan tindakan follow-up task."` dan arahkan ke Detail Task.
   - **HSE Staff (Petugas):** Cek atribut `authorId` atau pembuat laporan.
     - Jika Sama: Tampilkan *AppToast* `"Melanjutkan tindakan..."` dan buka Detail Task.
     - Jika Beda: Arahkan ke *Petugas Home*, tampilkan *AppToast*: `"Laporan tersebut dibuat oleh Petugas HSE lain."`
   - **PIC:** Cek kewenangan area PIC terhadap `areaId` laporan.
     - Jika Punya Kewenangan: Tampilkan *AppToast* `"Melanjutkan tindakan..."` dan buka Detail Task.
     - Jika Tidak Memiliki Wewenang: Arahkan ke *PIC Home*, tampilkan *AppToast*: `"Task tersebut bukan tanggung jawab area Anda."`

## 3. Strategi Implementasi & Arsitektur
Untuk memisahkan logika validasi yang kompleks agar tidak mengotori `TaskDetailScreen`, kita akan menggunakan pendekatan **Wrapper / Handler Screen**.
Ketika link `/share/report/:token` dipanggil, `GoRouter` akan mengarahkan ke `DeepLinkHandlerScreen`. Screen ini berfungsi sebagai "pintu gerbang ghaib" (hanya menampilkan loading) untuk melakukan _fetching_ data dan komputasi IF/ELSE, lalu melakukan _redirect_ ke halaman yang sebenarnya beserta trigger `AppToast`.

## 4. File yang Perlu Di-refactor & Ditambahkan
Berikut adalah daftar modifikasi pada project untuk mengimplementasikan fitur ini:

### A. Konfigurasi Deep Link Asli (OS Level)
- `android/app/src/main/AndroidManifest.xml`: Menambahkan `<intent-filter>` agar Android mengenali *domain* `mes.aksamala.co.id` dan *path* `/share/report/`.
- `ios/Runner/Info.plist` & `ios/Runner/Runner.entitlements`: Menambahkan konfigurasi *Associated Domains* (`applinks:mes.aksamala.co.id`).

### B. Router & Navigasi
- `lib/app/router/route_names.dart`: Tambahkan konstanta `static const String deepLinkHandler = 'deeplink-handler';`.
- `lib/app/router/app_router.dart`: 
  - Pastikan konfigurasi `GoRouter` bisa menangkap initial URL.
  - Tambahkan rute baru: `GoRoute(path: '/share/report/:token', name: RouteNames.deepLinkHandler, builder: (context, state) => DeepLinkHandlerScreen(token: state.pathParameters['token']!))`.

### C. Pembuatan Screen Baru (Validator)
- `lib/features/tasks/presentation/screens/deep_link_handler_screen.dart`: **(FILE BARU)**.
  Ini adalah inti dari *logic* yang diminta. Di dalam `initState` atau `useEffect`, screen ini akan:
  1. Memanggil *provider* untuk fetch data task berdasarkan `picToken`.
  2. Memeriksa `ref.read(currentUserProvider)`.
  3. Memisahkan logika pengecekan akses (Petugas, PIC, SPV).
  4. Melakukan `context.goNamed()` ke Home atau TaskDetail.
  5. Menjalankan `AppToast.show()` sesuai hasil kondisi.

### D. Penyesuaian Login (Redirect After Login)
- `lib/features/auth/presentation/screens/login_screen.dart`:
  Saat ini, setelah sukses login, aplikasi langsung mengarahkan pengguna secara *hardcode* ke peran masing-masing (contoh: `_goToHomeByRole`). Perlu ditambahkan parameter pembantu agar jika *GoRouter* mendeteksi URL spesifik sebelum login, pengguna dilempar kembali ke URL *Deep Link* setelah loginnya berhasil.

### E. Penyesuaian Komponen Toast
- `lib/core/widgets/app_toast.dart`: 
  Pastikan `AppToast` dapat dipanggil sesaat setelah perpindahan rute (navigasi `context.goNamed`) tanpa mengalami *context disposed error*. (Bisa dikombinasikan dengan _delayed execution_ atau parameter ekstra pada routing).