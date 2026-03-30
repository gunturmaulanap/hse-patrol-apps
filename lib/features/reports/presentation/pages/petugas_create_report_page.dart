import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/app_text_field.dart';

class PetugasCreateReportPage extends StatefulWidget {
  const PetugasCreateReportPage({super.key});

  @override
  State<PetugasCreateReportPage> createState() => _PetugasCreateReportPageState();
}

class _PetugasCreateReportPageState extends State<PetugasCreateReportPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data States
  String? _buildingType;
  String? _areaName;
  String? _riskLevel;
  final _notesController = TextEditingController();
  final _rootCauseController = TextEditingController();

  String get _formalTitle => 'Inspeksi ${_areaName ?? '-'} - Masalah: ${_rootCauseController.text.isNotEmpty ? _rootCauseController.text : '-'}';

  void _nextStep() {
    if (_currentStep < 6) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _submit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Submit Sukses')]),
        content: const Text('Laporan Inspeksi Anda berhasil divalidasi dan tersimpan di database. Apakah Anda ingin meneruskan laporan (Share) ke PIC via WhatsApp?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // exit report wizard
            },
            child: const Text('TUTUP SAJA', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final msg = 'Laporan Baru: $_formalTitle\nBgn $_buildingType.\nNotes: ${_notesController.text}';
              final url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(msg)}');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
              if (context.mounted) {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // exit report wizard
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, elevation: 0),
            icon: const Icon(Icons.share),
            label: const Text('Buka WhatsApp'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Inspeksi - Step ${_currentStep + 1}/7', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Batalkan Laporan?'),
              content: const Text('PERINGATAN: Laporan bersifat Realtime Mandatory. Jika Anda memaksa keluar, TIDAK ADA DRAFT yang disimpan. Anda harus mengulang dari nol.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('TIDAK')),
                TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('YA, BATALKAN', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          GFProgressBar(
            percentage: (_currentStep + 1) / 7,
            lineHeight: 6,
            radius: 0,
            backgroundColor: Colors.grey.shade200,
            progressBarColor: Colors.teal.shade600,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              onPageChanged: (idx) => setState(() => _currentStep = idx),
              children: [
                _buildStep1Building(),
                _buildStep2Area(),
                _buildStep3Risk(),
                _buildStep4Photos(),
                _buildStep5Notes(),
                _buildStep6RootCause(),
                _buildStep7Review(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Building() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('1. Tipe Bangunan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          _buildSelectionCard('ATAS', Icons.arrow_upward, () { setState(() => _buildingType = 'Atas'); _nextStep(); }),
          const SizedBox(height: 20),
          _buildSelectionCard('BAWAH', Icons.arrow_downward, () { setState(() => _buildingType = 'Bawah'); _nextStep(); }),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(String title, IconData icon, VoidCallback onTap) {
    return GFCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 32),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.teal.shade700),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.teal.shade900)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Area() {
    return _buildFormStep(
      '2. Lokasi (Area Master)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('Cari/Pilih Area...'),
                value: _areaName,
                isExpanded: true,
                items: ['Gudang Utama', 'Area Produksi A', 'Kantor Administrasi'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _areaName = val),
              ),
            ),
          ),
        ],
      ),
      isValid: _areaName != null,
    );
  }

  Widget _buildStep3Risk() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('3. Tingkat Risiko', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(child: _buildRiskCard('1', 'Kritis', GFColors.DANGER, 'Merah')),
              const SizedBox(width: 16),
              Expanded(child: _buildRiskCard('2', 'Berat', GFColors.WARNING, 'Kuning')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildRiskCard('3', 'Sedang', GFColors.SUCCESS, 'Hijau')),
              const SizedBox(width: 16),
              Expanded(child: _buildRiskCard('4', 'Aman', GFColors.INFO, 'Biru')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(String level, String label, Color color, String val) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: () { setState(() => _riskLevel = val); _nextStep(); },
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(level, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep4Photos() {
    return _buildFormStep(
      '4. Bukti Foto (Kamera)',
      Row(
        children: [
          Expanded(child: _buildPhotoSlot('Foto Wajib*')),
          const SizedBox(width: 12),
          Expanded(child: _buildPhotoSlot('Opsi 2')),
          const SizedBox(width: 12),
          Expanded(child: _buildPhotoSlot('Opsi 3')),
        ],
      ),
      isValid: true, // For mock testing purposes
    );
  }

  Widget _buildPhotoSlot(String label) {
    return AspectRatio(
      aspectRatio: 3/4,
      child: Container(
        decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.teal.shade200, style: BorderStyle.solid)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.teal.shade400, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5Notes() {
    return _buildFormStep(
      '5. Keterangan Detail',
      TextFormField(
        controller: _notesController,
        maxLines: 8,
        onChanged: (v) => setState(() {}),
        decoration: InputDecoration(hintText: 'Jelaskan kerusakan...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
      ),
      isValid: _notesController.text.isNotEmpty,
    );
  }

  Widget _buildStep6RootCause() {
    return _buildFormStep(
      '6. Analisis Akar Masalah',
      TextFormField(
        controller: _rootCauseController,
        maxLines: 6,
        onChanged: (v) => setState(() {}),
        decoration: InputDecoration(hintText: 'Prediksi mengapa ini bisa terjadi...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
      ),
      isValid: _rootCauseController.text.isNotEmpty,
      nextLabel: 'REVIEW FINAL',
    );
  }

  Widget _buildStep7Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('7. Status Realtime: Review', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildReviewItem('Nama Laporan (Auto)', _formalTitle, Icons.smart_button),
          _buildReviewItem('Bangunan', _buildingType ?? '-', Icons.domain),
          _buildReviewItem('Area Location', _areaName ?? '-', Icons.location_on),
          _buildReviewItem('Tingkat Risiko', _riskLevel ?? '-', Icons.warning),
          _buildReviewItem('Keterangan', _notesController.text, Icons.notes),
          _buildReviewItem('Akar Masalah', _rootCauseController.text, Icons.lightbulb_outline),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: GFButton(onPressed: () => _pageController.jumpToPage(0), text: 'EDIT ULANG', type: GFButtonType.outline, color: GFColors.DARK, size: GFSize.LARGE, shape: GFButtonShape.pills)),
              const SizedBox(width: 16),
              Expanded(child: GFButton(onPressed: _submit, text: 'SUBMIT', color: GFColors.SUCCESS, size: GFSize.LARGE, shape: GFButtonShape.pills)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReviewItem(String title, String val, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormStep(String title, Widget body, {required bool isValid, String nextLabel = 'LANJUTKAN'}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(child: body),
          Row(
            children: [
              Expanded(child: GFButton(onPressed: _prevStep, text: 'KEMBALI', type: GFButtonType.outline, color: GFColors.DARK, size: GFSize.LARGE, shape: GFButtonShape.pills)),
              const SizedBox(width: 16),
              Expanded(child: GFButton(onPressed: isValid ? _nextStep : null, text: nextLabel, color: GFColors.PRIMARY, size: GFSize.LARGE, shape: GFButtonShape.pills)),
            ],
          )
        ],
      ),
    );
  }
}
