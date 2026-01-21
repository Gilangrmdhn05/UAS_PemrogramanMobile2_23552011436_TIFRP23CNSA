import 'dart:convert';
import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:warungku_mobile/utils/constants.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  bool _isLoading = true;

  List<Product> get items => [..._items];
  bool get isLoading => _isLoading;

  // Definees
  final List<String> _mockCategoryNames = const [
    'Minuman',
    'Pakaian pria',
    'Elektronik',
    'Makanan',
    'Kecantikan',
    'Rumah',
    'Olahraga',
    'Aksesoris pria',
    'Aksesoris wanita',
    'Pakaian wanita',
    'Sepatu pria',
    'Sepatu wanita',
  ];
  final Random _random = Random();

  String? _authToken;

  void update(String? token, int? userId) {
    _authToken = token;
  }

  Future<void> fetchAndSetProducts() async {
    _isLoading = true;
    notifyListeners();
    final url = Uri.parse('${ApiConstants.baseUrl}/produk.php');
    
    try {
      final response = await http.get(
        url,
        headers: _authToken != null ? {'Authorization': 'Bearer $_authToken'} : {},
      );

      final extractedData = json.decode(response.body);

      if (extractedData == null || extractedData['status'] != true) {
        throw Exception('Gagal memuat data produk: ${response.body}');
      }

      final List<dynamic> productData = extractedData['data'];
      
      List<Product> loadedProducts = productData
          .map((prodData) => Product.fromJson(prodData as Map<String, dynamic>))
          .toList();

      // Assign mock categories if categoryName is null or empty
      loadedProducts = loadedProducts.map((product) {
        if (product.categoryName == null || product.categoryName!.isEmpty || product.categoryName == '0') {
          return Product(
            id: product.id, name: product.name, imageUrl: product.imageUrl, price: product.price,
            description: product.description, stock: product.stock, isFlashSale: product.isFlashSale,
            originalPrice: product.originalPrice, discountPercentage: product.discountPercentage,
            categoryName: _mockCategoryNames[_random.nextInt(_mockCategoryNames.length)],
          );
        }
        return product;
      }).toList();


      _items = loadedProducts;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Product findById(int id) {
    return _items.firstWhere((prod) => prod.id == id);
  }
}
  