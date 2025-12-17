import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Button.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_ToastMessage.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/card_Container.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';
import 'package:perfumeapp/screens/widgets/otp_field.dart';
import 'package:perfumeapp/services/api_service.dart';
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
      showAppToast(context, message: s, type: ToastType.warning);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map? ?? {};
    final email = args['email'] ?? '';
    final action = args['action'] ?? 'signup';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCardContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(text: 'Enter OTP', size: 32, weight: FontWeight.w700),
                  8.gap,

                  AppText(text: 'Send on $email', size: 18),
                  32.gap,

                  OtpField(
                    length: 5,
                    onCompleted: (otp) {
                      debugPrint('OTP Entered: $otp');
                    },
                  ),
                  40.gap,

                  AppButton(
                    text: "Verify",
                    isLoading: _loading,
                    onPressed: _loading ? null : () => _verify(args),
                  ),
                  24.gap,

                  TextButton(
                    onPressed: () {},
                    child: AppText(text: 'Resend OTP', size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
