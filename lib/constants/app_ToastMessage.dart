import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';

enum ToastType { success, warning, error }

class AppToast extends StatelessWidget {
  final String message;
  final ToastType type;

  const AppToast({super.key, required this.message, required this.type});

  Color get _iconBackgroundColor {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.error:
        return AppColors.error;
    }
  }

  IconData get _icon {
    switch (type) {
      case ToastType.success:
        return Icons.check;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.error:
        return Icons.close;
    }
  }

  Color get _textColor => AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: _iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: AppColors.white, size: 20),
            ),
            12.gapW,
            Expanded(
              child: AppText(
                text: message,
                size: 16,
                weight: FontWeight.w500,
                color: _textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showAppToast(
  BuildContext context, {
  required String message,
  ToastType type = ToastType.success,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 0,
      right: 0,
      child: AppToast(message: message, type: type),
    ),
  );

  overlay.insert(entry);

  Future.delayed(duration, () {
    entry.remove();
  });
}
