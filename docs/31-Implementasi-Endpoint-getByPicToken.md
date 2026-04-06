# 31. Implementasi & Perbaikan Endpoint `getByPicToken` & Deep Link

Dokumen ini ditujukan untuk **Tim Backend (Laravel & Infra)** guna menyelesaikan masalah Deep Link WhatsApp yang tidak otomatis membuka aplikasi dan me-return `404 Not Found`.

---

## 1. Mengapa Link WA Tidak Langsung Redirect ke App & Menuju 404?

### Kasus Sebelumnya (Menampilkan JSON)
Pada versi sebelumnya, Deep Link WhatsApp mengarah langsung ke **Endpoint API Laravel**, contohnya:
`https://mes.aksamala.co.id/api/hse/reports/pic/EHpiDPQhcfwekAIykNOZ`

Ketika link ini diklik, browser akan memanggil API tersebut, dan sewajarnya Laravel merespon dengan data JSON:
```json
{
  "status": "success",
  "message": "PIC token valid",
  "redirect_to": "https://mes.aksamala.co.id/api/hse-reports/24"
}
```

### Kasus Sekarang (Menampilkan 404 Not Found)
Berdasarkan standar implementasi keamanan Universal Links (iOS) dan App Links (Android), Deep Link **tidak boleh** mengarah langsung ke Endpoint API. Link URL yang dibagikan ke WhatsApp kini diseragamkan menjadi Front-End routing:
`https://mes.aksamala.co.id/share/report/EHpiDPQhcfwekAIykNOZ`

Karena perubahan struktur URL pelaporan menjadi _client-side router_ (`/share/report/`), muncul **dua kendala**:
1. **Tidak Redirect ke App:** Android butuh file `assetlinks.json` di server untuk secara paksa membuka aplikasi tanpa membuka Chrome. Karena ini tahap Testing (menggunakan Debug Keystore), Android akan membuka Chrome.
2. **Website Error 404:** Ketika Chrome dipaksa membuka URL `https://mes.aksamala.co.id/share/report/EHpiDPQ...`, Nginx / Laravel mencari *folder* statis tersebut secara fisik. Karena foldernya tidak ada (dan Nginx belum dipasang SPA Fallback), Nginx mereturn halaman HTML **404 Not Found**. Ini bukan dari Flutter, tapi murni *Response 404 Server Nginx*.

---

## 2. Instruksi Perbaikan Untuk Tim Backend

Untuk menuntaskan fitur ini dan membuatnya _Production-Ready_, Tim Backend harus melakukan 3 hal berikut:

### A. Implementasi SPA Fallback di Server Web (Nginx)
Aplikasi Flutter Web (yang di-_compile_ di root web) menggunakan arsitektur _Single Page Application (SPA)_. Maka Server (Nginx) harus mengembalikan `index.html` setiap kali user mengakses struktur URL apapun, bukannya me-return HTML bawaan 404 Not Found.

* **Aksi:** Konfigurasi Nginx conf (di block `mes.aksamala.co.id` yang menjadi _static host_ website).
* **Kode Tambahan Nginx:**
  ```nginx
  location / {
      try_files $uri $uri/ /index.html;
  }
  ```
*Dengan ini, pelacakan link URL seperti `/share/report/:token` akan memuat tampilan visual Flutter Web yang otomatis membuka dialog App Link.*

### B. Mendaftarkan `assetlinks.json`
Agar HP Android tidak mem-bypass Aplikasi dan langsung membuka website (yang sering dikomplain karena buka browser), server root `mes.aksamala.co.id` harus memuat file relasi.

* **Aksi:** Upload file berikut di dalam folder `public/.well-known/assetlinks.json` (Laravel public):
  ```json
  [
    {
      "relation": ["delegate_permission/common.handle_all_urls"],
      "target": {
        "namespace": "android_app",
        "package_name": "com.example.hse_aksamala", 
        "sha256_cert_fingerprints": [
          "MASUKKAN_SHA256_RELEASE_KEY_DISINI",
          "MASUKKAN_SHA256_DEBUG_KEY_DISINI_JIKA_DIPERLUKAN_TESTING"
        ]
      }
    }
  ]
  ```

### C. Pembuatan Endpoint Khusus Validasi PIC Token di API
Saat aplikasi Flutter berhasil dibuka dari tautan Deep Link, Flutter membutuhkan data lengkap Laporan untuk ditampilkannya di layar utama. Flutter mencoba memanggil API Endpoint:
`GET /api/hse-reports/pic/{pic_token}`

(Sebelumnya di backend, Laravel menggunakan endpoint URL `/api/hse/reports/pic/{pic_token}` dengan pemandu JSON *redirect_to*. Perbedaan rute inilah yang menyebabkan API menolak request frontend sekarang dengan status `404`).

* **Aksi:** Buat atau sesuaikan rute pada `routes/api.php` Laravel agar cocok dengan panggilan path Front-End:
  ```php
  Route::get('hse-reports/pic/{pic_token}', [HseReportController::class, 'getByPicToken']);
  ```
* **Contoh Logic Controller Response:**
  Metode ini WAJIB langsung memulangkan / me-return format response data **yang sama persis strukturnya** seperti dipanggil melalui Endpoint API ID Report (`/api/hse-reports/{id}`). Tidak boleh hanya mereturn json _redirect_to_ layaknya versi lalu.
  ```php
  public function getByPicToken($pic_token) {
      $report = HseReport::with(['user', 'area', 'followUps'])
                ->where('pic_token', $pic_token)
                ->first();
      
      if (!$report) {
          return response()->json([
              'message' => 'Token laporan tidak valid atau sudah kedaluwarsa.',
              'token_valid' => false
          ], 404);
      }

      return response()->json([
          'token_valid' => true,
          'authorized' => true,
          'data' => $report // Wajib melampirkan seluruh object JSON report
      ], 200);
  }
  ```

---

Dengan ketiga hal ini diimplementasikan serentak di sisi Server / Backend:
1. Klik Link WA ✅ -> OS Android tidak akan singgah ke Chrome tapi langsung memunculkan Aplikasi (Berkat _assetlinks.json_).
2. Jika tidak terinstall aplikasi dan terlempar ke Website ✅ -> Memuat Web Flutter dengan normal tanpa pesan nginx 404 (Berkat _Nginx Fallback_).
3. Di dalam Aplikasi ✅ -> Data Report dikonversi sukses melalui token (Berkat tambahan _Endpoint GET_ di Laravel API).
