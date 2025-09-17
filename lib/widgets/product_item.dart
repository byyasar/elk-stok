import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/models/product.dart';
import '/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback onProductUpdated;

  const ProductItem({
    super.key,
    required this.product,
    required this.onProductUpdated,
  });

  Color _getStockBackgroundColor(int stock) {
    if (stock > 0) {
      // Stok var - açık yeşil
      return const Color(0xFF1C2127).withOpacity(0.5).withGreen(77);
    } else {
      // Stok yok - açık kırmızı
      return const Color(0xFF1C2127).withOpacity(0.5).withRed(77);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            ).then((result) {
              final messenger = ScaffoldMessenger.maybeOf(context);
              if (result == 'deleted') {
                // Ürün silindi, listeyi yenile ve ana ekranda mesaj göster
                onProductUpdated();
                messenger?.showSnackBar(
                  const SnackBar(
                    content: Text('Ürün başarıyla silindi'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              } else if (result is Product) {
                // Ürün güncellendi, listeyi yenile
                onProductUpdated();
                messenger?.showSnackBar(
                  const SnackBar(
                    content: Text('Ürün başarıyla güncellendi'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStockBackgroundColor(product.stock),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF283039),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFF283039),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFF137FEC),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        print('Resim yükleme hatası: $url - $error'); // Debug için
                        return Container(
                          color: const Color(0xFF283039),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Color(0xFF9DABB9),
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stok: ${product.stock}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      if (product.location.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                product.location,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow Icon
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}