import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../data/product_service.dart';
import '../../widgets/product_list.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/search_bar.dart' as custom;
import '../../widgets/bottom_navigation.dart';
import '../../services/pdf_service.dart';
import 'add_product_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  int _currentIndex = 0;
  bool _isLoading = true;
  
  // Filter options
  String _selectedLocation = 'Tümü';
  String _selectedStockFilter = 'Tümü';
  List<String> _locations = ['Tümü'];
  bool _showLowStock = false;
  
  // View options
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await ProductService.getProducts();
      
      // Extract unique locations
      final locations = products
          .map((p) => p.location)
          .where((location) => location.isNotEmpty)
          .toSet()
          .toList();
      locations.sort();
      locations.insert(0, 'Tümü');
      
      setState(() {
        _products = products;
        _filteredProducts = products;
        _locations = locations;
        _isLoading = false;
      });
      
      // Apply current filters
      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürünler yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        // Search filter
        bool matchesSearch = _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Location filter
        bool matchesLocation = _selectedLocation == 'Tümü' ||
            product.location == _selectedLocation;
        
        // Stock filter
        bool matchesStock = true;
        if (_selectedStockFilter == 'Stokta Yok') {
          matchesStock = product.stock == 0;
        } else if (_selectedStockFilter == 'Az Stok') {
          matchesStock = product.stock > 0 && product.stock <= 5;
        } else if (_selectedStockFilter == 'Yeterli Stok') {
          matchesStock = product.stock > 5;
        }
        
        // Low stock filter
        bool matchesLowStock = !_showLowStock || product.stock <= 5;
        
        return matchesSearch && matchesLocation && matchesStock && matchesLowStock;
      }).toList();
    });
  }

  void _onLocationChanged(String? location) {
    setState(() {
      _selectedLocation = location ?? 'Tümü';
    });
    _applyFilters();
  }

  void _onStockFilterChanged(String? filter) {
    setState(() {
      _selectedStockFilter = filter ?? 'Tümü';
    });
    _applyFilters();
  }

  void _onLowStockToggle(bool? value) {
    setState(() {
      _showLowStock = value ?? false;
    });
    _applyFilters();
  }


  Future<void> _printProducts() async {
    // Check if there are products to print
    if (_filteredProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yazdırılacak ürün bulunamadı'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('PDF hazırlanıyor...'),
              ],
            ),
          );
        },
      );

      await PdfService.generateAndPrintProductList(_filteredProducts);
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulurken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareProducts() async {
    // Check if there are products to share
    if (_filteredProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paylaşılacak ürün bulunamadı'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('PDF hazırlanıyor...'),
              ],
            ),
          );
        },
      );

      await PdfService.generateAndShareProductList(_filteredProducts);
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF paylaşılırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    
    if (index == 1) {
      // Ekle sekmesi
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddProductScreen(),
        ),
      ).then((_) {
        // Geri dönüldüğünde ürünleri yenile
        _loadProducts();
        setState(() => _currentIndex = 0);
      });
    } else if (index == 2) {
      // Ayarlar sekmesi
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
        ),
      ).then((_) {
        setState(() => _currentIndex = 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ürünler',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Print Button
                  IconButton(
                    onPressed: _filteredProducts.isNotEmpty ? _printProducts : null,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.print,
                        color: _filteredProducts.isNotEmpty ? const Color(0xFFFF9800) : Colors.grey,
                        size: 24,
                      ),
                    ),
                    tooltip: 'Yazdır',
                  ),
                  // Share Button
                  IconButton(
                    onPressed: _filteredProducts.isNotEmpty ? _shareProducts : null,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.share,
                        color: _filteredProducts.isNotEmpty ? const Color(0xFF4CAF50) : Colors.grey,
                        size: 24,
                      ),
                    ),
                    tooltip: 'Paylaş',
                  ),
                  // View Toggle Button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _isGridView ? Icons.view_list : Icons.grid_view,
                        color: const Color(0xFF2196F3),
                        size: 24,
                      ),
                    ),
                    tooltip: _isGridView ? 'Liste Görünümü' : 'Grid Görünümü',
                  ),
                  // Add Product Button
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProductScreen(),
                        ),
                      ).then((_) => _loadProducts());
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF137FEC).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF137FEC),
                        size: 24,
                      ),
                    ),
                    tooltip: 'Ürün Ekle',
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: custom.SearchBar(
                onChanged: _filterProducts,
                onClear: () {
                  setState(() {
                    _searchQuery = '';
                  });
                  _applyFilters();
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Filter Options
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Location and Stock Filter Row
                  Row(
                    children: [
                      // Location Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLocation,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: _locations.map((String location) {
                                return DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(
                                    location,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: _onLocationChanged,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Stock Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStockFilter,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: const [
                                DropdownMenuItem(value: 'Tümü', child: Text('Tümü')),
                                DropdownMenuItem(value: 'Stokta Yok', child: Text('Stokta Yok')),
                                DropdownMenuItem(value: 'Az Stok', child: Text('Az Stok (≤5)')),
                                DropdownMenuItem(value: 'Yeterli Stok', child: Text('Yeterli Stok (>5)')),
                              ],
                              onChanged: _onStockFilterChanged,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Low Stock Toggle and Clear Filters
                  Row(
                    children: [
                      // Low Stock Toggle
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: _showLowStock,
                              onChanged: _onLowStockToggle,
                              activeColor: const Color(0xFF137FEC),
                            ),
                            const Text(
                              'Sadece Az Stoklu Ürünler',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      
                      // Clear Filters Button
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedLocation = 'Tümü';
                            _selectedStockFilter = 'Tümü';
                            _showLowStock = false;
                          });
                          _applyFilters();
                        },
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Temizle'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Product List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF137FEC),
                      ),
                    )
                  : _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Henüz ürün eklenmemiş'
                                    : 'Arama sonucu bulunamadı',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _isGridView
                          ? ProductGrid(
                              products: _filteredProducts,
                              onProductUpdated: _loadProducts,
                            )
                          : ProductList(
                              products: _filteredProducts,
                              onProductUpdated: _loadProducts,
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}