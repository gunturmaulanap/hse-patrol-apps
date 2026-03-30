# 05 Coding Standards and Conventions

## Tujuan
Aturan ini dibuat agar developer dan AI agent menulis kode yang konsisten.

## 1. Naming convention

### File
Gunakan `snake_case`.
Contoh:
- `login_screen.dart`
- `report_card.dart`
- `app_router.dart`

### Class
Gunakan `PascalCase`.
Contoh:
- `LoginScreen`
- `ReportCard`
- `CreateReportFormState`

### Variable dan function
Gunakan `camelCase`.
Contoh:
- `isLoading`
- `submitReport()`
- `selectedBuildingType`

## 2. Satu file satu tanggung jawab
Jangan campur:
- screen
- provider
- repository
- model

Dalam satu file besar.

## 3. Screen harus ringan
Screen hanya berisi:
- layout utama
- konsumsi provider
- navigation
- trigger action sederhana

Business logic pindahkan ke:
- provider
- usecase
- repository

## 4. Widget pecah menjadi reusable parts
Jika satu screen sudah lebih dari kira-kira 200–250 baris, mulai pecah.

## 5. Jangan hardcode string berulang
String umum sebaiknya disimpan di constants jika sering dipakai.

## 6. Error handling wajib jelas
Setiap call API harus punya kemungkinan state:
- loading
- success
- empty
- error

## 7. Model API wajib typed
Jangan gunakan `Map<String, dynamic>` berlebihan di level presentation.
Gunakan model typed.

## 8. Provider naming
Contoh penamaan:
- `authProvider`
- `myReportsProvider`
- `reportDetailProvider`
- `createReportFormProvider`

## 9. State object untuk form bertahap
Untuk create report dan follow up, gunakan state object khusus.

Contoh field create report form state:
- selectedBuildingType
- selectedLocation
- isAddingNewLocation
- newLocationCode
- newLocationName
- selectedRiskLevel
- damagePhotos
- notes
- rootCause

## 10. Validasi ditempatkan konsisten
- validasi field sederhana bisa di UI
- validasi submit final juga harus diperiksa di provider/usecase

## 11. Async rules
Semua async action:
- tangani try/catch
- map error ke user-friendly message
- jangan silent failure

## 12. Navigation rules
Gunakan `go_router` secara konsisten.
Jangan campur banyak gaya navigation kecuali perlu.

## 13. Format dan lint
Sebelum commit:
```bash
dart format .
flutter analyze
```

## 14. Comment rules
Komentar hanya untuk:
- alasan keputusan penting
- logic kompleks
- TODO yang nyata

Jangan komentar yang hanya mengulang kode.

## 15. Commit style yang disarankan
Contoh:
- `feat(auth): add login flow`
- `feat(reports): add create report step 1 and 2`
- `fix(pic): handle invalid token state`
- `refactor(core): simplify app button`
