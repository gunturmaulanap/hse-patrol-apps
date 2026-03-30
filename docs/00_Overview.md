# 00 Overview — HSE Aksamala Flutter Project

## Tujuan dokumen ini
Dokumen ini adalah panduan utama untuk membangun aplikasi Flutter **HSE Aksamala** dari nol sampai siap dipakai. Dokumen dipecah ke beberapa file bernomor agar mudah dibaca oleh:

- developer manusia
- AI agent di VS Code
- tim frontend yang ingin bekerja konsisten

Dokumen ini sudah direvisi mengikuti keputusan UI terbaru:

- tabel `locations` diganti menjadi `areas`
- **Petugas Patroli HSE** hanya memiliki 2 menu utama: `Patroli` dan `Profile`
- **PIC Tindak Lanjut** memiliki 3 menu utama: `Home`, `Finding`, dan `Profile`
- Petugas **tidak bisa** menambahkan area baru dari aplikasi mobile
- PIC `Home` menampilkan card area berdasarkan hak akses master
- PIC `Finding` menampilkan daftar report dan action icon
- status report mendukung review lanjutan dari Petugas terhadap follow up PIC

## Prinsip utama proyek
1. **Simple but clean**
   - jangan over-engineering
   - tetap pakai struktur folder yang rapi
2. **Feature-first architecture**
   - folder dibagi berdasarkan fitur, bukan berdasarkan file type global semata
3. **AI-friendly documentation**
   - semua keputusan teknis dijelaskan singkat dan tegas
   - setiap file punya tujuan jelas
4. **Production mindset**
   - state jelas
   - error handling jelas
   - API contract jelas
   - komponen reusable
5. **Modern UI**
   - Material 3
   - spacing lega
   - kartu modern
   - bottom navigation jelas
   - interaksi mudah untuk user lapangan

## Hasil akhir yang diharapkan
Aplikasi Flutter harus memiliki modul berikut:

- authentication
- splash dan session check
- permission camera
- menu Petugas: patrol history dan profile
- menu PIC: home, finding, profile
- create report step by step untuk Petugas
- detail report Petugas
- detail report PIC
- follow up PIC step by step
- review follow up oleh Petugas (`approved` / `rejected`)
- API integration ke backend Laravel
- state management yang stabil

## Struktur dokumen
- `00_Overview.md` → gambaran umum proyek
- `01_Product_Context.md` → tujuan bisnis, role, flow aplikasi
- `02_Tech_Stack_and_Packages.md` → stack Flutter dan package yang dipakai
- `03_Folder_Architecture.md` → struktur folder final
- `04_Project_Setup_Step_by_Step.md` → langkah setup project dari nol
- `05_Coding_Standards_and_Conventions.md` → aturan coding dan naming
- `06_State_Management_and_App_Flow.md` → state management, navigation, session flow
- `07_Feature_Specification.md` → rincian fitur per modul
- `08_API_Integration_Guide.md` → pola integrasi backend Laravel
- `09_UI_UX_Design_System.md` → panduan UI modern dan user friendly
- `10_AI_Agent_Working_Guide.md` → aturan kerja AI agent di VS Code
- `11_Implementation_Roadmap.md` → urutan pengerjaan dari awal sampai akhir
- `12_Quality_Checklist_and_Release.md` → checklist QA, UAT, dan release
- `13_Initial_Agent_Prompts.md` → prompt siap pakai untuk AI agent
- `14_API_Response_Examples.md` → contoh request dan response API
- `15_First_Sprint_Task_List.md` → pembagian task sprint awal
- `16_Modern_UI_Component_Sources.md` → referensi komponen UI modern
- `21_UI_Revision_Areas_and_Menu_Update.md` → ringkasan perubahan terbaru

## Keputusan arsitektur
Untuk proyek ini, gunakan:

- **Flutter stable**
- **Riverpod** untuk state management
- **go_router** untuk navigation
- **Dio** untuk HTTP client
- **Freezed + json_serializable** untuk model API
- **camera** untuk akses kamera langsung
- **flutter_secure_storage** untuk token login
- **Material 3** untuk design system dasar

## Rule penting
- backend adalah sumber kebenaran untuk data
- frontend wajib mengikuti endpoint dan struktur tabel final
- flow create report dan follow up harus step-by-step
- foto wajib menggunakan kamera, bukan gallery
- upload mendukung maksimal **3 foto** untuk laporan awal dan follow up
- menu utama harus mengikuti role user
- data area untuk PIC wajib berasal dari akses master backend
