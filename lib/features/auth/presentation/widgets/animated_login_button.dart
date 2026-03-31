import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

enum ButtonState {
  initial,
  loading,
  success,
}

class AnimatedLoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const AnimatedLoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<AnimatedLoginButton>
    with SingleTickerProviderStateMixin {
  ButtonState _buttonState = ButtonState.initial;
  late AnimationController _animationController;
  late Animation<double> _shrinkAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shrinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
  }

  @override
  void didUpdateWidget(AnimatedLoginButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading && _buttonState == ButtonState.initial) {
        _animateToLoading();
      }
    }
  }

  void _animateToLoading() {
    setState(() {
      _buttonState = ButtonState.loading;
    });
    _animationController.forward();
  }

  void _resetToInitial() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _buttonState = ButtonState.initial;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isShrunk = _shrinkAnimation.value < 0.95;
    final bool isFullyShrunk = _shrinkAnimation.value < 0.1;

    return GestureDetector(
      onTap: widget.isLoading || _buttonState == ButtonState.loading
          ? null
          : () {
              if (widget.onPressed != null) {
                widget.onPressed();
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(
            isFullyShrunk ? 56 / 2 : AppRadius.pill,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: isShrunk ? 0 : 20,
              offset: isShrunk ? Offset.zero : const Offset(0, 8),
              spreadRadius: isShrunk ? 0 : 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isFullyShrunk ? 0 : 32,
          ),
          child: AnimatedOpacity(
            opacity: _fadeAnimation.value,
            duration: const Duration(milliseconds: 200),
            child: isFullyShrunk
                ? _buildLoadingIndicator()
                : _buildLabel(),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      'Login',
      style: AppTypography.h3.copyWith(
        color: const Color(0xFF1E1E1E),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        children: [
          // Dark center
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1E1E).withOpacity(0.3),
            ),
          ),
          // Rotating white arc
          Positioned.fill(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
