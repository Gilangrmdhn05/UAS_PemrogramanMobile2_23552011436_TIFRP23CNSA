import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warungku_mobile/models/order.dart';
import 'package:warungku_mobile/providers/auth_provider.dart';
import 'package:warungku_mobile/providers/cart_provider.dart';
import 'package:warungku_mobile/providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedPaymentMethod;
  bool _isLoading = false;
  final _addressController = TextEditingController(text: "Alamat Dummy");

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu!')),
      );
      return;
    }
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat pengiriman tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final orders = Provider.of<OrderProvider>(context, listen: false);

      if (auth.userId == null || auth.token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login untuk melakukan checkout.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Convert CartItems to OrderItems
      final List<OrderItem> orderItems = cart.items.values.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id,
          title: cartItem.product.name,
          quantity: cartItem.quantity,
          price: cartItem.product.price,
          imageUrl: cartItem.product.imageUrl,
        );
      }).toList();

      orders.addOrderLocally(
        orderItems,
        cart.totalAmount,
        _addressController.text,
        _selectedPaymentMethod!,
      );

      cart.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dibuat!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst); // Go back to home

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${error.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: cart.itemCount == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text('Keranjang Anda kosong.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 10),
                  const Text('Tidak ada item untuk di-checkout.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.storefront_outlined),
                    label: const Text('Mulai Belanja'),
                     style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  )
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section: Alamat Pengiriman
                        _buildSectionCard(
                          context,
                          title: 'Alamat Pengiriman',
                          child: TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan alamat lengkap Anda',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: 2,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section: Detail Pesanan
                        _buildSectionCard(
                          context,
                          title: 'Detail Pesanan',
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cart.items.length,
                            separatorBuilder: (ctx, i) => Divider(height: 1, color: Colors.grey[200]),
                            itemBuilder: (ctx, i) {
                              final cartItem = cart.items.values.toList()[i];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    cartItem.product.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 50),
                                  ),
                                ),
                                title: Text(cartItem.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${cartItem.quantity} x ${currencyFormatter.format(cartItem.product.price)}'),
                                trailing: Text(
                                  currencyFormatter.format(cartItem.quantity * cartItem.product.price),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section: Metode Pembayaran
                        _buildSectionCard(
                          context,
                          title: 'Metode Pembayaran',
                          child: Column(
                            children: [
                              _buildPaymentMethodTile('bank_transfer', 'Transfer Bank'),
                              _buildPaymentMethodTile('cash_on_delivery', 'Pembayaran Tunai (COD)'),
                              _buildPaymentMethodTile('e_wallet', 'E-Wallet (GoPay, OVO)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Summary Bar
                _buildSummaryBar(context, cart),
              ],
            ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget child}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(String value, String title) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (val) {
        setState(() {
          _selectedPaymentMethod = val;
        });
      },
      contentPadding: EdgeInsets.zero,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildSummaryBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Bayar:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              Text(
                currencyFormatter.format(cart.totalAmount),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text('Buat Pesanan Sekarang'),
            ),
          ),
        ],
      ),
    );

  }
}