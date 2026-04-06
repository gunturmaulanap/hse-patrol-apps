# 32. Detail Implementasi & Syarat Infrastruktur untuk Deeplink

Dokumen ini disusun untuk menjelaskan landasan teknis kepada **Tim Backend** dan **Tim Server/Infrastruktur** mengenai mengapa beberapa perbaikan di sisi server mutlak diperlukan agar fitur _Deep Link_ WhatsApp dapat berjalan sempurna.

---

## 1. Penjelasan: Mengapa Harus Ada Konfigurasi di Server (Nginx)?

### Kendala yang Terjadi (Website Error 404)
Saat ini, apabila tautan seperti `https://mes.aksamala.co.id/share/report/123` di-klik, web browser (Chrome/Safari) akan menampilkan **halaman HTML 404 Not Found**. Perlu ditekankan bahwa pesan 404 ini **bukan berasal dari aplikasi Flutter**, melainkan dari web server (Nginx/Apache).

### Mengapa Nginx Me-return 404?
Aplikasi Flutter Web arsitekturnya adalah **Single Page Application (SPA)**, di mana seluruh aplikasi direpresentasikan oleh satu file statis (`index.html`). 
Saat Nginx menerima _request_ menuju `.../share/report/123`, Nginx akan mencari apakah ada _folder fisik_ bernama `/share/report/123` di dalam server. Karena folder tersebut tidak ada, Nginx langsung menolaknya (404).

### Solusi Ideal (Best Practice)
Tim Server **100% wajib** menambahkan mekanisme _SPA Fallback Routing_ di dalam `nginx.conf`:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```
Aturan ini akan memerintahkan Nginx: *"Jika folder/file yang diminta tidak ada, jangan return 404, tapi kembalikan file index.html"*. Setelah `index.html` dikembalikan, Router internal Flutter Web akan menangani sisa path-nya.

### Solusi Alternatif (Jalan Pintas tanpa modifikasi Nginx)
Jika tim server menolak/kesulitan mengubah konfigurasi Nginx, aplikasi Flutter **harus** di-_downgrade_ URL router-nya menjadi **HashUrlStrategy**.
Tautan tidak lagi `.../share/report/123`, melainkan harus diawali tanda pagar:
**`https://mes.aksamala.co.id/#/share/report/123`**
Tanda pagar (Hash/Fragment) ini hanya dibaca oleh browser client-side, sehingga Nginx tidak akan pernah mencari foldernya dan hanya akan mereturn halaman utama. *(Catatan: URL yang mengandung Hash sering kali bermasalah di App Links beberapa tipe OS Android lama).*

---

## 2. Penjelasan: Mengapa Memerlukan Tambahan Endpoint API Baru?

### Kendala yang Terjadi ("Token Tidak Valid atau Kedaluwarsa")
Meskipun aplikasi Flutter sudah berhasil terbuka dari Deep Link, aplikasi **tetap gagal** memuat isi laporan dan justru mengeluarkan _Toast/Error_: "Token Tidak Valid".

Hal ini terjadi karena **Aplikasi Flutter tidak memiliki akses langsung ke Database**. Flutter harus mengecek data secara resmi melalui perantara API Laravel.

Pada blok log di Flutter, terekam error:
`Route /api/hse-reports/pic/{picToken} tidak ditemukan.`
Singkatnya, aplikasi Flutter telah memanggil API Laravel untuk meminta detail laporan dengan modal token tersebut. Namun, **karena Endpoint khusus tersebut belum di-assign atau belum dibuat di `routes/api.php`**, Laravel mengembalikan `NotFoundHttpException` (404). Flutter menganggap penolakan 404 dari Laravel ini sebagai bukti bahwa token *"sudah kedaluwarsa"*.

### Celah Kegagalan Solusi Alternatif (Mencari di List Laporan)
Sebagai jalan pintas, Developer Flutter telah mencoba memaksa mem-_bypass_ Endpoint tersebut dengan men-download senarai semua laporan di Endpoint `GET /api/hse-reports`, berharap aplikasinya bisa mencocokkan `pic_token` secara manual. 

Ironisnya metode ini juga gagal karena **Backend Laravel menyembunyikan / tidak men-select field `pic_token`** saat merespons data tabel secara kolektif (List API). Data tersebut di-_exclude_ di Backend, sehingga Frontend (Flutter) tidak mendapati referensi yang bisa di-_query_.

### Solusi Ideal (Best Practice)
1. Tim Backend membuat fungsi API tunggal (Endpoint Request Khusus):
```php
// routes/api.php
Route::get('hse-reports/pic/{pic_token}', [HseReportController::class, 'getByPicToken']);
```
2. Endpoint tersebut **wajib** me-return utuh JSON yang spesifik berisikan data relasi Report (`user, area, followUps`), persis seperti layaknya return API Detail Task. 

### Solusi Alternatif (Jalan Pintas tanpa menambah Endpoint)
Jika opsi menambah endpoint sama sekali tidak dimungkinkan, Tim Backend **wajib** mengekspos Parameter Atribut Databasenya: Sertakan kolom `pic_token` agar dirender public ketika Front-End memanggil daftar kolektif laporan (contohnya memanggil Endpoint List All). Hal ini memungkinkan Frontend melakukan pemilahan (*filtering*) token secara swadaya.
