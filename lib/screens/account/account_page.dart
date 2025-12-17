// account_page.dart
import 'package:flutter/material.dart';
import 'package:perfumeapp/screens/Cart/cart_screen.dart';
import 'package:perfumeapp/screens/account/account_viewmodel.dart';
import 'package:perfumeapp/screens/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/gap_extension.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountViewModel(),
      child: Consumer<AccountViewModel>(
        builder: (context, viewModel, child) {
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
                    if (viewModel.loggedIn) ...[
                      _ProfileCard(
                        email: viewModel.email,
                        firstName: viewModel.firstName,
                        lastName: viewModel.lastName,
                        phone: viewModel.phone,
                      ),
                      const SizedBox(height: 20),
                    ],

                    /// Menu Items
                    _buildMenuItems(context, viewModel),

                    const Spacer(),

                    /// Logout Button (Only show if logged in)
                    if (viewModel.loggedIn) ...[
                      _LogoutButton(onTap: () => _handleLogout(viewModel)),
                      const SizedBox(height: 20),
                    ],

                    /// Version
                    _buildVersionInfo(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, AccountViewModel viewModel) {
    return Column(
      children: [
        if (viewModel.loggedIn) ...[
          _MenuTile(
            title: 'Edit My Profile',
            onTap: () => _navigateToEditProfile(context),
          ),
          _MenuTile(
            title: 'My Orders History',
            onTap: () => _navigateToHistory(context),
          ),
        ],

        /// Always show these items
        _MenuTile(
          title: 'View Cart',
          onTap: () => _navigateToCart(context, viewModel),
        ),
        _MenuTile(
          title: 'Data Privacy',
          onTap: () => _navigateToDataPrivacy(context),
        ),
        _MenuTile(
          title: 'Contact Us',
          onTap: () => _navigateToContactUs(context),
        ),

        /// Show Login/Signup if not logged in
        if (!viewModel.loggedIn) ...[
          const SizedBox(height: 20),
          _LoginButton(onTap: () => _navigateToAuth(context, viewModel)),
        ],
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: const [
        Text('Version', style: TextStyle(fontSize: 14, color: Colors.black54)),
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
    );
  }

  Future<void> _navigateToEditProfile(BuildContext context) async {
    // Import EditProfileScreen here
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );

    // Reload after editing
    final viewModel = Provider.of<AccountViewModel>(context, listen: false);
    await viewModel.loadAuthInfo();
  }

  Future<void> _navigateToHistory(BuildContext context) async {
    await Navigator.pushNamed(context, '/historyScreen');
    setState(() {});
  }

  Future<void> _navigateToCart(
    BuildContext context,
    AccountViewModel viewModel,
  ) async {
    final cartId = await viewModel.getCartId();
    if (cartId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      }
      return;
    }

    // Import CartScreen here
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartScreen(cartId: cartId)),
    );
  }

  Future<void> _navigateToDataPrivacy(BuildContext context) async {
    await Navigator.pushNamed(context, '/dataprivacyScreen');
  }

  Future<void> _navigateToContactUs(BuildContext context) async {
    await Navigator.pushNamed(context, '/contactusScreen');
  }

  Future<void> _navigateToAuth(
    BuildContext context,
    AccountViewModel viewModel,
  ) async {
    await Navigator.pushNamed(context, '/auth');
    await viewModel.loadAuthInfo(); // Reload after auth flow
  }

  Future<void> _handleLogout(AccountViewModel viewModel) async {
    await viewModel.logout();
  }
}

// Keep all the UI widget classes as they are (unchanged)
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
