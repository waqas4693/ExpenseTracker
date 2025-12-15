import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/expense_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/app_config.dart';
import '../../data/models/expense_model.dart';
import '../widgets/month_calendar.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ExpenseController _controller = Get.find<ExpenseController>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = AppConstants.defaultCategories[0];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toStringAsFixed(0);
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
    } else {
      _titleController.text = 'Family Expense';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onMonthChanged(DateTime month) {
    // Month changed, no action needed
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _addNewCategory() {
    // TODO: Show dialog to add new category
    Get.snackbar('Info', 'Add new category feature coming soon');
  }

  void _saveExpense() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar('Error', 'Please enter an expense title');
      return;
    }

    final amountText = _amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return;
    }

    final expense = ExpenseModel(
      id: widget.expense?.id ?? const Uuid().v4(),
      title: title,
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      description: title,
      account: 'Cash',
      source: 'manual',
      status: 'approved',
    );

    if (widget.expense != null) {
      _controller.updateExpense(expense);
    } else {
      _controller.addExpense(expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return Scaffold(
          backgroundColor: AppConfig.surfaceColor,
          appBar: AppBar(
            backgroundColor: AppConfig.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppConfig.textPrimaryColor,
              ),
              onPressed: () => Get.back(),
            ),
            title: const Text(
              'Add Expense',
              style: TextStyle(
                color: AppConfig.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: AppConfig.surfaceColor,
        appBar: AppBar(
          backgroundColor: AppConfig.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppConfig.textPrimaryColor,
            ),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Add Expense',
            style: TextStyle(
              color: AppConfig.textPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar Component
                      MonthCalendar(
                        selectedDate: _selectedDate,
                        onDateSelected: _onDateSelected,
                        onMonthChanged: _onMonthChanged,
                      ),
                      const SizedBox(height: 32),
                      // Expense Title Section
                      const Text(
                        'Expense Title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppConfig.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter expense title',
                          hintStyle: const TextStyle(
                            color: AppConfig.textSecondaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppConfig.primaryLightColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppConfig.primaryLightColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppConfig.primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppConfig.backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Amount Section
                      const Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppConfig.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: const TextStyle(
                            color: AppConfig.textSecondaryColor,
                          ),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '\$',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppConfig.textPrimaryColor,
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppConfig.primaryLightColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppConfig.primaryLightColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppConfig.primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppConfig.backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Expense Category Section
                      const Text(
                        'Expense Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppConfig.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Category Buttons
                      Row(
                        children: [
                          // Add New Category Button (dashed border)
                          GestureDetector(
                            onTap: _addNewCategory,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppConfig.textSecondaryColor,
                                  style: BorderStyle.solid,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppConfig.textSecondaryColor,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Category Buttons
                          Expanded(
                            child: Row(
                              children: [
                                // Show first 2 categories as buttons
                                ...AppConstants.defaultCategories.take(2).map((
                                  category,
                                ) {
                                  final isSelected =
                                      _selectedCategory == category;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: GestureDetector(
                                        onTap: () => _selectCategory(category),
                                        child: Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppConfig.primaryColor
                                                : AppConfig.backgroundColor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppConfig.primaryColor
                                                  : AppConfig.textSecondaryColor
                                                        .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              category,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppConfig
                                                          .textPrimaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Show more categories if needed (scrollable)
                      if (AppConstants.defaultCategories.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: AppConstants.defaultCategories
                                .skip(2)
                                .map((category) {
                                  final isSelected =
                                      _selectedCategory == category;
                                  return GestureDetector(
                                    onTap: () => _selectCategory(category),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppConfig.primaryColor
                                            : AppConfig.backgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppConfig.primaryColor
                                              : AppConfig.textSecondaryColor
                                                    .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : AppConfig.textPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // ADD EXPENSE Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConfig.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'ADD EXPENSE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
