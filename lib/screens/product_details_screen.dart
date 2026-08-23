import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_image.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const int _maximumQuantity = 20;

  int _quantity = 1;
  bool _isAdding = false;

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity -= 1);
    }
  }

  void _increaseQuantity() {
    if (_quantity < _maximumQuantity) {
      setState(() => _quantity += 1);
    }
  }

  Future<void> _addToCart() async {
    if (_isAdding) {
      return;
    }

    setState(() => _isAdding = true);
    try {
      await context.read<CartProvider>().addProduct(
        widget.product,
        quantity: _quantity,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Added to cart successfully.')),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Could not add this item. Please try again.'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;

    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool useWideLayout = constraints.maxWidth >= 760;
            final double horizontalPadding = useWideLayout ? 32 : 16;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                32,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: useWideLayout
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: _ProductHero(product: product)),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _ProductInformation(
                                product: product,
                                quantity: _quantity,
                                isAdding: _isAdding,
                                onDecrease: _decreaseQuantity,
                                onIncrease: _increaseQuantity,
                                onAdd: _addToCart,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _ProductHero(product: product),
                            const SizedBox(height: 24),
                            _ProductInformation(
                              product: product,
                              quantity: _quantity,
                              isAdding: _isAdding,
                              onDecrease: _decreaseQuantity,
                              onIncrease: _increaseQuantity,
                              onAdd: _addToCart,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ProductImage(
        imageUrl: product.image,
        semanticLabel: '${product.name} product image',
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({
    required this.product,
    required this.quantity,
    required this.isAdding,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAdd,
  });

  final Product product;
  final int quantity;
  final bool isAdding;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final double selectedTotal = product.price * quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            product.category,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 14),
        Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              'Rs. ${product.price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            Semantics(
              label: '${product.rating} out of 5 stars',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.star_rounded,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('About this item', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        Text('Quantity', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        _QuantitySelector(
          quantity: quantity,
          onDecrease: quantity == 1 ? null : onDecrease,
          onIncrease: quantity == _ProductDetailsScreenState._maximumQuantity
              ? null
              : onIncrease,
        ),
        const SizedBox(height: 28),
        Text(
          'Selected total: Rs. ${selectedTotal.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isAdding ? null : onAdd,
            icon: isAdding
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.shopping_bag_rounded),
            label: Text(
              isAdding ? 'Adding to cart…' : 'Add to Cart',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Quantity $quantity',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox.square(
              dimension: 48,
              child: IconButton(
                onPressed: onDecrease,
                tooltip: 'Decrease quantity',
                icon: const Icon(Icons.remove_rounded),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48),
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox.square(
              dimension: 48,
              child: IconButton.filledTonal(
                onPressed: onIncrease,
                tooltip: 'Increase quantity',
                icon: const Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
