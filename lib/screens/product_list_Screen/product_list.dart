// product_list.dart - Fixed version
import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Button.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';
import 'package:perfumeapp/screens/product_list_Screen/product_list_viewmodel.dart';
import 'package:perfumeapp/screens/product_list_Screen/widgets/grid_product_card.dart';
import 'package:perfumeapp/screens/product_list_Screen/widgets/horizontal_product_card.dart';
import 'package:perfumeapp/screens/product_list_Screen/widgets/list_Product_Card.dart';
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
            // appBar: AppBar(
            //   title: const Text('Perfume Store'),
            //   actions: [
            //     IconButton(
            //       icon: const Icon(Icons.shopping_cart),
            //       onPressed: () async {
            //         final cartId = await ProductListViewModel.getCartId();
            //         if (cartId == null) {
            //           if (mounted) {
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               const SnackBar(content: Text('Cart is empty')),
            //             );
            //           }
            //           return;
            //         }
            //         if (mounted) {
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (_) => CartScreen(cartId: cartId),
            //             ),
            //           );
            //         }
            //       },
            //     ),
            //   ],
            //   leading: Builder(
            //     builder: (context) => IconButton(
            //       icon: const Icon(Icons.menu),
            //       onPressed: () => Scaffold.of(context).openDrawer(),
            //     ),
            //   ),
            // ),
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
    final horizontalProducts = viewModel.filteredProducts.take(10).toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Header
            AppText(text: "Perfume\nHouse", size: 28, weight: FontWeight.w600),

            const SizedBox(height: 20),

            /// 🔹 Horizontal Scroll
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: horizontalProducts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: HorizontalProductCard(
                      product: horizontalProducts[index],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            /// 🔹 Popular Products Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Popular Products",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/allProductView'),
                  child: Container(
                    height: 25,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "See All",
                        style: TextStyle(fontSize: 12, color: AppColors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔹 Grid Products (2 per row)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.filteredProducts.length > 10
                  ? 10
                  : viewModel.filteredProducts.length,
              itemBuilder: (context, index) {
                final product = viewModel.filteredProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ListProductCard(
                    product: product,
                    onAdd: () => _handleAddToCart(product.id),
                  ),
                );
              },
            ),
            Center(
              child: SizedBox(
                width: 200,
                child: AppButton(
                  text: "See All",
                  onPressed: () {
                    Navigator.pushNamed(context, '/allProductView');
                  },
                ),
              ),
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
