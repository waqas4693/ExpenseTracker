import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'sms_expense_parser.dart';
import 'parsed_expense_storage.dart';
import '../data/models/parsed_expense_model.dart';

class SmsReaderService {
  final SmsQuery _smsQuery = SmsQuery();
  final ParsedExpenseStorage _storage = ParsedExpenseStorage();
  bool _isListening = false;

  /// Request SMS permission
  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Check if SMS permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Read all SMS messages from device
  /// Returns list of parsed expenses
  /// The parser will determine if messages are expense-related based on content
  Future<List<ParsedExpenseModel>> readAllMessages({int? daysBack}) async {
    if (!await hasPermission()) {
      throw Exception('SMS permission not granted');
    }

    try {
      // Get all SMS messages from inbox
      print('[SMS Reader] Starting to read SMS messages...');
      final messages = await _smsQuery.querySms(
        kinds: [SmsQueryKind.Inbox],
        sort: true,
      );
      print('[SMS Reader] Total SMS messages found: ${messages.length}');

      // Filter by date if specified
      DateTime? cutoffDate;
      if (daysBack != null) {
        cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
        print(
          '[SMS Reader] Filtering messages from last $daysBack days (after ${cutoffDate.toString()})',
        );
      }

      print(
        '[SMS Reader] Reading all messages - parser will filter by content',
      );

      // Convert to list format for parser
      final List<Map<String, dynamic>> messageList = [];
      int skippedByDate = 0;

      for (final message in messages) {
        final sender = message.sender ?? '';
        final body = message.body ?? '';
        final dateSent = message.date ?? DateTime.now();

        print('[SMS Reader] Processing message from: $sender');
        print(
          '[SMS Reader] Message body: ${body.length > 100 ? body.substring(0, 100) + "..." : body}',
        );
        print('[SMS Reader] Message date: $dateSent');

        // Skip if before cutoff date
        if (cutoffDate != null && dateSent.isBefore(cutoffDate)) {
          print('[SMS Reader] ⏭️ Skipped: Message is before cutoff date');
          skippedByDate++;
          continue;
        }

        // Add all messages to parsing list - parser will determine if they're expenses
        messageList.add({
          'body': body,
          'address': sender,
          'dateSent': dateSent.millisecondsSinceEpoch,
        });
        print(
          '[SMS Reader] ✓ Added message to parsing list (parser will filter by content)',
        );
      }

      print('[SMS Reader] Summary:');
      print('[SMS Reader]   - Total messages: ${messages.length}');
      print('[SMS Reader]   - Skipped by date: $skippedByDate');
      print('[SMS Reader]   - Messages to parse: ${messageList.length}');

      // Parse messages
      print('[SMS Reader] Starting to parse ${messageList.length} messages...');
      final parsedExpenses = SmsExpenseParser.parseMessages(
        messages: messageList,
      );
      print(
        '[SMS Reader] Parsed ${parsedExpenses.length} expenses from messages',
      );

      // Save to temporary storage (only new ones, avoid duplicates)
      await _saveNewParsedExpenses(parsedExpenses);

      return parsedExpenses;
    } catch (e) {
      throw Exception('Failed to read SMS: $e');
    }
  }

  StreamSubscription<SmsMessage>? _smsSubscription;

