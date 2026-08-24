import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quickbite_cafe/models/app_user.dart';
import 'package:quickbite_cafe/models/chat_message.dart';
import 'package:quickbite_cafe/providers/chat_provider.dart';
import 'package:quickbite_cafe/repositories/chat_repository.dart';
import 'package:quickbite_cafe/screens/chat_screen.dart';
import 'package:quickbite_cafe/services/database_service.dart';
import 'package:quickbite_cafe/theme/app_theme.dart';
import 'package:quickbite_cafe/utils/app_constants.dart';

void main() {
  test('admin users and order workflow statuses are configured', () {
    const AppUser admin = AppUser(
      id: 1,
      name: 'Administrator',
      phone: '000000000',
      email: 'admin',
      role: 'admin',
    );

    expect(admin.isAdmin, isTrue);
    expect(
      AppConstants.adminOrderStatuses,
      containsAll(<String>['Confirmed', 'Rejected', 'Delivered']),
    );
  });

  testWidgets('café chat saves a customer message for the admin', (
    WidgetTester tester,
  ) async {
    final _MemoryChatRepository repository = _MemoryChatRepository();
    await tester.pumpWidget(
      ChangeNotifierProvider<ChatProvider>(
        create: (_) => ChatProvider(repository),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ChatScreen(userId: 7),
        ),
      ),
    );

    expect(find.text('Chat with café'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'What is the delivery time?',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();
    expect(find.text('What is the delivery time?'), findsOneWidget);
    expect(repository.messages.single.senderRole, 'customer');
  });
}

class _MemoryChatRepository extends ChatRepository {
  _MemoryChatRepository()
    : super(DatabaseService(databaseName: 'unused_chat_test.db'));

  final List<ChatMessage> messages = <ChatMessage>[];

  @override
  Future<List<ChatMessage>> getMessages({int? userId}) async {
    return messages
        .where((message) => userId == null || message.userId == userId)
        .toList(growable: false);
  }

  @override
  Future<void> send({
    required int userId,
    required String senderRole,
    required String message,
  }) async {
    messages.add(
      ChatMessage(
        id: messages.length + 1,
        userId: userId,
        customerName: 'Test Customer',
        senderRole: senderRole,
        message: message,
        createdAt: DateTime(2026),
      ),
    );
  }
}
