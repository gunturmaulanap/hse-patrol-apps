# 01 Auth

## Ringkasan

Bagian ini menjelaskan endpoint autentikasi untuk login, logout, dan pengambilan data user yang sedang aktif.

---

## 1. Login

### Endpoint

```http
POST /login
```

### Content-Type

```http
application/x-www-form-urlencoded
```

### Body Parameters

| Field | Type | Required | Keterangan |
|---|---|---:|---|
| `email` | string | Ya | Email pengguna |
| `password` | string | Ya | Password pengguna |

### Contoh Request (cURL)

```bash
curl --request POST '{{BASE_URL}}/login' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'email=user@example.com' \
  --data-urlencode 'password=your-password'
```

### Tujuan

Digunakan untuk autentikasi user dan mendapatkan token akses.

### Catatan

- Format respons token tidak tersedia pada file sumber.
- Simpan token hasil login dan gunakan sebagai Bearer Token untuk endpoint lain.

---

## 2. Logout

### Endpoint

```http
POST /logout
```

### Headers

```http
Authorization: Bearer <access_token>
```

### Contoh Request (cURL)

```bash
curl --request POST '{{BASE_URL}}/logout' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json'
```

### Tujuan

Mengakhiri sesi user yang sedang login.

---

## 3. Get Current User

### Endpoint

```http
GET /me
```

### Headers

```http
Authorization: Bearer <access_token>
```

### Contoh Request (cURL)

```bash
curl --request GET '{{BASE_URL}}/me' \
  --header 'Authorization: Bearer {{TOKEN}}' \
  --header 'Accept: application/json'
```

### Tujuan

Mengambil informasi profil user yang sedang terautentikasi.

---

## Contoh alur auth

### 1) Login

```text
POST /login
```

### 2) Simpan token

```text
access_token = <token hasil login>
```

### 3) Gunakan token untuk endpoint lain

```http
Authorization: Bearer <access_token>
```

### 4) Logout saat sesi selesai

```text
POST /logout
```

---

## Rekomendasi untuk AI agent

Saat AI agent menggunakan API ini:

1. lakukan login terlebih dahulu,
2. simpan token secara aman di memory/session,
3. tambahkan token ke semua request yang membutuhkan autentikasi,
4. tangani kasus token expired dengan melakukan login ulang,
5. hindari menyimpan kredensial hard-coded di prompt atau source code.
