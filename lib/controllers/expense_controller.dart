import 'package:get/get.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';
import 'filter_controller.dart';
import 'navigation_controller.dart';
import '../routes/app_routes.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository _repository = ExpenseRepository();

  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxList<ExpenseModel> filteredExpenses = <ExpenseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble filteredTotalExpenses = 0.0.obs;
  final RxMap<String, double> expensesByCategory = <String, double>{}.obs;
  final RxList<Map<String, dynamic>> categoryBreakdown =
      <Map<String, dynamic>>[].obs;
  final RxDouble categoryTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    isLoading.value = true;
    try {
      expenses.value = await _repository.getAllExpenses();
      totalExpenses.value = await _repository.getTotalExpenses();
      expensesByCategory.value = await _repository.getExpensesByCategory();
      // Load filtered expenses if FilterController is available
      try {
        await loadFilteredExpenses();
      } catch (e) {
        // FilterController not initialized yet, will be loaded from HomeScreen
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFilteredExpenses() async {
    try {
      final filterController = Get.find<FilterController>();
      final filter = filterController.selectedFilter.value;

      DateTime? startDate;
      DateTime? endDate;
      final now = DateTime.now();

      switch (filter) {
        case FilterType.today:
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case FilterType.thisWeek:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case FilterType.thisMonth:
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
      }

      filteredExpenses.value = await _repository.getAllExpenses(
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate total from filtered expenses
      filteredTotalExpenses.value = filteredExpenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load filtered expenses: $e');
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    isLoading.value = true;
    try {
      await _repository.addExpense(expense);
      await loadExpenses();
      await loadFilteredExpenses();
      
      // Navigate to home page and update navigation state
      try {
        final navController = Get.find<NavigationController>();
        navController.setNavItem(NavItem.home);
      } catch (e) {
        // NavigationController might not be available, continue anyway
      }
      
      // Navigate to home page
      Get.offNamedUntil(
        AppRoutes.home,
        (route) => false, // Clear all previous routes
      );
      
      Get.snackbar('Success', 'Expense added successfully');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    isLoading.value = true;
    try {
      await _repository.updateExpense(expense);
      await loadExpenses();
      await loadFilteredExpenses();
      Get.back();
      Get.snackbar('Success', 'Expense updated successfully');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(String id) async {
    isLoading.value = true;
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
      await loadFilteredExpenses();
      Get.snackbar('Success', 'Expense deleted successfully');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategoryBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final data = await _repository.getCategoryBreakdown(
        startDate: startDate,
        endDate: endDate,
      );
      categoryBreakdown.value = List<Map<String, dynamic>>.from(
        data['categories'],
      );
      categoryTotal.value = data['total'] as double;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load category breakdown: $e');
    }
  }

  /// Bulk create expenses (used for SMS expenses)
  /// Returns the number of successfully created expenses
  Future<int> bulkCreateExpenses(List<ExpenseModel> expenses) async {
    if (expenses.isEmpty) return 0;

    isLoading.value = true;
    int successCount = 0;
    try {
      // Try bulk create first
      try {
        await _repository.bulkCreateExpenses(expenses);
        successCount = expenses.length;
      } catch (e) {
        // Fallback to individual creation
        for (final expense in expenses) {
          try {
            await _repository.addExpense(expense);
            successCount++;
          } catch (err) {
            // Continue with other expenses even if one fails
            print('Failed to save expense ${expense.id}: $err');
          }
        }
      }

      // Reload expenses after bulk create
      await loadExpenses();
      await loadFilteredExpenses();

      return successCount;
    } catch (e) {
      throw Exception('Failed to bulk create expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
