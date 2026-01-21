import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warungku_mobile/models/product.dart';
import 'package:warungku_mobile/providers/cart_provider.dart';
import 'package:warungku_mobile/screens/detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- IMAGE SECTION ---
          Expanded(
            child: InkWell(
              onTap: () => _navigateToDetail(context),
              child: Hero(
                tag: 'productImage-${product.id}',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // --- INFO SECTION ---
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1, // Limit to 1 line to save space
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter.format(product.price),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // --- ACTION BUTTONS ---
                Row(
                  children: [
                    // Detail Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToDetail(context),
                        icon: const Icon(Icons.visibility_outlined, size: 14),
                        label: const Text('Detail'),
                        style: _buttonStyle(context, isPrimary: false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: product.stock <= 0 ? null : () => _addToCart(context),
                        icon: const Icon(Icons.add_shopping_cart, size: 14),
                        label: const Text('Tambah'),
                        style: _buttonStyle(context, isPrimary: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(BuildContext context, {required bool isPrimary}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? Theme.of(context).primaryColor : Colors.white,
      foregroundColor: isPrimary ? Colors.white : Theme.of(context).primaryColor,
      side: isPrimary ? null : BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      elevation: isPrimary ? 2 : 0,
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(product: product),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    Provider.of<CartProvider>(context, listen: false).addToCart(product);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'LIHAT',
          textColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pushNamed('/cart');
          },
        ),
      ),
    );
  }
}
