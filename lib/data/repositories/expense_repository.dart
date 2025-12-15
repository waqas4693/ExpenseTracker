import 'package:dio/dio.dart';
import '../models/expense_model.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class ExpenseRepository {
  final ApiService _apiService = ApiService();

  Future<List<ExpenseModel>> getAllExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (category != null) {
        queryParams['category'] = category;
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        ApiConstants.expenses,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final expensesList = data['expenses'] as List;
        return expensesList
            .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load expenses');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage =
            e.response?.data['message'] ??
            e.message ??
            'Failed to load expenses';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    try {
      final response = await _apiService.post(
        ApiConstants.expenses,
        data: expense.toJson(includeId: false),
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ExpenseModel.fromJson(data['expense'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add expense');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage =
            e.response?.data['message'] ?? e.message ?? 'Failed to add expense';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.expenses}/${expense.id}',
        data: expense.toJson(includeId: false),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ExpenseModel.fromJson(data['expense'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update expense');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage =
            e.response?.data['message'] ??
            e.message ??
            'Failed to update expense';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final response = await _apiService.delete('${ApiConstants.expenses}/$id');

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete expense');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage =
            e.response?.data['message'] ??
            e.message ??
            'Failed to delete expense';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final expenses = await getAllExpenses(
        startDate: startDate,
        endDate: endDate,
      );
      return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      throw Exception('Failed to calculate total expenses: $e');
    }
  }

  Future<Map<String, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final expenses = await getAllExpenses(
        startDate: startDate,
        endDate: endDate,
      );
      final Map<String, double> categoryTotals = {};
      for (var expense in expenses) {
        final currentTotal = categoryTotals[expense.category] ?? 0.0;
        categoryTotals[expense.category] = currentTotal + expense.amount;
      }
      return categoryTotals;
    } catch (e) {
      throw Exception('Failed to get expenses by category: $e');
    }
  }

  Future<Map<String, dynamic>> getCategoryBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiService.get(
        '${ApiConstants.expenses}/by-category',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return {
          'categories': data['categories'] as List,
          'total': (data['total'] as num).toDouble(),
        };
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to get category breakdown',
        );
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage =
            e.response?.data['message'] ??
            e.message ??
            'Failed to get category breakdown';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get category breakdown: $e');
    }
  }

  Future<List<ExpenseModel>> bulkCreateExpenses(
    List<ExpenseModel> expenses,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstants.expensesBulk,
        data: {
          'expenses': expenses.map((e) => e.toJson(includeId: false)).toList(),
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        final expensesList = data['expenses'] as List;
        return expensesList
            .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to bulk create expenses',
        );
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage =
            e.response?.data['message'] ??
            e.message ??
            'Failed to bulk create expenses';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }
}
