class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.image,
    required this.rating,
  });

  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String image;
  final double rating;

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? image,
    double? rating,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      image: image ?? this.image,
      rating: rating ?? this.rating,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'image': image,
      'rating': rating,
    };
  }

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String,
      rating: (map['rating'] as num).toDouble(),
    );
  }
}
