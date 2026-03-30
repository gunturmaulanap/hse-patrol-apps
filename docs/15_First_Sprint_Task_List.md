# 15 First Sprint Task List

## Tujuan
Dokumen ini berisi pembagian task sprint awal setelah revisi UI terbaru. Sprint ini tetap fokus membuat pondasi yang benar, tetapi sudah mengakomodasi role shell baru untuk Petugas dan PIC.

## Target sprint pertama
Pada akhir sprint pertama, hasil minimum yang diharapkan:
- project Flutter sudah bisa dijalankan
- arsitektur folder sudah siap
- theme dan router sudah siap
- auth dasar sudah jalan
- shell tab per role sudah siap
- reusable UI component utama sudah jadi
- screen awal `Patroli`, `Home PIC`, dan `Finding PIC` bisa ditampilkan sebagai placeholder / basic list

## Durasi saran
- 5 sampai 7 hari kerja

---

# Sprint 1 Backlog

## Epic 1 — Project Foundation

### Task 1.1 Create Flutter project
Output:
- project baru berhasil dibuat
- Android build debug berjalan
- iOS build disiapkan jika diperlukan

### Task 1.2 Add dependencies
Output:
- pubspec dependencies terpasang sesuai dokumentasi

Checklist:
- [ ] riverpod
- [ ] go_router
- [ ] dio
- [ ] freezed
- [ ] json_serializable
- [ ] flutter_secure_storage
- [ ] camera
- [ ] permission_handler
- [ ] intl

### Task 1.3 Setup folder architecture
Output:
- folder core dan feature-first architecture sudah dibuat

Checklist:
- [ ] core folder
- [ ] shared folder
- [ ] features/auth
- [ ] features/patrol
- [ ] features/create_report
- [ ] features/pic_home
- [ ] features/pic_finding
- [ ] features/profile
- [ ] features/follow_up

---

## Epic 2 — App Foundation

### Task 2.1 App theme
Output:
- Material 3 theme modern siap dipakai

### Task 2.2 App router
Output:
- go_router bekerja untuk route dasar dan role shell

Checklist:
- [ ] splash route
- [ ] login route
- [ ] petugas shell route
- [ ] PIC shell route
- [ ] token route untuk PIC

### Task 2.3 Core services
Output:
- service dasar siap dipakai semua feature

Checklist:
- [ ] dio client
- [ ] secure storage service
- [ ] app config / env setup

---

## Epic 3 — Authentication and Role Shell

### Task 3.1 Auth data layer
Output:
- datasource, repository, dan model auth tersedia

### Task 3.2 Auth presentation layer
Output:
- login dan session check berjalan

Checklist:
- [ ] auth provider
- [ ] splash screen
- [ ] login screen
- [ ] logout action
- [ ] role-based redirect
- [ ] petugas bottom nav shell
- [ ] PIC bottom nav shell

Acceptance criteria:
- [ ] login sukses menyimpan token
- [ ] app restart tetap membaca session
- [ ] logout menghapus token
- [ ] Petugas masuk ke tab `Patroli`
- [ ] PIC masuk ke tab `Home`

---

## Epic 4 — Reusable UI

### Task 4.1 Base components
Output:
- komponen dasar siap dipakai banyak screen

Checklist:
- [ ] primary button
- [ ] secondary button
- [ ] text field
- [ ] text area
- [ ] app card
- [ ] loading widget
- [ ] empty state widget
- [ ] error state widget
- [ ] bottom action bar
- [ ] photo slot card
- [ ] bottom navigation wrapper
- [ ] area card
- [ ] report action icon bar

---

## Epic 5 — Role Landing Screens

### Task 5.1 Petugas Patrol screen
Output:
- screen riwayat patroli tampil dengan mock/basic API

Checklist:
- [ ] patrol list screen
- [ ] patrol list item
- [ ] status chip
- [ ] action icons

### Task 5.2 PIC Home screen
Output:
- PIC home tampil berisi card area

Checklist:
- [ ] accessible area model
- [ ] PIC home screen
- [ ] area card widget

### Task 5.3 PIC Finding screen
Output:
- finding list tampil dengan kolom utama

Checklist:
- [ ] finding list screen
- [ ] finding list item
- [ ] status chip
- [ ] action icons

---

# Out of scope sprint 1
Fitur berikut belum wajib selesai di sprint pertama:
- create report step-by-step lengkap
- upload foto kamera lengkap
- review approve/reject final ke backend penuh
- token deep link flow lengkap
- UI polish final
- release build final

---

# Deliverables sprint 1
Pada akhir sprint 1 harus ada:
- project foundation yang rapi
- login flow jalan
- session check jalan
- reusable UI components tersedia
- petugas shell tampil
- PIC shell tampil
- patrol list / PIC home / PIC finding punya tampilan dasar
