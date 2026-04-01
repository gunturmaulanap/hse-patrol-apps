# 02 Report

## Ringkasan

Bagian ini mencakup endpoint yang berhubungan dengan:

- pembuatan report HSE,
- update atau cancel report,
- pengambilan daftar dan detail report,
- pengambilan data area,
- follow-up report.

---

## 1. Create Report

### Endpoint

```http
POST /hse-reports
```

### Content-Type

```http
multipart/form-data
```

### Body Parameters

| Field | Type | Required | Keterangan |
|---|---|---:|---|
| `area_id` | integer | Ya | ID area |
| `risk_level` | integer | Ya | Level risiko |
| `root_cause` | string | Ya | Penyebab utama |
| `notes` | string | Ya | Catatan tambahan |
| `photos[0..n]` | file[] | Tidak | Lampiran foto |

### Contoh Request (cURL)

```bash
curl --request POST '{{BASE_URL}}/hse-reports' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json' \
  --form 'area_id=13' \
  --form 'risk_level=2' \
  --form 'root_cause=lantai kotor' \
  --form 'notes=tolong dibersihkan' \
  --form 'photos[0]=@/path/to/img1.png'
```

---

## 2. Update / Cancel Report

### Endpoint

```http
PUT /hse-reports/{reportId}
```

### Content-Type

```http
multipart/form-data
```

### Body Parameters

| Field | Type | Required | Keterangan |
|---|---|---:|---|
| `mode` | string | Ya | Mode aksi: `update` atau `cancel` |
| `area_id` | integer | Kondisional | Diisi saat update |
| `risk_level` | integer | Kondisional | Diisi saat update |
| `root_cause` | string | Kondisional | Diisi saat update |
| `notes` | string | Kondisional | Diisi saat update |
| `photo[0..n]` | file[] | Tidak | File foto pengganti/tambahan |

### Contoh update report

```bash
curl --request PUT '{{BASE_URL}}/hse-reports/{{REPORT_ID}}' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --form 'mode=update' \
  --form 'area_id=13' \
  --form 'risk_level=2' \
  --form 'root_cause=lantai licin' \
  --form 'notes=sudah diberi tanda peringatan'
```

### Contoh cancel report

```bash
curl --request PUT '{{BASE_URL}}/hse-reports/{{REPORT_ID}}' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --form 'mode=cancel'
```

### Catatan

- Koleksi sumber menandai endpoint ini sebagai `update/cancel report`.
- Nilai `mode` didokumentasikan dari catatan koleksi sebagai `update` atau `cancel`.

---

## 3. Get Report By ID

### Endpoint

```http
GET /hse-reports/{id}
```

### Contoh Request (cURL)

```bash
curl --request GET '{{BASE_URL}}/hse-reports/{{REPORT_ID}}' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json'
```

---

## 4. List Report

### Endpoint

```http
GET /hse-reports
```

### Query Parameters

| Field | Type | Required | Keterangan |
|---|---|---:|---|
| `area_id` | integer | Tidak | Filter berdasarkan area |
| `status` | string | Tidak | Filter status report |
| `per_page` | integer | Tidak | Jumlah item per halaman |

### Nilai status yang muncul pada koleksi

```text
pending / followupdone / reject / approved
```

### Contoh Request (cURL)

```bash
curl --request GET '{{BASE_URL}}/hse-reports?area_id=13&status=pending&per_page=10' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json'
```

### Catatan

- Nilai `status` di atas diambil dari contoh query pada koleksi dan belum tentu merupakan daftar enum final.

---

## 5. Get Areas

### Endpoint

```http
GET /areas
```

### Query Parameters

| Field | Type | Required | Keterangan |
|---|---|---:|---|
| `user_id` | integer | Tidak | Filter area berdasarkan user tertentu |

### Contoh Request (cURL)

```bash
curl --request GET '{{BASE_URL}}/areas' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json'
```

### Contoh dengan filter user

```bash
curl --request GET '{{BASE_URL}}/areas?user_id={{USER_ID}}' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json'
```

---

## 6. Area By User

### Endpoint

```http
GET /areas/by-user
```

### Tujuan

Mengambil area yang terkait dengan user yang sedang login.

### Contoh Request (cURL)

```bash
curl --request GET '{{BASE_URL}}/areas/by-user' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json'
```

---

## 7. Create Follow Up

### Endpoint

```http
POST /{reportId}/follow-ups
```

