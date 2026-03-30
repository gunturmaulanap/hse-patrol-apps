# 12 Quality Checklist and Release

## Tujuan
Checklist ini dipakai sebelum project dianggap siap dipakai internal.

## A. Functional Checklist

### Auth
- [ ] Splash check session berjalan
- [ ] Login berhasil
- [ ] Logout berhasil
- [ ] Role redirect benar

### Camera Permission
- [ ] Permission diminta dengan benar
- [ ] Jika ditolak, user mendapat instruksi jelas
- [ ] Bisa membuka settings bila perlu

### My Reports
- [ ] List report tampil
- [ ] Empty state tampil jika kosong
- [ ] Detail report tampil benar

### Create Report
- [ ] Step 1 pilih bangunan berjalan
- [ ] Step 2 pilih lokasi / tambah lokasi berjalan
- [ ] Step 3 pilih risiko berjalan
- [ ] Step 4 upload sampai 3 foto berjalan
- [ ] Step 5 notes berjalan
- [ ] Step 6 root cause berjalan
- [ ] Step 7 review berjalan
- [ ] Submit report sukses
- [ ] Setelah submit, kembali ke list report

### PIC
- [ ] Token route dapat dibuka
- [ ] Jika belum login, login lalu lanjut ke report benar
- [ ] Invalid token state tampil benar
- [ ] PIC bisa lihat detail report

### Follow Up
- [ ] Upload sampai 3 foto after berjalan
- [ ] Action wajib diisi
- [ ] Notes wajib diisi
- [ ] Submit follow up sukses
- [ ] Status report berubah sesuai backend

## B. Technical Checklist
- [ ] Folder structure sesuai dokumentasi
- [ ] Tidak ada file random di luar feature
- [ ] Riverpod dipakai konsisten
- [ ] go_router dipakai konsisten
- [ ] Dio client terpusat
- [ ] Secure storage dipakai untuk token
- [ ] Model API generated dengan build_runner
- [ ] Error mapping ada
- [ ] Loading state ada
- [ ] Empty state ada
- [ ] Success feedback ada

## C. UI Checklist
- [ ] Material 3 aktif
- [ ] Typography konsisten
- [ ] Button besar dan mudah ditekan
- [ ] Spacing lega
- [ ] Card modern
- [ ] Form tidak terasa padat
- [ ] Warna risiko disertai label teks
- [ ] Tampilan tetap jelas di device kecil

## D. Performance Checklist
- [ ] Navigasi terasa cepat
- [ ] List tidak janky
- [ ] Image preview tidak terlalu berat
- [ ] Tidak ada rebuild berlebihan yang jelas terasa

## E. QA Scenarios
1. Login Petugas HSE lalu buat report lengkap
2. Tambah lokasi baru lalu submit report
3. Pilih lokasi existing lalu submit report
4. Submit report dengan 1 foto
5. Submit report dengan 3 foto
6. Login PIC dari link token
7. Login PIC manual lalu buka task
8. Submit follow up dengan 1 foto
9. Submit follow up dengan 3 foto
10. Cek state invalid token
11. Cek network error
12. Cek unauthorized / session expired

## F. Release Rules
Sebelum release:
- pastikan base URL environment benar
- nonaktifkan debug log yang tidak perlu
- pastikan app name dan icon benar
- pastikan permission text jelas
- lakukan smoke test di device nyata

## G. Final Standard
Aplikasi dianggap siap jika:
- flow Petugas HSE lengkap
- flow PIC lengkap
- UI terasa modern dan user friendly
- folder architecture tetap rapi
- AI agent masih bisa melanjutkan project tanpa kebingungan
