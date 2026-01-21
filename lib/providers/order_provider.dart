import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../utils/constants.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  String? _authToken;
  int? _userId;

  List<Order> get orders {
    return [..._orders];
  }

  void update(String? authToken, int? userId) {
    _authToken = authToken;
    _userId = userId;
    // Optionally fetch orders immediately after update if token/userId changed
    // if (_authToken != null && _userId != null) {
    //   fetchOrders();
    // }
  }

  Future<void> fetchOrders() async {
    if (_authToken == null || _userId == null) {
      // Handle scenario where user is not authenticated
      _orders = [];
      notifyListeners();
      return;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/orders.php?user_id=$_userId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      final responseData = json.decode(response.body);

      if (responseData['status'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to fetch orders.');
      }

      final List<Order> loadedOrders = [];
      responseData['data'].forEach((orderData) {
        loadedOrders.add(Order.fromJson(orderData));
      });
      _orders = loadedOrders.reversed.toList(); // Show newest orders first
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<OrderItem> orderItems, double total, String address, String paymentMethod) async {
    if (_authToken == null || _userId == null) {
      throw Exception('User not authenticated.');
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/order.php');
    final timestamp = DateTime.now();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'user_id': _userId,
          'metode_pembayaran': paymentMethod,
          'shipping_address': address, // The server might need this
          'items': orderItems
              .map((oi) => {
                    'product_id': oi.productId,
                    'quantity': oi.quantity,
                    'price': oi.price,
                  })
              .toList(),
        }),
      );

      if (response.statusCode >= 400) {
        throw Exception('Gagal membuat pesanan. Status: ${response.statusCode}, Body: ${response.body}');
      }
      
      final responseData = json.decode(response.body);

      if (responseData['status'] != true) {
        throw Exception(responseData['message'] ?? 'Gagal menempatkan pesanan dari server.');
      }
      
      final newOrderId = responseData['data']['order_id'];
      if (newOrderId == null) {
        throw Exception('ID Pesanan tidak diterima dari server.');
      }

      final newOrder = Order(
        id: newOrderId.toString(),
        amount: total,
        products: orderItems,
        dateTime: timestamp,
        status: 'pending',
        deliveryAddress: address,
        paymentMethod: paymentMethod,
      );

      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (error) {
      debugPrint('Error in addOrder: ${error.toString()}');
      rethrow;
    }
  }

  void addOrderLocally(List<OrderItem> orderItems, double total, String address, String paymentMethod) {
    final timestamp = DateTime.now();
    final newOrder = Order(
      id: DateTime.now().toString(),
      amount: total,
      products: orderItems,
      dateTime: timestamp,
      status: 'pending',
      deliveryAddress: address,
      paymentMethod: paymentMethod,
    );
    _orders.insert(0, newOrder);
    notifyListeners();
  }
}
