import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart' as ord;

class OrderItemCard extends StatelessWidget {
  final ord.Order order;

  OrderItemCard(this.order);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ExpansionTile(
        title: Text('Rp ${order.amount.toStringAsFixed(0)}'),
        subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(order.dateTime)),
        trailing: Text('Status: ${order.status}'),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Pesanan:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('Alamat Pengiriman: ${order.deliveryAddress}'),
                Text('Metode Pembayaran: ${order.paymentMethod}'),
                if (order.paymentId != null)
                  Text('ID Pembayaran: ${order.paymentId}'),
                SizedBox(height: 10),
                Text(
                  'Produk Dipesan:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: order.products.length,
                  itemBuilder: (ctx, i) {
                    final product = order.products[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.imageUrl),
                      ),
                      title: Text(product.title),
                      subtitle: Text('Harga: Rp ${product.price.toStringAsFixed(0)}'),
                      trailing: Text('${product.quantity}x'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
