import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addr1Ctrl = TextEditingController();
  final _addr2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    try {
      final res = await ApiService.getProfile(token: token);
      if (res['success'] == true) {
        final u = res['user'] as Map<String, dynamic>;
        _firstCtrl.text = u['firstName'] ?? '';
        _lastCtrl.text = u['lastName'] ?? '';
        _emailCtrl.text = u['email'] ?? '';
        _phoneCtrl.text = u['phone'] ?? '';
        final sa = u['shippingAddress'] as Map<String, dynamic>? ?? {};
        _addr1Ctrl.text = sa['address_line1'] ?? '';
        _addr2Ctrl.text = sa['address_line2'] ?? '';
        _cityCtrl.text = sa['city'] ?? '';
        _stateCtrl.text = sa['state'] ?? '';
        _postalCtrl.text = sa['postal_code'] ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['error'] ?? 'Failed to load profile')),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final body = {
      'firstName': _firstCtrl.text.trim(),
      'lastName': _lastCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'shippingAddress': {
        'address_line1': _addr1Ctrl.text.trim(),
        'address_line2': _addr2Ctrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'postal_code': _postalCtrl.text.trim(),
      },
    };

    try {
      final res = await ApiService.updateProfile(body, token: token);
      if (res['success'] == true) {
        final u = res['user'] as Map<String, dynamic>?;
        if (u != null) {
          // persist some user fields locally
          await prefs.setString('userFirstName', u['firstName'] ?? '');
          await prefs.setString('userLastName', u['lastName'] ?? '');
          if (u['phone'] != null)
            await prefs.setString('userPhone', u['phone']);
          final sa = u['shippingAddress'] as Map<String, dynamic>?;
          if (sa != null) {
            await prefs.setString(
              'userAddress_line1',
              sa['address_line1'] ?? '',
            );
            await prefs.setString(
              'userAddress_line2',
              sa['address_line2'] ?? '',
            );
            await prefs.setString('userAddress_city', sa['city'] ?? '');
            await prefs.setString('userAddress_state', sa['state'] ?? '');
            await prefs.setString(
              'userAddress_postal_code',
              sa['postal_code'] ?? '',
            );
          }
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['error'] ?? 'Update failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstCtrl,
                      decoration: const InputDecoration(
                        labelText: 'First name',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _lastCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Last name (optional)',
                      ),
                    ),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email (read-only)',
                      ),
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addr1Ctrl,
                      decoration: const InputDecoration(
                        labelText: 'Address line 1',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _addr2Ctrl,
                      decoration: const InputDecoration(
                        labelText: 'Address line 2',
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'City',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _stateCtrl,
                            decoration: const InputDecoration(
                              labelText: 'State',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _postalCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Postal code',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: saving ? null : _save,
                      child: saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
