import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ShareHelper {
  /// Bagikan File Lokal (Digunakan di Halaman Create Report / Draft)
  static Future<void> shareLocalImage({
    required String imagePath,
    required String caption,
  }) async {
    try {
      final xFile = XFile(imagePath);
      // Membagikan file fisik dengan teks sebagai caption
      await Share.shareXFiles([xFile], text: caption);
    } catch (e) {
      debugPrint('Gagal share gambar lokal: $e');
    }
  }

  /// Bagikan URL Gambar dari Backend (Digunakan di Halaman Detail Report)
  static Future<void> shareNetworkImage({
    required BuildContext context,
    required String imageUrl,
    required String caption,
  }) async {
    try {
      // Tampilkan indikator loading (opsional tapi disarankan karena butuh waktu download)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // 1. Download gambar dari server
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      // 2. Buat file sementara di memori HP
      final tempDir = await getTemporaryDirectory();
      // Gunakan timestamp agar nama file unik jika share berkali-kali
      final fileName = 'laporan_hse_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File('${tempDir.path}/$fileName').create();
      
      // 3. Tulis byte gambar ke file lokal
      await file.writeAsBytes(bytes);

      // Tutup indikator loading
      if (context.mounted) Navigator.pop(context);

      // 4. Share gambar yang sudah diunduh + Caption
      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: caption);

    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Tutup loading jika error
      debugPrint('Gagal share gambar network: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyiapkan gambar untuk dibagikan.')),
        );
      }
    }
  }
}