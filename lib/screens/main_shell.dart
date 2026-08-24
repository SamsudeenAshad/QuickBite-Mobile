import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../models/app_user.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'products_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, this.user, this.onLogout});

  final AppUser? user;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    final NavigationProvider navigation = context.watch<NavigationProvider>();
    final int selectedIndex = navigation.selectedIndex;

    return PopScope<void>(
      canPop: selectedIndex == AppTab.home,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selectedIndex != AppTab.home) {
          navigation.goHome();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: <Widget>[
            HomeScreen(
              onBrowseMenu: navigation.openMenu,
              onOpenCart: navigation.openCart,
            ),
            const ProductsScreen(),
            CartScreen(
              onCheckout: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CheckoutScreen(onBackHome: navigation.goHome),
                  ),
                );
              },
            ),
            const OrdersScreen(),
            ProfileScreen(
              onOpenOrders: () => navigation.selectTab(AppTab.orders),
              user: user,
              onLogout: onLogout,
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: selectedIndex,
          onDestinationSelected: navigation.selectTab,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'cafe-chat',
          tooltip: 'Chat with café',
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (_) => const ChatScreen()),
          ),
          child: const Icon(Icons.chat_bubble_outline_rounded),
        ),
      ),
    );
  }
}
