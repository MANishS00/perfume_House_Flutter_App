import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/card_Container.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';
import 'package:perfumeapp/models/product.dart';
import 'package:perfumeapp/screens/product_details/product_details_screen.dart';

class ListProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const ListProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

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
      child: AppCardContainer(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: 70,
                height: 90,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 12),

            // 📄 Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: "${product.size} ml",
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  4.gap,
                  AppText(
                    text: product.description,
                    maxLines: 1,
                    size: 12,
                    color: Colors.grey.shade600,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 💲 Price + Cart
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Price",
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
                4.gap,
                Text(
                  "${product.price.toStringAsFixed(0)} ₹",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: onAdd,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
