// product_list_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:perfumeapp/models/product.dart';
import 'package:perfumeapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductListViewModel extends ChangeNotifier {
  List<Product> _products = [];
  bool _loading = true;
  String _searchQuery = '';

  List<Product> get products => _products;
  bool get loading => _loading;
  String get searchQuery => _searchQuery;

  TextEditingController searchController = TextEditingController();

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final email = prefs.getString('userEmail');
    final firstName = prefs.getString('userFirstName');
    final lastName = prefs.getString('userLastName');
    final phone = prefs.getString('userPhone');
    final address1 = prefs.getString('userAddress_line1');
    return {
      'loggedIn': token != null,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'address1': address1,
    };
  }

  Future<void> loadProducts() async {
    try {
      final raw = await ApiService.fetchProducts();
      _products = raw
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  List<Product> get filteredProducts {
    if (_searchQuery.trim().isEmpty) return _products;
    final q = _searchQuery.toLowerCase();
    return _products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }

  static Future<String?> getCartId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cartId');
  }

  static Future<void> saveCartId(String cartId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cartId', cartId);
  }

  Future<Map<String, dynamic>> addToCart(
    String productId,
    BuildContext context,
  ) async {
    final currentCartId = await getCartId();
    final res = await ApiService.addToCart(currentCartId, productId, 1);
    if (res['success'] == true) {
      final cartId = res['cartId'] as String? ?? res['cart']?['cartId'];
      if (cartId != null) await saveCartId(cartId);
      return {'success': true, 'message': 'Added to cart'};
    } else {
      return {
        'success': false,
        'message': 'Failed to add to cart: ${res['error']}',
      };
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userEmail');
    // Note: cartId is intentionally kept as-is
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
