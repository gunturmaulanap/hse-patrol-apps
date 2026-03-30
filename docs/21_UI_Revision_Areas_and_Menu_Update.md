# 21 UI Revision — Areas and Role Menu Update

## Ringkasan perubahan
Dokumen ini merangkum keputusan revisi terbaru agar AI agent dan developer tidak salah implementasi.

## Perubahan utama
1. `locations` diganti menjadi `areas`
2. Petugas tidak dapat input area baru dari mobile app
3. Menu Petugas hanya:
   - Patroli
   - Profile
4. Menu PIC:
   - Home
   - Finding
   - Profile
5. Home PIC berisi card area berdasarkan akses master
6. Finding PIC berisi list report dengan kolom utama:
   - name
   - status
   - action icons
7. Petugas Patrol menampilkan list report dengan:
   - name report
   - status
   - action approve/reject/detail
8. `name report` disarankan dibuat di backend dari `notes`
9. ML Kit Text Recognition **tidak dipakai** untuk mengolah text input notes menjadi name report

## Dampak implementasi
- ganti semua istilah `location` menjadi `area` pada layer Flutter
- hapus flow tambah area baru
- tambahkan role shell dengan bottom navigation berbeda
- tambahkan review follow up state oleh Petugas
- tambahkan UI home PIC berbasis card area
- tambahkan UI finding PIC berbasis list report
