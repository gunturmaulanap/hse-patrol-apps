# 14 API Response Examples

## Tujuan
Dokumen ini berisi contoh request dan response agar AI agent dan developer Flutter memahami kontrak data dengan lebih jelas.

## Catatan penting
- contoh ini adalah referensi implementasi frontend
- nama field harus mengikuti backend final
- jika backend nanti memakai format response wrapper, sesuaikan mapper tanpa mengubah model domain utama

---

# 1. Authentication

## POST /api/login
### Request
```json
{
  "username": "petugas.hse",
  "password": "secret123"
}
```

### Response sukses
```json
{
  "token": "jwt_or_access_token_here",
  "user": {
    "id": 1,
    "name": "Budi Santoso",
    "role": "petugas_hse",
    "phone": "081234567890"
  }
}
```

## GET /api/me
### Response sukses
```json
{
  "id": 1,
  "name": "Budi Santoso",
  "role": "petugas_hse",
  "phone": "081234567890"
}
```

---

# 2. Locations

## GET /api/locations?building_type=atas
### Response sukses
```json
[
  {
    "id": 1,
    "code": "LOC-001",
    "name": "Ruang Panel",
    "building_type": "atas"
  },
  {
    "id": 2,
    "code": "LOC-002",
    "name": "Koridor Barat",
    "building_type": "atas"
  }
]
```

## POST /api/locations
### Request
```json
{
  "code": "LOC-003",
  "name": "Ruang Pompa",
  "building_type": "bawah"
}
```

### Response sukses
```json
{
  "id": 3,
  "code": "LOC-003",
  "name": "Ruang Pompa",
  "building_type": "bawah"
}
```

### Response validasi gagal
```json
{
  "message": "Validation failed",
  "errors": {
    "name": [
      "Nama lokasi sudah digunakan untuk building type ini"
    ]
  }
}
```

---

# 3. HSE Reports

## POST /api/hse-reports
### Request
```json
{
  "location_id": 1,
  "risk_level": "merah",
  "root_cause": "Kebocoran pipa di area plafon",
  "notes": "Plafon lembab dan terdapat rembesan air"
}
```

### Response sukses
```json
{
  "id": 1001,
  "code": "HSE-20260326-0001",
  "user_id": 1,
  "location_id": 1,
  "risk_level": "merah",
  "root_cause": "Kebocoran pipa di area plafon",
  "notes": "Plafon lembab dan terdapat rembesan air",
  "status": "submitted",
  "pic_token": "secure_token_abc_123"
}
```

## GET /api/hse-reports
### Response sukses
```json
[
  {
    "id": 1001,
    "code": "HSE-20260326-0001",
    "location": {
      "id": 1,
      "code": "LOC-001",
      "name": "Ruang Panel",
      "building_type": "atas"
    },
    "risk_level": "merah",
    "notes": "Plafon lembab dan terdapat rembesan air",
    "status": "submitted"
  },
  {
    "id": 1002,
    "code": "HSE-20260326-0002",
    "location": {
      "id": 2,
      "code": "LOC-002",
      "name": "Koridor Barat",
      "building_type": "bawah"
    },
    "risk_level": "kuning",
    "notes": "Dinding retak memanjang",
    "status": "waiting_pic"
  }
]
```

## GET /api/hse-reports/{id}
### Response sukses
```json
{
  "id": 1001,
  "code": "HSE-20260326-0001",
  "user": {
    "id": 1,
    "name": "Budi Santoso",
    "role": "petugas_hse"
  },
  "location": {
    "id": 1,
    "code": "LOC-001",
    "name": "Ruang Panel",
    "building_type": "atas"
  },
  "risk_level": "merah",
  "root_cause": "Kebocoran pipa di area plafon",
  "notes": "Plafon lembab dan terdapat rembesan air",
  "status": "waiting_pic",
  "pic_token": "secure_token_abc_123",
  "details": {
    "id": 501,
    "hse_report_id": 1001,
    "photo1": "uploads/reports/1001/photo1.jpg",
    "photo2": "uploads/reports/1001/photo2.jpg",
    "photo3": null
  },
  "followups": []
}
```

