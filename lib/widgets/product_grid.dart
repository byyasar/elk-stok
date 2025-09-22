import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/models/product.dart';
import '/screens/product_detail_screen.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final VoidCallback onProductUpdated;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onProductUpdated,
  });

  Color _getStockBackgroundColor(int stock) {
    if (stock > 0) {
      return const Color(0xFF1C2127).withValues(alpha: 0.5).withGreen(77);
    } else {
      return const Color(0xFF1C2127).withValues(alpha: 0.5).withRed(77);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Material(
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
              onProductUpdated();
              messenger?.showSnackBar(
                const SnackBar(
                  content: Text('Ürün başarıyla silindi'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            } else if (result is Product) {
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStockBackgroundColor(product.stock),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
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
              ),
              
              const SizedBox(height: 8),
              
              // Product Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Stock and Price
                    Row(
                      children: [
                        Text(
                          'Stok: ${product.stock}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        if (product.price != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '₺${product.price!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Location and Date
                    if (product.location.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.location,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    if (product.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.createdAt!.day}.${product.createdAt!.month}.${product.createdAt!.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
