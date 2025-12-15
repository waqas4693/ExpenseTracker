import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../data/models/expense_model.dart';
import '../../core/config/app_config.dart';
import '../../routes/app_routes.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/month_calendar.dart';
import '../widgets/semi_circular_chart.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  DateTime _selectedDate = DateTime.now();
  String _activeTab = 'Spends'; // 'Spends' or 'Categories'
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  late final NavigationController _navController;

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    // Reload category data when date changes
    _loadCategoryData();
  }

  void _onMonthChanged(DateTime month) {
    // Reload category breakdown when month changes
    _loadCategoryData();
  }

  void _loadCategoryData() {
    // Calculate start and end of selected date's month
    final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final endDate = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
      23,
      59,
      59,
    );
    _expenseController.loadCategoryBreakdown(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  void initState() {
    super.initState();
    _navController = Get.put(NavigationController());
    _navController.setNavItem(NavItem.allExpenses);
    // Load category data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoryData();
    });
  }

  double _calculateTotal(List<ExpenseModel> expenses) {
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  List<ExpenseModel> _getFilteredExpenses(List<ExpenseModel> expenses) {
    return expenses.where((expense) {
      return expense.date.year == _selectedDate.year &&
          expense.date.month == _selectedDate.month &&
          expense.date.day == _selectedDate.day;
    }).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
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
    Get.offNamed(AppRoutes.home);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppConfig.surfaceColor,
        appBar: AppBar(
          backgroundColor: AppConfig.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppConfig.textPrimaryColor,
            ),
            onPressed: () => Get.offNamed(AppRoutes.home),
          ),
          title: const Text(
            'Total Expenses',
            style: TextStyle(
              color: AppConfig.textPrimaryColor,
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

            final allExpenses = _expenseController.expenses;
            final filteredExpenses = _getFilteredExpenses(allExpenses);
            final totalAmount = _calculateTotal(filteredExpenses);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calendar
                        MonthCalendar(
                          selectedDate: _selectedDate,
                          onDateSelected: _onDateSelected,
                          onMonthChanged: _onMonthChanged,
                        ),
                        const SizedBox(height: 24),
                        // Spending Summary Circle
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Gray ring
                                  SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: CircularProgressIndicator(
                                      value: 0.6, // 60% of budget
                                      strokeWidth: 12,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppConfig.primaryColor,
                                      ),
                                    ),
                                  ),
                                  // Blue circle with amount
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: AppConfig.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Rs ${totalAmount.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'You have Spend total',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppConfig.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '60% of you budget',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppConfig.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Tabs
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _activeTab = 'Spends'),
                                child: Column(
                                  children: [
                                    Text(
                                      'Spends',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _activeTab == 'Spends'
                                            ? AppConfig.primaryColor
                                            : AppConfig.textSecondaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 2,
                                      color: _activeTab == 'Spends'
                                          ? AppConfig.primaryColor
                                          : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _activeTab = 'Categories'),
                                child: Column(
                                  children: [
                                    Text(
                                      'Categories',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _activeTab == 'Categories'
                                            ? AppConfig.primaryColor
                                            : AppConfig.textSecondaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 2,
                                      color: _activeTab == 'Categories'
                                          ? AppConfig.primaryColor
                                          : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Transaction List
                        if (_activeTab == 'Spends')
                          filteredExpenses.isEmpty
                              ? Center(
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
                                          'No expenses found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppConfig.textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: filteredExpenses.map((expense) {
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              _getCategoryIcon(
                                                expense.category,
                                              ),
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
                                                    color: AppConfig
                                                        .textPrimaryColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  DateFormat(
                                                    'd MMM yyyy',
                                                  ).format(expense.date),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppConfig
                                                        .textSecondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Amount and Payment Method
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Rs ${expense.amount.toStringAsFixed(0)}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppConfig
                                                          .textPrimaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                expense.account,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppConfig
                                                      .textSecondaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                )
                        else
                          // Categories tab content
                          Obx(() {
                            final categoryBreakdown =
                                _expenseController.categoryBreakdown;
                            final filteredExpenses = _getFilteredExpenses(
                              _expenseController.expenses,
                            );

                            if (categoryBreakdown.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.pie_chart_outline,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No category data found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppConfig.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Convert to CategoryData for chart
                            final categoryData = categoryBreakdown.map((item) {
                              return CategoryData(
                                category: item['category'] as String,
                                amount: (item['total'] as num).toDouble(),
                                percentage: (item['percentage'] as num)
                                    .toDouble(),
                                color: AppConfig.primaryColor,
                              );
                            }).toList();

                            return Column(
                              children: [
                                // Category Breakdown Chart
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppConfig.backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SemiCircularChart(
                                    categories: categoryData,
                                    size: 250,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Transaction List (same as Spends tab)
                                filteredExpenses.isEmpty
                                    ? Center(
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
                                                'No expenses found',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: AppConfig
                                                      .textSecondaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: filteredExpenses.map((
                                          expense,
                                        ) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppConfig.backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                // Category Icon
                                                Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppConfig.surfaceColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    _getCategoryIcon(
                                                      expense.category,
                                                    ),
                                                    color:
                                                        AppConfig.primaryColor,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                // Category Name and Date
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        expense.category,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppConfig
                                                              .textPrimaryColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        DateFormat(
                                                          'd MMM yyyy',
                                                        ).format(expense.date),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppConfig
                                                              .textSecondaryColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Amount and Payment Method
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'Rs ${expense.amount.toStringAsFixed(0)}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppConfig
                                                            .textPrimaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      expense.account,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppConfig
                                                            .textSecondaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                              ],
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
}
