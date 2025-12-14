import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Button.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_TextField.dart';
import 'package:perfumeapp/constants/app_ToastMessage.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/card_Container.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';
import 'package:perfumeapp/services/api_service.dart';
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
    showAppToast(context, message: s, type: ToastType.warning);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Auth'),
        backgroundColor: AppColors.background,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: 'Join Us',
                      size: 32,
                      weight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),

                    8.gap,

                    AppText(
                      text: 'with Email',
                      size: 18,
                      color: AppColors.textPrimary,
                    ),

                    24.gap,
                    AppTextField(
                      hintText: 'Enter your email',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    40.gap,

                    AppButton(
                      text: "Send OTP",
                      isLoading: _loading,
                      onPressed: _loading ? null : _requestCode,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
