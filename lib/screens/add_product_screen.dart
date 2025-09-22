import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product.dart';
import '../../data/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  
  File? _selectedImage;
 //String? _uploadedImageUrl; // Supabase'e yüklenen resmin URL'si
  String _imageUrl = 'https://images.pexels.com/photos/1029624/pexels-photo-1029624.jpeg'; // Varsayılan resim URL'si
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resim seçilirken hata oluştu: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _selectImageSource() async {
      showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: Theme.of(context).textTheme.bodyLarge?.color),
                title: Text('Galeriden Seç', style: Theme.of(context).textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Theme.of(context).textTheme.bodyLarge?.color),
                title: Text('Kameradan Çek', style: Theme.of(context).textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final String objectPath = fileName; // Sadece dosya adı, 'products/' klasörü ekleme
      final bytes = await imageFile.readAsBytes();

      print('Resim yükleniyor - Dosya: $fileName, Boyut: ${bytes.length} bytes'); // Debug için

      await Supabase.instance.client.storage
          .from('product_images')
          .uploadBinary(
            objectPath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );
      
      final String publicUrl = Supabase.instance.client.storage.from('product_images').getPublicUrl(objectPath);
      print('Oluşturulan Public URL: $publicUrl'); // Debug için
      print('Resim yüklendi - Public URL: $publicUrl'); // Debug için
      return publicUrl;
    } catch (e) {
      print('Resim yükleme hatası: $e'); // Debug için
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resim yüklenirken hata oluştu: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _imageUrl; // Varsayılan bir resim URL'si ile başlat

      if (_selectedImage != null) {
        final uploadedUrl = await _uploadImageToSupabase(_selectedImage!);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
          print('Resim başarıyla yüklendi: $finalImageUrl'); // Debug için
        } else {
          print('Resim yüklenemedi, varsayılan resim kullanılıyor'); // Debug için
        }
      }

      final product = Product(
        name: _nameController.text.trim(),
        imageUrl: finalImageUrl,
        stock: int.parse(_stockController.text.trim()),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        price: _priceController.text.trim().isNotEmpty 
            ? double.tryParse(_priceController.text.trim()) 
            : null,
        createdAt: DateTime.now(),
      );

      print('Ürün kaydediliyor - Resim URL: $finalImageUrl'); // Debug için
      await ProductService.addProduct(product);

      if (mounted) {
        Navigator.pop(context, product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ürün başarıyla eklendi'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      print('Ürün kaydetme hatası: $e'); // Debug için
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ürün eklenirken hata oluştu: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Yeni Ürün Ekle',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Center(
                        child: GestureDetector(
                          onTap: _selectImageSource,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              image: _selectedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: NetworkImage(_imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Basic Information
                      Text(
                        'Temel Bilgiler',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // Product Name
                      Text(
                        'Ürün Adı *',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Örn: Mavi T-Shirt',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ürün adı gereklidir';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        'Açıklama',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Ürün özelliklerini girin',
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Stock and Price
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adet *',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _stockController,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Adet gereklidir';
                                    }
                                    if (int.tryParse(value.trim()) == null) {
                                      return 'Geçerli bir sayı girin';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fiyat (₺)',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _priceController,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    hintText: '0.00',
                                  ),
                                  validator: (value) {
                                    if (value != null && value.trim().isNotEmpty) {
                                      if (double.tryParse(value.trim()) == null) {
                                        return 'Geçerli bir fiyat girin';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Location Field
                      Text(
                        'Konum',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _locationController,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Örn: Depo A, Raf 3',
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Technical Specifications
                      Text(
                        'Teknik Özellikler (Opsiyonel)',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      const SizedBox(height: 32),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveProduct,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            'Kaydet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}