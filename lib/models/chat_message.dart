class ChatMessage {
  const ChatMessage({
    this.id,
    required this.userId,
    required this.customerName,
    required this.senderRole,
    required this.message,
    required this.createdAt,
  });

  final int? id;
  final int userId;
  final String customerName;
  final String senderRole;
  final String message;
  final DateTime createdAt;

  bool get fromAdmin => senderRole == 'admin';

  factory ChatMessage.fromMap(Map<String, Object?> map) {
    return ChatMessage(
      id: (map['id'] as num?)?.toInt(),
      userId: (map['userId'] as num).toInt(),
      customerName: map['customerName'] as String? ?? 'Customer',
      senderRole: map['senderRole'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
