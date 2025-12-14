import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_colors.dart';

class AppCardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
