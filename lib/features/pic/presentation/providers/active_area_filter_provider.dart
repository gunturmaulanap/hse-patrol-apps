import 'package:flutter_riverpod/flutter_riverpod.dart';

// Menyimpan nama Area yang dipilih PIC dari Home Screen.
// Null berarti melihat semua temuan dari semua area yang menjadi otorisasi PIC.
final activeAreaFilterProvider = StateProvider<String?>((ref) => null);
