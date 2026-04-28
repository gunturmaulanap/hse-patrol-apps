import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';

enum AppButtonType { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.primary
                    ? AppColors.textInverse
                    : type == AppButtonType.secondary
                        ? AppColors.textInverse
                        : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(text),
      ],
    );

    Widget button;
    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textInverse,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            disabledForegroundColor: AppColors.textInverse.withValues(alpha: 0.7),
            elevation: 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.primaryDark.withValues(alpha: 0.8);
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.primaryLight.withValues(alpha: 0.5);
              }
              if (states.contains(WidgetState.focused)) {
                return AppColors.primaryLight.withValues(alpha: 0.3);
              }
              return null;
            }),
          ),
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
        break;
      case AppButtonType.secondary:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textInverse,
            disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.6),
            disabledForegroundColor: AppColors.textInverse.withValues(alpha: 0.7),
            elevation: 2,
            shadowColor: AppColors.secondary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.secondaryDark.withValues(alpha: 0.8);
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.secondary.withValues(alpha: 0.8);
              }
              if (states.contains(WidgetState.focused)) {
                return AppColors.secondary.withValues(alpha: 0.85);
              }
              return null;
            }),
          ),
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
        break;
      case AppButtonType.outlined:
        button = OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary, width: 2),
            disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ).copyWith(
            side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
              if (states.contains(WidgetState.disabled)) {
                return BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 2);
              }
              return BorderSide(color: AppColors.primary, width: 2);
            }),
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.primary.withValues(alpha: 0.1);
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.primary.withValues(alpha: 0.05);
              }
              return null;
            }),
          ),
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.primary.withValues(alpha: 0.1);
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.primary.withValues(alpha: 0.05);
              }
              return null;
            }),
          ),
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
