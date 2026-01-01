import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../core/config/app_config.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ExpenseController expenseController;
  late final NavigationController navController;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    expenseController = Get.find<ExpenseController>();
    navController = Get.find<NavigationController>();

    // Set initial nav item
    navController.setNavItem(NavItem.home);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.shopping_cart;
      case 'uber':
      case 'transport':
        return Icons.directions_bike;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }

  Future<bool> _onWillPop() async {
    // Double-tap-to-exit pattern
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      Get.snackbar(
        'Press back again to exit',
        '',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: AppConfig.textPrimaryColor.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return false;
    }
    return true; // Exit the app
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppConfig.surfaceColor,
        body: SafeArea(
        child: Obx(() {
          if (expenseController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final allExpenses = expenseController.expenses;
          final totalExpense = expenseController.totalExpenses.value;
          final latestExpenses = allExpenses.take(3).toList();

          // Calculate monthly total (for now, using total expenses)
          final monthlyBudget =
              5000.0; // Placeholder - can be from user settings
          final totalSalary =
              2000.0; // Placeholder - can be from income tracking

          return Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                color: AppConfig.backgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textPrimaryColor,
                      ),
                    ),
                    // Profile Picture
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConfig.primaryColor,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      Row(
                        children: [
                          // Total Salary Card
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.account_balance_wallet,
                              label: 'Total Salary',
                              amount: totalSalary,
                              isHighlighted: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Total Expense Card (Highlighted)
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.account_balance_wallet,
                              label: 'Total Expense',
                              amount: totalExpense,
                              isHighlighted: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Monthly Budget Card
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.account_balance_wallet,
                              label: 'Monthly',
                              amount: monthlyBudget,
                              isHighlighted: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.add,
                              label: 'Savings',
                              isHighlighted: true,
                              onTap: () {
                                // TODO: Navigate to savings
                                Get.snackbar(
                                  'Info',
                                  'Savings feature coming soon',
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.notifications,
                              label: 'Remind',
                              isHighlighted: false,
                              onTap: () {
                                // TODO: Navigate to reminders
                                Get.snackbar(
                                  'Info',
                                  'Reminders feature coming soon',
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.account_balance_wallet,
                              label: 'Budget',
                              isHighlighted: false,
                              onTap: () {
                                // TODO: Navigate to budget
                                Get.snackbar(
                                  'Info',
                                  'Budget feature coming soon',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Pagination Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPaginationDot(true),
                          const SizedBox(width: 8),
                          _buildPaginationDot(false),
                          const SizedBox(width: 8),
                          _buildPaginationDot(false),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Latest Entries Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Latest Entries',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConfig.textPrimaryColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.more_horiz,
                              color: AppConfig.textPrimaryColor,
                            ),
                            onPressed: () {
                              // TODO: Show more options
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Latest Entries List
                      if (latestExpenses.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No expenses yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppConfig.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add your first expense',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppConfig.textSecondaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...latestExpenses.map((expense) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppConfig.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Category Icon
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppConfig.surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(expense.category),
                                    color: AppConfig.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Category Name and Date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.category,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppConfig.textPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat(
                                          'd MMM yyyy',
                                        ).format(expense.date),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppConfig.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Amount and Payment Method
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rs ${expense.amount.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppConfig.textPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      expense.account,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppConfig.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation Bar
              const CustomBottomNavBar(),
            ],
          );
        }),
      ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required double amount,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppConfig.primaryColor
            : AppConfig.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlighted ? Colors.white : AppConfig.textPrimaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isHighlighted
                  ? Colors.white.withValues(alpha: 0.9)
                  : AppConfig.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.white : AppConfig.textPrimaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppConfig.primaryColor
              : AppConfig.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isHighlighted ? Colors.white : AppConfig.textPrimaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isHighlighted
                    ? Colors.white
                    : AppConfig.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppConfig.primaryColor
            : AppConfig.textSecondaryColor.withValues(alpha: 0.3),
      ),
    );
  }
}
