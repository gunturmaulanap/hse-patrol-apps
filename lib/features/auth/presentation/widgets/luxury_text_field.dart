import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class LuxuryTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final bool isPasswordField;
  final bool isUsernameField;

  const LuxuryTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.isPasswordField = false,
    this.isUsernameField = false,
  });

  @override
  State<LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<LuxuryTextField> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.1),
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            obscureText: widget.obscureText,
            style: AppTypography.body1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: AppColors.primary,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.body1.copyWith(
                color: Colors.white.withValues(alpha: 0.3),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: (widget.isUsernameField || widget.isPasswordField)
                  ? Icon(
                      widget.isUsernameField ? PhosphorIcons.user(PhosphorIconsStyle.regular) : PhosphorIcons.lock(PhosphorIconsStyle.regular),
                      color: _isFocused ? AppColors.primary : Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? Icon(
                      PhosphorIcons.eye(PhosphorIconsStyle.regular),
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
