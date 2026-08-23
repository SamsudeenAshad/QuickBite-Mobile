import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../widgets/state_message.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderProvider>().loadOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your orders')),
      body: SafeArea(
        top: false,
        child: Consumer<OrderProvider>(
          builder:
              (
                BuildContext context,
                OrderProvider orderProvider,
                Widget? child,
              ) {
                if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                  return const _OrdersLoadingState();
                }

                if (orderProvider.ordersErrorMessage != null &&
                    orderProvider.orders.isEmpty) {
                  return StateMessage(
                    icon: Icons.receipt_long_outlined,
                    title: 'Orders are unavailable',
                    message: orderProvider.ordersErrorMessage!,
                    actionLabel: 'Try again',
                    onAction: orderProvider.loadOrders,
                  );
                }

                if (orderProvider.orders.isEmpty) {
                  return const StateMessage(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    message: 'Your order history will appear here after you place your first order.',
                  );
                }

                final List<OrderModel> orders = <OrderModel>[
                  ...orderProvider.orders,
                ]..sort(_newestOrderFirst);

                return _OrdersList(
                  orders: orders,
                  isRefreshing: orderProvider.isLoading,
                  errorMessage: orderProvider.ordersErrorMessage,
                  onRefresh: orderProvider.loadOrders,
                );
              },
        ),
      ),
    );
  }
}

int _newestOrderFirst(OrderModel first, OrderModel second) {
  final int dateComparison = second.createdAt.compareTo(first.createdAt);
  if (dateComparison != 0) {
    return dateComparison;
  }
  return (second.id ?? 0).compareTo(first.id ?? 0);
}

class _OrdersLoadingState extends StatelessWidget {
  const _OrdersLoadingState();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading your order history',
      liveRegion: true,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    required this.orders,
    required this.isRefreshing,
    required this.errorMessage,
    required this.onRefresh,
  });

  final List<OrderModel> orders;
  final bool isRefreshing;
  final String? errorMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontalPadding = constraints.maxWidth >= 720 ? 32 : 16;

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      12,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _OrdersIntroduction(orderCount: orders.length),
                    ),
                  ),
                  if (isRefreshing)
                    SliverToBoxAdapter(
                      child: Semantics(
                        label: 'Refreshing orders',
                        liveRegion: true,
                        child: const LinearProgressIndicator(minHeight: 3),
                      ),
                    ),
                  if (errorMessage != null)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        4,
                        horizontalPadding,
                        12,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _OrderErrorBanner(
                          message: errorMessage!,
                          onRetry: onRefresh,
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      4,
                      horizontalPadding,
                      32,
                    ),
                    sliver: SliverList.separated(
                      itemCount: orders.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return _OrderCard(order: orders[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrdersIntroduction extends StatelessWidget {
  const _OrdersIntroduction({required this.orderCount});

  final int orderCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          '$orderCount ${orderCount == 1 ? 'order' : 'orders'} in your history, newest first',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$orderCount ${orderCount == 1 ? 'order' : 'orders'}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your most recent orders appear first.',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final _OrderStatusStyle statusStyle = _statusStyleFor(order.status);
    final String date = _formatOrderDate(order.createdAt);
    final String total = formatCurrency(order.total);

    return Semantics(
      container: true,
      label:
          'Order ${order.displayId}. $date. Total $total. Status ${order.status}. Payment method ${order.paymentMethod}.',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.secondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            order.displayId,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            date,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          _OrderStatusChip(
                            style: statusStyle,
                            label: order.status,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _OrderDetail(
                      icon: Icons.payments_outlined,
                      label: 'Payment',
                      value: order.paymentMethod,
                    ),
                    const SizedBox(height: 12),
                    _OrderDetail(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Total',
                      value: total,
                      emphasize: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderStatusChip extends StatelessWidget {
  const _OrderStatusChip({required this.style, required this.label});

  final _OrderStatusStyle style;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.foregroundColor.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(style.icon, size: 17, color: style.foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: style.foregroundColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetail extends StatelessWidget {
  const _OrderDetail({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    (emphasize
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.bodyMedium)
                        ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderErrorBanner extends StatelessWidget {
  const _OrderErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusStyle {
  const _OrderStatusStyle({
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
}

_OrderStatusStyle _statusStyleFor(String status) {
  switch (status) {
    case AppConstants.orderStatusPreparing:
      return _OrderStatusStyle(
        icon: Icons.schedule_rounded,
        foregroundColor: AppColors.warning,
        backgroundColor: AppColors.warning.withValues(alpha: .11),
      );
    case AppConstants.orderStatusCompleted:
      return _OrderStatusStyle(
        icon: Icons.check_circle_outline_rounded,
        foregroundColor: AppColors.success,
        backgroundColor: AppColors.success.withValues(alpha: .10),
      );
    case AppConstants.orderStatusCancelled:
      return _OrderStatusStyle(
        icon: Icons.cancel_outlined,
        foregroundColor: AppColors.danger,
        backgroundColor: AppColors.danger.withValues(alpha: .09),
      );
    default:
      return const _OrderStatusStyle(
        icon: Icons.info_outline_rounded,
        foregroundColor: AppColors.textSecondary,
        backgroundColor: AppColors.surfaceMuted,
      );
  }
}

String _formatOrderDate(DateTime dateTime) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final DateTime localDate = dateTime.toLocal();
  final int twelveHour = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
  final String minute = localDate.minute.toString().padLeft(2, '0');
  final String period = localDate.hour < 12 ? 'AM' : 'PM';
  return '${localDate.day} ${months[localDate.month - 1]} '
      '${localDate.year} · $twelveHour:$minute $period';
}
