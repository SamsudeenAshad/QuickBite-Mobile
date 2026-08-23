import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.cartItemCount,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final int? cartItemCount;

  @override
  Widget build(BuildContext context) {
    final int itemCount =
        cartItemCount ??
        context.select<CartProvider, int>((cart) => cart.itemCount);

    return Semantics(
      container: true,
      label: 'Main navigation',
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        animationDuration: const Duration(milliseconds: 250),
        destinations: <NavigationDestination>[
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: _CartNavigationIcon(
              itemCount: itemCount,
              icon: Icons.shopping_bag_outlined,
            ),
            selectedIcon: _CartNavigationIcon(
              itemCount: itemCount,
              icon: Icons.shopping_bag_rounded,
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _CartNavigationIcon extends StatelessWidget {
  const _CartNavigationIcon({required this.itemCount, required this.icon});

  final int itemCount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final String itemLabel = itemCount == 1 ? 'item' : 'items';

    return Semantics(
      label: itemCount == 0 ? 'Cart, empty' : 'Cart, $itemCount $itemLabel',
      child: ExcludeSemantics(
        child: itemCount == 0
            ? Icon(icon)
            : Badge(
                label: Text(itemCount > 99 ? '99+' : '$itemCount'),
                child: Icon(icon),
              ),
      ),
    );
  }
}
