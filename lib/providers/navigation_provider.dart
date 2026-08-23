import 'package:flutter/foundation.dart';

abstract final class AppTab {
  static const int home = 0;
  static const int menu = 1;
  static const int cart = 2;
  static const int orders = 3;
  static const int profile = 4;
  static const int count = 5;

  static bool isValid(int index) => index >= home && index < count;
}

class NavigationProvider extends ChangeNotifier {
  NavigationProvider({int initialIndex = AppTab.home})
    : assert(AppTab.isValid(initialIndex)),
      _selectedIndex = initialIndex;

  int _selectedIndex;

  int get selectedIndex => _selectedIndex;

  void selectTab(int index) {
    if (!AppTab.isValid(index)) {
      throw RangeError.range(index, AppTab.home, AppTab.profile, 'index');
    }
    if (_selectedIndex == index) {
      return;
    }

    _selectedIndex = index;
    notifyListeners();
  }

  void goHome() => selectTab(AppTab.home);

  void openMenu() => selectTab(AppTab.menu);

  void openCart() => selectTab(AppTab.cart);
}
