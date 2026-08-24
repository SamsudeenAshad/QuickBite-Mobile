import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<({String text, bool fromCafe})> _messages =
      <({String text, bool fromCafe})>[
        (
          text: 'Hi! Welcome to QuickBite Café. How can we help you today?',
          fromCafe: true,
        ),
      ];
  bool _isReplying = false;

  Future<void> _send() async {
    final String message = _controller.text.trim();
    if (message.isEmpty || _isReplying) return;
    setState(() {
      _messages.add((text: message, fromCafe: false));
      _controller.clear();
      _isReplying = true;
    });
    _scrollToEnd();
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() {
      _messages.add((text: _replyFor(message), fromCafe: true));
      _isReplying = false;
    });
    _scrollToEnd();
  }

  String _replyFor(String message) {
    final String text = message.toLowerCase();
    if (text.contains('order')) {
      return 'You can check your latest order and its status from the Orders tab.';
    }
    if (text.contains('delivery')) {
      return 'Our standard delivery charge is Rs. 200. Preparation usually takes 20–30 minutes.';
    }
    if (text.contains('open') || text.contains('time')) {
      return 'We are open daily from 8:00 AM to 10:00 PM.';
    }
    if (text.contains('promo') || text.contains('offer')) {
      return 'Check the Promotions page for today’s active café offers and codes.';
    }
    return 'Thanks for contacting the café. A team member will help with your request shortly.';
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
              'Online now',
              style: TextStyle(color: AppColors.success, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isReplying ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: _TypingBubble(),
                    );
                  }
                  final message = _messages[index];
                  return Align(
                    alignment: message.fromCafe
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: _MessageBubble(message: message),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
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
                      onPressed: _isReplying ? null : _send,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ({String text, bool fromCafe}) message;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 310),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: message.fromCafe ? AppColors.surfaceMuted : AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: message.fromCafe ? AppColors.textPrimary : Colors.white,
          height: 1.4,
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
