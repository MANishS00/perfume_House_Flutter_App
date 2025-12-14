import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/product_list.dart';
import 'screens/auth_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/checkout_screen.dart';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (WebViewPlatform.instance == null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
      }
    }
  }

  runApp(const PerfumeApp());
}

class PerfumeApp extends StatelessWidget {
  const PerfumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfume House',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const ProductListScreen(),
      routes: {
        '/auth': (c) => const AuthScreen(),
        '/verify': (c) => const VerifyScreen(),
        '/checkout': (c) => const CheckoutScreen(),
      },
    );
  }
}
