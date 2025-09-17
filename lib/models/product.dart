class Product {
  final String? id;
  final String? userId;
  final String name;
  final String imageUrl;
  final int stock;
  final String description;
  final String location;

  Product({
    this.id,
    this.userId,
    required this.name,
    required this.imageUrl,
    required this.stock,
    this.description = '',
    this.location = '',
  });

  Product copyWith({
    String? id,
    String? userId,
    String? name,
    String? imageUrl,
    int? stock,
    String? description,
    String? location,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'stock': stock,
      'description': description,
      'location': location,
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
    
    return Product(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      imageUrl: imageUrl,
      stock: json['stock'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }
}