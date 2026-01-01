import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/filter_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../data/models/expense_model.dart';
import '../../routes/app_routes.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/donut_chart.dart';
import '../widgets/bar_chart_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final FilterController _filterController = Get.put(FilterController());
  late final NavigationController _navController;
  DateTime? _customDate;
  bool _showCategoryTab = true;

  @override
  void initState() {
    super.initState();
    _navController = Get.find<NavigationController>();
    // _navController.setNavItem(NavItem.analytics);
    _customDate = DateTime.now();
  }

  Future<void> _selectCustomDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _filterController.setFilter(FilterType.today);
      });
    }
  }

  Map<String, double> _getExpensesByCategory(List<ExpenseModel> expenses) {
    final Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }
    return categoryTotals;
  }

  Map<String, double> _getMonthlyExpenses(List<ExpenseModel> expenses) {
    final Map<String, double> monthlyTotals = {};
    for (var expense in expenses) {
      final monthKey = DateFormat('MMM').format(expense.date);
      monthlyTotals[monthKey] =
          (monthlyTotals[monthKey] ?? 0.0) + expense.amount;
    }
    return monthlyTotals;
  }

  List<ExpenseModel> _getFilteredExpenses() {
    final allExpenses = _expenseController.expenses;
    final now = DateTime.now();

    switch (_filterController.selectedFilter.value) {
      case FilterType.today:
        return allExpenses.where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month &&
              expense.date.day == now.day;
        }).toList();
      case FilterType.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return allExpenses.where((expense) {
          return expense.date.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) &&
              expense.date.isBefore(now.add(const Duration(days: 1)));
        }).toList();
      case FilterType.thisMonth:
        if (_customDate != null) {
          return allExpenses.where((expense) {
            return expense.date.year == _customDate!.year &&
                expense.date.month == _customDate!.month;
          }).toList();
        }
        return allExpenses.where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month;
        }).toList();
    }
  }

  Future<bool> _onWillPop() async {
    Get.offNamed(AppRoutes.home);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Get.offNamed(AppRoutes.home),
        ),
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (_expenseController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredExpenses = _getFilteredExpenses();
        final totalAmount = filteredExpenses.fold<double>(
          0.0,
          (sum, expense) => sum + expense.amount,
        );
        final categoryTotals = _getExpensesByCategory(filteredExpenses);
        final monthlyTotals = _getMonthlyExpenses(_expenseController.expenses);
        final topCategory = categoryTotals.entries.isNotEmpty
            ? categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b)
            : null;

        return Column(
          children: [
            // Filter Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterTab(
                      label: 'Today',
                      filter: FilterType.today,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterTab(
                      label: 'This Week',
                      filter: FilterType.thisWeek,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterTab(
                      label: _customDate != null
                          ? DateFormat('MMM d').format(_customDate!)
                          : 'This Month',
                      filter: FilterType.thisMonth,
                      isCustom: true,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Set up your budget Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.track_changes,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Set up your budget',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track your spending and stay on top of your finances',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Spending Categories Section
                    if (topCategory != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${DateFormat('MMM d').format(_customDate ?? DateTime.now())} spending categories',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You\'ve spent Rs ${totalAmount.toStringAsFixed(0)} so far in ${DateFormat('MMM d').format(_customDate ?? DateTime.now())}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            DonutChart(
                              value: topCategory.value,
                              total: totalAmount,
                              color: Colors.amber,
                              centerLabel: topCategory.key,
                              centerValue:
                                  'Rs ${topCategory.value.toStringAsFixed(0)}',
                              legendLabel: topCategory.key,
                              legendValue:
                                  'Rs ${topCategory.value.toStringAsFixed(0)}',
                            ),
                            if (topCategory.value > 0 && totalAmount > 0) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+100% vs last month',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Bank Expenses Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bank Expenses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Showing expenses for 1 selected bank',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          DonutChart(
                            value: totalAmount,
                            total: totalAmount > 0 ? totalAmount : 1,
                            color: Colors.pink,
                            centerLabel: 'cash',
                            centerValue: 'Rs ${totalAmount.toStringAsFixed(0)}',
                            legendLabel: 'cash',
                            legendValue: 'Rs ${totalAmount.toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Categories Breakdown Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tabs
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _showCategoryTab = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _showCategoryTab
                                          ? Colors.white
                                          : Colors.grey[100],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Category',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _showCategoryTab
                                              ? const Color(0xFF1A1A1A)
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _showCategoryTab = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !_showCategoryTab
                                          ? Colors.white
                                          : Colors.grey[100],
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Merchant',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: !_showCategoryTab
                                              ? const Color(0xFF1A1A1A)
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Categories Breakdown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (categoryTotals.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'No expenses found',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          else
                            ...categoryTotals.entries.map((entry) {
                              final percentage = totalAmount > 0
                                  ? (entry.value / totalAmount * 100)
                                  : 0.0;
                              return _buildCategoryItem(
                                category: entry.key,
                                amount: entry.value,
                                percentage: percentage,
                                total: totalAmount,
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Monthly Expenses Trend
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly Expenses Trend',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 24),
                          BarChartWidget(monthlyData: monthlyTotals),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Stats
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Stats',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatItem(
                            'Most Expensive Category',
                            topCategory?.key ?? 'N/A',
                          ),
                          const SizedBox(height: 12),
                          _buildStatItem(
                            'Total Expenses',
                            'Rs ${totalAmount.toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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

  Widget _buildFilterTab({
    required String label,
    required FilterType filter,
    bool isCustom = false,
  }) {
    return Obx(() {
      final isSelected = _filterController.selectedFilter.value == filter;
      return GestureDetector(
        onTap: () {
          if (isCustom) {
            _selectCustomDate();
          } else {
            _filterController.setFilter(filter);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF9EFF00) // Lime green
                : const Color(0xFF2C2C2C), // Dark grey
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
              if (isCustom && isSelected) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryItem({
    required String category,
    required double amount,
    required double percentage,
    required double total,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              // Category Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Category Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${percentage.toStringAsFixed(0)}% of total',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Amount
              Text(
                'Rs${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          // Progress Bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF9EFF00), // Lime green
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
      case 'transportation':
        return Icons.directions_car;
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
      case 'transportation':
        return Colors.red;
      case 'food':
        return Colors.orange;
      case 'shopping':
        return Colors.blue;
      case 'bills':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'health':
        return Colors.green;
      case 'education':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
