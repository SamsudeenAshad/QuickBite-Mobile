import 'product.dart';

class CartItem {
  const CartItem({
    this.id,
    required this.productId,
    required this.quantity,
    this.product,
  });

  final int? id;
  final int productId;
  final int quantity;
  final Product? product;

  double get lineTotal => (product?.price ?? 0) * quantity;

  CartItem copyWith({
    int? id,
    int? productId,
    int? quantity,
    Product? product,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
    );
  }

  Map<String, Object?> toMap({bool includeId = true}) {
    return <String, Object?>{
      if (includeId && id != null) 'id': id,
      'productId': productId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, Object?> map) {
    return CartItem(
      id: (map['id'] as num?)?.toInt(),
      productId: (map['productId'] as num).toInt(),
      quantity: (map['quantity'] as num).toInt(),
    );
  }

  factory CartItem.fromJoinedMap(Map<String, Object?> map) {
    return CartItem(
      id: (map['cartId'] as num).toInt(),
      productId: (map['productId'] as num).toInt(),
      quantity: (map['quantity'] as num).toInt(),
      product: Product(
        id: (map['productId'] as num).toInt(),
        name: map['productName'] as String,
        description: map['productDescription'] as String,
        category: map['productCategory'] as String,
        price: (map['productPrice'] as num).toDouble(),
        image: map['productImage'] as String,
        rating: (map['productRating'] as num).toDouble(),
      ),
    );
  }
}
