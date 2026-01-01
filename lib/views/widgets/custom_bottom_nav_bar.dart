import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../controllers/navigation_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();

    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Bottom Navigation Bar
          BottomNavigationBar(
            currentIndex: _getCurrentIndex(navController.currentNavItem.value),
            onTap: (index) => _onItemTapped(index, navController),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1A1A1A),
            unselectedItemColor: Colors.grey[600],
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'All Expense',
              ),
              // Placeholder for center button
              BottomNavigationBarItem(
                icon: Icon(Icons.circle_outlined, color: Colors.transparent),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sms),
                label: 'SMS Expenses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
          // Center Add Button
          Positioned(
            bottom: 8,
            child: FloatingActionButton(
              onPressed: () => Get.toNamed(AppRoutes.addExpense),
              backgroundColor: const Color(0xFF1A1A1A),
              elevation: 2,
              mini: true,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(NavItem navItem) {
    switch (navItem) {
      case NavItem.home:
        return 0;
      case NavItem.allExpenses:
        return 1;
      case NavItem.smsExpenses:
        return 3; // Skip index 2 (center button)
      case NavItem.settings:
        return 4; // Skip index 2 (center button)
    }
  }

  void _onItemTapped(int index, NavigationController controller) {
    // Prevent navigation if already on the same route
    final currentRoute = Get.currentRoute;
    String targetRoute;
    NavItem targetNavItem;

    switch (index) {
      case 0:
        targetRoute = '/';
        targetNavItem = NavItem.home;
        break;
      case 1:
        targetRoute = '/all-expenses';
        targetNavItem = NavItem.allExpenses;
        break;
      case 2:
        // Center button - handled by FloatingActionButton
        return;
      case 3:
        targetRoute = '/sms-expenses';
        targetNavItem = NavItem.smsExpenses;
        break;
      case 4:
        targetRoute = '/settings';
        targetNavItem = NavItem.settings;
        break;
      default:
        return;
    }

    // If already on the target route, don't navigate
    if (currentRoute == targetRoute) {
      return;
    }

    // Update navigation state
    controller.setNavItem(targetNavItem);

    // Navigate to the target route using offNamedUntil to preserve permanent controllers
    Get.offNamedUntil(
      targetRoute,
      (route) => false, // Clear all previous routes
    );
  }
}
