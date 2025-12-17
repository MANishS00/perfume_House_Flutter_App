// cart_screen.dart - Fixed version
import 'package:flutter/material.dart';
import 'package:perfumeapp/screens/Cart/cart_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:perfumeapp/constants/app_Button.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/screens/widgets/cart_item_tile.dart';

class CartScreen extends StatefulWidget {
  final String cartId;
  const CartScreen({required this.cartId, super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CartViewModel(widget.cartId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartWithErrorHandling(_viewModel);
    });
  }

  Future<void> _loadCartWithErrorHandling(CartViewModel viewModel) async {
    try {
      await viewModel.loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load cart: $e')));
      }
    }
  }

  Future<void> _handleChangeQuantity(String itemId, int newQty) async {
    try {
      await _viewModel.changeQuantity(itemId, newQty);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quantity: $e')),
        );
      }
    }
  }

  Future<void> _handleRemoveItem(String itemId) async {
    try {
      await _viewModel.removeItem(itemId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
      }
    }
  }

  Future<void> _navigateToCheckout() async {
    try {
      await _viewModel.saveCartIdForCheckout();
      await Navigator.pushNamed(context, '/checkout');

      // Refresh cart after returning from checkout
      if (mounted) {
        await _loadCartWithErrorHandling(_viewModel);
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Navigation failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<CartViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Your Cart'),
              backgroundColor: AppColors.background,
            ),
            backgroundColor: AppColors.background,
            body: _buildBody(viewModel),
            bottomNavigationBar: _buildBottomBar(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(CartViewModel viewModel) {
    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.cart == null || !viewModel.hasItems) {
      return const Center(child: AppText(text: 'Cart is empty'));
    }

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: viewModel.cart!.items.length,
        itemBuilder: (context, i) {
          final item = viewModel.cart!.items[i];
          return CartItemTile(
            imagePath: item.image,
            title: item.name,
            size: '',
            price: 'Rs ${item.price.toStringAsFixed(2)}',
            quantity: item.quantity,
            onIncrement: () =>
                _handleChangeQuantity(item.id, item.quantity - 1),
            onDecrement: () =>
                _handleChangeQuantity(item.id, item.quantity + 1),
            // onRemove: () => _handleRemoveItem(item.id),
          );
        },
      ),
    );
  }

  Widget? _buildBottomBar(CartViewModel viewModel) {
    if (viewModel.loading || !viewModel.hasItems) {
      return null;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AppButton(text: "Add Address", onPressed: _navigateToCheckout),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
