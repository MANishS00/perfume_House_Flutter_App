import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final double height;
  final double width;
  final double radius;

  final Color backgroundColor;
  final Color textColor;

  final double textSize;
  final FontWeight textWeight;
  final double elevation;

  final IconData? icon;
  final double iconSize;
  final Color? iconColor;
  final double iconGap;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56,
    this.width = double.infinity,
    this.radius = 28,
    this.backgroundColor = AppColors.buttonPrimary,
    this.textColor = AppColors.white,
    this.textSize = 18,
    this.textWeight = FontWeight.w600,
    this.elevation = 0,

    // icon (optional)
    this.icon,
    this.iconSize = 20,
    this.iconColor,
    this.iconGap = 8,
  });

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: hasIcon
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: iconSize, color: iconColor ?? textColor),
                  iconGap.gapW,
                  AppText(
                    text: text,
                    size: textSize,
                    weight: textWeight,
                    color: textColor,
                  ),
                ],
              )
            : AppText(
                text: text,
                size: textSize,
                weight: textWeight,
                color: textColor,
              ),
      ),
    );
  }
}
