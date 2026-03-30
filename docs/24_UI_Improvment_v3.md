Fase 1: Persiapan Global (Konfigurasi Desain Sistem)
Anda harus mendefinisikan tipografi, warna, dan radius yang exact sebelum membangun widget.

Step 1: Font & Tipografi (Inter Font)
Desain ini menggunakan font sans-serif modern yang sangat bersih, kemungkinan besar Inter. Kita akan menggunakan google_fonts.

1. Buka pubspec.yaml dan tambahkan:

YAML
dependencies:
flutter:
sdk: flutter

# ...

google_fonts: ^6.1.0 # Pastikan versi terbaru
phosphor_flutter: ^2.0.0 # Untuk ikon garis modern (opsional) 2. Buka lib/app/theme/app_typography.dart (Ganti total isi file Anda):

Dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
// Gunakan Inter sebagai font dasar
static TextStyle get baseTextStyle => GoogleFonts.inter();

// Header Sapaan (Good Morning)
static TextStyle get h1 => baseTextStyle.copyWith(
fontSize: 26,
fontWeight: FontWeight.w700, // Bold
color: AppColors.textPrimary,
);

// Sub-header Sapaan (Good Morning,)
static TextStyle get h2 => baseTextStyle.copyWith(
fontSize: 18,
fontWeight: FontWeight.w300, // Light
color: AppColors.textPrimary,
);

// Judul Section (Team Productivity, Tasks)
static TextStyle get h3 => baseTextStyle.copyWith(
fontSize: 20,
fontWeight: FontWeight.w600, // Semi-Bold
color: AppColors.textPrimary,
);

// Judul Task Card
static TextStyle get body1 => baseTextStyle.copyWith(
fontSize: 16,
fontWeight: FontWeight.w500, // Medium
color: AppColors.textPrimary,
);

// Teks Sekunder (Caption, Time)
static TextStyle get caption => baseTextStyle.copyWith(
fontSize: 14,
fontWeight: FontWeight.w400, // Regular
color: AppColors.textSecondary,
);

// Teks Terbalik (Di atas warna kuning/ungu)
static TextStyle get body1Inverted => body1.copyWith(color: AppColors.textInverted);
static TextStyle get h3Inverted => h3.copyWith(color: AppColors.textInverted);
}
Step 2: Palet Warna (Pixel-Perfect)
Ubah palet warna Anda agar selaras dengan desain target.

Buka lib/app/theme/app_colors.dart (Ubah Variabel Ini):

Dart
import 'package:flutter/material.dart';

class AppColors {
// Latar belakang harus hitam pekat
static const Color background = Color(0xFF000000);

// Warna kartu/surface harus abu-abu gelap, jangan hitam agar kontras
static const Color surface = Color(0xFF1C1C1E);
static const Color surfaceLight = Color(0xFF2C2C2E);

// Warna Aksen High-Contrast (KUNCI UI MODERN)
static const Color primary = Color(0xFFE8FA61); // Kuning Neon (Untuk Tombol +)
static const Color secondary = Color(0xFFC5C6FA); // Ungu Pastel (Untuk Card Recap)

// Text Colors
static const Color textPrimary = Color(0xFFFFFFFF);
static const Color textSecondary = Color(0xFFA0A0A5); // Teks abu-abu terang
static const Color textInverted = Color(0xFF000000); // Teks hitam di atas warna kuning/ungu
}
Step 3: Border Radius (High Radius)
Ubah nilai radius sudut agar ekstrem bulat.

Buka lib/app/theme/app_radius.dart (Atur Radius Sudut):

Dart
class AppRadius {
static const double large = 32.0; // Untuk Card di Homepage & Recap
static const double pill = 999.0; // Untuk Floating Bottom Nav & Tombol
}
Fase 2: Implementasi Layout Presisi
Sekarang kita akan merombak total hierarki widget.

