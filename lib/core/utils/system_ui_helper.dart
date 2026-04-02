import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class untuk mengatur System UI (Status Bar & Navigation Bar)
class SystemUIHelper {
  SystemUIHelper._();

  /// Atur System UI Mode
  ///
  /// [mode] - Mode system UI yang diinginkan:
  /// - `'normal'` - Status bar dan navigation bar tetap terlihat (default)
  /// - `'edgeToEdge'` - Konten memenuhi layar, di belakang system bars (RECOMMENDED)
  /// - `'immersive'` - Sembunyikan semua system bars (fullscreen sepenuhnya)
  /// - `'immersiveSticky'` - Sembunyikan system bars, tapi muncul saat swipe (auto-hide)
  static void setSystemUIMode({
    required String mode,
    bool statusBarVisible = true,
    bool navigationBarVisible = true,
  }) {
    switch (mode) {
      case 'normal':
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: SystemUiOverlay.values,
        );
        break;

      case 'edgeToEdge':
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: [
            SystemUiOverlay.top, // Status bar tetap visible
            SystemUiOverlay.bottom, // Navigation bar transparent
          ],
        );
        break;

      case 'immersive':
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersive,
          overlays: [],
        );
        break;

      case 'immersiveSticky':
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
          overlays: [],
        );
        break;

      default:
        final overlays = <SystemUiOverlay>[
          if (statusBarVisible) SystemUiOverlay.top,
          if (navigationBarVisible) SystemUiOverlay.bottom,
        ];
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: overlays,
        );
    }
  }

  /// Set status bar style (light/dark)
  ///
  /// [isDark] - true untuk dark icons, false untuk light icons
  static void setStatusBarStyle({required bool isDark}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  /// Set prefered orientations (orientasi layar yang diizinkan)
  ///
  /// [orientations] - List orientasi yang diizinkan
  static void setPreferredOrientations(List<DeviceOrientation> orientations) {
    SystemChrome.setPreferredOrientations(orientations);
  }

  /// Reset ke default system UI
  static void resetToDefault() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Enable immersive mode (hide all system bars)
  ///
  /// [sticky] - jika true, system bars muncul temporary saat swipe
  static void enableImmersiveMode({bool sticky = true}) {
    setSystemUIMode(mode: sticky ? 'immersiveSticky' : 'immersive');
  }

  /// Disable immersive mode (show system bars)
  static void disableImmersiveMode() {
    resetToDefault();
  }

  /// Set ke portrait only (hanya orientasi portrait)
  static void portraitOnly() {
    setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Enable all orientations
  static void enableAllOrientations() {
    setPreferredOrientations(DeviceOrientation.values);
  }
}
