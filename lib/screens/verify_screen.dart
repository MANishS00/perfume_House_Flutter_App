import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  void _verify(Map args) async {
    final email = args['email'] as String? ?? '';
    final action = args['action'] as String? ?? 'signup';
    final code = _codeCtrl.text.trim();
    if (code.length != 5) return _show('Enter 5-digit code');
    setState(() => _loading = true);
    try {
      final tempCartId = args['tempCartId'] as String?;
      final res = await ApiService.verifyCode(
        email,
        code,
        action,
        tempCartId: tempCartId,
      );
      if (res['success'] == true) {
        _show('Verified! You are logged in.');
        // store token and cartId
        final prefs = await SharedPreferences.getInstance();
        if (res['token'] != null)
          await prefs.setString('authToken', res['token']);
        if (res['user'] != null && res['user']['email'] != null)
          await prefs.setString('userEmail', res['user']['email']);
        if (res['cartId'] != null)
          await prefs.setString('cartId', res['cartId']);
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        _show(res['error']?.toString() ?? 'Verification failed');
      }
    } catch (e) {
      _show('Network error');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _show(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map? ?? {};
    final email = args['email'] ?? '';
    final action = args['action'] ?? 'signup';
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('A 5-digit code was sent to $email for $action.'),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(labelText: 'Enter code'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : () => _verify(args),
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
