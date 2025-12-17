// product_list.dart - Fixed version
import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';
import 'package:perfumeapp/screens/Cart/cart_screen.dart';
import 'package:perfumeapp/screens/product_details/product_details_screen.dart';
import 'package:perfumeapp/screens/product_list_Screen/product_list_viewmodel.dart';
import 'package:perfumeapp/screens/product_list_Screen/widgets/grid_product_card.dart';
import 'package:perfumeapp/screens/product_list_Screen/widgets/horizontal_product_card.dart';
import 'package:provider/provider.dart';

class AllProductView extends StatefulWidget {
  const AllProductView({super.key});

  @override
  State<AllProductView> createState() => _AllProductViewState();
}

class _AllProductViewState extends State<AllProductView> {
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
            backgroundColor: AppColors.background,
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

  Widget _buildProductList(ProductListViewModel viewModel) {
    // final horizontalProducts = viewModel.filteredProducts.take(10).toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppText(
                  text: "Perfume\nHouse",
                  size: 28,
                  weight: FontWeight.w600,
                ),
                const Spacer(),
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
            ),
            6.gap,

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = viewModel.filteredProducts[index];
                return GridProductCard(
                  product: product,
                  onAdd: () => _handleAddToCart(product.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
