import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../../routes/app_routes.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          _buildNavItem(
            context: context,
            icon: Icons.home,
            label: 'Home',
            navItem: NavItem.home,
            controller: navController,
          ),
          // All Expenses
          _buildNavItem(
            context: context,
            icon: Icons.list_alt,
            label: 'All Expense',
            navItem: NavItem.allExpenses,
            controller: navController,
          ),
          // Plus Button (Center)
          _buildPlusButton(context),
          // Analytics
          _buildNavItem(
            context: context,
            icon: Icons.bar_chart,
            label: 'Analytics',
            navItem: NavItem.analytics,
            controller: navController,
          ),
          // Settings
          _buildNavItem(
            context: context,
            icon: Icons.settings,
            label: 'Settings',
            navItem: NavItem.settings,
            controller: navController,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required NavItem navItem,
    required NavigationController controller,
  }) {
    return Obx(() {
      final isSelected = controller.currentNavItem.value == navItem;
      return GestureDetector(
        onTap: () {
          controller.setNavItem(navItem);
          switch (navItem) {
            case NavItem.home:
              Get.offNamed('/');
              break;
            case NavItem.allExpenses:
              Get.offNamed('/all-expenses');
              break;
            case NavItem.analytics:
              Get.offNamed('/analytics');
              break;
            case NavItem.settings:
              Get.offNamed('/settings');
              break;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPlusButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.addExpense),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          shape: BoxShape.circle,
          border: Border.all(width: 3, color: Colors.transparent),
          gradient: const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF2196F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
