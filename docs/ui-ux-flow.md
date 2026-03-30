# UI/UX Flow Aktual (As-Is) — Petugas & PIC

Dokumen ini menjelaskan **flow UI/UX yang sudah ada saat ini di kode**, mulai dari login, navigasi role-based, pembuatan laporan oleh Petugas, sampai follow up oleh PIC dan review balik oleh Petugas.

---

## 1) Ruang Lingkup

Flow yang didokumentasikan:

1. Login dan redirect role.
2. Shell + bottom navigation Petugas dan PIC.
3. Alur Petugas membuat laporan (7 step).
4. Alur PIC melihat finding dan membuat follow up (3 step).
5. Review follow up oleh Petugas di detail laporan.
6. Perbedaan implementation yang sudah ada vs target dokumentasi besar project.

---

## 2) Peta Entry & Navigasi Utama

### 2.1 Router saat ini (aktif)

- Inisialisasi router: `GoRouter` dengan `initialLocation: /login`.
- Route login: `/login`.
- Route detail laporan: `/report/:id`.
- Route wizard Petugas: `/petugas/create-report` sampai `/petugas/create-report/review`.
- Route wizard follow up PIC: `/pic/follow-up/photos` → `/pic/follow-up/notes` → `/pic/follow-up/review`.
- Dua shell terpisah:
  - Shell Petugas: `patrol`, `home`, `profile`.
  - Shell PIC: `home`, `finding`, `profile`.

### 2.2 Konstanta nama route

Konstanta route sudah terpusat dan dipakai lintas screen:

- `petugasCreateReport*`
- `reportDetail`
- `picFollowUp*`
- `petugasPatrol`, `petugasHome`, `petugasProfile`
- `picHome`, `picFinding`, `picProfile`

---

## 3) UX Flow Login (As-Is)

### 3.1 Screen Login

**Tujuan UX:** masuk cepat, 1 card form, error jelas, CTA tunggal.

Elemen UI yang sudah ada:

- Branding icon shield + judul aplikasi.
- Form card modern (shadow ringan, radius besar).
- Field `Username` dan `Password`.
- Error message inline jika kredensial salah.
- Tombol utama `Login` dengan loading state.
- Informasi mock credential di bawah form.

Perilaku:

1. User isi username/password.
2. Tap login → loading simulasi 1 detik.
3. Validasi ke `mock_auth_service`.
4. Jika sukses:
   - role `petugas` → ke `petugasHome`.
   - role `pic` → ke `picHome`.
5. Jika gagal → pesan error muncul di card.

### 3.2 Splash (tersedia, namun bukan initial route saat ini)

Screen splash sudah ada dan melakukan:

- cek session,
- redirect ke login/picHome/petugasHome.

Catatan: saat ini router start dari `/login`, jadi splash belum jadi titik masuk default.

---

## 4) UX Struktur Role & Bottom Navigation

### 4.1 Petugas Shell

Bottom nav Petugas saat ini berisi 3 menu:

1. `Patroli`
2. `Home`
3. `Profile`

> Catatan: pada dokumen produk terbaru, arah akhirnya adalah 2 menu (`Patroli`, `Profile`). Di code sekarang masih ada `Home`.

### 4.2 PIC Shell

Bottom nav PIC sudah sesuai target revisi:

1. `Home`
2. `Finding`
3. `Profile`

---

## 5) UX Flow Petugas — Dari Login sampai Buat Laporan

## 5.1 Entry Petugas

Setelah login role `petugas`, user diarahkan ke `Petugas Home`.

### 5.1.1 Petugas Home (Dashboard)

Komponen utama:

- Greeting + motivasi singkat.
- Kartu CTA besar gradien: **Buat Laporan Patroli**.
- Ringkasan angka harian sederhana (Laporan, Menunggu).

Interaksi utama:

- Tap kartu CTA → masuk ke wizard create report step 1.

### 5.1.2 Patrol List (Riwayat Patroli)

Komponen:

