import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../widgets/promotion_banner.dart';
import '../widgets/state_message.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onBrowseMenu,
    this.onOpenCart,
    this.onOpenNotifications,
    this.notificationCount = 0,
  });

  final VoidCallback onBrowseMenu;
  final VoidCallback? onOpenCart;
  final VoidCallback? onOpenNotifications;
  final int notificationCount;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void _searchMenu(String query) {
    context.read<ProductProvider>().search(query);
  }

  void _submitSearch(String query) {
    _searchMenu(query);
    widget.onBrowseMenu();
  }

  void _chooseCategory(String category) {
    final ProductProvider products = context.read<ProductProvider>();
    products.search('');
    products.selectCategory(category);
    widget.onBrowseMenu();
  }

  void _browseAllProducts() {
    context.read<ProductProvider>().clearFilters();
    widget.onBrowseMenu();
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
                    16,
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
                            _HomeHeader(
                              onOpenCart: widget.onOpenCart,
                              onOpenNotifications: widget.onOpenNotifications,
                              notificationCount: widget.notificationCount,
                            ),
                            const SizedBox(height: 24),
                            _SearchBar(
                              controller: _searchController,
                              onChanged: _searchMenu,
                              onSubmitted: _submitSearch,
                              onBrowseMenu: widget.onBrowseMenu,
                            ),
                            const SizedBox(height: 24),
                            const PromotionBanner(),
                            const SizedBox(height: 32),
                            _SectionHeading(
                              title: 'Browse categories',
                              actionLabel: 'See menu',
                              onAction: _browseAllProducts,
                            ),
                            const SizedBox(height: 14),
                            _CategoryGrid(
                              selectedCategory: products.selectedCategory,
                              onSelected: _chooseCategory,
                            ),
                            const SizedBox(height: 34),
                            _SectionHeading(
                              title: 'Popular right now',
                              actionLabel: 'View all',
                              onAction: _browseAllProducts,
                            ),
                            const SizedBox(height: 14),
                            _PopularProducts(
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.onOpenCart,
    required this.onOpenNotifications,
    required this.notificationCount,
  });

  final VoidCallback? onOpenCart;
  final VoidCallback? onOpenNotifications;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    final int itemCount = context.select<CartProvider, int>(
      (cart) => cart.itemCount,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome to',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        if (onOpenNotifications != null) ...<Widget>[
          const SizedBox(width: 8),
          SizedBox.square(
            dimension: 48,
            child: IconButton.filledTonal(
              onPressed: onOpenNotifications,
              tooltip: notificationCount == 0
                  ? 'Open notifications'
                  : 'Open $notificationCount notifications',
              icon: Badge(
                isLabelVisible: notificationCount > 0,
                label: Text(
                  notificationCount > 9 ? '9+' : '$notificationCount',
                ),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ),
          ),
        ],
        if (onOpenCart != null) ...<Widget>[
          const SizedBox(width: 12),
          SizedBox.square(
            dimension: 48,
            child: IconButton.filledTonal(
              onPressed: onOpenCart,
              tooltip: itemCount == 0
                  ? 'Open empty cart'
                  : 'Open cart with $itemCount items',
              icon: Badge(
                isLabelVisible: itemCount > 0,
                label: Text(itemCount > 99 ? '99+' : '$itemCount'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onBrowseMenu,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onBrowseMenu;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: 'Search the café menu',
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: 'Search food and drinks',
          hintText: 'Try “iced coffee”',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: IconButton(
            onPressed: onBrowseMenu,
            tooltip: 'Browse matching menu items',
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(width: 8),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selectedCategory,
    required this.onSelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  static const List<({String title, IconData icon})> _categories =
      <({String title, IconData icon})>[
        (title: AppConstants.burgersCategory, icon: Icons.lunch_dining_rounded),
        (title: AppConstants.pizzaCategory, icon: Icons.local_pizza_rounded),
        (title: AppConstants.drinksCategory, icon: Icons.local_cafe_rounded),
        (title: AppConstants.dessertsCategory, icon: Icons.cake_rounded),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12;
        final int columnCount = constraints.maxWidth >= 720 ? 4 : 2;
        final double itemWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _categories
              .map((category) {
                return SizedBox(
                  width: itemWidth,
                  child: CategoryCard(
                    title: category.title,
                    icon: category.icon,
                    selected: selectedCategory == category.title,
                    onTap: () => onSelected(category.title),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

class _PopularProducts extends StatelessWidget {
  const _PopularProducts({required this.provider, required this.onOpenProduct});

  final ProductProvider provider;
  final ValueChanged<Product> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Semantics(
            label: 'Loading popular menu items',
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (provider.errorMessage != null && provider.products.isEmpty) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        title: 'The menu did not load',
        message: provider.errorMessage!,
        actionLabel: 'Try again',
        onAction: () {
          provider.loadProducts(force: true);
        },
      );
    }

    final List<Product> popularProducts = provider.popularProducts;
    if (popularProducts.isEmpty) {
      return const StateMessage(
        icon: Icons.restaurant_menu_rounded,
        title: 'Menu coming soon',
        message: 'Fresh café favourites will appear here.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16;
        final double textScale = MediaQuery.textScalerOf(context).scale(1);
        int columnCount = constraints.maxWidth >= 980
            ? 4
            : constraints.maxWidth >= 680
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
          children: popularProducts
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
