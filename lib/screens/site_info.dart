import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SiteInfoScreen extends StatefulWidget {
  const SiteInfoScreen({super.key});

  @override
  State<SiteInfoScreen> createState() => _SiteInfoScreenState();
}

class _SiteInfoScreenState extends State<SiteInfoScreen> {
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

  Widget section(String title, String body) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              body.isNotEmpty ? body : 'Not set',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final about = tpl['site.about'] ?? '';
    final privacy = tpl['site.privacy'] ?? '';
    final terms = tpl['site.terms'] ?? '';
    final contactEmail = tpl['site.contact.email'] ?? '';
    final contactPhone = tpl['site.contact.phone'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Site Info')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadTemplates,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  section('About', about),
                  section('Privacy Policy', privacy),
                  section('Terms & Conditions', terms),
                  Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contact',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Email: ${contactEmail.isNotEmpty ? contactEmail : 'Not set'}',
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Phone: ${contactPhone.isNotEmpty ? contactPhone : 'Not set'}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
