import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'repositories/cart_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/product_repository.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';

class QuickBiteApp extends StatelessWidget {
  const QuickBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final database = DatabaseService.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
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
        home: const _AppEntry(),
      ),
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onFinished: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const MainShell()),
        );
      },
    );
  }
}
