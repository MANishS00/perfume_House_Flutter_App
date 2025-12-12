import 'package:flutter/material.dart';
import 'package:perfumeapp/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  final String cartId;
  const CartScreen({required this.cartId, super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Cart? cart;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    setState(() => loading = true);
    try {
      final res = await ApiService.getCart(widget.cartId);
      if (res['success'] == true) {
        setState(() {
          cart = Cart.fromJson(res['cart'] as Map<String, dynamic>);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${res['error']}')));
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load cart: $e')));
    }
  }

  Future<void> changeQuantity(String itemId, int newQty) async {
    if (cart == null) return;
    if (newQty < 1) return removeItem(itemId);
    final res = await ApiService.updateItem(widget.cartId, itemId, newQty);
    if (res['success'] == true) {
      await loadCart();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: ${res['error']}')));
    }
  }

  Future<void> removeItem(String itemId) async {
    final res = await ApiService.removeItem(widget.cartId, itemId);
    if (res['success'] == true) {
      await loadCart();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Remove failed: ${res['error']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.abc_outlined),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (cart == null || cart!.items.isEmpty)
          ? const Center(child: Text('Cart is empty'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: cart!.items.length,
              itemBuilder: (context, i) {
                final item = cart!.items[i];
                return Card(
                  child: ListTile(
                    leading: item.image.isNotEmpty
                        ? Image.network(
                            item.image,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.image_not_supported),
                          ),
                    title: Text(item.name),
                    subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () =>
                              changeQuantity(item.id, item.quantity - 1),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () =>
                              changeQuantity(item.id, item.quantity + 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      // If cart has items show a checkout button at the bottom
      bottomNavigationBar: (!loading && cart != null && cart!.items.isNotEmpty)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // ensure cartId is stored in prefs so checkout merges it
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('cartId', widget.cartId);
                    // navigate to checkout (no directProduct)
                    await Navigator.pushNamed(context, '/checkout');
                    // refresh after return
                    await loadCart();
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      'Proceed to Checkout',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
