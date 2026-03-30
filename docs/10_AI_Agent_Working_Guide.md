# 10 AI Agent Working Guide

## Tujuan
Dokumen ini dibuat agar AI agent di VS Code memahami proyek dengan benar dan tidak membuat arsitektur rusak.

## Rule utama untuk AI agent
1. Ikuti semua file dokumentasi bernomor ini secara urut.
2. Jangan mengubah arsitektur folder tanpa instruksi.
3. Jangan membuat package baru tanpa alasan jelas.
4. Jangan mengubah kontrak endpoint backend.
5. Jangan mencampur banyak pendekatan state management.
6. Semua screen baru harus memakai komponen reusable yang sudah ada.
7. Semua feature harus mengikuti struktur `data/domain/presentation`.
8. Jika membuat file baru, letakkan pada feature yang benar.

## Prioritas implementasi
AI agent harus mengerjakan proyek dengan urutan berikut:
1. setup project
2. theme + router + core
3. auth
4. camera permission
5. my reports
6. create report flow
7. report detail
8. pic tasks
9. pic detail by token
10. follow up flow
11. polish UI
12. testing and cleanup

## Rule code generation
Saat membuat kode, AI agent harus:
- membuat kode compileable
- tidak meninggalkan TODO kosong yang tidak dijelaskan
- tidak membuat mock berlebihan jika backend sudah jelas
- memecah file besar menjadi widget/provider/repository yang terpisah
- memakai typed models untuk request dan response

## Rule file creation
Jika AI agent diminta membuat feature baru, AI agent harus membuat file pada pola ini:

```text
features/<feature>/
  data/
  domain/
  presentation/
```

## Rule untuk form step-by-step
Create report dan follow up adalah form bertahap.

AI agent harus:
- menyimpan state form di provider
- tidak mengandalkan state lokal screen untuk keseluruhan proses
- mendukung back/next tanpa kehilangan data step sebelumnya

## Rule untuk photo upload
AI agent harus:
- mendukung 3 slot foto
- memakai kamera langsung
- tidak memakai gallery untuk flow utama
- memisahkan photo before dan photo after

## Rule untuk navigation
AI agent harus:
- memakai `go_router`
- mendukung token route untuk PIC
- menangani unauthenticated deep link flow

## Rule untuk UI
AI agent harus:
- memakai Material 3
- menggunakan spacing modern
- membuat komponen besar dan mudah ditekan
- mempertahankan tampilan user friendly untuk petugas lapangan

## Rule ketika ragu
Jika AI agent ragu, ikuti prioritas berikut:
1. backend contract
2. folder architecture
3. UX flow
4. design system
5. clean code consistency

## Prompt template untuk AI agent
Gunakan template ini saat meminta AI agent mengerjakan task:

```text
Ikuti dokumentasi proyek HSE Aksamala.
Gunakan arsitektur folder yang sudah ditentukan.
Gunakan Riverpod, go_router, Dio, Freezed.
Jangan ubah endpoint backend.
Buat kode yang compileable, modular, dan modern.
Kerjakan hanya task berikut: <isi task>.
```

## Contoh task prompt

### Contoh 1
```text
Kerjakan feature auth.
Buat login screen, auth provider, auth remote datasource, auth repository, login request/response model, dan integrasi ke POST /api/login.
Ikuti struktur folder yang sudah ditentukan.
```

### Contoh 2
```text
Kerjakan create report step 1 sampai step 3.
Gunakan createReportFormProvider untuk menyimpan state.
Jangan buat upload foto dulu.
```

### Contoh 3
```text
Kerjakan komponen reusable photo_slot_card, sticky bottom action bar, dan risk_level_card dengan gaya modern Material 3.
```
