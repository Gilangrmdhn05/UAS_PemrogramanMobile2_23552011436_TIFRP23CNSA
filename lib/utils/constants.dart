// lib/utils/constants.dart

// =====================================================================================
// =====================================================================================
//
//   ‼️  PENTING: ANDA HARUS MENGATUR ALAMAT IP DI FILE INI   ‼️
//
// =====================================================================================
//
//  Aplikasi tidak bisa terhubung ke server XAMPP Anda karena alamat IP belum diatur.
//  Ikuti langkah-langkah di bawah ini untuk memperbaikinya.
//
//  LANGKAH 1: CARI TAHU ALAMAT IP KOMPUTER ANDA
//  -------------------------------------------------
//  1. Buka Command Prompt di Windows.
//  2. Ketik perintah ini lalu tekan Enter:
//
//     ipconfig
//
//  3. Cari bagian "Wireless LAN adapter Wi-Fi" atau "Ethernet adapter Ethernet".
//  4. Temukan alamat "IPv4 Address". Alamatnya akan terlihat seperti `192.168.1.10`.
//
//
//  LANGKAH 2: MASUKKAN ALAMAT IP ANDA DI BAWAH
//  -------------------------------------------------
//  Ganti alamat IP di dalam tanda kutip di bawah ini dengan alamat IP yang Anda temukan
//  di LANGKAH 1.
//
//  Contoh: Jika IP Anda 192.168.1.10, maka baris di bawah akan menjadi:
//  static const String _host = 'http://192.168.1.10/warungku';
//
// =====================================================================================

class ApiConstants {
  // ‼️ PENTING: GANTI IP_ANDA_DI_SINI DENGAN IP LOKAL KOMPUTER ANDA ‼️
  // Caranya: buka CMD, ketik `ipconfig`, cari alamat IPv4 di koneksi Wi-Fi Anda.
  // Pastikan HP dan komputer ada di jaringan Wi-Fi yang sama.
  static const String _host = 'http://192.168.56.1/warungku'; // Ganti IP_ANDA_DI_SINI

  // --- (Jangan ubah bagian di bawah ini) ---

  /// Base URL untuk API.
  static const String baseUrl = '$_host/api';

  /// Base URL untuk gambar produk.
  static const String imageBaseUrl = '$_host/assets/images/produk/';

  /// Mock categories moved from home_screen.dart
  static const List<Map<String, String>> mockCategories = [
    {'id': '', 'name': '-- Semua Kategori --'},
    {'id': '1', 'name': 'Minuman'},
    {'id': '2', 'name': 'Pakaian Pria'},
    {'id': '3', 'name': 'Elektronik'},
    {'id': '4', 'name': 'Makanan'},
    {'id': '5', 'name': 'Kecantikan'},
    {'id': '6', 'name': 'Rumah'},
    {'id': '7', 'name': 'Olahraga'},
    {'id': '8', 'name': 'Aksesoris pria'},
    {'id': '9', 'name': 'Aksesoris wanita'},
    {'id': '10', 'name': 'Pakaian wanita'},
    {'id': '11', 'name': 'Sepatu pria'},
    {'id': '12', 'name': 'Sepatu wanita'},
    {'id': '13', 'name': 'Aksesoris Pria'}, // Ensure ID matches your product data
    {'id': '14', 'name': 'Aksesoris Wanita'}, // Ensure ID matches your product data
    {'id': '15', 'name': 'Pakaian Wanita'}, // Ensure ID matches your product data
    {'id': '16', 'name': 'Sepatu Pria'}, // Ensure ID matches your product data
    {'id': '17', 'name': 'Sepatu Wanita'}, // Ensure ID matches your product data
  ];

  static String getCategoryNameById(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return 'Uncategorized';
    }
    final categoryMap = mockCategories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'name': 'Uncategorized'},
    );
    return categoryMap['name']!;
  }
}