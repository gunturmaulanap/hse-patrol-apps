# 06 State Management and App Flow

## Pendekatan state management
Gunakan **Riverpod**.

## Jenis state utama yang dibutuhkan

### Global state
- session user
- auth token
- current user role
- app router guard
- pending PIC token intent
- selected bottom navigation tab per role

### Feature state
- patrol history list untuk Petugas
- detail report Petugas
- create report form
- PIC accessible areas
- PIC finding list
- PIC report detail
- create follow up form
- camera permission state
- review follow up state (`approved` / `rejected`)

## Pola state yang disarankan
Untuk async screen gunakan pola:
- loading
- data
- empty
- error

Untuk form gunakan immutable form state.

## Auth flow

### Splash logic
Saat splash:
1. cek token di secure storage
2. jika tidak ada token → login
3. jika ada token → hit endpoint `/me`
4. jika valid → arahkan sesuai role
5. jika gagal → clear session dan ke login

## Role-based flow

### Petugas Patroli HSE
Setelah login:
- jika permission camera belum pernah diminta → bisa minta izin saat akan masuk flow foto
- lalu masuk ke shell/tab Petugas
- default tab = `Patroli`

### PIC
Setelah login:
- jika login dari deep link token → resolve token lalu buka detail report PIC
- jika login manual → masuk ke shell/tab PIC
- default tab = `Home`

## Tab state per role

### Petugas tabs
- `patrol`
- `profile`

### PIC tabs
- `home`
- `finding`
- `profile`

## Create report state
Buat provider khusus misalnya `createReportFormProvider`.

State minimal:
- buildingType
- selectedAreaId
- selectedAreaName
- riskLevel
- notes
- rootCause
- photos list max 3
- generatedReportNamePreview
- isSubmitting

Catatan:
- Petugas **tidak bisa** input area baru
- state area baru tidak perlu ada lagi

## Finding list state untuk PIC
Buat provider misalnya `picFindingListProvider`.

State minimal:
- selectedAreaId optional
- finding list
- filters status optional
- loading state
- refresh state

## Follow up state
Buat provider khusus misalnya `createFollowupFormProvider`.

State minimal:
- reportId
- action
- notes
- photos list max 3
- isSubmitting

## Review follow up state oleh Petugas
Buat provider misalnya `followupReviewProvider`.

State minimal:
- reportId
- selectedDecision (`approved` / `rejected`)
- rejectionNote optional jika backend mendukung
- isSubmitting

## Deep link / token flow
Ketika aplikasi dibuka dari token PIC:
1. baca token dari route
2. cek apakah user login
3. jika belum login → simpan pending token sementara
4. login berhasil → resolve token
5. buka detail report terkait
6. jika token invalid → tampil error page

## Data refresh rules
- setelah submit report → refresh patrol history Petugas
- setelah create follow up → refresh detail report PIC dan finding list
- setelah review follow up → refresh patrol history Petugas dan finding PIC
- setelah login PIC → refresh accessible areas di home

## Camera flow
Gunakan custom camera page jika memungkinkan.

Prinsip:
- hanya ambil dari kamera
- tidak ada opsi gallery
- hasilnya dikembalikan sebagai file local
- tiap slot foto disimpan di state form

## Error mapping yang harus ada
- invalid token PIC
- login gagal
- area tidak ditemukan
- upload foto gagal
- network timeout
- unauthorized
- follow up sudah tidak valid untuk direview

## UX state yang wajib ada
- full page loading
- section loading
- empty state dengan CTA
- retry state
- tab state preservation sederhana
