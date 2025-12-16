import 'package:flutter/material.dart';
import 'package:perfumeapp/screens/cart_screen.dart';
import 'package:perfumeapp/screens/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/gap_extension.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _loggedIn = false;
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadAuthInfo();
  }

  Future<void> _loadAuthInfo() async {
    final authInfo = await _authInfo();
    setState(() {
      _loggedIn = authInfo['loggedIn'] == true;
      _email = authInfo['email'] ?? '';
      _firstName = authInfo['firstName'] ?? '';
      _lastName = authInfo['lastName'] ?? '';
      _phone = authInfo['phone'] ?? '';
    });
  }

  Future<Map<String, dynamic>> _authInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final email = prefs.getString('userEmail') ?? '';
    final firstName = prefs.getString('userFirstName') ?? '';
    final lastName = prefs.getString('userLastName') ?? '';
    final phone = prefs.getString('userPhone') ?? '';

    return {
      'loggedIn': token != null && token.isNotEmpty,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userEmail');
    await prefs.remove('userFirstName');
    await prefs.remove('userLastName');
    await prefs.remove('userPhone');

    await _loadAuthInfo(); // Reload auth info to update UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              12.gap,

              /// Back Button
              AppBar(
                title: const Text("Account Page"),
                backgroundColor: AppColors.background,
              ),
              16.gap,

              /// Profile Card (Only show if logged in)
              if (_loggedIn) ...[
                _ProfileCard(
                  email: _email,
                  firstName: _firstName,
                  lastName: _lastName,
                  phone: _phone,
                ),
                const SizedBox(height: 20),
              ],

              /// Menu Items
              if (_loggedIn) ...[
                _MenuTile(
                  title: 'Edit My Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ).then((_) => _loadAuthInfo()); // Reload after editing
                  },
                ),
                _MenuTile(
                  title: 'My Orders History',
                  onTap: () async {
                    await Navigator.pushNamed(context, '/historyScreen');
                    setState(() {});
                  },
                ),
              ],

              /// Always show these items
              _MenuTile(
                title: 'View Cart',
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final cartId = prefs.getString('cartId');
                  if (cartId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cart is empty')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(cartId: cartId),
                    ),
                  );
                },
              ),

              _MenuTile(
                title: 'Data Privacy',
                onTap: () {
                  Navigator.pushNamed(context, '/dataprivacyScreen');
                },
              ),
              _MenuTile(
                title: 'Contact Us',
                onTap: () {
                  Navigator.pushNamed(context, '/contactusScreen');
                },
              ),

              /// Show Login/Signup if not logged in
              if (!_loggedIn) ...[
                const SizedBox(height: 20),
                _LoginButton(
                  onTap: () async {
                    await Navigator.pushNamed(context, '/auth');
                    await _loadAuthInfo(); // Reload after auth flow
                  },
                ),
              ],

              const Spacer(),

              /// Logout Button (Only show if logged in)
              if (_loggedIn) ...[
                _LogoutButton(
                  onTap: () async {
                    await _logout();
                  },
                ),
                const SizedBox(height: 20),
              ],

              /// Version
              Column(
                children: const [
                  Text(
                    'Version',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1.0.2',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String phone;

  const _ProfileCard({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        '${firstName.isNotEmpty ? firstName : ''}'
                '${lastName.isNotEmpty ? ' $lastName' : ''}'
            .trim();
    final initial = displayName.isNotEmpty ? displayName[0] : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFE0E0E0),
            child: Text(
              initial.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName.isNotEmpty ? displayName : 'Guest User',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          if (email.isNotEmpty) ...[
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 4),
          ],
          if (phone.isNotEmpty)
            Text(
              phone,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _MenuTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.chevron_right, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.power_settings_new, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LoginButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.login, color: Colors.green),
            SizedBox(width: 10),
            Text(
              'Login / Signup',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