---

# 4. HSE Report Details

## POST /api/hse-reports/{id}/details
### Request
multipart/form-data:
- `photo1`
- `photo2`
- `photo3`

### Response sukses
```json
{
  "id": 501,
  "hse_report_id": 1001,
  "photo1": "uploads/reports/1001/photo1.jpg",
  "photo2": "uploads/reports/1001/photo2.jpg",
  "photo3": null
}
```

## GET /api/hse-reports/{id}/details
### Response sukses
```json
{
  "id": 501,
  "hse_report_id": 1001,
  "photo1": "uploads/reports/1001/photo1.jpg",
  "photo2": "uploads/reports/1001/photo2.jpg",
  "photo3": null
}
```

---

# 5. PIC by Token

## GET /api/pic/report-by-token/{token}
### Response sukses
```json
{
  "id": 1001,
  "code": "HSE-20260326-0001",
  "location": {
    "id": 1,
    "code": "LOC-001",
    "name": "Ruang Panel",
    "building_type": "atas"
  },
  "risk_level": "merah",
  "root_cause": "Kebocoran pipa di area plafon",
  "notes": "Plafon lembab dan terdapat rembesan air",
  "status": "waiting_pic",
  "details": {
    "id": 501,
    "hse_report_id": 1001,
    "photo1": "uploads/reports/1001/photo1.jpg",
    "photo2": "uploads/reports/1001/photo2.jpg",
    "photo3": null
  },
  "followups": []
}
```

### Response token tidak valid
```json
{
  "message": "Report tidak ditemukan atau token tidak valid"
}
```

---

# 6. HSE Report Followups

## POST /api/hse-reports/{id}/followups
### Request
multipart/form-data:
- `action` = "Perbaikan plafon dan penutupan titik bocor"
- `notes` = "Perbaikan selesai, area sudah dibersihkan"
- `photo1`
- `photo2`
- `photo3`
- `follow_up_by` = `7`

### Response sukses
```json
{
  "id": 801,
  "hse_report_id": 1001,
  "action": "Perbaikan plafon dan penutupan titik bocor",
  "notes": "Perbaikan selesai, area sudah dibersihkan",
  "photo1": "uploads/followups/1001/photo1.jpg",
  "photo2": "uploads/followups/1001/photo2.jpg",
  "photo3": null,
  "follow_up_by": 7
}
```

## GET /api/hse-reports/{id}/followups
### Response sukses
```json
[
  {
    "id": 801,
    "hse_report_id": 1001,
    "action": "Perbaikan plafon dan penutupan titik bocor",
    "notes": "Perbaikan selesai, area sudah dibersihkan",
    "photo1": "uploads/followups/1001/photo1.jpg",
    "photo2": "uploads/followups/1001/photo2.jpg",
    "photo3": null,
    "follow_up_by": 7
  }
]
```

---

# 7. Error Response Umum

## 401 Unauthorized
```json
{
  "message": "Unauthenticated"
}
```

## 403 Forbidden
```json
{
  "message": "Anda tidak memiliki akses ke resource ini"
}
```

## 422 Validation Error
```json
{
  "message": "Validation failed",
  "errors": {
    "notes": [
      "Field notes wajib diisi"
    ]
  }
}
```

## 500 Server Error
```json
{
  "message": "Terjadi kesalahan pada server"
}
```

---

# 8. Mapping ke Model Flutter

## Auth
- `AuthUserModel`
- `LoginResponseModel`

## Locations
- `LocationModel`

## Report list
- `HseReportListItemModel`

## Report detail
- `HseReportDetailModel`
- `HseReportPhotoDetailModel`
- `HseReportFollowupModel`

## Create report request
- `CreateHseReportRequest`

## Follow up request
- `CreateHseReportFollowupRequest`

---

# 9. Catatan untuk AI Agent
AI agent harus:
- menulis mapper dengan aman untuk field nullable seperti `photo2` dan `photo3`
- memisahkan model remote dan entity domain jika diperlukan
- tidak mengasumsikan semua endpoint memakai wrapper yang sama tanpa verifikasi backend
