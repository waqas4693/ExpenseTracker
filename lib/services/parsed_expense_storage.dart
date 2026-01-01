import 'package:get_storage/get_storage.dart';
import '../data/models/parsed_expense_model.dart';
import '../core/constants/app_constants.dart';

class ParsedExpenseStorage {
  final GetStorage _storage = GetStorage();

  /// Saves a parsed expense to temporary storage
  Future<void> saveParsedExpense(ParsedExpenseModel expense) async {
    final expenses = getAllParsedExpenses();
    expenses.add(expense);
    await _saveAllParsedExpenses(expenses);
  }

  /// Saves multiple parsed expenses to temporary storage
  Future<void> saveParsedExpenses(List<ParsedExpenseModel> expenses) async {
    final existingExpenses = getAllParsedExpenses();
    existingExpenses.addAll(expenses);
    await _saveAllParsedExpenses(existingExpenses);
  }

  /// Gets all parsed expenses from temporary storage
  List<ParsedExpenseModel> getAllParsedExpenses() {
    final data = _storage.read<List<dynamic>>(AppConstants.parsedExpensesKey);
    if (data == null) return [];

    return data
        .map((json) => ParsedExpenseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Gets parsed expenses by status
  List<ParsedExpenseModel> getParsedExpensesByStatus(String status) {
    return getAllParsedExpenses()
        .where((expense) => expense.status == status)
        .toList();
  }

  /// Gets pending parsed expenses
  List<ParsedExpenseModel> getPendingExpenses() {
    return getParsedExpensesByStatus('pending');
  }

  /// Gets approved parsed expenses
  List<ParsedExpenseModel> getApprovedExpenses() {
    return getParsedExpensesByStatus('approved');
  }

  /// Gets rejected parsed expenses
  List<ParsedExpenseModel> getRejectedExpenses() {
    return getParsedExpensesByStatus('rejected');
  }

  /// Updates a parsed expense
  Future<void> updateParsedExpense(ParsedExpenseModel expense) async {
    final expenses = getAllParsedExpenses();
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
      await _saveAllParsedExpenses(expenses);
    }
  }

  /// Updates the status of a parsed expense
  Future<void> updateParsedExpenseStatus(String id, String status) async {
    final expenses = getAllParsedExpenses();
    final index = expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      expenses[index] = expenses[index].copyWith(status: status);
      await _saveAllParsedExpenses(expenses);
    }
  }

  /// Approves a parsed expense
  Future<void> approveParsedExpense(String id) async {
    await updateParsedExpenseStatus(id, 'approved');
  }

  /// Rejects a parsed expense
  Future<void> rejectParsedExpense(String id) async {
    await updateParsedExpenseStatus(id, 'rejected');
  }

  /// Approves multiple parsed expenses
  Future<void> approveParsedExpenses(List<String> ids) async {
    final expenses = getAllParsedExpenses();
    for (final expense in expenses) {
      if (ids.contains(expense.id)) {
        final index = expenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          expenses[index] = expense.copyWith(status: 'approved');
        }
      }
    }
    await _saveAllParsedExpenses(expenses);
  }

  /// Rejects multiple parsed expenses
  Future<void> rejectParsedExpenses(List<String> ids) async {
    final expenses = getAllParsedExpenses();
    for (final expense in expenses) {
      if (ids.contains(expense.id)) {
        final index = expenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          expenses[index] = expense.copyWith(status: 'rejected');
        }
      }
    }
    await _saveAllParsedExpenses(expenses);
  }

  /// Deletes a parsed expense
  Future<void> deleteParsedExpense(String id) async {
    final expenses = getAllParsedExpenses();
    expenses.removeWhere((e) => e.id == id);
    await _saveAllParsedExpenses(expenses);
  }

  /// Deletes multiple parsed expenses
  Future<void> deleteParsedExpenses(List<String> ids) async {
    final expenses = getAllParsedExpenses();
    expenses.removeWhere((e) => ids.contains(e.id));
    await _saveAllParsedExpenses(expenses);
  }

  /// Clears all parsed expenses
  Future<void> clearAllParsedExpenses() async {
    await _storage.remove(AppConstants.parsedExpensesKey);
  }

  /// Clears parsed expenses by status
  Future<void> clearParsedExpensesByStatus(String status) async {
    final expenses = getAllParsedExpenses();
    expenses.removeWhere((e) => e.status == status);
    await _saveAllParsedExpenses(expenses);
  }

  /// Gets count of parsed expenses by status
  int getParsedExpenseCountByStatus(String status) {
    return getParsedExpensesByStatus(status).length;
  }

  /// Gets total count of parsed expenses
  int getTotalParsedExpenseCount() {
    return getAllParsedExpenses().length;
  }

  /// Checks if a parsed expense exists (by ID)
  bool parsedExpenseExists(String id) {
    return getAllParsedExpenses().any((e) => e.id == id);
  }

  /// Saves all parsed expenses to storage
  Future<void> _saveAllParsedExpenses(List<ParsedExpenseModel> expenses) async {
    final jsonList = expenses.map((e) => e.toJson()).toList();
    await _storage.write(AppConstants.parsedExpensesKey, jsonList);
  }
}