> Path ditulis sesuai koleksi sumber. Verifikasi kembali jika implementasi backend sebenarnya menggunakan prefix tambahan.

### Content-Type

```http
multipart/form-data
```

### Body Parameters

| Field | Type | Required | Keterangan |
|---|---|---:|---|
| `action` | string | Ya | Tindakan follow-up |
| `notes_pic` | string | Ya | Catatan dari PIC |
| `notes_hse` | string | Tidak | Catatan dari HSE |
| `photos[0..n]` | file[] | Tidak | Lampiran foto |

### Contoh Request (cURL)

```bash
curl --request POST '{{BASE_URL}}/{{REPORT_ID}}/follow-ups' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json' \
  --form 'action=disapu' \
  --form 'notes_pic=lantai sudah bersih' \
  --form 'notes_hse=' \
  --form 'photos[0]=@/path/to/img2.png'
```

---

## 8. Update Follow Up

### Endpoint

```http
PUT /{reportId}/follow-ups/{followupId}
```

### Content-Type

```http
multipart/form-data
```

### Body Parameters

| Field | Type | Required | Keterangan |
|---|---|---:|---|
| `mode` | string | Ya | Gunakan `update` |
| `action` | string | Tidak | Tindakan follow-up |
| `notes_pic` | string | Tidak | Catatan dari PIC |
| `photo[0..n]` | file[] | Tidak | File foto |

### Contoh Request (cURL)

```bash
curl --request PUT '{{BASE_URL}}/{{REPORT_ID}}/follow-ups/{{FOLLOWUP_ID}}' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json' \
  --form 'mode=update' \
  --form 'action=bersihkan area' \
  --form 'notes_pic=area sudah ditangani'
```

---

## 9. Get Follow Up By Report

### Endpoint

```http
GET /{reportId}/follow-ups
```

### Contoh Request (cURL)

```bash
curl --request GET '{{BASE_URL}}/{{REPORT_ID}}/follow-ups' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json'
```

---

## 10. Get Follow Up By ID

### Endpoint

```http
GET /{reportId}/follow-ups/{followupId}
```

### Contoh Request (cURL)

```bash
curl --request GET '{{BASE_URL}}/{{REPORT_ID}}/follow-ups/{{FOLLOWUP_ID}}' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json'
```

---

## 11. Approval Follow Up

### Endpoint

```http
PUT /{reportId}/follow-ups/{followupId}
```

### Content-Type

```http
application/json
```

### Body

```json
{
  "mode": "approval",
  "approval": "approved",
  "notes_hse": ""
}
```

### Field body

| Field | Type | Required | Keterangan |
|---|---|---:|---|
| `mode` | string | Ya | Gunakan `approval` |
| `approval` | string | Ya | Status approval, contoh: `approved` |
| `notes_hse` | string | Tidak | Catatan dari HSE |

### Contoh Request (cURL)

```bash
curl --request PUT '{{BASE_URL}}/{{REPORT_ID}}/follow-ups/{{FOLLOWUP_ID}}' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{
    "mode": "approval",
    "approval": "approved",
    "notes_hse": ""
  }'
```

---

## 12. Delete Follow Up

### Endpoint

```http
PUT /{reportId}/follow-ups/{followupId}
```

### Content-Type

```http
application/json
```

### Body

```json
{
  "mode": "delete"
}
```

### Contoh Request (cURL)

```bash
curl --request PUT '{{BASE_URL}}/{{REPORT_ID}}/follow-ups/{{FOLLOWUP_ID}}' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{
    "mode": "delete"
  }'
```

---

## Ringkasan mode penting

| Context | Field | Nilai |
|---|---|---|
| Update report | `mode` | `update` |
| Cancel report | `mode` | `cancel` |
| Update follow-up | `mode` | `update` |
| Approval follow-up | `mode` | `approval` |
| Delete follow-up | `mode` | `delete` |

---

## Catatan untuk AI agent

Agar AI agent lebih aman saat memakai dokumentasi ini:

1. gunakan placeholder seperti `{{BASE_URL}}`, `{{TOKEN}}`, `{{REPORT_ID}}`, dan `{{FOLLOWUP_ID}}`,
2. jangan simpan token asli di knowledge file,
3. perlakukan field file upload sebagai `multipart/form-data`,
4. validasi nilai `mode` sebelum mengirim request,
5. verifikasi path follow-up ke backend final sebelum implementasi otomatis penuh.
