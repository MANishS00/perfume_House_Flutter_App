// cart_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:perfumeapp/models/cart.dart';
import 'package:perfumeapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartViewModel extends ChangeNotifier {
  Cart? _cart;
  bool _loading = true;
  String _cartId;

  Cart? get cart => _cart;
  bool get loading => _loading;
  String get cartId => _cartId;

  CartViewModel(this._cartId);

  Future<void> loadCart() async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.getCart(_cartId);
      if (res['success'] == true) {
        _cart = Cart.fromJson(res['cart'] as Map<String, dynamic>);
      } else {
        throw Exception(res['error'] ?? 'Failed to load cart');
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> changeQuantity(String itemId, int newQty) async {
    if (_cart == null) return;

    if (newQty < 1) {
      await removeItem(itemId);
      return;
    }

    try {
      final res = await ApiService.updateItem(_cartId, itemId, newQty);
      if (res['success'] == true) {
        await loadCart();
      } else {
        throw Exception(res['error'] ?? 'Update failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final res = await ApiService.removeItem(_cartId, itemId);
      if (res['success'] == true) {
        await loadCart();
      } else {
        throw Exception(res['error'] ?? 'Remove failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveCartIdForCheckout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cartId', _cartId);
  }

  bool get hasItems => _cart != null && _cart!.items.isNotEmpty;
}
