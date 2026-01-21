import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warungku_mobile/models/product.dart';
import 'package:warungku_mobile/providers/auth_provider.dart';
import 'package:warungku_mobile/providers/cart_provider.dart';
import 'package:warungku_mobile/providers/product_provider.dart';
import 'package:warungku_mobile/screens/cart_screen.dart';
import 'package:warungku_mobile/screens/profile_screen.dart';
import 'package:warungku_mobile/screens/order_screen.dart';
import 'package:warungku_mobile/utils/constants.dart';
import 'package:warungku_mobile/widgets/badge.dart';
import 'package:warungku_mobile/widgets/product_card.dart';
import 'dart:async'; // Import for Timer

// Simple FlashSale model for demonstration
class _FlashSale {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final List<Product> productsInSale; // Changed from List<String> productIds

  _FlashSale({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.productsInSale = const [], // Updated constructor
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Product> _filteredProducts = [];
  String? _selectedCategory; // For category filtering

  _FlashSale? _activeFlashSale;
  _FlashSale? _upcomingFlashSale;
  Duration _timeRemaining = Duration.zero;
  Timer? _countdownTimer;



  @override
  void initState() {
    super.initState();
    // Chain _initFlashSales after products are fetched
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _productsFuture = Provider.of<ProductProvider>(context, listen: false).fetchAndSetProducts().then((_) {
      _initFlashSales(); // Initialize flash sales after products are loaded
      _filterProducts(); // Filter products after flash sales are initialized
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _countdownTimer?.cancel(); // Cancel timer
    super.dispose();
  }

  void _initFlashSales() {
    final now = DateTime.now();
    final allProducts = Provider.of<ProductProvider>(context, listen: false).items;

    // Filter products for mock flash sales
    final flashSaleProducts1 = allProducts.where((p) => ['p1', 'p2', 'p3'].contains(p.id)).toList();
    final flashSaleProducts2 = allProducts.where((p) => ['p4', 'p5'].contains(p.id)).toList();

    // Mock Flash Sales (replace with actual data fetching)
    // Active flash sale (ends 1 hour from now)
    final mockActiveSale = _FlashSale(
      id: 'fs1',
      startTime: now.subtract(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 1)),
      productsInSale: flashSaleProducts1, // Assign actual products
    );

    // Upcoming flash sale (starts 2 days from now)
    final mockUpcomingSale = _FlashSale(
      id: 'fs2',
      startTime: now.add(const Duration(days: 2)),
      endTime: now.add(const Duration(days: 2, hours: 2)),
      productsInSale: flashSaleProducts2, // Assign actual products
    );

    setState(() { // setState here to trigger UI update for flash sale section
      if (now.isAfter(mockActiveSale.startTime) && now.isBefore(mockActiveSale.endTime)) {
        _activeFlashSale = mockActiveSale;
        _timeRemaining = _activeFlashSale!.endTime.difference(now);
        _startCountdown();
      } else if (now.isBefore(mockUpcomingSale.startTime)) {
        _upcomingFlashSale = mockUpcomingSale;
        _timeRemaining = _upcomingFlashSale!.startTime.difference(now);
        _startCountdown();
      }
    });
  }

  Future<void> _onRefresh() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<ProductProvider>(context, listen: false).fetchAndSetProducts();
    _filterProducts(); // Re-filter after refresh
    _initFlashSales(); // Refresh flash sales too
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final now = DateTime.now();
        if (_activeFlashSale != null) {
          _timeRemaining = _activeFlashSale!.endTime.difference(now);
          if (_timeRemaining.isNegative) {
            _activeFlashSale = null;
            timer.cancel();
            _initFlashSales(); // Re-initialize to check for upcoming or reset
          }
        } else if (_upcomingFlashSale != null) {
          _timeRemaining = _upcomingFlashSale!.startTime.difference(now);
          if (_timeRemaining.isNegative) {
            _activeFlashSale = _upcomingFlashSale;
            _upcomingFlashSale = null;
            timer.cancel();
            _initFlashSales(); // Re-initialize to start countdown for active sale
          }
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _filterProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    List<Product> products = productProvider.items;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      products = products.where((product) {
        // product.categoryName now holds the category ID
        return product.categoryName == _selectedCategory;
      }).toList();
    }

    setState(() {
      _filteredProducts = products;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterProducts();
    });
  }

  Widget _buildGreetingBanner() {
    final userName = Provider.of<AuthProvider>(context, listen: false).userName;
    return Column( // Wrap in Column to add margin-bottom SizedBox
      children: [
        Container(
          width: double.infinity,
          // Web has padding: 30px 0; and then content inside a container,
          // so apply vertical padding here and horizontal to the inner content.
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, // Matches 135deg approximately
              end: Alignment.bottomRight,
              colors: [Color(0xFF198754), Color(0xFF20c997)], // Matching web gradient
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // Apply horizontal padding here
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang Kembali, ${userName ?? 'Pengguna'} 👋',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700, // Matching web font weight
                        fontSize: 28.8, // 1.8rem * 16px/rem = 28.8px
                      ),
                ),
                const SizedBox(height: 10), // Matching margin-bottom: 10px
                Text(
                  'Temukan produk favorit Anda dengan harga terbaik',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.95), // Matching web opacity
                        fontSize: 16, // 1rem * 16px/rem = 16px
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30), // Matching web margin-bottom: 30px
      ],
    );
  }

