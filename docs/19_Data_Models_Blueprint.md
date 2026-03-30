# 19 Data Models Blueprint

## Tujuan
Dokumen ini menjadi blueprint model data Flutter yang mengikuti backend final setelah revisi `areas`, menu role baru, dan finding list PIC.

## Prinsip model data
- gunakan `freezed` + `json_serializable`
- pisahkan request model dan response model bila perlu
- buat entity/domain model hanya jika memang dibutuhkan
- untuk versi awal, model data boleh tetap dekat dengan bentuk response backend

## Model inti yang wajib ada

## 1. AppUser
### Fields
- `id`
- `name`
- `email`
- `role`
- `phone`
- `isActive`

## 2. AreaModel
Mengikuti tabel backend `areas`.

### Fields
- `id`
- `code`
- `name`
- `buildingType`

### Mapping JSON
- `building_type` → `buildingType`

## 3. HseReportModel
Mengikuti tabel backend `hse_reports`.

### Fields
- `id`
- `code`
- `userId`
- `areaId`
- `name`
- `riskLevel`
- `rootCause`
- `notes`
- `status`
- `picToken`

### Mapping JSON
- `user_id` → `userId`
- `area_id` → `areaId`
- `risk_level` → `riskLevel`
- `root_cause` → `rootCause`
- `pic_token` → `picToken`

## 4. HseReportDetailModel
### Fields
- `id`
- `hseReportId`
- `photo1`
- `photo2`
- `photo3`

## 5. HseReportFollowUpModel
### Fields
- `id`
- `hseReportId`
- `action`
- `notes`
- `photo1`
- `photo2`
- `photo3`
- `followUpBy`

## 6. AccessibleAreaModel
Model untuk PIC Home.

### Fields
- `id`
- `code`
- `name`
- `buildingType`
- `findingCount` optional

## 7. FindingListItemModel
Model list untuk PIC Finding.

### Fields
- `id`
- `code`
- `name`
- `status`
- `areaName`
- `canCreateFollowUp`
- `canCreateFollowUpLanjutan`

## 8. PatrolListItemModel
Model list untuk Petugas Patrol.

### Fields
- `id`
- `code`
- `name`
- `status`
- `canApprove`
- `canReject`

## Request models yang wajib ada

## 1. LoginRequest
- `emailOrUsername`
- `password`

## 2. CreateHseReportRequest
- `areaId`
- `riskLevel`
- `rootCause`
- `notes`

### Mapping JSON
- `area_id`
- `risk_level`
- `root_cause`

Catatan:
- field `name` tidak wajib dikirim jika backend meng-generate otomatis dari `notes`

## 3. UploadReportPhotosRequest
- `photo1`
- `photo2`
- `photo3`

## 4. CreateFollowUpRequest
- `action`
- `notes`
- `photo1`
- `photo2`
- `photo3`
- `followUpBy`

## 5. ReviewFollowUpRequest
- `decision`
- `notes` optional

## Draft models untuk state frontend

## 1. CreateReportDraft
- `buildingType`
- `selectedAreaId`
- `riskLevel`
- `photo1Path`
- `photo2Path`
- `photo3Path`
- `notes`
- `rootCause`
- `reportNamePreview`

## 2. FollowUpDraft
- `reportId`
- `photo1Path`
- `photo2Path`
- `photo3Path`
- `action`
- `notes`
