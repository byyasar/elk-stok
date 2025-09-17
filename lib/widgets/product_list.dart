import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_item.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final VoidCallback onProductUpdated;

  const ProductList({
    super.key,
    required this.products,
    required this.onProductUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductItem(
          product: products[index],
          onProductUpdated: onProductUpdated,
        );
      },
    );
  }
}