- List card laporan dengan thumbnail, area, tanggal.
- Badge status + badge risk level.
- Empty state jika belum ada laporan.

Interaksi:

- Tap item → masuk detail laporan.

---

## 5.2 Create Report Petugas (7 Step)

State wizard disimpan di provider `createReportFormProvider`.

### Step 1 — Building Type

- User pilih salah satu card:
  - Fasilitas Produksi
  - Fasilitas Non-Produksi
- UX: tap card langsung lanjut ke step 2.

### Step 2 — Lokasi/Area

- Dropdown area mock.
- Tombol `Kembali` + `Lanjutkan`.
- Validasi: wajib pilih area sebelum lanjut.

### Step 3 — Risk Level

- Grid 4 card warna:
  - Kritis (1), Berat (2), Sedang (3), Ringan (4).
- UX: tap card langsung lanjut ke step 4.

### Step 4 — Foto Temuan

- 3 slot foto.
- Capture dari kamera (`image_picker` source camera).
- Minimal 1 foto wajib untuk lanjut.
- Ada proses OCR (`google_mlkit_text_recognition`) yang menambahkan hasil deteksi ke notes.

### Step 5 — Notes/Keterangan

- Text area deskripsi temuan.
- Tombol lanjut aktif jika isi tidak kosong.

### Step 6 — Root Cause

- Text area analisa akar masalah.
- Tombol `Review` menuju step 7.

### Step 7 — Review & Submit

- Ringkasan data: bangunan, area, risiko, total foto, notes, root cause.
- Tombol:
  - `Kirim Laporan`
  - `Kembali Edit`

Saat submit sukses:

1. Simpan ke mock DB.
2. Reset draft provider.
3. Tampil dialog sukses.
4. Aksi dialog:
   - Bagikan via WhatsApp.
   - Selesai (kembali ke Home Petugas).

---

## 5.3 Detail Laporan (Petugas)

Di halaman detail, Petugas melihat:

- status laporan,
- area, risk level, waktu, notes, root cause,
- foto temuan,
- riwayat follow up/review.

Keputusan UX berbasis status:

- `Pending` / `Rejected`: tampil pesan menunggu tindak lanjut PIC.
- `Follow Up Done`: muncul 2 CTA besar:
  - `Tolak Perbaikan` (wajib isi alasan)
  - `Approve (Selesai)`

Jika Petugas menolak:

- alasan disimpan ke history,
- status report jadi `Rejected`.

Jika Petugas approve:

- status report jadi `Approved`.

---

## 6) UX Flow PIC — Dari Login sampai Follow Up

## 6.1 Entry PIC

Setelah login role `pic`, user masuk ke `PIC Home`.

### 6.1.1 PIC Home

Komponen:

- greeting user,
- deskripsi area tanggung jawab,
- grid `AreaCard` berdasarkan `areaAccess` user,
- count temuan yang butuh aksi (status `Pending` / `Rejected`).

Interaksi:

- Tap area card:
  1. set filter area aktif,
  2. pindah otomatis ke tab `Finding`.

### 6.1.2 PIC Finding

Komponen:

- list finding terfilter area akses PIC,
- title laporan formal: `Inspeksi {area} - Masalah: {rootCause}`,
- status badge,
- aksi clear filter area.

Interaksi:

- tap item finding → buka detail laporan.

---

## 6.2 PIC Follow Up (3 Step)

Flow dimulai dari detail report ketika status memungkinkan (`Pending` atau `Rejected`).

### Trigger dari Detail Report

Pada role PIC:

- status `Pending` → CTA `Mulai Tindak Lanjut`.
- status `Rejected` → CTA `Ulangi Tindak Lanjut` + guidance baca alasan penolakan.

Sebelum masuk wizard:

- `reportId` diset ke `picFollowUpFormProvider`.

### Step 1 — Foto Perbaikan

- 3 slot foto, kamera langsung.
- minimal 1 foto wajib.
- tombol: `Batal` / `Lanjutkan`.

### Step 2 — Catatan Perbaikan

