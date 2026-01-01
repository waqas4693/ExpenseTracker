// Example usage of SMS Expense Parser
// This file demonstrates how to use the SMS parsing service

import 'sms_expense_parser.dart';
import 'parsed_expense_storage.dart';
import '../data/models/parsed_expense_model.dart';

class SmsParserExample {
  final SmsExpenseParser _parser = SmsExpenseParser();
  final ParsedExpenseStorage _storage = ParsedExpenseStorage();

  /// Example: Parse a single SMS message
  Future<void> parseSingleMessageExample() async {
    // Example SMS message from a bank
    const message = '''
    MEEZAN BANK: Rs. 5,000.00 debited from account ending 1234.
    Transaction at KFC GULSHAN on 15-Dec-2024.
    Available balance: Rs. 45,000.00
    ''';

    const senderNumber = 'VK-MEZNBNK';
    final messageDate = DateTime.now();

    // Parse the message
    final parsedExpense = SmsExpenseParser.parseMessage(
      message: message,
      senderNumber: senderNumber,
      messageDate: messageDate,
    );

    if (parsedExpense != null) {
      // Save to temporary storage
      await _storage.saveParsedExpense(parsedExpense);
      print('Parsed expense: ${parsedExpense.title} - ${parsedExpense.amount}');
    } else {
      print('Message is not a payment message');
    }
  }

  /// Example: Parse multiple SMS messages
  Future<void> parseMultipleMessagesExample() async {
    // Example list of SMS messages (format from SMS reading library)
    final messages = [
      {
        'body': 'Rs. 1,500.00 debited from account. Payment at McDonald\'s.',
        'address': 'VK-MEZNBNK',
        'dateSent': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      },
      {
        'body': 'You spent Rs. 2,000.00 at Shell Petrol Station.',
        'address': 'VK-HBL',
        'dateSent': DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      },
      {
        'body': 'Rs. 3,000.00 credited to your account. Thank you!',
        'address': 'VK-UBL',
        'dateSent': DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch,
      },
    ];

    // Parse all messages
    final parsedExpenses = SmsExpenseParser.parseMessages(messages: messages);

    // Save all parsed expenses to temporary storage
    await _storage.saveParsedExpenses(parsedExpenses);

    print('Parsed ${parsedExpenses.length} expenses');
    
    // Get pending expenses
    final pendingExpenses = _storage.getPendingExpenses();
    print('Pending expenses: ${pendingExpenses.length}');
  }

  /// Example: Get and manage parsed expenses
  Future<void> manageParsedExpensesExample() async {
    // Get all pending expenses
    final pendingExpenses = _storage.getPendingExpenses();
    
    // Approve an expense
    if (pendingExpenses.isNotEmpty) {
      await _storage.approveParsedExpense(pendingExpenses.first.id);
    }

    // Approve multiple expenses
    final idsToApprove = pendingExpenses.take(3).map((e) => e.id).toList();
    await _storage.approveParsedExpenses(idsToApprove);

    // Reject an expense
    final remainingPending = _storage.getPendingExpenses();
    if (remainingPending.isNotEmpty) {
      await _storage.rejectParsedExpense(remainingPending.first.id);
    }

    // Get approved expenses
    final approvedExpenses = _storage.getApprovedExpenses();
    print('Approved expenses: ${approvedExpenses.length}');
  }

  /// Example: Clear old parsed expenses
  Future<void> clearOldExpensesExample() async {
    // Clear all rejected expenses
    await _storage.clearParsedExpensesByStatus('rejected');

    // Or clear all parsed expenses
    // await _storage.clearAllParsedExpenses();
  }
}

