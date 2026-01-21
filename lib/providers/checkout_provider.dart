import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:warungku_mobile/providers/cart_provider.dart';

import 'package:warungku_mobile/utils/constants.dart'; // For API base URL

class CheckoutProvider with ChangeNotifier {
  Future<bool> placeOrder(
    int userId,
    String token,
    List<CartItem> cartItems,
    String paymentMethod,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/order.php'); // Hypothetical order API endpoint

    try {
      final List<Map<String, dynamic>> products = cartItems.map((item) => {
            'product_id': item.product.id,
            'name': item.product.name,
            'quantity': item.quantity,
            'price': item.product.price,
          }).toList();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Assuming token-based authentication
        },
        body: json.encode({
          'user_id': userId,
          'products': products,
          'payment_method': paymentMethod,
          'total_amount': cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity)),
          // Add other necessary details like shipping address if applicable
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          // Order placed successfully
          return true;
        } else {
          // Handle API-specific errors
          debugPrint('Failed to place order: ${responseData['message']}');
          return false;
        }
      } else {
        // Handle HTTP errors
        debugPrint('HTTP Error: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (error) {
      debugPrint('Error placing order: $error');
      return false;
    }
  }
}
