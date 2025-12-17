import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller; // optional
  final String? hintText;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsets padding;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.height = 56,
    this.backgroundColor = AppColors.background,
    this.borderColor = AppColors.black,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            isDense: true,
          ),
        ),
      ),
    );
  }
}
