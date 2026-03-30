# 13 Initial Agent Prompts

## Tujuan
Dokumen ini berisi prompt siap pakai untuk AI agent di VS Code agar agent bekerja konsisten, tidak merusak arsitektur, dan mengerjakan proyek HSE Aksamala secara bertahap.

## Rule sebelum memakai prompt
Sebelum memberi prompt ke AI agent:
1. pastikan semua file dokumentasi `00` sampai `16` tersedia di workspace
2. minta agent membaca dokumen secara urut
3. kerjakan satu task kecil sampai selesai
4. selalu minta agent membuat kode compileable
5. jangan minta agent mengerjakan terlalu banyak fitur sekaligus

## Prompt dasar untuk semua task
Gunakan prompt dasar ini setiap kali memulai task baru.

```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Gunakan arsitektur folder yang sudah ditentukan.
Gunakan Riverpod, go_router, Dio, Freezed, json_serializable, dan Material 3.
Jangan ubah kontrak endpoint backend.
Jangan membuat file di luar folder architecture.
Buat kode yang compileable, modular, rapi, dan modern.
Kerjakan hanya task berikut: <isi task di sini>.
Di akhir, tampilkan daftar file yang dibuat/diubah.
```

---

## Prompt 1 — Setup project foundation
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 00, 02, 03, 04, dan 05 terlebih dahulu.
Buat foundation project Flutter dari nol.
Kerjakan:
- setup pubspec dependencies sesuai dokumentasi
- setup folder architecture
- setup main.dart
- setup app.dart
- setup theme app Material 3
- setup go_router dasar
- setup Dio client dasar
- setup secure storage service dasar
Pastikan kode compileable.
Tampilkan semua file yang dibuat.
```

## Prompt 2 — Authentication feature
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 03, 06, 08, dan 11.
Kerjakan feature auth.
Buat:
- auth models
- auth remote datasource
- auth repository
- auth provider dengan Riverpod
- login screen modern
- splash session check
- logout flow
Integrasikan ke endpoint:
- POST /api/login
- POST /api/logout
- GET /api/me
Jangan kerjakan feature lain.
Pastikan kode compileable.
```

## Prompt 3 — Reusable UI components
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 03, 05, dan 09.
Buat reusable UI components modern Material 3 untuk proyek ini.
Buat:
- app_primary_button
- app_secondary_button
- app_text_field
- app_text_area_field
- app_card
- section_header
- app_empty_state
- app_error_state
- app_loading_view
- bottom_action_bar
- step_progress_header
- photo_slot_card
Komponen harus mobile friendly dan siap dipakai di banyak screen.
```

## Prompt 4 — Permission camera
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 06, 07, dan 11.
Buat feature permission camera.
Buat:
- permission service
- permission provider
- permission state
- permission screen
- helper untuk open app settings
Flow:
- cek permission kamera
- jika belum diizinkan, tampilkan screen penjelasan
- jika ditolak permanen, arahkan ke settings
Jangan implement gallery.
```

## Prompt 5 — My reports screen
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 07, 08, dan 11.
Kerjakan feature my reports untuk Petugas Patroli HSE.
Buat:
- model list report
- remote datasource
- repository
- provider
- my reports screen
- report card widget
Screen harus punya:
- loading state
- empty state
- error state
- pull to refresh
- tap ke detail report
```

## Prompt 6 — Create report form state
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 06, 07, dan 08.
Buat provider state untuk create report step by step.
Provider harus menyimpan:
- buildingType
- selectedLocation
- isCreatingNewLocation
- newLocationCode
- newLocationName
- riskLevel
- photo1
- photo2
- photo3
- notes
- rootCause
- isSubmitting
Buat methods update, reset, validate per step, dan submit flow dasar.
Jangan buat UI screen dulu.
```

## Prompt 7 — Create report steps 1 sampai 3
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 07, 08, 09, dan 11.
Kerjakan create report flow step 1 sampai step 3.
Buat screen:
- pilih building type
- pilih atau tambah lokasi
- pilih risk level
Gunakan createReportFormProvider sebagai source of truth.
Tiap step harus punya tombol back, reset, dan lanjut.
UI harus modern dan mudah dipakai di lapangan.
```

## Prompt 8 — Create report photo step
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 07, 09, dan 11.
Kerjakan create report step foto kerusakan.
Kebutuhan:
- maksimal 3 foto
- minimal 1 foto wajib
- kamera langsung
- tidak ada gallery
Gunakan komponen reusable photo_slot_card.
Setelah foto diambil, tampilkan preview, ambil ulang, dan hapus.
```

## Prompt 9 — Submit create report end to end
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 07, 08, 11, dan 14.
Selesaikan submit create report end to end.
Flow submit:
1. POST /api/hse-reports
2. ambil report id dari response
3. POST /api/hse-reports/{id}/details untuk upload photo1-photo3
4. tampilkan success feedback
5. redirect ke my reports
Buat error handling jelas jika step 1 atau step 2 gagal.
```

## Prompt 10 — Report detail screen
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 07, 08, 09, 11, dan 14.
Buat report detail screen.
Tampilkan:
- code
- lokasi
- building type
- risk level
- notes
- root cause
- status
- photo before 1 sampai 3
- follow up section jika tersedia
Screen harus rapi, modern, dan mudah dibaca.
```

## Prompt 11 — PIC detail by token
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 06, 07, 08, dan 11.
Buat flow PIC dari token.
Kebutuhan:
- route menerima token
- jika belum login, simpan intent lalu arahkan ke login
- setelah login sukses, lanjut ke detail report berdasarkan token
- tampilkan invalid token state jika token tidak valid
Jangan kerjakan submit follow up dulu.
```

## Prompt 12 — Follow up form
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 07, 08, 09, 11, dan 14.
Buat flow follow up PIC.
Buat:
- follow up form provider
- step foto after max 3
- step action dan notes
- submit ke POST /api/hse-reports/{id}/followups
- refresh detail report setelah sukses
Minimal 1 foto wajib ada.
UI harus modern dan ramah user.
```

## Prompt 13 — UI polish
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 09 dan 12.
Lakukan UI polish untuk seluruh aplikasi.
Perbaiki:
- spacing
- typography
- card style
- button hierarchy
- loading state
- empty state
- snackbar / success messages
- visual consistency antar screen
Jangan ubah business logic.
```

## Prompt 14 — QA cleanup
```text
Ikuti dokumentasi proyek HSE Aksamala Flutter.
Baca file 12.
Lakukan cleanup dan quality pass.
Kerjakan:
- hapus dead code
- rapikan import
- pastikan compile sukses
- cek error state utama
- cek validation form
- cek router guard
- cek state reset saat submit sukses
Buat ringkasan hasil pengecekan.
```

## Cara memakai prompt dengan aman
- jalankan satu prompt per sesi kerja besar
- setelah agent selesai, review hasil dan commit
- baru lanjut ke prompt berikutnya
- jangan gabungkan 3-4 prompt dalam sekali jalan

## Urutan prompt yang disarankan
1. setup foundation
2. reusable UI
3. auth
4. permission camera
5. my reports
6. create report state
7. create report UI
8. submit create report
9. report detail
10. pic token flow
11. follow up form
12. polish dan QA
