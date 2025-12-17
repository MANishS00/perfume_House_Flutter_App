import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_colors.dart';

class InfoDetailScreen extends StatelessWidget {
  final String title;
  final String body;

  const InfoDetailScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(text: title, size: 20, weight: FontWeight.w600),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: AppText(text: body.isNotEmpty ? body : 'Loading...', size: 14),
      ),
    );
  }
}
