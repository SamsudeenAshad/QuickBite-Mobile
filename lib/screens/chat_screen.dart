import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../utils/keyboard_helper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.userId});

  final int userId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refresh(silent: true),
    );
  }

  Future<void> _refresh({bool silent = false}) async {
    if (!mounted || widget.userId <= 0) return;
    await context.read<ChatProvider>().loadForCustomer(widget.userId);
    if (mounted) _scrollToEnd();
  }

  Future<void> _send() async {
    final String message = _controller.text.trim();
    if (message.isEmpty || widget.userId <= 0) return;
    _controller.clear();
    await context.read<ChatProvider>().sendCustomerMessage(
      widget.userId,
      message,
    );
    if (mounted) _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Chat with café'),
            Text(
              'Replies from the admin team',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh messages',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Consumer<ChatProvider>(
          builder: (context, chat, _) {
            return Column(
              children: <Widget>[
                if (chat.isLoading) const LinearProgressIndicator(minHeight: 2),
                if (chat.errorMessage != null)
                  MaterialBanner(
                    content: Text(chat.errorMessage!),
                    actions: <Widget>[
                      TextButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                Expanded(
                  child: chat.messages.isEmpty && !chat.isLoading
                      ? const _EmptyConversation()
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: chat.messages.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final ChatMessage message = chat.messages[index];
                            return Align(
                              alignment: message.fromAdmin
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: _MessageBubble(message: message),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onTap: showSoftKeyboard,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: const InputDecoration(
                            labelText: 'Message the café',
                            hintText: 'Ask about your order…',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox.square(
                        dimension: 52,
                        child: IconButton.filled(
                          tooltip: 'Send message',
                          onPressed: chat.isSending ? null : _send,
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Start a conversation with the café. An admin can reply from the admin dashboard.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 310),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: message.fromAdmin ? AppColors.surfaceMuted : AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message.fromAdmin ? 'Café admin' : 'You',
            style: TextStyle(
              color: message.fromAdmin ? AppColors.secondary : Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            message.message,
            style: TextStyle(
              color: message.fromAdmin
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