  /// Start listening for new incoming SMS
  /// Note: This feature may not work on all devices due to Android restrictions
  /// The receiver listener requires the app to be fully rebuilt and may need app restart
  /// The parser will determine if messages are expense-related based on content
  void startListening({
    Function(ParsedExpenseModel)? onNewExpense,
    Function(String)? onError,
  }) {
    if (_isListening) return;

    try {
      final SmsReceiver receiver = SmsReceiver();

      // Try to access the stream - this may fail if plugin isn't registered
      // Wrap in try-catch to handle gracefully
      Stream<SmsMessage>? stream;
      try {
        stream = receiver.onSmsReceived;
      } catch (e) {
        onError?.call(
          'SMS receiver not available. Please restart the app after installing. Error: $e',
        );
        return;
      }

      if (stream == null) {
        onError?.call(
          'SMS receiver stream is not available. This feature may require app restart.',
        );
        return;
      }

      _smsSubscription = stream.listen(
        (SmsMessage message) async {
          try {
            final sender = message.sender ?? '';
            final body = message.body ?? '';
            final dateSent = message.date ?? DateTime.now();

            print('[SMS Reader] New incoming SMS from: $sender');
            print(
              '[SMS Reader] Message: ${body.length > 100 ? body.substring(0, 100) + "..." : body}',
            );

            // Parse the message - parser will determine if it's expense-related
            final parsedExpense = SmsExpenseParser.parseMessage(
              message: body,
              senderNumber: sender,
              messageDate: dateSent,
            );

            if (parsedExpense != null) {
              // Check if already exists (avoid duplicates)
              final existing = _storage.getAllParsedExpenses();
              final isDuplicate = existing.any(
                (e) =>
                    e.amount == parsedExpense.amount &&
                    e.senderNumber == parsedExpense.senderNumber &&
                    e.date.day == parsedExpense.date.day &&
                    e.date.month == parsedExpense.date.month &&
                    e.date.year == parsedExpense.date.year,
              );

              if (!isDuplicate) {
                // Save to temporary storage
                await _storage.saveParsedExpense(parsedExpense);

                // Notify callback
                onNewExpense?.call(parsedExpense);
              }
            }
          } catch (e) {
            onError?.call('Error parsing SMS: $e');
          }
        },
        onError: (error) {
          onError?.call('SMS listener error: $error');
        },
      );

      _isListening = true;
    } catch (e) {
      onError?.call('Failed to start SMS listener: $e');
      _isListening = false;
    }
  }

  /// Stop listening for new SMS
  void stopListening() {
    _smsSubscription?.cancel();
    _smsSubscription = null;
    _isListening = false;
  }

  /// Save new parsed expenses, avoiding duplicates
  Future<void> _saveNewParsedExpenses(
    List<ParsedExpenseModel> newExpenses,
  ) async {
    print('[SMS Reader] Checking for duplicates before saving...');
    final existing = _storage.getAllParsedExpenses();
    print('[SMS Reader] Existing expenses in storage: ${existing.length}');
    final existingIds = existing.map((e) => e.id).toSet();

    // Filter out duplicates based on amount, sender, and date
    final uniqueExpenses = <ParsedExpenseModel>[];
    int duplicateCount = 0;

    for (final expense in newExpenses) {
      // Check if exact duplicate exists
      if (existingIds.contains(expense.id)) {
        print(
          '[SMS Reader] ⏭️ Skipped duplicate (exact ID match): ${expense.title} - Rs ${expense.amount}',
        );
        duplicateCount++;
        continue;
      }

      // Check if similar expense exists (same amount, sender, date)
      final isDuplicate = existing.any(
        (e) =>
            e.amount == expense.amount &&
            e.senderNumber == expense.senderNumber &&
            e.date.day == expense.date.day &&
            e.date.month == expense.date.month &&
            e.date.year == expense.date.year,
      );

      if (isDuplicate) {
        print(
          '[SMS Reader] ⏭️ Skipped duplicate (similar expense): ${expense.title} - Rs ${expense.amount} on ${expense.date}',
        );
        duplicateCount++;
      } else {
        print(
          '[SMS Reader] ✓ New expense: ${expense.title} - Rs ${expense.amount}',
        );
        uniqueExpenses.add(expense);
      }
    }

    print('[SMS Reader] Saving summary:');
    print('[SMS Reader]   - New expenses: ${newExpenses.length}');
    print('[SMS Reader]   - Duplicates: $duplicateCount');
    print('[SMS Reader]   - Unique to save: ${uniqueExpenses.length}');

    if (uniqueExpenses.isNotEmpty) {
      await _storage.saveParsedExpenses(uniqueExpenses);
      print(
        '[SMS Reader] ✓ Saved ${uniqueExpenses.length} new expenses to storage',
      );
    } else {
      print('[SMS Reader] ⚠️ No new expenses to save (all were duplicates)');
    }
  }
}
