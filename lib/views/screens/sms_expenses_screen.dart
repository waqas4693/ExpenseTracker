import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/sms_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../data/models/parsed_expense_model.dart';
import '../../core/config/app_config.dart';
import '../../routes/app_routes.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class SmsExpensesScreen extends StatefulWidget {
  const SmsExpensesScreen({super.key});

  @override
  State<SmsExpensesScreen> createState() => _SmsExpensesScreenState();
}

class _SmsExpensesScreenState extends State<SmsExpensesScreen> {
  late final SmsController _smsController;
  late final NavigationController _navController;

  @override
  void initState() {
    super.initState();
    _smsController = Get.find<SmsController>();
    _navController = Get.find<NavigationController>();
    _navController.setNavItem(NavItem.smsExpenses);
    _smsController.loadParsedExpenses();
  }

  Future<bool> _onWillPop() async {
    Get.offNamed(AppRoutes.home);
    return false;
  }

  Future<void> _approveAllExpenses() async {
    final pendingExpenses = _smsController.parsedExpenses
        .where((e) => e.status == 'pending')
        .toList();

    if (pendingExpenses.isEmpty) {
      Get.snackbar(
        'No Expenses',
        'No pending expenses to approve',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Approve All Expenses'),
        content: Text(
          'Are you sure you want to approve ${pendingExpenses.length} expense(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Approve All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ids = pendingExpenses.map((e) => e.id).toList();
      await _smsController.approveParsedExpenses(ids);
      _smsController.loadParsedExpenses();
      Get.snackbar(
        'Success',
        'All expenses approved',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _rejectAllExpenses() async {
    final pendingExpenses = _smsController.parsedExpenses
        .where((e) => e.status == 'pending')
        .toList();

    if (pendingExpenses.isEmpty) {
      Get.snackbar(
        'No Expenses',
        'No pending expenses to reject',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reject All Expenses'),
        content: Text(
          'Are you sure you want to reject ${pendingExpenses.length} expense(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Reject All'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ids = pendingExpenses.map((e) => e.id).toList();
      await _smsController.rejectParsedExpenses(ids);
      _smsController.loadParsedExpenses();
      Get.snackbar(
        'Success',
        'All expenses rejected',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _approveExpense(String id) async {
    await _smsController.approveParsedExpense(id);
    _smsController.loadParsedExpenses();
    Get.snackbar(
      'Success',
      'Expense approved',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _rejectExpense(String id) async {
    await _smsController.rejectParsedExpense(id);
    _smsController.loadParsedExpenses();
    Get.snackbar(
      'Success',
      'Expense rejected',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
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
            icon: const Icon(Icons.arrow_back, color: AppConfig.textPrimaryColor),
            onPressed: () => Get.offNamed(AppRoutes.home),
          ),
          title: const Text(
            'SMS Expenses',
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
            final pendingCount = _smsController.getPendingCount();
            final hasPending = pendingCount > 0;

            return Column(
              children: [
                // Top Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppConfig.backgroundColor,
                  child: Column(
                    children: [
                      // Manual Scan Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _smsController.isLoading.value
                              ? null
                              : () async {
                                  if (!_smsController.hasPermission.value) {
                                    await _smsController.requestPermission();
                                  }
                                  if (_smsController.hasPermission.value) {
                                    await _smsController.scanAllMessages();
                                  }
                                },
                          icon: _smsController.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(
                            _smsController.isLoading.value
                                ? 'Scanning...'
                                : 'Scan Messages',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConfig.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (hasPending) ...[
                        const SizedBox(height: 12),
                        // Accept All & Reject All Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _approveAllExpenses,
                                icon: const Icon(Icons.check_circle),
                                label: Text('Approve All ($pendingCount)'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: const BorderSide(color: Colors.green),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _rejectAllExpenses,
                                icon: const Icon(Icons.cancel),
                                label: Text('Reject All ($pendingCount)'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Permission Status
                if (!_smsController.hasPermission.value)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'SMS permission required to scan messages',
                            style: TextStyle(color: Colors.orange[900]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Expenses List
                Expanded(
                  child: _smsController.parsedExpenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sms_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No expenses found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Scan Messages" to find expenses from SMS',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _smsController.parsedExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = _smsController.parsedExpenses[index];
                            return _buildExpenseCard(expense);
                          },
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

  Widget _buildExpenseCard(ParsedExpenseModel expense) {
    final isPending = expense.status == 'pending';
    final isApproved = expense.status == 'approved';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending
              ? Colors.orange.withOpacity(0.3)
              : isApproved
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.orange[100]
                      : isApproved
                          ? Colors.green[100]
                          : Colors.red[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  expense.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPending
                        ? Colors.orange[900]
                        : isApproved
                            ? Colors.green[900]
                            : Colors.red[900],
                  ),
                ),
              ),
              const Spacer(),
              // Amount
              Text(
                'Rs ${expense.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            expense.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConfig.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          // Details
          Row(
            children: [
              Icon(Icons.category, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                expense.category,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.account_balance, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                expense.account,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Date & Sender
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(expense.date),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.phone, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  expense.senderNumber,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Original Message (collapsible)
          if (expense.originalMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                'View Original SMS',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    expense.originalMessage,
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ],
          // Action Buttons (only for pending)
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _approveExpense(expense.id),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectExpense(expense.id),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

