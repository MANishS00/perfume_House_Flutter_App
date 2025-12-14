import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/card_Container.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';

class CartItemTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String size;
  final String price;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.size,
    required this.price,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppCardContainer(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            /// Product Image
            imagePath.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      imagePath,
                      height: 80,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                  )
                : const SizedBox(
                    height: 80,
                    width: 50,
                    child: Icon(Icons.image_not_supported),
                  ),

            const SizedBox(width: 16),

            /// Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(text: title, size: 18, weight: FontWeight.w700),
                  4.gap,

                  AppText(text: size, size: 14, color: Colors.black54),

                  const SizedBox(height: 8),

                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB45309), // orange-brown
                    ),
                  ),
                ],
              ),
            ),

            /// Quantity Controller
            Row(
              children: [
                _CircleButton(icon: Icons.remove, onTap: onIncrement),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                _CircleButton(
                  icon: Icons.add,
                  backgroundColor: const Color(0xFFB45309),
                  iconColor: Colors.white,
                  onTap: onDecrement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable circular button
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor = const Color(0xFF2C2F36),
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
