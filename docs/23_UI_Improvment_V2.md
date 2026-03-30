Bagian 1: Analisis Permasalahan Kode Saat Ini
Berdasarkan struktur folder Anda (lib/features/shell, lib/features/reports/presentation/screens), saya dapat mengidentifikasi mengapa tampilannya masih standar:

File petugas_shell_screen.dart (Halaman Utama/Shell):

Analisis: Kemungkinan besar Anda menggunakan Scaffold standar dengan properti bottomNavigationBar: BottomNavigationBar(...). Ini membuat Bottom Nav Anda menempel kaku di bagian bawah layar dan tidak bisa dibuat mengambang (floating).

Masalah: Template gambar menggunakan custom widget berbentuk kapsul (pill) yang diletakkan di dalam Stack di atas konten, sehingga terlihat mengambang dan memiliki margin dari pinggir layar.

File petugas_home_screen.dart (Konten Homepage):

Analisis: Halaman ini kemungkinan menggunakan ListView atau Column standar dengan widget AppCard atau ListTile Material.

Masalah: Layout pada template gambar membutuhkan sectioning yang spesifik (Header -> Hero Card 'Recap' -> List Tugas Berjudul). Widget kartu Anda saat ini kemungkinan masih memiliki bayangan (elevation/shadow) dan sudut yang kurang membulat (border radius kecil).

File app_colors.dart & app_theme.dart:

Analisis: Anda sudah mengeset warna gelap, tetapi mungkin belum menentukan warna solid spesifik untuk High-Contrast Accent (Kuning Neon/Ungu Pastel) yang merupakan kunci estetika desain ini.

Bagian 2: Panduan Perubahan Manual (Implementasi)
Ikuti langkah-langkah ini secara runtut untuk mengubah layout.

Langkah 1: Pengaturan Desain Sistem Global (Warna & Radius)
Ubah pondasi tema Anda agar selaras dengan desain modern.

File: lib/app/theme/app_colors.dart (Ubah Variabel Ini)

Dart
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
  static const Color textSecondary = Color(0xFFA0A0A5);
  static const Color textInverted = Color(0xFF000000); // Teks di atas warna kuning/ungu
}
File: lib/app/theme/app_radius.dart (Atur Radius Sudut)

Dart
class AppRadius {
  // Desain modern butuh sudut yang sangat bulat (squircle)
  static const double large = 32.0; // Untuk Card di Homepage
  static const double pill = 999.0;  // Untuk Floating Bottom Nav & Tombol
}
Langkah 2: Merombak Total Bottom Menu (Menjadi Floating)
Kita harus berhenti menggunakan Scaffold.bottomNavigationBar bawaan. Kita akan menggunakan Stack di dalam Scaffold.body.

File: lib/features/shell/presentation/screens/petugas_shell_screen.dart
(Ubah build method Anda menjadi seperti di bawah)

Dart
// Import phosphor_flutter untuk ikon modern (rekomendasi)
import 'package:phosphor_flutter/phosphor_flutter.dart'; 

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
          child: Padding(
            // Beri padding bawah agar konten tidak tertutup bottom nav melayang
            padding: const EdgeInsets.only(bottom: 100), 
            child: widget.navigationShell, // Atau widget halaman Anda
          ),
        ),
        
        // 2. KUSTOM FLOATING BOTTOM MENU (Bentuk Kapsul Melayang)
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

// Helper Widget untuk Nav Item
Widget _buildNavItem({required IconData icon, required bool isActive, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        color: isActive ? AppColors.tertiary : AppColors.textSecondary,
        size: 28,
      ),
    ),
  );
}
Langkah 3: Merombak Total Konten Homepage
Kita akan membangun layout homepage persis seperti gambar.

File: lib/features/reports/presentation/screens/petugas_home_screen.dart
(Hapus build method lama, ganti dengan struktur ini)

