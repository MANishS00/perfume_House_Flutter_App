import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfumeapp/constants/app_colors.dart';

class AppText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const AppText({
    super.key,
    required this.text,
    this.size,
    this.color,
    this.weight,
    this.align,
    this.maxLines,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.poppins(
        fontSize: size ?? 14,
        color: color ?? AppColors.black,
        fontWeight: weight ?? FontWeight.normal,
      ),
    );
  }
}
