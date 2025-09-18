import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../data/product_service.dart';
import '../../widgets/product_list.dart';
import '../../widgets/search_bar.dart' as custom;
import '../../widgets/bottom_navigation.dart';
import 'add_product_screen.dart';
import 'settings_screen.dart';
import 'output_screen.dart';

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
  
  // Filtreleme seçenekleri
  String _selectedFilter = 'Tümü';
  final List<String> _filterOptions = [
    'Tümü',
    'Stokta Var',
    'Stokta Yok',
    'A-Z Sırala',
    'Z-A Sırala',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await ProductService.getProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
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
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Product> filtered = _products;

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Kategori filtresi
    switch (_selectedFilter) {
      case 'Stokta Var':
        filtered = filtered.where((product) => product.stock > 0).toList();
        break;
      case 'Stokta Yok':
        filtered = filtered.where((product) => product.stock == 0).toList();
        break;
      case 'A-Z Sırala':
        filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'Z-A Sırala':
        filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'Tümü':
      default:
        // Sıralama yapma
        break;
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _showOutputScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OutputScreen(
          products: _filteredProducts,
          filterType: _selectedFilter,
          searchQuery: _searchQuery,
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Uygulamayı Kapat',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Text(
            'Uygulamayı kapatmak istediğinizden emin misiniz?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _exitApp();
              },
              child: Text(
                'Kapat',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _exitApp() {
    // iOS'ta uygulamayı kapatmak için exit(0) kullanıyoruz
    exit(0);
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ürünler',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        if (!_isLoading)
                          Text(
                            '${_filteredProducts.length} ürün gösteriliyor',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Çıktı Butonu
                      IconButton(
                        onPressed: _filteredProducts.isEmpty ? null : _showOutputScreen,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: Color(0xFF10B981),
                            size: 24,
                          ),
                        ),
                        tooltip: 'Çıktı Al',
                      ),
                      const SizedBox(width: 8),
                      // Çıkış Butonu
                      IconButton(
                        onPressed: _showExitDialog,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        tooltip: 'Uygulamayı Kapat',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: custom.SearchBar(
                onChanged: _filterProducts,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filter Options
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = _filterOptions[index];
                  final isSelected = _selectedFilter == filter;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _onFilterChanged(filter);
                        }
                      },
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: const Color(0xFF137FEC),
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF137FEC) : Theme.of(context).dividerColor,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
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