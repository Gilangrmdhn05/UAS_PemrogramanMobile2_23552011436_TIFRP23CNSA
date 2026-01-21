import 'package:flutter/foundation.dart';
import '../models/product.dart'; // Assuming you have a Product model

class OrderItem {
  final int productId;
  final String title;
  final int quantity;
  final double price;
  final String imageUrl; // Add imageUrl for display in order history

  OrderItem({
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'title': title,
      'quantity': quantity,
      'price': price,
      'image_url': imageUrl,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: int.parse(json['product_id'].toString()),
      title: json['title'] as String,
      quantity: int.parse(json['quantity'].toString()),
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] as String,
    );
  }
}

class Order {
  final String id;
  final double amount;
  final List<OrderItem> products;
  final DateTime dateTime;
  final String status; // e.g., 'pending', 'completed', 'cancelled'
  final String deliveryAddress;
  final String paymentMethod;
  final String? paymentId; // Transaction ID from payment gateway, if applicable

  Order({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.paymentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'products': products.map((item) => item.toJson()).toList(),
      'date_time': dateTime.toIso8601String(),
      'status': status,
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      'payment_id': paymentId,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      amount: double.parse(json['amount'].toString()),
      products: (json['products'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      dateTime: DateTime.parse(json['date_time'] as String),
      status: json['status'] as String,
      deliveryAddress: json['delivery_address'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentId: json['payment_id'] as String?,
    );
  }
}
