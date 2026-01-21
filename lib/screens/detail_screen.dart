import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warungku_mobile/models/product.dart';
import 'package:warungku_mobile/providers/cart_provider.dart';
import 'package:warungku_mobile/screens/cart_screen.dart';

class DetailScreen extends StatefulWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _quantity = 1;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _addToCart() {
    Provider.of<CartProvider>(context, listen: false).addToCart(widget.product, _quantity);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} (x$_quantity) ditambahkan ke keranjang!'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'LIHAT',
          textColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pushNamed(CartScreen.routeName);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildProductDetails(),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 2,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [
            Shadow(blurRadius: 5, color: Colors.black54)
          ]),
        ),
        centerTitle: true,
        background: Hero(
          tag: 'productImage-${widget.product.id}',
          child: Image.network(
            widget.product.imageUrl,
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.3),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price
            Text(
              currencyFormatter.format(widget.product.price),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Product Name
            Text(
              widget.product.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 16),
            // Stock Info
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Stok tersedia: ${widget.product.stock} unit',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 24),
            // Description
            Text(
              'Deskripsi Produk',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.product.description.isNotEmpty
                  ? widget.product.description
                  : 'Tidak ada deskripsi untuk produk ini.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black54,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 100), // Extra space to scroll past bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuantitySelector(),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _addToCart,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Tambah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              if (_quantity > 1) {
                setState(() {
                  _quantity--;
                });
              }
            },
            color: Colors.black54,
          ),
          Text(
            '$_quantity',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_quantity < widget.product.stock) {
                setState(() {
                  _quantity++;
                });
              } else {
                 ScaffoldMessenger.of(context).hideCurrentSnackBar();
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Stok tidak mencukupi!'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                 ));
              }
            },
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
