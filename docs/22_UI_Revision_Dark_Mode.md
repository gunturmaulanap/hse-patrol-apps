Dokumentasi Improvisasi UI/UX (To-Be) — Transisi Modern Dark Mode
Dokumen ini mendefinisikan panduan pembaruan antarmuka (UI) dan pengalaman pengguna (UX) dari arsitektur As-Is menuju Target Architecture bertema Modern Dark Mode. Pembaruan ini berfokus pada presentation layer di Flutter tanpa mengubah state management atau business logic yang sudah berjalan (seperti createReportFormProvider dan picFollowUpFormProvider).

1) Konsep Visual Utama (Design Language)
Untuk mencapai tampilan modern dan premium, seluruh elemen UI harus mematuhi aturan berikut:

Warna Latar Utama: Hitam pekat (#000000 atau #09090B).

Warna Aksen (High Contrast): Kuning Neon (#E8FA61) sebagai CTA utama, dipadukan dengan warna pastel sekunder seperti Ungu Muda (#C5C6FA) dan Putih Tulang untuk elemen pendukung.

Bentuk Geometris (Squircle): Penggunaan border-radius ekstrem (misal: BorderRadius.circular(32)).

Elevasi & Bayangan (Shadows): Dihilangkan sepenuhnya. Desain menggunakan pendekatan flat dengan kontras warna sebagai pemisah elemen, bukan bayangan jatuh (drop shadow).

Tipografi & Ikon: Font sans-serif bersih (seperti Inter atau Plus Jakarta Sans) dan ikon line/stroke (misal: Phosphor Icons), bukan Material Icons bawaan.

2) Pembaruan Global & Navigasi
2.1 Shell & Bottom Navigation
As-Is: Menggunakan standar BottomNavigationBar.

To-Be: Diubah menjadi Floating Pill Navigation.

Implementasi: Gunakan Stack di dalam Scaffold. Konten utama di-scroll di belakang navigasi.

Bentuk: Container melayang di area bawah tengah dengan latar belakang abu-abu sangat gelap (#1C1C1E) dan radius kapsul penuh (circular(50)).

Indikator Aktif: Ikon menyala putih/kuning dengan latar belakang highlight membulat.

3) Pembaruan Flow Petugas
3.1 Layar Login (/login)
As-Is: Form card modern dengan shadow ringan.

To-Be: * Hapus card background dan shadow. Form menyatu langsung dengan latar belakang gelap.

Field input (Username, Password) menggunakan fill color abu-abu gelap (#1C1C1E) dengan border tipis tak kasat mata yang akan menyala (Kuning Neon) saat focused.

Tombol Login menggunakan warna Kuning Neon solid dengan teks hitam tebal.

3.2 Dashboard / Petugas Home (petugasHome)
As-Is: Kartu CTA besar gradien untuk "Buat Laporan Patroli".

To-Be:

Ubah CTA menjadi Hero Card menggunakan warna Kuning Neon murni tanpa gradien. Beri radius sudut 32.

Ringkasan angka harian ditampilkan dalam chips berwarna Ungu Pastel atau abu-abu gelap di bawah Hero Card.

3.3 Wizard Create Report (7 Step)
Flow tetap dipertahankan 7 langkah, namun representasi visualnya diubah:

Indikator Progres: Gunakan dashed line (garis putus-putus) di atas app bar, di mana step aktif menyala terang.

Step 1 (Building Type) & Step 3 (Risk Level): * To-Be: Ubah grid card menjadi kotak besar. Saat tidak dipilih, warnanya gelap transparan. Saat ditekan (selected), warnanya berubah solid (misal: merah muda untuk Kritis, kuning untuk Ringan).

Step 4 (Foto Temuan):

To-Be: Slot foto dirender menggunakan package dotted_border dengan stroke tebal. Setelah difoto, gambar memenuhi kotak dengan clip-radius melengkung.

4) Pembaruan Flow PIC
4.1 PIC Home & Finding (picHome, picFinding)
As-Is: Grid AreaCard dan list item standar.

To-Be:

AreaCard menggunakan kombinasi warna pastel (Ungu, Kuning, Putih) secara berselang-seling dengan teks hitam, menciptakan hierarki visual yang jelas di atas background hitam.

List laporan di tab Finding dirender sebagai card hitam flat dengan border tipis #333333. Gunakan pill-badge kecil menyala (Kuning/Merah) di sudut kanan atas untuk status Pending/Rejected.

4.2 Wizard Follow Up (3 Step)
Format visual disamakan dengan wizard Petugas. Halaman review (Step 3) menggunakan kontras warna untuk membedakan antara informasi dari Petugas (masalah) dan catatan dari PIC (tindak lanjut).

5) Pembaruan Lintas Role (Closed Loop)
5.1 Detail Laporan (reportDetail)
As-Is: Menampilkan informasi runut dengan CTA di bawah.

To-Be: * Riwayat status (Pending -> Follow Up Done -> Approved/Rejected) divisualisasikan menggunakan UI Vertical Timeline yang bersih.

Floating Action Area: Saat status memerlukan aksi (misal Petugas harus menekan Tolak Perbaikan atau Approve), letakkan tombol ini di dalam container melayang (floating box) di area bawah layar yang fixed, sehingga tombol selalu terlihat meskipun pengguna men-scroll detail laporan yang panjang.