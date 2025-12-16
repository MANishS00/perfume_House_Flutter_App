import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/card_Container.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';
import 'package:perfumeapp/screens/info_Screen.dart';
import 'package:perfumeapp/services/api_service.dart';

class DataprivacyScreen extends StatefulWidget {
  const DataprivacyScreen({super.key});

  @override
  State<DataprivacyScreen> createState() => _DataprivacyScreenState();
}

class _DataprivacyScreenState extends State<DataprivacyScreen> {
  bool loading = true;
  Map<String, String> tpl = {};

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    setState(() => loading = true);
    try {
      final res = await ApiService.getSiteTemplates();
      if (res['success'] == true) {
        final raw = res['templates'] as Map<String, dynamic>? ?? {};
        setState(
          () => tpl = raw.map((k, v) => MapEntry(k, v?.toString() ?? '')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load site info')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  void _openDetail(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InfoDetailScreen(title: title, body: body),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final about = tpl['site.about'] ?? '';
    final privacy = tpl['site.privacy'] ?? '';
    final terms = tpl['site.terms'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: AppText(text: 'Data Privacy', size: 20, weight: FontWeight.w600),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ArrowCardTile(
              text: "About App",
              onTap: () =>
                  _openDetail(context, title: "About App", body: about),
            ),
            10.gap,
            ArrowCardTile(
              text: "Privacy Policy",
              onTap: () =>
                  _openDetail(context, title: "Privacy Policy", body: privacy),
            ),
            10.gap,
            ArrowCardTile(
              text: "Terms and Conditions",
              onTap: () => _openDetail(
                context,
                title: "Terms and Conditions",
                body: terms,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArrowCardTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ArrowCardTile({Key? key, required this.text, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: GestureDetector(
        onTap: onTap,
        child: AppCardContainer(
          radius: 12,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(text: text),
                const Icon(Icons.arrow_forward_ios, size: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
