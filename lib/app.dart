import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'repositories/cart_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/product_repository.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';

class QuickBiteApp extends StatelessWidget {
  const QuickBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final database = DatabaseService.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              ProductProvider(ProductRepository(database))..loadProducts(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(CartRepository(database))..loadCart(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(OrderRepository(database))..loadOrders(),
        ),
      ],
      child: MaterialApp(
        title: 'QuickBite Café',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _FoundationScreen(),
      ),
    );
  }
}

class _FoundationScreen extends StatelessWidget {
  const _FoundationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_cafe_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'QuickBite Café',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Warm bites, made simple.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  const _FoundationStatus(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FoundationStatus extends StatelessWidget {
  const _FoundationStatus();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, products, child) {
        if (products.isLoading) {
          return Semantics(
            label: 'Loading café menu',
            child: const CircularProgressIndicator(),
          );
        }

        if (products.errorMessage != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 32),
                  const SizedBox(height: 12),
                  Text(products.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: products.loadProducts,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        return Semantics(
          label: '${products.products.length} menu items ready',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                Text(
                  '${products.products.length} menu items ready',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
