import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';
import 'package:perfumeapp/models/product.dart';
import 'package:perfumeapp/screens/product_details/product_details_screen.dart';

class HorizontalProductCard extends StatelessWidget {
  final Product product;

  const HorizontalProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },

      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            10.gap,
            Column(
              children: [
                Expanded(child: Container()),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: product.category == 'Women'
                                  ? Colors.pink
                                  : product.category == 'Men'
                                  ? Colors.black
                                  : Colors.blueGrey,

                              border: Border.all(
                                color: product.category == 'Women'
                                    ? Colors.pink
                                    : product.category == 'Men'
                                    ? Colors.black
                                    : Colors.blueGrey,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: AppText(
                                text: product.category.toUpperCase(),
                                size: 12,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Center(
                          child: AppText(
                            text: product.name,
                            size: 9,
                            align: TextAlign.center,
                          ),
                        ),
                      ),

                      10.gap,
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
