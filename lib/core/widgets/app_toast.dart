import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Modern Toast Notification yang Auto-Dismiss
/// Lebih smooth daripada SnackBar dan langsung hilang tanpa perlu user action
enum ToastType { success, error, warning, info }

class AppToast {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// Tampilkan toast yang auto-dismiss
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    // Hapus toast yang sedang tampil
    if (_isShowing) {
      _removeToast();
    }

    // Buat overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: _removeToast,
      ),
    );

    // Tampilkan overlay
    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;

    // Auto-dismiss setelah duration
    Future.delayed(duration, () {
      if (_isShowing) {
        _removeToast();
      }
    });
  }

  static void _removeToast() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  /// Shortcut methods
  static void success(BuildContext context, {required String message}) {
    show(context, message: message, type: ToastType.success);
  }

  static void error(BuildContext context, {required String message}) {
    show(context, message: message, type: ToastType.error);
  }

  static void warning(BuildContext context, {required String message}) {
    show(context, message: message, type: ToastType.warning);
  }

  static void info(BuildContext context, {required String message}) {
    show(context, message: message, type: ToastType.info);
  }
}

/// Widget Toast dengan Animasi Smooth
class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide from top + fade in
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16, // Di bawah status bar
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: child,
              ),
            );
          },
          child: _buildToastContent(),
        ),
      ),
    );
  }

  Widget _buildToastContent() {
    // Config berdasarkan tipe
    final config = _getToastConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: config.iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              config.icon,
              color: config.iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Message
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(
                color: config.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  _ToastConfig _getToastConfig() {
    switch (widget.type) {
      case ToastType.success:
        return _ToastConfig(
          backgroundColor: AppColors.statusApproved,
          icon: Icons.check_circle,
          iconColor: Colors.black,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.3),
          textColor: Colors.black,
        );
      case ToastType.error:
        return _ToastConfig(
          backgroundColor: Colors.red.shade800,
          icon: Icons.error,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.2),
          textColor: Colors.white,
        );
      case ToastType.warning:
        return _ToastConfig(
          backgroundColor: AppColors.statusRejected,
          icon: Icons.warning,
          iconColor: Colors.black,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.3),
          textColor: Colors.black,
        );
      case ToastType.info:
        return _ToastConfig(
          backgroundColor: AppColors.primary,
          icon: Icons.info,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.2),
          textColor: Colors.white,
        );
    }
  }
}

class _ToastConfig {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color textColor;

  _ToastConfig({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.textColor,
  });
}
