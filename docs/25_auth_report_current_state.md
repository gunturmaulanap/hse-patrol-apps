# 25. Auth + Report Current State (April 2026)

## Ringkasan status saat ini

Dokumen ini menjelaskan kondisi implementasi **auth** dan **report petugas screens** setelah integrasi backend terbaru.

---

## 1) Auth flow (login + role + redirect)

### Endpoint yang dipakai

- `POST /login`
- `GET /me`
- `POST /logout`

Base URL mengikuti `AppEnv.baseUrl`:

- `https://mes.aksamala.co.id/api`

### Format response login yang didukung

Frontend sekarang memproses response seperti ini secara defensif:

```json
{
  "status": "success",
  "token": "...",
  "token_type": "Bearer",
  "user": {
    "id": 35,
    "name": "Abdul Majid",
    "email": "abdulmajid@aksamala.co.id",
    "role": "pic_area"
  }
}
```

### Mapping role backend -> role app

Field `user.role` dari backend dipetakan sebagai berikut:

- `pic_area` -> `UserRole.pic`
- `hse_staff` -> `UserRole.petugasHse`
- `hse_supervisor` -> `UserRole.petugasHse`
- fallback string yang mengandung `pic` -> `UserRole.pic`
- fallback string yang mengandung `hse`/`petugas` -> `UserRole.petugasHse`

### Dampak routing

Setelah login sukses:

- role PIC diarahkan ke route PIC home
- role HSE staff/supervisor diarahkan ke route Petugas home

Masalah sebelumnya “semua role masuk ke petugas home” terjadi karena role belum tersedia pada payload lama / fallback default role. Dengan payload baru yang menyertakan role, redirect sudah bisa terbedakan.

---

## 2) Storage dan inisialisasi web

Perbaikan penting:

- storage web tidak lagi menggunakan null-assert langsung ke shared preferences
- dilakukan lazy init + explicit init saat app startup
- `main()` memanggil:
  - `SecureStorageService.init()`
  - `DioClient.initInterceptors()`

Tujuan:

- mencegah error `Unexpected null value` di Flutter Web ketika token disimpan/dibaca.

---

## 3) Report data source backend

### Endpoint list report

- `GET /hse-reports`

### Parsing list dibuat defensif

Frontend sekarang mendukung kemungkinan bentuk response:

- root array
- wrapper `data: []`
- wrapper nested `data.data: []`
- wrapper `items: []`
- nested `data.items: []`

### Parsing title untuk report card

- Jika backend mengirim `title`, maka dipakai sebagai judul utama.
- Jika tidak ada `title`, fallback ke `name`.
- Jika keduanya kosong, UI membentuk title dengan format:

```text
Inspeksi <area> - Masalah: <rootCause>
```

> Catatan: area fallback sementara bisa berupa `Area #<areaId>` jika backend list belum mengirim nama area.

---

## 4) Integrasi backend pada 3 layar Petugas

Layar berikut tidak lagi mengambil data dari `mockDatabaseProvider` untuk list task utama:

1. `petugas_home_screen.dart`
2. `petugas_all_tasks_screen.dart`
3. `petugas_calendar_screen.dart`

Ketiganya sekarang memakai provider backend map-ready:

- `petugasReportMapsProvider`

Provider ini:

- fetch list report dari backend
- normalisasi status (`pending`, `followupdone`, `approved`, dll)
- menyiapkan field UI (`title`, `area`, `rootCause`, `status`, `date`, dll)

### Mapping status backend -> UI

- `pending` -> `Pending`
- `followupdone` / `follow_up_done` -> `Follow Up Done`
- `approved` / `completed` -> `Completed`
- `reject` / `rejected` -> `Pending`
- `canceled` / `cancelled` -> `Canceled`

---

## 5) Known limitations (sementara)

1. **Area name**
   - Jika endpoint list report belum mengirim `area_name`/`area.name`, UI fallback ke `Area #<id>`.

2. **Role source of truth**
   - Role idealnya konsisten di login dan `/me`.
   - Bila `/me` gagal, app masih dapat fallback ke user hasil login.

3. **Mock data masih ada di modul lain**
   - Beberapa screen/page lain di project masih memakai mock provider untuk kebutuhan demo.

---

## 6) Rekomendasi lanjutan

1. Tambahkan contract response backend resmi untuk:
   - list report (`title`, `area_name`, `created_at`, status enum final)
   - `/me` (role enum final)

2. Jika memungkinkan, standardisasi field role backend (mis. enum tunggal) agar mapping frontend lebih sederhana.

3. Tambahkan integration test minimal untuk:
   - login PIC vs HSE redirect
   - fallback title format
   - list report kosong/error state per layar

---

## 7) File yang terkait langsung dengan perubahan saat ini

- `lib/features/auth/data/models/user_model.dart`
- `lib/features/reports/data/datasource/report_remote_datasource.dart`
- `lib/features/reports/presentation/providers/report_provider.dart`
- `lib/features/reports/presentation/screens/petugas_home_screen.dart`
- `lib/features/reports/presentation/screens/petugas_all_tasks_screen.dart`
- `lib/features/reports/presentation/screens/petugas_calendar_screen.dart`
