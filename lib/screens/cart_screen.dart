import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/product_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (BuildContext context, CartProvider cart, Widget? child) {
        final bool showSummary = !cart.isEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Your cart'),
            actions: <Widget>[
              if (!cart.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Semantics(
                      label:
                          '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'} in cart',
                      child: ExcludeSemantics(
                        child: _ItemCountBadge(itemCount: cart.itemCount),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(top: false, child: _CartBody(cart: cart)),
          bottomNavigationBar: showSummary
              ? _CartSummary(
                  cart: cart,
                  onCheckout: () => _handleCheckout(context, cart),
                )
              : null,
        );
      },
    );
  }

  void _handleCheckout(BuildContext context, CartProvider cart) {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Your cart is empty. Add an item before checkout.'),
          ),
        );
      return;
    }

    if (cart.isLoading || cart.isUpdating) {
      return;
    }

    onCheckout();
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    final BuildContext screenContext = context;

    if (cart.isLoading && cart.isEmpty) {
      return const _LoadingState();
    }

    if (cart.errorMessage != null && cart.isEmpty) {
      return _ErrorState(
        message: cart.errorMessage!,
        onRetry: () async {
          await cart.loadCart();
        },
      );
    }

    if (cart.isEmpty) {
      return const _EmptyState();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontalPadding = constraints.maxWidth >= 720 ? 24 : 16;
        final bool isBusy = cart.isLoading || cart.isUpdating;
        final bool disableAnimations = MediaQuery.disableAnimationsOf(context);

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AnimatedSwitcher(
                  duration: disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: isBusy
                      ? Semantics(
                          key: const ValueKey<String>('updating-cart'),
                          label: 'Updating cart',
                          liveRegion: true,
                          child: const LinearProgressIndicator(minHeight: 3),
                        )
                      : const SizedBox(
                          key: ValueKey<String>('cart-idle'),
                          height: 3,
                        ),
                ),
                if (cart.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      0,
                    ),
                    child: _InlineErrorBanner(
                      message: cart.errorMessage!,
                      onRetry: () async {
                        await cart.loadCart();
                      },
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      24,
                    ),
                    itemCount: cart.items.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 12);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final CartItem item = cart.items[index];
                      final String productName =
                          item.product?.name ?? 'Menu item';

                      return _CartItemCard(
                        item: item,
                        isUpdating: isBusy,
                        onIncrement: () => _runCartUpdate(
                          screenContext,
                          () => cart.incrementQuantity(item),
                          errorMessage:
                              'We could not increase $productName. Please try again.',
                        ),
                        onDecrement: () => _runCartUpdate(
                          screenContext,
                          () => cart.decrementQuantity(item),
                          errorMessage:
                              'We could not decrease $productName. Please try again.',
                        ),
                        onRemove: () => _runCartUpdate(
                          screenContext,
                          () => cart.removeItem(item),
                          errorMessage:
                              'We could not remove $productName. Please try again.',
                          successMessage:
                              '$productName was removed from your cart.',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _runCartUpdate(
    BuildContext context,
    Future<void> Function() update, {
    required String errorMessage,
    String? successMessage,
  }) async {
    try {
      await update();

      if (!context.mounted || successMessage == null) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () async {
                await _runCartUpdate(
                  context,
                  update,
                  errorMessage: errorMessage,
                  successMessage: successMessage,
                );
              },
            ),
          ),
        );
    }
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.isUpdating,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final bool isUpdating;
  final Future<void> Function() onIncrement;
  final Future<void> Function() onDecrement;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final String productName = product?.name ?? 'Unavailable menu item';
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ProductImage(
                  imageUrl: product?.image ?? '',
                  semanticLabel: '$productName product image',
                  width: 88,
                  height: 88,
                  borderRadius: BorderRadius.circular(16),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        productName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (product != null) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatCurrency(product.price),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: colors.primary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          await onRemove();
                        },
                  tooltip: 'Remove $productName from cart',
                  style: IconButton.styleFrom(
                    minimumSize: const Size.square(48),
                    foregroundColor: colors.error,
                    backgroundColor: colors.errorContainer,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: <Widget>[
                _QuantityControl(
                  productName: productName,
                  quantity: item.quantity,
                  isUpdating: isUpdating,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
                Semantics(
                  label: 'Line total ${formatCurrency(item.lineTotal)}',
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Item total',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatCurrency(item.lineTotal),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.productName,
    required this.quantity,
    required this.isUpdating,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String productName;
  final int quantity;
  final bool isUpdating;
  final Future<void> Function() onIncrement;
  final Future<void> Function() onDecrement;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: '$productName quantity controls',
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              onPressed: isUpdating || quantity <= 1
                  ? null
                  : () async {
                      await onDecrement();
                    },
              tooltip: quantity <= 1
                  ? 'Minimum quantity reached'
                  : 'Decrease $productName quantity',
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              icon: const Icon(Icons.remove_rounded),
            ),
            Semantics(
              label: 'Quantity $quantity',
              liveRegion: true,
              child: ExcludeSemantics(
                child: SizedBox(
                  width: 36,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: isUpdating
                  ? null
                  : () async {
                      await onIncrement();
                    },
              tooltip: 'Increase $productName quantity',
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart, required this.onCheckout});

  final CartProvider cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      elevation: 12,
      shadowColor: colors.shadow,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final Widget totals = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _SummaryRow(
                        label: 'Subtotal',
                        value: formatCurrency(cart.subtotal),
                      ),
                      const SizedBox(height: 6),
                      _SummaryRow(
                        label: 'Delivery charge',
                        value: formatCurrency(cart.deliveryCharge),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(),
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: formatCurrency(cart.total),
                        isTotal: true,
                      ),
                    ],
                  );
                  final Widget checkoutButton = FilledButton.icon(
                    onPressed: cart.isLoading || cart.isUpdating || cart.isEmpty
                        ? null
                        : onCheckout,
                    icon: cart.isLoading || cart.isUpdating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      cart.isLoading || cart.isUpdating
                          ? 'Updating Cart...'
                          : 'Proceed to Checkout',
                    ),
                  );

                  if (constraints.maxWidth >= 600) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(child: totals),
                        const SizedBox(width: 32),
                        SizedBox(width: 260, child: checkoutButton),
                      ],
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      totals,
                      const SizedBox(height: 16),
                      checkoutButton,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = isTotal
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyMedium;

    return Semantics(
      label: '$label $value',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label, style: style),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: style?.copyWith(
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCountBadge extends StatelessWidget {
  const _ItemCountBadge({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Loading your cart',
        liveRegion: true,
        child: const SizedBox.square(
          dimension: 36,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.cloud_off_rounded, size: 40, color: colors.error),
                  const SizedBox(height: 16),
                  Text(
                    'We could not load your cart',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      await onRetry();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.error_outline_rounded, color: colors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onErrorContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await onRetry();
                },
                style: TextButton.styleFrom(minimumSize: const Size(88, 48)),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 48,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your cart is waiting',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Add something delicious from the menu, then come back here to check out.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