Step 4: Homepage Presisi (Cloning Layar Utama)
Kita akan membangun homepage persis seperti gambar target, tanpa bayangan (no shadows), menggunakan CustomScrollView untuk header yang smooth.

Buka lib/features/reports/presentation/screens/petugas_home_screen.dart (Ganti Total Build Method Anda):
(Hapus Scaffold.appBar lama, dan bangun struktur sliver di bawah ini)

Dart
import 'package:flutter/material.dart';
// Gunakan phosphor_flutter untuk ikon garis modern yang persis
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';

class PetugasHomeScreen extends StatefulWidget {
const PetugasHomeScreen({super.key});

@override
State<PetugasHomeScreen> createState() => \_PetugasHomeScreenState();
}

class \_PetugasHomeScreenState extends State<PetugasHomeScreen> {
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,
body: CustomScrollView(
slivers: [
// ==============================
// 1. PRESISI HEADER (Sapaan & Avatar)
// ==============================
SliverAppBar(
backgroundColor: AppColors.background,
expandedHeight: 80,
floating: true,
pinned: false,
elevation: 0,
leading: null,
automaticallyImplyLeading: false,
flexibleSpace: FlexibleSpaceBar(
titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
centerTitle: false,
title: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
// Sapaan dan Nama (Tisha)
Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisAlignment: MainAxisAlignment.end,
children: [
Text(
"Good Morning,",
style: AppTypography.h2.copyWith(color: AppColors.textSecondary),
),
Text(
"Tisha", // Ambil dari UserModel Anda
style: AppTypography.h1,
),
],
),
// Avatar Profil (Bisa ditekan)
GestureDetector(
onTap: () {
// Navigasi ke halaman profile Anda
context.push('/profile');
},
child: const CircleAvatar(
radius: 25,
backgroundColor: AppColors.surfaceLight,
child: Icon(PhosphorIcons.userBold(), color: Colors.white),
),
)
],
),
),
),

          // ==============================
          // 2. PRESISI KONTEN UTAMA
          // ==============================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2.1 TEAM PRODUCTIVITY CARD (Klon Ungu Besar)
                  _buildTeamProductivityCard(),

                  const SizedBox(height: 32),

                  // 2.2 TASKS SECTION HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tasks",
                        style: AppTypography.h3,
                      ),
                      Row(
                        children: [
                          Text(
                            "View All",
                            style: AppTypography.caption,
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 2.3 TASKS LIST (Klon Card Tanpa Shadow)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Tampilkan data mock laporan patroli terakhir
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: _buildTaskCard(index),
                );
              },
              childCount: 3, // Data mock dari 3 laporan terakhir
            ),
          ),

          // Beri padding bawah agar konten tidak tertutup bottom nav melayang
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );

}

// ==============================
// PRESISI WIDGET HELPERS
// ==============================

// Widget untuk Card Productivity (Klon Ungu Pastel besar)
Widget \_buildTeamProductivityCard() {
return Container(
width: double.infinity,
decoration: BoxDecoration(
color: AppColors.secondary, // Ungu Pastel solid
borderRadius: BorderRadius.circular(AppRadius.large), // Radius sangat bulat
),
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Team Productivity",
style: AppTypography.h3Inverted,
),
const SizedBox(height: 16),
// Visualisasi Tanggal (Sederhanakan grid kotak dari gambar)
Text(
"April",
style: AppTypography.caption.copyWith(color: AppColors.textInverted),
),
const SizedBox(height: 12),
// Grid Kalender
Wrap(
spacing: 12,
runSpacing: 12,
children: List.generate(10, (index) => _buildDateBox(index)),
)
],
),
);
}

// Helper Widget kotak tanggal kecil di dalam Card Recap
Widget \_buildDateBox(int index) {
bool isCompleted = index % 3 == 0; // Mock data
return Container(
height: 25,
width: 25,
decoration: BoxDecoration(
// Kotak yang selesai menyala Kuning Neon
color: isCompleted ? AppColors.primary : AppColors.surface.withOpacity(0.3),
borderRadius: BorderRadius.circular(8),
),
);
}

