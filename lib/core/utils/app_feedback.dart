import 'package:flutter/material.dart';

class AppFeedback {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      textColor: Theme.of(context).colorScheme.onPrimaryContainer,
      iconColor: Theme.of(context).colorScheme.primary,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      textColor: Theme.of(context).colorScheme.onSecondaryContainer,
      iconColor: Theme.of(context).colorScheme.secondary,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      textColor: Theme.of(context).colorScheme.onErrorContainer,
      iconColor: Theme.of(context).colorScheme.error,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      textColor: Theme.of(context).colorScheme.onSurface,
      iconColor: Theme.of(context).colorScheme.tertiary,
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: iconColor.withValues(alpha: 0.3)),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
