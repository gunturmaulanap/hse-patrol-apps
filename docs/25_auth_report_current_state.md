# 25. Auth + Report Current State (Production Backend)

## Ringkasan

Dokumen ini merekam kondisi terbaru integrasi auth + report saat backend sudah masuk tahap production.

Fokus perubahan:

1. login membaca payload production terbaru (`token`, `role_id`, `role_name`),
2. task dan area kembali menggunakan data backend sebagai source of truth,
3. fallback mock untuk alur auth/report/create task dilepas.

---

## 1) Auth flow production

### Endpoint

- `POST /login`
- `GET /me`
- `POST /logout`

Base URL:

- `https://mes.aksamala.co.id/api`

### Contoh response login yang dipakai

```json
{
  "status": "success",
  "token": "...",
  "token_type": "Bearer",
  "user": {
    "id": 35,
    "name": "Abdul Majid",
    "email": "abdulmajid@aksamala.co.id",
    "role_id": 22,
    "role_name": "HSE"
  }
}
```

### Mapping role backend -> role app

Frontend memetakan role dari kombinasi `role_id`, `role_name`, dan fallback `role`:

- `role_id == 12` -> `UserRole.pic`
- `role_id == 22` -> `UserRole.petugasHse`
- `role_name` mengandung `pic` -> `UserRole.pic`
- `role_name` mengandung `supervisor` -> `UserRole.hseSupervisor`
- `role_name` mengandung `hse` -> `UserRole.petugasHse`

### Redirect setelah login

- `pic` -> PIC home
- `hseSupervisor` -> Supervisor home
- selain itu -> Petugas home

---

## 2) Storage/session

Token tetap disimpan via `SessionManager` + `SecureStorageService`.

Pada web, penyimpanan memakai `SharedPreferences` melalui inisialisasi aman (`SecureStorageService.init()`), sehingga tidak bergantung null assertion.

---

## 3) Report & area source of truth

### Task list

Provider task sekarang mengambil data langsung dari backend:

- `GET /hse-reports`

Tidak ada fallback ke mock database pada provider task utama.

### Area list

Provider area mengambil data backend:

- `GET /areas`

Tidak ada fallback ke mock area.

---

## 4) Create task (production)

Create task tetap melalui backend:

- `POST /hse-reports`

Response create terbaru sudah berbentuk wrapper `data` dan digunakan sebagai sumber data utama.

Perubahan penting:

- tidak lagi menulis report ke mock database setelah submit,
- tidak ada fallback success palsu jika request backend gagal,
- provider task di-`invalidate` setelah submit sukses agar UI memuat ulang data backend terbaru.

---

## 5) Catatan parsing response

### Login

- field token utama: `token`
- fallback kompatibilitas masih mengizinkan `access_token` bila ada
- user diparsing dari `user` root atau wrapper yang valid

### Report create/list/detail

Parser task mendukung:

- `id`, `user_id`, `area_id` bisa berupa int/string,
- `photos` bisa berupa list atau object (`photo1`, `photo2`, dst),
- `created_at` dipakai sebagai fallback tanggal jika `date` tidak tersedia.

---

## 6) Scope yang sudah production-backed

Modul yang sudah kembali backend-driven untuk alur utama:

- auth login/logout/me,
- task list provider (petugas/supervisor dashboard flows),
- area provider,
- create task submit + refresh list.

---

## 7) Sisa modul non-target

Beberapa screen lama di luar scope auth/report utama (khusus demo/legacy PIC flow tertentu) masih memiliki ketergantungan mock dan perlu migrasi terpisah jika ingin full backend-only untuk seluruh aplikasi.
