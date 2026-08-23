import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'home_screen.dart';
import 'products_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

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
            const _PendingTab(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart',
            ),
            const _PendingTab(
              icon: Icons.receipt_long_outlined,
              title: 'Your orders',
            ),
            const _PendingTab(
              icon: Icons.person_outline_rounded,
              title: 'Your profile',
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: selectedIndex,
          onDestinationSelected: navigation.selectTab,
        ),
      ),
    );
  }
}

class _PendingTab extends StatelessWidget {
  const _PendingTab({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
