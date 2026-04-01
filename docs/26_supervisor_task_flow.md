# 26. Supervisor Task Flow Specification

## Tujuan

Menambahkan flow khusus role **HSE Supervisor** agar dapat:

- memantau task milik dirinya sendiri,
- memantau task milik seluruh **HSE Staff**,
- melihat dashboard ringkas di home,
- tetap bisa membuat task baru,
- tidak bisa melakukan action terhadap task yang dibuat staff lain.

Dokumen ini menjadi acuan implementasi UI/route/provider supervisor.

---

## 1) Role dan akses

### Role sumber backend

Dari login atau `/me`:

- `hse_supervisor` -> supervisor flow
- `hse_staff` -> petugas flow
- `pic_area` -> pic flow

### Prinsip akses supervisor

- Supervisor **boleh melihat**:
  - own task (task yang dibuat dirinya)
  - staff task (task semua hse_staff)
- Supervisor **boleh action** (approve/reject/cancel, dll) **hanya** untuk own task.
- Supervisor **tidak boleh action** pada task milik staff lain (read-only di detail).

---

## 2) Struktur screen supervisor

Akan ditambahkan screen baru dengan pola visual yang setara petugas:

1. `supervisor_shell_screen.dart`
   - bottom menu: **home**, **+**, **calendar**
   - behavior dan style mengikuti shell petugas

2. `supervisor_home_screen.dart`
   - tampilan dasar sama dengan petugas home
   - blok “3 task terdepan” diisi **3 task terbaru dari staff** (bukan own task)

3. `supervisor_calendar_screen.dart`
   - tampilan sama dengan calendar petugas
   - data task adalah gabungan:
     - own task supervisor
     - seluruh staff task

4. `supervisor_all_tasks_screen.dart`
   - struktur mirip all tasks petugas
   - tab level 1: `Own Task` dan `Staff Task`
   - untuk `Own Task`: langsung tampil tab status (All/Pending/Follow Up Done/Completed/Canceled)
   - untuk `Staff Task`: tampil **selector staff dulu**, setelah staff dipilih baru tampil tab status

---

## 3) Data flow provider supervisor

Akan disiapkan provider baru berbasis data task backend map-ready:

1. `supervisorOwnTaskMapsProvider`
   - filter creator == current supervisor

2. `supervisorStaffTaskMapsProvider`
   - filter role pembuat == hse_staff
   - exclude own task supervisor

3. `supervisorAllVisibleTaskMapsProvider`
   - gabungan own + staff (untuk calendar)

4. `supervisorStaffNamesProvider`
   - ekstrak unik nama staff dari staff task list

5. `supervisorStaffTaskByNameProvider(staffName)`
   - task list spesifik staff terpilih

> Catatan: field pembuat task mengikuti payload backend yang tersedia (mis. `creator_id`, `creator_name`, `created_by`, `staff_name`). Parsing akan dibuat defensif dengan fallback.

---

## 4) Detail task permission matrix

Pada halaman detail task:

- jika user supervisor membuka own task:
  - action area aktif seperti petugas (sesuai status)
- jika user supervisor membuka staff task:
  - action area disembunyikan / disabled
  - tampil badge informasi: “Read only - Task milik staff”

Implementation rule:

- deteksi owner task terhadap current user (id/email/nama sesuai field tersedia)
- semua handler action harus guard:
  - jika bukan owner -> return + snackbar info

---

## 5) Integrasi create task untuk supervisor

Supervisor dapat membuat task via tombol `+` di shell supervisor.
Flow create tetap menggunakan flow yang sudah ada pada petugas agar konsisten:

- route create task diarahkan ke flow existing create task.

Setelah submit sukses:

- kembali ke supervisor home.

---

## 6) Route & redirect plan

Tambahan route names:

- `supervisorHome`
- `supervisorAllTasks`
- `supervisorCalendar`
- `supervisorShell`

Role redirect saat bootstrap/login:

- `pic_area` -> pic shell/home
- `hse_staff` -> petugas shell/home
- `hse_supervisor` -> supervisor shell/home

---

## 7) Naming cleanup: report -> task

Target user: penamaan file lebih konsisten ke istilah **task**.

Strategi aman bertahap:

1. Tambah file supervisor baru dengan prefix `supervisor_*_task*` bila relevan.
2. Untuk file existing petugas, lakukan rename bertahap dengan compatibility alias route agar tidak memutus referensi.
3. Hindari big-bang rename dalam satu patch untuk mencegah regression routing/import.

Batch awal (aman) yang akan dikerjakan sekarang:

- tambah file supervisor dengan naming task-oriented,
- pertahankan file petugas lama (kompatibel),
- update route name display/label ke “Task”.

---

## 8) Acceptance criteria

1. Login sebagai `hse_supervisor` masuk ke supervisor shell.
2. Supervisor home menampilkan 3 task terbaru dari staff.
3. Supervisor calendar menampilkan own + seluruh staff task.
4. Supervisor all tasks punya tab `Own Task` dan `Staff Task`.
5. Pada tab `Staff Task`, user memilih staff dulu baru status filter.
6. Supervisor tidak bisa action task milik staff lain di detail.
7. Supervisor tetap bisa membuat task dari tombol `+`.
8. Build analyzer untuk file yang diubah tidak error.
