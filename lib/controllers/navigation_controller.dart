import 'package:get/get.dart';

enum NavItem { home, allExpenses, smsExpenses, settings }

class NavigationController extends GetxController {
  final Rx<NavItem> currentNavItem = NavItem.home.obs;

  void setNavItem(NavItem item) {
    currentNavItem.value = item;
  }
}
