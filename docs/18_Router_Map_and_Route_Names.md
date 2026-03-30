# 18 Router Map and Route Names

## Tujuan
Dokumen ini menjelaskan peta route final setelah revisi menu role:
- Petugas: `Patroli`, `Profile`
- PIC: `Home`, `Finding`, `Profile`

Gunakan `go_router` dengan pendekatan shell route / stateful shell route agar bottom navigation per role lebih rapi.

## Route names utama
- `splash`
- `login`
- `petugasShell`
- `picShell`
- `petugasPatrol`
- `petugasProfile`
- `picHome`
- `picFinding`
- `picProfile`
- `reportDetail`
- `createReportBuildingType`
- `createReportArea`
- `createReportRisk`
- `createReportPhotos`
- `createReportNotes`
- `createReportRootCause`
- `createReportReview`
- `picFollowUpPhotos`
- `picFollowUpForm`
- `picReportByToken`

## Public routes

### splash
- path: `/`
- access: public

### login
- path: `/login`
- access: public

## Petugas shell

### shell
- path: `/petugas`
- access: Petugas only

### tab 1 — Patroli
- name: `petugasPatrol`
- path: `/petugas/patrol`

### tab 2 — Profile
- name: `petugasProfile`
- path: `/petugas/profile`

## PIC shell

### shell
- path: `/pic`
- access: PIC only

### tab 1 — Home
- name: `picHome`
- path: `/pic/home`

### tab 2 — Finding
- name: `picFinding`
- path: `/pic/finding`

### tab 3 — Profile
- name: `picProfile`
- path: `/pic/profile`

## Shared detail routes

### reportDetail
- path: `/reports/:reportId`
- access: authenticated

Catatan:
- halaman detail dapat dipakai Petugas maupun PIC
- isi action menyesuaikan role

## Create report routes — Petugas
- `/reports/create/building-type`
- `/reports/create/area`
- `/reports/create/risk`
- `/reports/create/photos`
- `/reports/create/notes`
- `/reports/create/root-cause`
- `/reports/create/review`

## Follow up routes — PIC
- `/pic/reports/:reportId/follow-up/photos`
- `/pic/reports/:reportId/follow-up/form`

## PIC token entry route
- `/pic/token/:token`

Behavior:
- jika belum login → redirect ke login dan simpan intent
- jika sudah login → validasi token lalu buka report terkait

## Redirect logic

### Saat splash
- jika token tidak ada → login
- jika token ada dan role petugas → `/petugas/patrol`
- jika token ada dan role PIC → `/pic/home`

### Saat login sukses
- jika ada pending PIC token intent → buka `/pic/token/:token`
- jika role Petugas → `/petugas/patrol`
- jika role PIC → `/pic/home`
