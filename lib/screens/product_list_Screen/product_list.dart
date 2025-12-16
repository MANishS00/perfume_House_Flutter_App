// product_list.dart - Fixed version
import 'package:flutter/material.dart';
import 'package:perfumeapp/screens/Cart/cart_screen.dart';
import 'package:perfumeapp/screens/edit_profile.dart';
import 'package:perfumeapp/screens/order_history.dart';
import 'package:perfumeapp/screens/product_list_Screen/product_list_viewmodel.dart';
import 'package:perfumeapp/screens/site_info.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Initialize viewModel but don't use context here
    _viewModel = ProductListViewModel();
    // Load products after widget is mounted and provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductsWithErrorHandling(_viewModel);
    });
  }

  Future<void> _loadProductsWithErrorHandling(
    ProductListViewModel viewModel,
  ) async {
    try {
      await viewModel.loadProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
      }
    }
  }

  Future<void> _handleAddToCart(String productId) async {
    final result = await _viewModel.addToCart(productId, context);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'] as String)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ProductListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Perfume Store'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () async {
                    final cartId = await ProductListViewModel.getCartId();
                    if (cartId == null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cart is empty')),
                        );
                      }
                      return;
                    }
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartScreen(cartId: cartId),
                        ),
                      );
                    }
                  },
                ),
              ],
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            drawer: _buildDrawer(context, viewModel),
            body: viewModel.loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _loadProductsWithErrorHandling(viewModel),
                    child: _buildProductList(viewModel),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ProductListViewModel viewModel) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>>(
        future: viewModel.getAuthInfo(),
        builder: (context, snap) {
          final loggedIn = snap.hasData && (snap.data!['loggedIn'] == true);
          final email = snap.hasData
              ? (snap.data!['email'] ?? '') as String
              : '';
          final firstName = snap.hasData
              ? (snap.data!['firstName'] ?? '') as String
              : '';
          final lastName = snap.hasData
              ? (snap.data!['lastName'] ?? '') as String
              : '';
          final phone = snap.hasData
              ? (snap.data!['phone'] ?? '') as String
              : '';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Menu',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    if (loggedIn &&
                        (firstName.isNotEmpty || email.isNotEmpty)) ...[
                      const SizedBox(height: 8),
                      Text(
                        '$firstName${lastName.isNotEmpty ? ' $lastName' : ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (loggedIn && phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (loggedIn && email.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('View Cart'),
                onTap: () async {
                  final cartId = await ProductListViewModel.getCartId();
                  if (cartId == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cart is empty')),
                      );
                    }
                    return;
                  }
                  Navigator.pop(context);
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartScreen(cartId: cartId),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Site Info'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SiteInfoScreen()),
                  );
                },
              ),
              if (loggedIn)
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('My Orders'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrderHistoryScreen(),
                      ),
                    );
                  },
                ),
              if (loggedIn)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Edit Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
              if (loggedIn)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await viewModel.logout();
                    Navigator.pop(context);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login / Signup'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.pushNamed(context, '/auth');
                    viewModel.notifyListeners();
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductList(ProductListViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: viewModel.filteredProducts.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: viewModel.searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search products by name, brand or category',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                viewModel.setSearchQuery(v);
              },
            ),
          );
        }
        final p = viewModel.filteredProducts[i - 1];
        return Card(
          child: ListTile(
            leading: p.imageUrl.isNotEmpty
                ? Image.network(
                    p.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                : const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.image_not_supported),
                  ),
            title: Text(p.name),
            subtitle: Text('\$${p.price.toStringAsFixed(2)} • ${p.brand}'),
            trailing: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _handleAddToCart(p.id),
                  child: const Text('Add'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      '/checkout',
                      arguments: {
                        'directProduct': {'productId': p.id, 'qty': 1},
                      },
                    );
                    viewModel.notifyListeners();
                  },
                  child: const Text('Buy'),
                ),
              ],
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
