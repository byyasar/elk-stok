class Product {
  final String? id;
  final String? userId;
  final String name;
  final String imageUrl;
  final int stock;
  final String description;
  final String location;
  final double? price;
  final DateTime? createdAt;

  Product({
    this.id,
    this.userId,
    required this.name,
    required this.imageUrl,
    required this.stock,
    this.description = '',
    this.location = '',
    this.price,
    this.createdAt,
  });

  Product copyWith({
    String? id,
    String? userId,
    String? name,
    String? imageUrl,
    int? stock,
    String? description,
    String? location,
    double? price,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      location: location ?? this.location,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'stock': stock,
      'description': description,
      'location': location,
      if (price != null) 'price': price,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (userId != null) 'user_id': userId,
    };
  }

  factory Product.fromSupabaseJson(Map<String, dynamic> json) {
    String imageUrl = json['imageUrl'] as String? ?? '';
    
    // Eğer imageUrl geçersizse (boş, "a", veya geçersiz URL), varsayılan resim kullan
    if (imageUrl.isEmpty || 
        imageUrl == 'a' || 
        !imageUrl.startsWith('http')) {
      imageUrl = 'https://images.pexels.com/photos/1029624/pexels-photo-1029624.jpeg';
    }
    
    // Tarih parsing
    DateTime? createdAt;
    if (json['created_at'] != null) {
      try {
        createdAt = DateTime.parse(json['created_at'] as String);
      } catch (e) {
        createdAt = null;
      }
    }
    
    return Product(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      imageUrl: imageUrl,
      stock: json['stock'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      createdAt: createdAt,
    );
  }
}