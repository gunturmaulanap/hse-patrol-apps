# 11 Implementation Roadmap

## Tujuan
Dokumen ini menentukan urutan kerja terbaik setelah revisi UI, menu role, dan perubahan `locations` menjadi `areas`.

## Phase 1 — Foundation
Target:
- project bisa jalan
- theme jalan
- router jalan
- core services siap

Task:
1. create project
2. add packages
3. setup folder structure
4. setup theme
5. setup router
6. setup dio client
7. setup secure storage
8. setup shared enums

## Phase 2 — Authentication and Role Shell
Target:
- login jalan
- splash session check jalan
- role-based redirect jalan
- shell/tab per role sudah siap

Task:
1. auth models
2. auth datasource
3. auth repository
4. auth provider
5. splash screen
6. login screen
7. role shell router
8. petugas bottom nav shell
9. PIC bottom nav shell

## Phase 3 — Core UI Components
Target:
- reusable UI tersedia sebelum fitur banyak dibuat

Task:
1. app button
2. app card
3. app text field
4. loading state
5. empty state
6. error state
7. step progress header
8. photo slot card
9. bottom action bar
10. area access card
11. report action icon bar

## Phase 4 — Camera Permission
Target:
- permission flow jelas

Task:
1. permission service
2. permission provider
3. permission screen
4. settings redirect handling

## Phase 5 — Petugas Patrol History
Target:
- Petugas bisa melihat riwayat patroli dan review follow up

Task:
1. patrol history model
2. patrol datasource
3. patrol repository
4. patrol provider
5. patrol list screen
6. patrol list item widget
7. approve/reject action handling

## Phase 6 — Create Report Step-by-Step
Target:
- create report flow selesai end-to-end

Task:
1. form provider
2. step 1 building type
3. step 2 area selection only
4. step 3 risk level
5. step 4 photo before max 3
6. step 5 notes
7. step 6 root cause
8. step 7 review
9. submit create report
10. upload report detail photos
11. preview report name dari notes optional

## Phase 7 — PIC Home and Finding
Target:
- PIC manual login memiliki home yang hidup dan daftar finding yang jelas

Task:
1. accessible areas model
2. areas datasource
3. PIC home provider
4. PIC home screen with area cards
5. finding model
6. finding datasource
7. finding provider
8. finding screen
9. filter area/status sederhana

## Phase 8 — Report Detail
Target:
- detail report tampil lengkap untuk Petugas dan PIC

Task:
1. detail model
2. detail provider
3. detail screen
4. photo preview sections
5. follow up history section
6. review section untuk Petugas

## Phase 9 — Follow Up PIC
Target:
- PIC bisa submit follow up lengkap

Task:
1. follow up form provider
2. photo after step max 3
3. action and notes step
4. submit follow up
5. refresh finding and detail data
6. handle follow up lanjutan saat status rejected

## Phase 10 — Token and Deep Link
Target:
- PIC bisa masuk dari token dan tetap landing ke report yang tepat

Task:
1. pic detail by token
2. invalid token state
3. pending intent after login
4. token redirect handling

## Phase 11 — Polish and QA
Target:
- UX matang
- error handling lengkap
- app siap testing

Task:
1. loading polish
2. error polish
3. empty state polish
4. success messages
5. validation polish
6. router guard test
7. manual QA

## Definition of Done
Sebuah phase dianggap selesai jika:
- compile sukses
- flow utama jalan
- error state minimal tersedia
- kode mengikuti struktur folder
- tidak ada file liar di luar arsitektur
