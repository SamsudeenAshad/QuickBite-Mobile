import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/cart_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/product_repository.dart';
import 'screens/main_shell.dart';
import 'screens/auth_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';
import 'utils/app_constants.dart';

class QuickBiteApp extends StatelessWidget {
  const QuickBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final database = DatabaseService.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository(database))..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(ChatRepository(database)),
        ),
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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          home: const _AppEntry(),
        ),
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _splashFinished = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashFinished) {
      return SplashScreen(
        onFinished: () => setState(() => _splashFinished = true),
      );
    }

    final AuthProvider auth = context.watch<AuthProvider>();
    if (auth.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isAuthenticated) return const AuthScreen();

    if (auth.currentUser!.isAdmin) {
      return AdminScreen(onLogout: auth.logout);
    }
    return MainShell(user: auth.currentUser, onLogout: auth.logout);
  }
}