- text area notes tindakan.
- validasi wajib isi.
- tombol: `Kembali` / `Lanjutkan`.

### Step 3 — Review Follow Up

- recap foto + catatan.
- tombol: `Kembali` / `Submit Follow Up`.

Submit sukses:

1. status report diupdate ke `Follow Up Done`.
2. log PIC follow up ditambahkan ke history.
3. draft follow up di-reset.
4. user diarahkan ke `PIC Home`.
5. snackbar sukses tampil.

---

## 7) UX Interaksi Lintas Role (Closed Loop)

Siklus laporan saat ini:

1. Petugas submit laporan (`Pending`).
2. PIC lihat finding dan kirim follow up (`Follow Up Done`).
3. Petugas review:
   - Approve → `Approved` (selesai).
   - Reject + alasan → `Rejected`.
4. Jika `Rejected`, PIC dapat mengirim follow up lanjutan.

Flow ini sudah membentuk loop dua arah yang jelas dan dapat ditelusuri via history pada detail report.

---

## 8) Ringkasan Komponen UI/UX yang Sudah Terwujud

### Kekuatan UX yang sudah ada

- Wizard step-by-step untuk Petugas dan PIC.
- Validasi mandatory untuk field penting.
- CTA utama jelas di setiap step.
- Role-based navigation cukup tegas.
- Status-driven action di detail report (kontekstual).
- Feedback user sudah ada: loading, snackbar, dialog sukses, empty state.

### Catatan konsistensi (as-is)

1. Ada dua varian flow create report di codebase:
   - flow `screens/create_report_*` (aktif di router),
   - flow monolitik `pages/petugas_create_report_page.dart` (prototype/alternatif).
2. Route awal masih `/login`, sementara splash sudah ada tapi belum jadi initial.
3. Menu Petugas saat ini masih 3 tab (`Patroli`, `Home`, `Profile`), belum sepenuhnya mengikuti dokumen revisi 2 tab.
4. Beberapa teks title list Petugas masih berbasis risk-level, sementara PIC sudah menggunakan format formal `Masalah: rootCause`.

---

## 9) Rekomendasi Prioritas (Agar Selaras Dokumen Produk)

1. Jadikan splash sebagai initial route dan aktifkan guard session secara penuh.
2. Finalisasi satu flow create report saja (hindari duplikasi `pages` vs `screens`).
3. Samakan naming laporan Petugas & PIC ke format backend (`Inspeksi {area} - Masalah: {rootCause}`).
4. Selaraskan bottom nav Petugas menjadi 2 menu bila mengikuti keputusan terbaru.
5. Tambahkan dokumentasi visual state per status report (`Pending`, `Follow Up Done`, `Rejected`, `Approved`) untuk QA.

---

## 10) Lampiran Referensi File Implementasi

- Router & nama route:
  - `lib/app/router/app_router.dart`
  - `lib/app/router/route_names.dart`
- Auth:
  - `lib/features/auth/presentation/screens/login_screen.dart`
  - `lib/core/mock_api/mock_auth_service.dart`
- Shell:
  - `lib/features/shell/presentation/screens/petugas_shell_screen.dart`
  - `lib/features/shell/presentation/screens/pic_shell_screen.dart`
- Petugas:
  - `lib/features/reports/presentation/screens/petugas_home_screen.dart`
  - `lib/features/reports/presentation/screens/patrol_list_screen.dart`
  - `lib/features/reports/presentation/screens/create_report_*.dart`
  - `lib/features/reports/presentation/screens/report_detail_screen.dart`
- PIC:
  - `lib/features/pic/presentation/screens/pic_home_screen.dart`
  - `lib/features/pic/presentation/screens/pic_finding_screen.dart`
  - `lib/features/pic/presentation/screens/pic_follow_up_*.dart`
- Mock data:
  - `lib/core/mock_api/mock_database.dart`

Dokumen ini menggambarkan kondisi **UI/UX yang sudah ada saat ini (as-is)** untuk mempermudah alignment tim sebelum penyempurnaan ke target arsitektur final.
