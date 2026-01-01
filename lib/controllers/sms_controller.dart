import 'package:get/get.dart';
import '../data/models/parsed_expense_model.dart';
import '../data/models/expense_model.dart';
import '../services/sms_reader_service.dart';
import '../services/parsed_expense_storage.dart';
import 'expense_controller.dart';

class SmsController extends GetxController {
  final SmsReaderService _smsService = SmsReaderService();
  final ParsedExpenseStorage _storage = ParsedExpenseStorage();

  final RxBool isLoading = false.obs;
  final RxBool hasPermission = false.obs;
  final RxBool isListening = false.obs;
  final RxList<ParsedExpenseModel> parsedExpenses = <ParsedExpenseModel>[].obs;
  final RxInt totalMessagesScanned = 0.obs;
  final RxInt newExpensesFound = 0.obs;
  final RxString errorMessage = ''.obs;

  // Configuration
  final RxList<String> allowedSenders = <String>[].obs;
  final RxInt scanDaysBack = 30.obs; // Default: scan last 30 days

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    // Check permission status
    hasPermission.value = await _smsService.hasPermission();

    // No sender filtering - parser will determine expense-related messages by content
    // allowedSenders list is kept for potential future manual filtering feature
    allowedSenders.value = [];

    // Load existing parsed expenses
    loadParsedExpenses();

    // Don't start listening automatically - let user control it
    // Start listening can be called manually when needed
  }

  /// Request SMS permission
  Future<bool> requestPermission() async {
    isLoading.value = true;
    try {
      final granted = await _smsService.requestPermission();
      hasPermission.value = granted;

      if (!granted) {
        Get.snackbar(
          'Permission Denied',
          'SMS permission is required to read payment messages',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return granted;
    } catch (e) {
      errorMessage.value = 'Failed to request permission: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Manually scan all messages
  Future<void> scanAllMessages() async {
    if (!hasPermission.value) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    newExpensesFound.value = 0;

    try {
      final expenses = await _smsService.readAllMessages(
        daysBack: scanDaysBack.value,
      );

      newExpensesFound.value = expenses.length;
      totalMessagesScanned.value += expenses.length;

      // Reload parsed expenses
      loadParsedExpenses();

      Get.snackbar(
        'Scan Complete',
        'Found ${expenses.length} new expense(s)',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to scan messages: $e';
      Get.snackbar(
        'Error',
        'Failed to scan messages: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Start listening for new incoming SMS
  void startListening() {
    if (isListening.value) return;
    if (!hasPermission.value) return;

    _smsService.startListening(
      onNewExpense: (ParsedExpenseModel expense) {
        // Add to list
        parsedExpenses.insert(0, expense);

        // Show notification
        Get.snackbar(
          'New Expense Found',
          '${expense.title} - Rs. ${expense.amount.toStringAsFixed(0)}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      },
      onError: (String error) {
        errorMessage.value = error;
        Get.snackbar('SMS Error', error, snackPosition: SnackPosition.BOTTOM);
      },
    );

    isListening.value = true;
  }

  /// Stop listening for new SMS
  void stopListening() {
    _smsService.stopListening();
    isListening.value = false;
  }

  /// Load parsed expenses from storage
  void loadParsedExpenses() {
    parsedExpenses.value = _storage.getAllParsedExpenses();
  }

  /// Get pending expenses count
  int getPendingCount() {
    return _storage.getParsedExpenseCountByStatus('pending');
  }

  /// Get approved expenses count
  int getApprovedCount() {
    return _storage.getParsedExpenseCountByStatus('approved');
  }

  /// Get rejected expenses count
  int getRejectedCount() {
    return _storage.getParsedExpenseCountByStatus('rejected');
  }

  /// Add allowed sender
  void addAllowedSender(String sender) {
    if (!allowedSenders.contains(sender)) {
      allowedSenders.add(sender);
      // Restart listening with new senders
      if (isListening.value) {
        stopListening();
        startListening();
      }
    }
  }

  /// Remove allowed sender
  void removeAllowedSender(String sender) {
    allowedSenders.remove(sender);
    // Restart listening with updated senders
    if (isListening.value) {
      stopListening();
      startListening();
    }
  }

  /// Update scan days back
  void updateScanDaysBack(int days) {
    scanDaysBack.value = days;
  }

  /// Convert ParsedExpenseModel to ExpenseModel
  ExpenseModel _convertToExpenseModel(ParsedExpenseModel parsed) {
    return ExpenseModel(
      id: parsed.id,
      title: parsed.title,
      amount: parsed.amount,
      category: parsed.category,
      date: parsed.date,
      description: parsed.description ?? parsed.originalMessage,
      account: parsed.account,
      source: 'sms', // Mark as SMS-sourced expense
      status: 'approved',
    );
  }

  /// Approve multiple parsed expenses
  Future<void> approveParsedExpenses(List<String> ids) async {
    isLoading.value = true;
    try {
      // Get the parsed expenses to approve
      final expensesToApprove = parsedExpenses
          .where((e) => ids.contains(e.id) && e.status == 'pending')
          .toList();

      if (expensesToApprove.isEmpty) {
        Get.snackbar('Info', 'No pending expenses to approve');
        return;
      }

      // Convert to ExpenseModel and save to backend
      final expenseController = Get.find<ExpenseController>();
      final expensesToSave = expensesToApprove
          .map((parsed) => _convertToExpenseModel(parsed))
          .toList();

      // Save expenses to backend using bulk create
      final successCount = await expenseController.bulkCreateExpenses(
        expensesToSave,
      );

      // Update status in local storage
      await _storage.approveParsedExpenses(ids);

      // Reload parsed expenses (main expenses list already reloaded by bulkCreateExpenses)
      loadParsedExpenses();

      Get.snackbar(
        'Success',
        'Approved and saved $successCount expense(s)',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve expenses: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reject multiple parsed expenses
  Future<void> rejectParsedExpenses(List<String> ids) async {
    await _storage.rejectParsedExpenses(ids);
    loadParsedExpenses();
    Get.snackbar(
      'Success',
      'Rejected ${ids.length} expense(s)',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Approve a single parsed expense
  Future<void> approveParsedExpense(String id) async {
    isLoading.value = true;
    try {
      // Find the parsed expense
      final parsedExpense = parsedExpenses.firstWhere(
        (e) => e.id == id && e.status == 'pending',
        orElse: () => throw Exception('Expense not found or already processed'),
      );

      // Convert to ExpenseModel
      final expense = _convertToExpenseModel(parsedExpense);

      // Save to backend using bulk create (which handles single items too)
      final expenseController = Get.find<ExpenseController>();
      await expenseController.bulkCreateExpenses([expense]);

      // Update status in local storage
      await _storage.approveParsedExpense(id);

      // Reload parsed expenses (main expenses list already reloaded by bulkCreateExpenses)
      loadParsedExpenses();

      Get.snackbar(
        'Success',
        'Expense approved and saved',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve expense: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reject a single parsed expense
  Future<void> rejectParsedExpense(String id) async {
    await _storage.rejectParsedExpense(id);
    loadParsedExpenses();
    Get.snackbar(
      'Success',
      'Expense rejected',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
