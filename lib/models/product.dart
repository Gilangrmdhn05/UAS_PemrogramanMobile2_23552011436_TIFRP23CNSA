import 'package:warungku_mobile/utils/constants.dart';

class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price; // This will be the displayed price (could be discounted)
  final double? originalPrice; // Original price before discount, if any
  final int? discountPercentage; // Discount percentage, if any
  final bool isFlashSale;
  final String description;
  final int stock;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    this.isFlashSale = false,
    required this.description,
    required this.stock,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['gambar'] as String? ?? '';
    
    // If the URL is just a filename, prepend the base URL for images
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = ApiConstants.imageBaseUrl + imageUrl;
    }
    
    // Use a placeholder if the URL is still empty
    if (imageUrl.isEmpty) {
      imageUrl = 'https://via.placeholder.com/300x300?text=No+Image';
    }

    final bool hasFlashSale = json['id_flash'] != null;
    final double? parsedHargaNormal = double.tryParse(json['harga_normal']?.toString() ?? '');
    final double? parsedHargaFinal = double.tryParse(json['harga_final']?.toString() ?? '');
    final int? parsedDiskonPersen = int.tryParse(json['diskon_persen']?.toString() ?? '');

    return Product(
      id: int.parse(json['id_produk'].toString()),
      name: json['nama_produk'] as String,
      imageUrl: imageUrl,
      price: parsedHargaFinal ?? 0.0, // Use 0.0 as default if parsing fails
      originalPrice: hasFlashSale ? parsedHargaNormal : null,
      discountPercentage: hasFlashSale ? parsedDiskonPersen : null,
      isFlashSale: hasFlashSale,
      description: json['deskripsi'] as String? ?? '',
      stock: int.parse(json['stok'].toString()),
      categoryName: json['id_kategori'].toString(), // Map id_kategori for now
    );
  }
}