// Widget untuk Kartu Tugas (List Item - Klon flat tanpa shadow)
Widget \_buildTaskCard(int index) {
// Tentukan warna ikon dan teks berdasarkan status mock
Color iconBackgroundColor = index == 0 ? AppColors.primary : AppColors.background;
Color iconColor = index == 0 ? AppColors.textInverted : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, // Abu-abu gelap flat
        borderRadius: BorderRadius.circular(AppRadius.large),
        // PENTING: Jangan gunakan bayangan (shadow)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(PhosphorIcons.shieldCheck(), color: iconColor, size: 28),
        ),
        title: Text("Area Produksi B", style: AppTypography.body1),
        subtitle: Text("Status: Follow Up Done", style: AppTypography.caption),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: () {
          // Navigasi ke detail laporan untuk Approve/Reject
          context.push('/report-detail/$index');
        },
      ),
    );

}
}
Step 5: Floating Bottom Menu (Klon Navigasi Kapsul)
Ubah total struktur shell Anda agar Nav Bar mengambang dengan tombol + yang menonjol.

Buka lib/features/shell/presentation/screens/petugas_shell_screen.dart (Ganti Build Method Anda):

Dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';

@override
Widget build(BuildContext context) {
// Kita asumsikan Anda menggunakan StatefulNavigationShell dari go_router
// atau IndexedStack standar.

return Scaffold(
backgroundColor: AppColors.background,
// PENTING: Jangan gunakan properti bottomNavigationBar: Scaffold

    body: Stack(
      children: [
        // 1. KONTEN UTAMA (Tab yang aktif)
        Positioned.fill(
          child: widget.navigationShell, // Atau widget halaman Anda
        ),

        // 2. KUSTOM FLOATING BOTTOM MENU (Bentuk Kapsul Melayang - Klon Presisi)
        Positioned(
          bottom: 24, // Jarak dari bawah layar
          left: 32,   // Margin kiri
          right: 32,  // Margin kanan
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surface, // Abu-abu gelap
              borderRadius: BorderRadius.circular(AppRadius.pill),
              // PENTING: Tanpa Shadow/Elevation untuk gaya modern flat
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // TAB HOME (Kiri)
                _buildNavItem(
                  icon: PhosphorIcons.house(), // Ganti ke ikon line modern
                  isActive: widget.navigationShell.currentIndex == 0,
                  onTap: () => widget.navigationShell.goBranch(0),
                ),

                // TOMBOL TENGAH + (MENONJOL & KUNING NEON)
                GestureDetector(
                  onTap: () {
                    // LANGSUNG MENUJU HALAMAN STEP WIZARD
                    // Sesuaikan route name dengan go_router Anda
                    context.push('/create-report');
                  },
                  child: Container(
                    height: 55,
                    width: 75,
                    decoration: BoxDecoration(
                      color: AppColors.primary, // Kuning Neon
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Icon(
                      Icons.add, // Ikon + standar tidak apa-apa
                      color: AppColors.textInverted, // Ikon hitam
                      size: 30,
                    ),
                  ),
                ),

                // TAB KALENDER (Kanan - Menggantikan Profile)
                _buildNavItem(
                  icon: PhosphorIcons.calendarBlank(), // Ikon Kalender
                  isActive: widget.navigationShell.currentIndex == 1,
                  // Tentukan branch kalender Anda di router
                  onTap: () => widget.navigationShell.goBranch(1),
                ),
              ],
            ),
          ),
        ),
      ],
    ),

);
}

// Helper Widget untuk Nav Item (Klon Presisi)
Widget \_buildNavItem({required IconData icon, required bool isActive, required VoidCallback onTap}) {
return GestureDetector(
onTap: onTap,
child: Container(
padding: const EdgeInsets.all(12),
child: Icon(
icon,
// Warna ikon menyala putih jika aktif, abu-abu jika tidak
color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
size: 28,
),
),
);
}
