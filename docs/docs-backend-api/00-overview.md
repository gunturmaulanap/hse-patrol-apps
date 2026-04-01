# 00 Overview

## Ringkasan

API ini digunakan untuk kebutuhan **HSE MES** dengan fokus utama pada:

1. autentikasi pengguna,
2. pengelolaan report HSE,
3. pengambilan data area,
4. tindak lanjut (follow-up) atas report.

Dokumentasi ini dirapikan dari file export Insomnia agar lebih mudah dibaca oleh developer maupun AI agent.

## Base URL

### Production

```text
https://mes.aksamala.co.id/api
```

## Format autentikasi

Sebagian besar endpoint menggunakan **Bearer Token**.

Header umum:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

## Content type yang digunakan

Endpoint pada koleksi ini menggunakan beberapa tipe body:

- `application/x-www-form-urlencoded` untuk login,
- `multipart/form-data` untuk create/update report dan create/update follow-up,
- `application/json` untuk approval dan delete follow-up.

## Konvensi penting dari koleksi sumber

Berdasarkan catatan pada koleksi Insomnia:

- untuk environment production, `baseUrl` diarahkan ke `https://mes.aksamala.co.id/api`,
- `mode=update` digunakan untuk update data,
- `mode=cancel` digunakan untuk membatalkan report,
- `mode=delete` digunakan untuk menghapus data follow-up.

## Daftar endpoint

### Auth

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/login` | Login user |
| POST | `/logout` | Logout user |
| GET | `/me` | Ambil profil user yang sedang login |

### Report & Area

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/hse-reports` | Membuat report baru |
| PUT | `/hse-reports/{reportId}` | Update atau cancel report |
| GET | `/hse-reports/{id}` | Ambil detail report berdasarkan ID |
| GET | `/hse-reports` | Ambil daftar report |
| GET | `/areas` | Ambil daftar area |
| GET | `/areas/by-user` | Ambil area berdasarkan user login |

### Follow-up Report

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/{reportId}/follow-ups` | Membuat follow-up untuk report |
| PUT | `/{reportId}/follow-ups/{followupId}` | Update follow-up |
| GET | `/{reportId}/follow-ups` | Ambil daftar follow-up per report |
| GET | `/{reportId}/follow-ups/{followupId}` | Ambil detail follow-up |
| PUT | `/{reportId}/follow-ups/{followupId}` | Approval follow-up |
| PUT | `/{reportId}/follow-ups/{followupId}` | Delete follow-up |

> Catatan: path follow-up ditulis sesuai koleksi Insomnia yang tersedia. Karena format path ini tidak menampilkan prefix `/hse-reports`, sebaiknya diverifikasi kembali ke implementasi backend.

## Alur penggunaan singkat

1. Login ke endpoint `/login` untuk mendapatkan token.
2. Gunakan token tersebut pada header `Authorization`.
3. Buat report melalui `/hse-reports`.
4. Ambil daftar atau detail report jika diperlukan.
5. Lakukan follow-up terhadap report sesuai workflow HSE.

## Batasan dokumentasi ini

Hal-hal berikut belum tersedia dari sumber yang diberikan:

- schema response resmi,
- kode status HTTP lengkap,
- detail validasi field,
- daftar enum resmi untuk semua status.

Jika Anda ingin, dokumentasi ini bisa dilanjutkan ke versi yang lebih lengkap seperti:

- OpenAPI/Swagger YAML,
- Postman Collection,
- knowledge file khusus untuk AI agent.
