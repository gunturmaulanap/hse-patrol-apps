# Panduan Penggunaan Notifikasi

Aplikasi ini menyediakan **2 Opsi Notifikasi** yang bisa digunakan:

## **OPSI 1: AppSnackBar (Improved)**

SnackBar bawaan Flutter yang sudah diperbaiki agar **auto-dismiss**.

### **Kelebihan:**
- ✅ Mudah digunakan
- ✅ Tetap di posisi bawah layar
- ✅ Auto-dismiss (tanpa tombol ✕)
- ✅ Tetap bisa menampilkan tombol action jika perlu

### **Cara Penggunaan:**

```dart
import '../../core/widgets/app_snackbar.dart';

// 1. Success message (Auto-dismiss)
AppSnackBar.success(context, message: 'Laporan berhasil disimpan!');

// 2. Error message (Auto-dismiss)
AppSnackBar.error(context, message: 'Gagal mengirim data');

// 3. Warning message (Auto-dismiss)
AppSnackBar.warning(context, message: 'Harap lengkapi semua field');

// 4. Info message (Auto-dismiss)
AppSnackBar.info(context, message: 'Data sedang diproses');

// 5. Dengan tombol action (jika user perlu dismiss manual)
AppSnackBar.success(
  context,
  message: 'Data berhasil disimpan',
  showAction: true, // Tampilkan tombol ✕
);
```

---

## **OPSI 2: AppToast (Recommended - Modern)**

Toast notification modern dengan **animasi smooth** dan muncul dari atas layar.

### **Kelebihan:**
- ✅ Lebih modern dan elegan
- ✅ Animasi slide + fade yang smooth
- ✅ Muncul di atas layar (tidak menutupi konten penting)
- ✅ Auto-dismiss tanpa user intervention
- ✅ Icon visual yang jelas
- ✅ Tidak ada tombol action (lebih clean)

### **Cara Penggunaan:**

```dart
import '../../core/widgets/app_toast.dart';

// 1. Success message
AppToast.success(context, message: 'Laporan berhasil disimpan!');

// 2. Error message
AppToast.error(context, message: 'Gagal mengirim data');

// 3. Warning message
AppToast.warning(context, message: 'Harap lengkapi semua field');

// 4. Info message
AppToast.info(context, message: 'Data sedang diproses');

// 5. Custom duration (default 2.5 detik)
AppToast.success(
  context,
  message: 'Operasi berhasil',
  duration: Duration(milliseconds: 1500), // Lebih cepat
);
```

---

## **Perbandingan:**

| Feature | AppSnackBar | AppToast |
|---------|-------------|----------|
| **Posisi** | Bawah layar | Atas layar |
| **Animasi** | Fade sederhana | Slide + Fade smooth |
| **Tampilan** | Flat | Modern dengan icon |
| **Auto-dismiss** | ✅ Yes (default) | ✅ Always |
| **User Action** | Optional ❌ | No |
| **Modern** | Standard | ✅ Very Modern |
| **Use Case** | Feedback umum | Feedback setelah action |

---

## **Rekomendasi Penggunaan:**

### **Gunakan AppSnackBar untuk:**
- Feedback umum yang simple
- Pesan yang butuh tombol action
- Validasi form
- Informasi yang tidak terlalu penting

### **Gunakan AppToast untuk:**
- Feedback setelah action (Save, Delete, Update)
- Notifikasi success/error penting
- Pesan yang perlu lebih menonjol
- Tampilan yang lebih modern dan professional

---

## **Contoh Implementasi di Action:**

### **Contoh 1: Setelah Submit Form**

```dart
void _submitForm() async {
  try {
    await _apiService.submitData(data);

    // Opsi 1: AppToast (Recommended)
    AppToast.success(context, message: 'Data berhasil disimpan!');

    // Opsi 2: AppSnackBar
    // AppSnackBar.success(context, message: 'Data berhasil disimpan!');

    context.pop();
  } catch (e) {
    AppToast.error(context, message: 'Gagal menyimpan: ${e.toString()}');
  }
}
```

### **Contoh 2: Setelah Delete**

```dart
void _deleteItem(int id) async {
  try {
    await _apiService.deleteItem(id);
    AppToast.success(context, message: 'Item berhasil dihapus');
    ref.invalidate(itemsProvider);
  } catch (e) {
    AppToast.error(context, message: 'Gagal menghapus item');
  }
}
```

### **Contoh 3: Validasi Form**

```dart
void _validateAndSubmit() {
  if (_formKey.currentState!.validate()) {
    _submitForm();
  } else {
    AppToast.warning(context, message: 'Harap lengkapi semua field yang wajib');
  }
}
```

---

## **Durasi yang Disarankan:**

- **Success**: 2000-2500ms (2-2.5 detik)
- **Error**: 3000-4000ms (3-4 detik) - user butuh waktu baca
- **Warning**: 2500-3000ms (2.5-3 detik)
- **Info**: 2000ms (2 detik)

---

## **Tips:**

1. **Jangan terlalu sering** - Gunakan hanya untuk feedback penting
2. **Pesan singkat & jelas** - Maksimal 2-3 baris
3. **Tepat dengan konteks** - Success gunakan hijau, Error gunakan merah
4. **Consistent** - Gunakan tipe notifikasi yang sama untuk kasus serupa

---

## **Migration dari SnackBar ke Toast:**

Cukup replace import dan method call:

```dart
// SEBELUM
import '../../core/widgets/app_snackbar.dart';
AppSnackBar.success(context, message: 'Success!');

// SESUDAH
import '../../core/widgets/app_toast.dart';
AppToast.success(context, message: 'Success!');
```

Sangat mudah! 🎉
