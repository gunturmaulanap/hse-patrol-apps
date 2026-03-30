# 20 Reusable Widget Blueprint

## Tujuan
Dokumen ini menjelaskan widget reusable yang harus dibuat lebih awal agar UI aplikasi **HSE Aksamala** terlihat modern, konsisten, dan cepat dirakit oleh AI agent.

## Prioritas widget yang wajib dibuat

## 1. AppScaffold
Wrapper scaffold global.

## 2. AppButton
Variant minimal:
- primary
- secondary
- outline
- danger
- text

## 3. AppTextField
Untuk login dan input singkat.

## 4. AppTextArea
Untuk notes, root cause, action follow up.

## 5. AppCard
Card dasar reusable.

## 6. AppSectionTitle
Judul section reusable.

## 7. AppStatusChip
Chip untuk status report.

Status minimal:
- submitted
- waiting_pic
- in_progress
- waiting_petugas_review
- approved
- rejected

## 8. AppRiskLevelCard
Pilihan risk level.

## 9. AppBuildingTypeCard
Pilihan building type.

## 10. AppAreaCard
Widget khusus untuk PIC Home.

### Kegunaan
- menampilkan card area berdasarkan akses PIC
- dipakai pada home PIC

### Isi card
- nama area
- building type
- code optional
- badge jumlah finding optional

## 11. AppReportListItem
List item reusable untuk list report/finding.

### Variasi
- mode Petugas
- mode PIC

### Isi utama
- name
- status chip
- subtitle area/code optional
- trailing action icons

## 12. AppActionIconGroup
Widget action icon kecil.

### Kegunaan
- detail
- create follow up
- create follow up lanjutan
- approve
- reject

## 13. AppPhotoSlot
Widget paling penting untuk project ini.

### State
- empty
- filled
- uploading
- error

## 14. AppBottomRoleNavigation
Bottom navigation reusable per role.

### Mode
- Petugas: Patrol, Profile
- PIC: Home, Finding, Profile

## 15. AppEmptyState
Harus mendukung pesan berbeda untuk:
- belum ada area PIC
- belum ada finding
- belum ada riwayat patroli

## 16. AppBottomActionBar
Untuk flow step-by-step create report dan follow up.
