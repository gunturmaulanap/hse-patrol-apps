# 08 API Integration Guide

## Tujuan
Dokumen ini menjelaskan kontrak integrasi frontend Flutter dengan backend Laravel setelah revisi `areas`, role menu baru, dan flow review follow up.

## Prinsip integrasi
- backend adalah source of truth
- frontend mengikuti kontrak final backend
- frontend tidak membuat area baru
- data area PIC berasal dari akses master backend
- `name` report disimpan di backend

## Entitas utama backend

### `areas`
- id
- code
- name
- building_type

### `hse_reports`
- id
- code
- user_id
- area_id
- name
- risk_level
- root_cause
- notes
- status
- pic_token

### `hse_report_details`
- id
- hse_report_id
- photo1
- photo2
- photo3

### `hse_report_followups`
- id
- hse_report_id
- action
- notes
- photo1
- photo2
- photo3
- follow_up_by

## Rekomendasi endpoint

### Auth
- `POST /api/login`
- `POST /api/logout`
- `GET /api/me`

### Areas
- `GET /api/areas?building_type=atas`
- `GET /api/areas?building_type=bawah`
- `GET /api/pic/areas`

Catatan:
- `GET /api/pic/areas` mengembalikan hanya area yang dapat diakses PIC saat login

### Reports — Petugas
- `GET /api/patrol-reports`
- `POST /api/hse-reports`
- `GET /api/hse-reports/{id}`
- `POST /api/hse-reports/{id}/details`
- `POST /api/hse-reports/{id}/review`

### Reports — PIC
- `GET /api/pic/findings`
- `GET /api/pic/findings/{id}`
- `GET /api/pic/report-by-token/{token}`
- `POST /api/hse-reports/{id}/followups`

## Create report flow

### Request create report
`POST /api/hse-reports`

Payload minimal:
- `area_id`
- `risk_level`
- `root_cause`
- `notes`

Catatan:
- `name` report diisi backend dari `notes`
- frontend boleh menampilkan preview `name`, tapi tidak wajib mengirim `name`

### Upload photos
`POST /api/hse-reports/{id}/details`

Multipart fields:
- `photo1`
- `photo2`
- `photo3`

## PIC finding flow

### List findings
`GET /api/pic/findings`

Response minimal per item:
- `id`
- `code`
- `name`
- `status`
- `area`
- `latest_followup_status` optional

### Follow up
`POST /api/hse-reports/{id}/followups`

Multipart fields:
- `action`
- `notes`
- `photo1`
- `photo2`
- `photo3`
- `follow_up_by`

## Petugas review flow

### Review endpoint
`POST /api/hse-reports/{id}/review`

Payload minimal:
- `decision`: `approved` / `rejected`
- `notes` optional jika backend mendukung catatan review

### Efek status
- `approved` → status report menjadi `approved`
- `rejected` → status report menjadi `rejected` dan PIC dapat kirim follow up lanjutan

## Status yang harus dipahami frontend
- `submitted`
- `waiting_pic`
- `in_progress`
- `waiting_petugas_review`
- `approved`
- `rejected`

## Catatan implementasi `name report`

### Jangan gunakan ML Kit OCR untuk text input
ML Kit Text Recognition dipakai untuk membaca teks dari gambar.

Karena sumber data di sini adalah `notes` yang diketik user, gunakan pendekatan berikut:
- backend membuat `name` dari potongan kalimat pertama atau keyword penting dari `notes`
- jika ingin preview di frontend, buat helper sederhana seperti `deriveReportName(notes)`
- backend tetap menyimpan `name` final