  Widget _buildFlashSaleSection() {
    String flashSaleIcon;
    String flashSaleTitle;
    String flashSaleCountdownText;
    List<Color> gradientColors;
    bool showFlashSaleProducts = false;

    if (_activeFlashSale != null && !_timeRemaining.isNegative) {
      flashSaleIcon = '⚡';
      flashSaleTitle = 'Flash Sale!';
      final hours = _timeRemaining.inHours;
      final minutes = _timeRemaining.inMinutes.remainder(60);
      final seconds = _timeRemaining.inSeconds.remainder(60);
      flashSaleCountdownText = 'Penawaran terbatas! Berakhir dalam: '
          '${hours.toString().padLeft(2, '0')} Jam '
          '${minutes.toString().padLeft(2, '0')} Menit '
          '${seconds.toString().padLeft(2, '0')} Detik';
      gradientColors = [const Color(0xFFFF4757), const Color(0xFFFF6B7A)]; // Red gradient
      showFlashSaleProducts = true;
    } else if (_upcomingFlashSale != null && !_timeRemaining.isNegative) {
      flashSaleIcon = '🎉';
      flashSaleTitle = 'Flash Sale Akan Datang!';
      final days = _timeRemaining.inDays;
      final hours = _timeRemaining.inHours.remainder(24);
      flashSaleCountdownText = 'Flash Sale dimulai dalam $days hari $hours jam lagi';
      gradientColors = [const Color(0xFFFFC107), const Color(0xFFFF9800)]; // Orange gradient
    } else {
      flashSaleIcon = '📢';
      flashSaleTitle = 'Tunggu Flash Sale Berikutnya';
      flashSaleCountdownText = 'Flash sale akan segera hadir dengan penawaran spesial!';
      gradientColors = [const Color(0xFF6C757D), const Color(0xFF5A6268)]; // Grey gradient
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(flashSaleIcon, style: const TextStyle(fontSize: 25)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flashSaleTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        flashSaleCountdownText,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showFlashSaleProducts) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                'Produk Flash Sale',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250, // Height for the horizontal list, adjust as needed for ProductCard height
              child: (_activeFlashSale != null && _activeFlashSale!.productsInSale.isNotEmpty)
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      itemCount: _activeFlashSale!.productsInSale.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: SizedBox( // Wrap ProductCard in SizedBox to give it a fixed width for horizontal list
                          width: 180, // Adjust width as needed for proper display in horizontal list
                          child: ProductCard(product: _activeFlashSale!.productsInSale[i]),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'Tidak ada produk di Flash Sale ini.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
            ),
          ] else ...[
            // Message if no active flash sale products
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  _activeFlashSale == null && _upcomingFlashSale == null
                      ? 'Tidak ada flash sale saat ini.'
                      : 'Nantikan produk-produk menarik di flash sale ini!',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          const SizedBox(height: 15), // Add some bottom padding
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    // Mock categories for demonstration. In a real app, fetch from ProductProvider.

    return Container(
      // The web version uses padding-left/right: 25px, padding-top/bottom: 25px
      // border-radius: 12px, margin-bottom: 30px, box-shadow, border-top: 4px
      margin: const EdgeInsets.only(bottom: 30), // Matching web margin-bottom
      padding: const EdgeInsets.all(25), // Matching web padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Matching web border-radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Slightly adjusted for Flutter
            blurRadius: 15, // Matching web blur
            offset: const Offset(0, 4), // Matching web offset
          ),
        ],
        border: Border(
          top: BorderSide(color: Theme.of(context).primaryColor, width: 4), // Matching web border-top
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Theme.of(context).primaryColor, size: 24), // bi bi-funnel
              const SizedBox(width: 10),
              const Text(
                'Filter & Pencarian', // Changed title to match web
                style: TextStyle(
                  fontWeight: FontWeight.w700, // Matching web font weight
                  color: Color(0xFF1a1a1a), // Matching web color
                  fontSize: 16, // Matching web font size
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Matching web margin-bottom
          // Only Category Dropdown remains in filter section
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              hintText: 'Pilih Kategori',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 2), // Matching web border
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Matching web padding
            ),
            items: ApiConstants.mockCategories.map((cat) {
              return DropdownMenuItem(
                value: cat['id'],
                child: Text(cat['name']!, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))), // Matching web font size and color
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value == '' ? null : value;
              });
            },
            style: const TextStyle(color: Color(0xFF333333)),
            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 12), // Matching web gap
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _filterProducts(); // Apply filter
                  },
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Cari', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF198754), // Matching web gradient start
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12), // Matching web padding
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0, // Handled by container shadow
                    shadowColor: const Color(0xFF198754).withOpacity(0.15), // Matching web box-shadow
                  ),
                ),
              ),
              if (_selectedCategory != null && _selectedCategory!.isNotEmpty) ...[
                const SizedBox(width: 12), // Matching web gap
                Expanded(
                  child: ElevatedButton.icon( // Changed to ElevatedButton for consistency
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null; // Reset filter
                        _filterProducts();
                      });
                    },
                    icon: const Icon(Icons.close, size: 18), // bi bi-x-circle
                    label: const Text('Reset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C757D), // Matching web reset button gradient start
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0, // Handled by container shadow
                      shadowColor: const Color(0xFF6C757D).withOpacity(0.15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Margin to align with web layout
      height: 45, // Slightly adjusted height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Matching web box-shadow
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Adjust padding
        ),
        style: const TextStyle(fontSize: 14),
        onChanged: (value) {
          _onSearchChanged(); // Triggers filtering
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        toolbarHeight: 70, // Increased height for better spacing
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              // Navigate to home or refresh
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF198754),
                      Color(0xFF20c997),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.shop,
                    color: Colors.white, // Color is masked by shader
                    size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF198754),
                      Color(0xFF20c997),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Warungku',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white, // Color is masked by shader
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, ch) => BadgeWidget(
              value: cart.itemCount.toString(),
              child: ch!,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF2D3436), size: 28),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2D3436), size: 28), // Changed to bag-check equivalent
            onPressed: () {
              Navigator.of(context).pushNamed(OrderScreen.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF2D3436), size: 28), // Changed to person-circle equivalent
            onPressed: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
          ),
          const SizedBox(width: 8), // Add some spacing at the end
        ],
      ),
      body: FutureBuilder(
        future: _productsFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (dataSnapshot.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat produk.', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Coba Lagi'),
                  )
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView( // Use SingleChildScrollView instead of ListView directly inside RefreshIndicator
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingBanner(),
                    _buildSearchBar(), // Integrated search bar here
                    const SizedBox(height: 20),
                    _buildFlashSaleSection(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildFilterSection(),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.category, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Produk Tersedia',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (_filteredProducts.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_filteredProducts.length} Produk',
                                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _filteredProducts.isEmpty && _searchQuery.isNotEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'Tidak ada produk yang ditemukan.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: LayoutBuilder( // Use LayoutBuilder for responsive grid
                              builder: (context, constraints) {
                                int crossAxisCount = 2; // Default for smaller screens
                                double childAspectRatio = 0.7; // Adjusted for 2 columns

                                if (constraints.maxWidth > 600) { // Medium to large screens
                                  crossAxisCount = 3;
                                  childAspectRatio = 0.6; // Adjusted for 3 columns
                                }
                                // You can add more breakpoints if needed, e.g., for very large screens
                                
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(8),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: childAspectRatio,
                                  ),
                                  itemCount: _filteredProducts.length,
                                  itemBuilder: (ctx, i) => ProductCard(product: _filteredProducts[i]),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 40), // Space before footer
                 // Add the footer
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
  }
