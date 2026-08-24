import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../widgets/product_image.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(force: true);
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Manage products' : 'Manage orders'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Log out',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _selectedIndex == 0 ? const _AdminProducts() : const _AdminOrders(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showProductForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add product'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}

class _AdminProducts extends StatelessWidget {
  const _AdminProducts();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => provider.loadProducts(force: true),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: provider.products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final Product product = provider.products[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      ProductImage(
                        imageUrl: product.image,
                        semanticLabel: product.name,
                        width: 76,
                        height: 76,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.category} • ${formatCurrency(product.price)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit ${product.name}',
                        onPressed: () =>
                            _showProductForm(context, product: product),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete ${product.name}',
                        color: AppColors.danger,
                        onPressed: () => _deleteProduct(context, product),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AdminOrders extends StatelessWidget {
  const _AdminOrders();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.orders.isEmpty) {
          return const Center(child: Text('No customer orders yet.'));
        }
        return RefreshIndicator(
          onRefresh: provider.loadOrders,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final OrderModel order = provider.orders[index];
              final String selectedStatus =
                  AppConstants.adminOrderStatuses.contains(order.status)
                  ? order.status
                  : AppConstants.orderStatusPreparing;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              order.displayId,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(
                            formatCurrency(order.total),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${order.customerName} • ${order.phone}'),
                      const SizedBox(height: 4),
                      Text(
                        order.address,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Order status',
                          prefixIcon: Icon(Icons.sync_alt_rounded),
                        ),
                        items: AppConstants.adminOrderStatuses
                            .map(
                              (status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (status) async {
                          if (status == null || status == order.status) return;
                          await provider.updateOrderStatus(order, status);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${order.displayId} updated to $status.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

Future<void> _deleteProduct(BuildContext context, Product product) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete product?'),
      content: Text('${product.name} will be removed from the menu.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await context.read<ProductProvider>().deleteProduct(product.id);
  }
}

Future<void> _showProductForm(BuildContext context, {Product? product}) async {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController(text: product?.name);
  final TextEditingController description = TextEditingController(
    text: product?.description,
  );
  final TextEditingController price = TextEditingController(
    text: product?.price.toStringAsFixed(0),
  );
  final TextEditingController image = TextEditingController(
    text: product?.image,
  );
  final TextEditingController rating = TextEditingController(
    text: product?.rating.toString() ?? '4.5',
  );
  String category = product?.category ?? AppConstants.burgersCategory;

  final Product? result = await showDialog<Product>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(product == null ? 'Add product' : 'Edit product'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _AdminField(controller: name, label: 'Product name'),
                  const SizedBox(height: 12),
                  _AdminField(
                    controller: description,
                    label: 'Description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: AppConstants.productCategories
                        .map(
                          (value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => category = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminField(
                    controller: price,
                    label: 'Price (Rs.)',
                    number: true,
                  ),
                  const SizedBox(height: 12),
                  _AdminField(controller: image, label: 'Image URL'),
                  const SizedBox(height: 12),
                  _AdminField(
                    controller: rating,
                    label: 'Rating (0–5)',
                    number: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final double parsedRating = double.parse(rating.text);
              if (parsedRating < 0 || parsedRating > 5) return;
              Navigator.pop(
                dialogContext,
                Product(
                  id: product?.id ?? 0,
                  name: name.text.trim(),
                  description: description.text.trim(),
                  category: category,
                  price: double.parse(price.text),
                  image: image.text.trim(),
                  rating: parsedRating,
                ),
              );
            },
            child: Text(product == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );

  name.dispose();
  description.dispose();
  price.dispose();
  image.dispose();
  rating.dispose();
  if (result == null || !context.mounted) return;
  final ProductProvider provider = context.read<ProductProvider>();
  if (product == null) {
    await provider.addProduct(result);
  } else {
    await provider.updateProduct(result);
  }
}

class _AdminField extends StatelessWidget {
  const _AdminField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.number = false,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool number;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required.';
        if (number && double.tryParse(value) == null) return 'Enter a number.';
        return null;
      },
    );
  }
}
