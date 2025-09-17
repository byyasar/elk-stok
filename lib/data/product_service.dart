import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _productsTableName = 'products';

  static Future<List<Product>> getProducts() async {
    // Mevcut kullanıcının ID'sini al
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }
    
    // Sadece mevcut kullanıcının ürünlerini getir
    final List<dynamic> productsData = await _supabase
        .from(_productsTableName)
        .select()
        .eq('user_id', currentUser.id);
    
    print('Supabase\'den ürünler alındı: ${productsData.length} adet (User ID: ${currentUser.id})'); // Debug için
    for (var product in productsData) {
      print('Ürün: ${product['name']} - User ID: ${product['user_id']} - Resim: ${product['imageUrl']}'); // Debug için
    }
    return productsData.map((json) => Product.fromSupabaseJson(json)).toList();
  }

  static Future<void> addProduct(Product product) async {
    // Mevcut kullanıcının ID'sini al
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }
    
    // Ürün verilerine user_id ekle
    final productData = product.toSupabaseJson();
    productData['user_id'] = currentUser.id;
    
    print('Supabase\'e ürün ekleniyor: $productData'); // Debug için
    await _supabase.from(_productsTableName).insert(productData);
    print('Ürün başarıyla eklendi - User ID: ${currentUser.id}'); // Debug için
  }

  static Future<void> updateProduct(Product product) async {
    // Mevcut kullanıcının ID'sini al
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }
    
    // Ürün verilerine user_id ekle
    final productData = product.toSupabaseJson();
    productData['user_id'] = currentUser.id;
    
    print('Ürün güncelleniyor - ID: ${product.id}, User ID: ${currentUser.id}'); // Debug için
    await _supabase
        .from(_productsTableName)
        .update(productData)
        .eq('id', product.id!);
    print('Ürün başarıyla güncellendi'); // Debug için
  }

  static Future<void> deleteProduct(String productId) async {
    // Mevcut kullanıcının ID'sini al
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }
    
    print('Ürün siliniyor - ID: $productId, User ID: ${currentUser.id}'); // Debug için
    await _supabase
        .from(_productsTableName)
        .delete()
        .eq('id', productId)
        .eq('user_id', currentUser.id); // Sadece kendi ürününü silebilsin
    print('Ürün başarıyla silindi'); // Debug için
  }
}