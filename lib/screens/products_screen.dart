import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../widgets/product_card.dart';
import '../widgets/state_message.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProductProvider? _productProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ProductProvider provider = context.read<ProductProvider>();
    if (!identical(provider, _productProvider)) {
      _productProvider?.removeListener(_syncSearchText);
      _productProvider = provider..addListener(_syncSearchText);
      _syncSearchText();
    }
  }

  void _syncSearchText() {
    final String query = _productProvider?.searchQuery ?? '';
    if (_searchController.text == query) {
      return;
    }
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  void dispose() {
    _productProvider?.removeListener(_syncSearchText);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double horizontalPadding = constraints.maxWidth >= 900
              ? 40
              : constraints.maxWidth >= 600
              ? 24
              : 16;

          return Consumer<ProductProvider>(
            builder: (context, products, child) {
              return RefreshIndicator(
                onRefresh: () => products.loadProducts(force: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    32,
                  ),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Our menu',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Find something fresh for every craving.',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _searchController,
                              onChanged: products.search,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                labelText: 'Search the menu',
                                hintText: 'Food, drinks or ingredients',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: products.searchQuery.isEmpty
                                    ? null
                                    : IconButton(
                                        onPressed: () => products.search(''),
                                        tooltip: 'Clear search',
                                        icon: const Icon(Icons.close_rounded),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _CategoryFilters(provider: products),
                            const SizedBox(height: 22),
                            _ResultsHeader(provider: products),
                            const SizedBox(height: 14),
                            _ProductResults(
                              provider: products,
                              onOpenProduct: _openProduct,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.provider});

  final ProductProvider provider;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Filter menu by category',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: AppConstants.menuCategories
            .map((category) {
              final bool isSelected = provider.selectedCategory == category;
              return Semantics(
                selected: isSelected,
                button: true,
                child: ChoiceChip(
                  selected: isSelected,
                  onSelected: (_) => provider.selectCategory(category),
                  avatar: isSelected
                      ? const Icon(Icons.check_rounded, size: 18)
                      : null,
                  label: Text(category),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.provider});

  final ProductProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const SizedBox.shrink();
    }

    final int resultCount = provider.filteredProducts.length;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            provider.selectedCategory == AppConstants.allCategory
                ? 'All favourites'
                : provider.selectedCategory,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          label: '$resultCount menu results',
          child: Text(
            '$resultCount ${resultCount == 1 ? 'item' : 'items'}',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ProductResults extends StatelessWidget {
  const _ProductResults({required this.provider, required this.onOpenProduct});

  final ProductProvider provider;
  final ValueChanged<Product> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 72),
        child: Center(
          child: Semantics(
            label: 'Loading menu items',
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (provider.errorMessage != null && provider.products.isEmpty) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        title: 'We could not load the menu',
        message: provider.errorMessage!,
        actionLabel: 'Try again',
        onAction: () {
          provider.loadProducts(force: true);
        },
      );
    }

    final List<Product> filteredProducts = provider.filteredProducts;
    if (filteredProducts.isEmpty) {
      return StateMessage(
        icon: Icons.search_off_rounded,
        title: 'No matching items',
        message: 'Try another search or clear the selected category.',
        actionLabel: 'Clear filters',
        actionIcon: Icons.filter_alt_off_rounded,
        onAction: provider.clearFilters,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16;
        final double textScale = MediaQuery.textScalerOf(context).scale(1);
        int columnCount = constraints.maxWidth >= 1040
            ? 4
            : constraints.maxWidth >= 720
            ? 3
            : constraints.maxWidth >= 330
            ? 2
            : 1;
        if (textScale > 1.35 && columnCount > 1) {
          columnCount -= 1;
        }
        final double itemWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: filteredProducts
              .map((product) {
                return SizedBox(
                  width: itemWidth,
                  child: ProductCard(
                    product: product,
                    onTap: () => onOpenProduct(product),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}
