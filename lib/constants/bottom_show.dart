import 'package:flutter/material.dart';
import 'package:logisticscustomer/constants/colors.dart';

class AppSnackBar {
  AppSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      accentColor: AppColors.electricTeal,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      accentColor: const Color(0xFFDC2626),
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      accentColor: const Color(0xFF2563EB),
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      accentColor: const Color(0xFFF59E0B),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color accentColor,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          backgroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Row(
              children: [
                // 🔥 Left Accent Bar
                Container(
                  width: 10,
                  height: 60,
                  color: accentColor,
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    color: Colors.white,
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}