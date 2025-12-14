import 'package:flutter/material.dart';
import 'package:perfumeapp/screens/account_Section.dart';
import 'package:perfumeapp/screens/cart_screen.dart';
import 'package:perfumeapp/screens/product_list.dart';
import 'package:perfumeapp/screens/widgets/custom_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final List<Widget> _pages = const [
    AccountPage(),
    ProductListScreen(),
    CartScreen(cartId: 'default_cart'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