Dart
import 'package:phosphor_flutter/phosphor_flutter.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    // Gunakan CustomScrollView agar header ikut bergeser saat di-scroll
    body: CustomScrollView(
      slivers: [
        // 1. MODERN HEADER (Good Morning & Avatar)
        SliverAppBar(
          backgroundColor: AppColors.background,
          expandedHeight: 80,
          floating: true,
          pinned: false,
          elevation: 0,
          leading: null, // Hapus arrow back otomatis
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            centerTitle: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Teks Sapaan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Good Morning,", 
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      "Petugas Aksamala", // Ambil dari UserModel Anda
                      style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                // AVATAR USER (Bisa ditekan untuk ke Profile)
                GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman profile Anda
                    context.push('/profile'); 
                  },
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.surfaceLight,
                    // Tambahkan NetworkImage jika sudah ada foto user
                    child: Icon(Icons.person, color: Colors.white), 
                  ),
                )
              ],
            ),
          ),
        ),

        // 2. KONTEN UTAMA (Recap Card & Task List)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: HERO CARD (Patrol Recap Bulan Ini)
                _buildPatrolRecapCard(),
                
                const SizedBox(height: 32),
                
                // SECTION 2: TASK LIST JUDUL
                Text(
                  "3 Laporan Terakhir", // Buat dinamis berdasarkan jumlah data
                  style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // SECTION 2: LIST DAFTAR TUGAS (Scrollable)
        // Gunakan SliverList untuk performa scroll yang baik menyatu dengan AppBar
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Ganti dengan widget kartu tugas Anda yang sudah di-update
              // Pastikan warna kartu surface gelap, radius besar, TANPA shadow.
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _buildTaskCard(index), 
              );
            },
            childCount: 3, // Data mock dari 3 laporan terakhir
          ),
        ),
      ],
    ),
  );
}

// Widget untuk Card Recap (Kuning/Ungu Pastel besar di atas)
Widget _buildPatrolRecapCard() {
  return Container(
    height: 180,
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.secondary, // Gunakan Ungu Pastel solid (tanpa gradien)
      borderRadius: BorderRadius.circular(AppRadius.large), // Radius sangat bulat
    ),
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rekap Patroli Bulan Ini",
          style: AppTypography.h3.copyWith(color: AppColors.textInverted),
        ),
        const Spacer(),
        // Visualisasi Tanggal (Sederhanakan grid kotak dari gambar)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(10, (index) => _buildDateBox(index)),
        )
      ],
    ),
  );
}

// Helper Widget kotak tanggal kecil di dalam Card Recap
Widget _buildDateBox(int index) {
  bool isPatrolled = index % 3 == 0; // Mock data
  return Container(
    height: 25,
    width: 25,
    decoration: BoxDecoration(
      color: isPatrolled ? AppColors.primary : AppColors.surface.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

// Widget untuk Kartu Tugas (List Item)
Widget _buildTaskCard(int index) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surface, // Abu-abu gelap flat
      borderRadius: BorderRadius.circular(AppRadius.medium),
      // PENTING: Jangan gunakan bayangan (shadow)
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(PhosphorIcons.shieldCheck(), color: AppColors.primary),
      ),
      title: Text("Area Produksi B", style: AppTypography.body1),
      subtitle: Text("Status: Follow Up Done", style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
      onTap: () {
        // Navigasi ke detail laporan untuk Approve/Reject
        context.push('/report-detail/$index'); 
      },
    ),
  );
}
Analisis Perubahan Setelah Implementasi:
Bottom Menu: Sekarang berbentuk kapsul yang mengambang 24px dari bawah layar, memiliki radius penuh (pill), dan tidak menempel kaku. Tombol tengah + berwarna Kuning Neon mencolok dan langsung memanggil context.push() ke halaman Wizard.

Layout Homepage:

Ada Header dengan sapaan dan Avatar yang bisa ditekan untuk ke Profile.

Terdapat Hero Card besar ("Patrol Recap") berwarna Pastel dengan radius besar, menampilkan rekap tanggal.

List laporan di bawahnya dirender sebagai kartu-kartu flat berwarna abu-abu gelap (AppColors.surface) tanpa bayangan, sehingga tampilannya bersih dan modern.

Halaman Wizard: Untuk wizard (7-step), Anda cukup memastikan kartu-kartu pilihan di dalam wizard tersebut menggunakan radius 32.0, latar belakang AppColors.surface, dan tanpa bayangan.