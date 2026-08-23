import 'package:flutter_test/flutter_test.dart';
import 'package:quickbite_cafe/providers/navigation_provider.dart';

void main() {
  test('navigation starts at Home and switches tabs', () {
    final navigation = NavigationProvider();

    expect(navigation.selectedIndex, AppTab.home);
    navigation.openMenu();
    expect(navigation.selectedIndex, AppTab.menu);
    navigation.openCart();
    expect(navigation.selectedIndex, AppTab.cart);
    navigation.goHome();
    expect(navigation.selectedIndex, AppTab.home);
  });

  test('navigation rejects a tab index outside the five destinations', () {
    final navigation = NavigationProvider();

    expect(() => navigation.selectTab(AppTab.count), throwsRangeError);
  });
}
