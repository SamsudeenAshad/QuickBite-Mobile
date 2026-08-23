import '../utils/app_constants.dart';

class OrderModel {
  const OrderModel({
    this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  final int? id;
  final String customerName;
  final String phone;
  final String address;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  String get displayId => id == null ? 'QB----' : 'QB${1000 + id!}';

  String get orderNumber => displayId;

  bool get isCancelled => status == AppConstants.orderStatusCancelled;

  OrderModel copyWith({
    int? id,
    String? customerName,
    String? phone,
    String? address,
    double? total,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap({bool includeId = true}) {
    return <String, Object?>{
      if (includeId && id != null) 'id': id,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, Object?> map) {
    return OrderModel(
      id: (map['id'] as num?)?.toInt(),
      customerName: map['customerName'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      total: (map['total'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
