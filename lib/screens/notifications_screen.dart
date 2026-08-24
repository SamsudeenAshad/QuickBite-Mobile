import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../models/order.dart';
import '../providers/chat_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.userId});

  final int userId;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    await Future.wait<void>(<Future<void>>[
      context.read<OrderProvider>().loadOrders(),
      if (widget.userId > 0)
        context.read<ChatProvider>().loadForCustomer(widget.userId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh notifications',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Consumer2<OrderProvider, ChatProvider>(
          builder: (context, orders, chat, _) {
            final List<_NotificationItem> items = <_NotificationItem>[
              ...orders.orders.map(_orderNotification),
              ...chat.messages
                  .where((message) => message.fromAdmin)
                  .map(_chatNotification),
            ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if ((orders.isLoading || chat.isLoading) && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (items.isEmpty) return const _EmptyNotifications();

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _NotificationCard(item: items[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

_NotificationItem _orderNotification(OrderModel order) {
  return _NotificationItem(
    icon: _orderIcon(order.status),
    iconColor: _orderColor(order.status),
    title: '${order.displayId} • ${order.status}',
    message: 'Your order status is now ${order.status.toLowerCase()}.',
    createdAt: order.createdAt,
  );
}

_NotificationItem _chatNotification(ChatMessage message) {
  return _NotificationItem(
    icon: Icons.chat_bubble_rounded,
    iconColor: AppColors.accent,
    title: 'New café reply',
    message: message.message,
    createdAt: message.createdAt,
  );
}

IconData _orderIcon(String status) {
  return switch (status) {
    'Delivered' => Icons.task_alt_rounded,
    'Rejected' || 'Cancelled' => Icons.cancel_rounded,
    'Confirmed' => Icons.check_circle_rounded,
    _ => Icons.restaurant_rounded,
  };
}

Color _orderColor(String status) {
  return switch (status) {
    'Delivered' || 'Confirmed' => AppColors.success,
    'Rejected' || 'Cancelled' => AppColors.danger,
    _ => AppColors.primary,
  };
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.iconColor.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(item.icon, color: item.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _formatTime(item.createdAt),
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: AppColors.textSecondary),
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

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 14),
            Text('No notifications yet', style: TextStyle(fontSize: 20)),
            SizedBox(height: 6),
            Text(
              'Order updates and replies from the café will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime date) {
  final DateTime local = date.toLocal();
  final String minute = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month}/${local.year} • ${local.hour}:$minute';
}

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final DateTime createdAt;
}
