import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  bool _isSignup = true;
  bool _loading = false;

  void _requestCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return _show('Enter email');
    // get tempCartId from prefs to pass along after requesting code
    final prefs = await SharedPreferences.getInstance();
    final tempCartId = prefs.getString('cartId');
    setState(() => _loading = true);
    try {
      final res = await ApiService.requestVerification(
        email,
        _isSignup ? 'signup' : 'login',
      );
      if (res['success'] == true) {
        _show('Code sent to $email');
        Navigator.pushNamed(
          context,
          '/verify',
          arguments: {
            'email': email,
            'action': _isSignup ? 'signup' : 'login',
            'tempCartId': tempCartId,
          },
        );
      } else {
        _show(res['error']?.toString() ?? 'Failed');
      }
    } catch (e) {
      _show('Network error');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _show(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _requestCode,
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isSignup
                              ? 'Request Signup Code'
                              : 'Request Login Code',
                        ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => setState(() => _isSignup = !_isSignup),
                  child: Text(
                    _isSignup ? 'Switch to Login' : 'Switch to Signup',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
