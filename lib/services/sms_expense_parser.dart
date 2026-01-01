import 'package:uuid/uuid.dart';
import '../data/models/parsed_expense_model.dart';

class SmsExpenseParser {
  static const _uuid = Uuid();

  // Pattern for amount extraction (supports Rs, ₹, PKR, USD, $, etc.)
  static final RegExp _amountPattern = RegExp(
    r'(?:Rs\.?|₹|PKR|USD|\$|INR)\s*([\d,]+\.?\d*)',
    caseSensitive: false,
  );

  // Keywords that indicate payment/debit
  static final List<String> _paymentKeywords = [
    'debited',
    'spent',
    'paid',
    'payment',
    'purchase',
    'transaction',
    'withdrawal',
    'charged',
    'deducted',
    'withdrawn',
  ];

  // Keywords that indicate credit (to ignore)
  static final List<String> _creditKeywords = [
    'credited',
    'received',
    'deposit',
    'refund',
    'added',
    'balance',
  ];

  // Merchant name patterns - looks for "at MERCHANT", "to MERCHANT", "from MERCHANT", etc.
  static final RegExp _merchantPattern = RegExp(
    r'(?:at|to|from|via|through)\s+([A-Z][A-Z\s&0-9\-]+)',
    caseSensitive: false,
  );

  // Alternative merchant pattern for "Payment to MERCHANT"
  static final RegExp _merchantPattern2 = RegExp(
    r'(?:payment|purchase|transaction)\s+(?:to|at|from)\s+([A-Z][A-Z\s&0-9\-]+)',
    caseSensitive: false,
  );

  // Pattern to extract account number or last 4 digits
  static final RegExp _accountPattern = RegExp(
    r'(?:account|acc|card)\s*(?:no|number|#)?\s*:?\s*[\*\s]*(\d{4,})',
    caseSensitive: false,
  );

  /// Parses an SMS message to extract expense information
  /// Returns null if the message is not a payment message
  static ParsedExpenseModel? parseMessage({
    required String message,
    required String senderNumber,
    required DateTime messageDate,
  }) {
    print('[SMS Parser] ========================================');
    print('[SMS Parser] Parsing message from: $senderNumber');
    print('[SMS Parser] Message: ${message.length > 150 ? message.substring(0, 150) + "..." : message}');
    
    final lowerMessage = message.toLowerCase();

    // 1. Check if message contains payment keywords
    final hasPaymentKeyword = _paymentKeywords.any(
      (keyword) => lowerMessage.contains(keyword),
    );
    final hasCreditKeyword = _creditKeywords.any(
      (keyword) => lowerMessage.contains(keyword),
    );

    print('[SMS Parser] Has payment keyword: $hasPaymentKeyword');
    print('[SMS Parser] Has credit keyword: $hasCreditKeyword');
    if (hasPaymentKeyword) {
      final foundKeywords = _paymentKeywords.where((k) => lowerMessage.contains(k)).toList();
      print('[SMS Parser] Found payment keywords: ${foundKeywords.join(", ")}');
    }
    if (hasCreditKeyword) {
      final foundKeywords = _creditKeywords.where((k) => lowerMessage.contains(k)).toList();
      print('[SMS Parser] Found credit keywords: ${foundKeywords.join(", ")}');
    }

    // Skip if it's a credit message or doesn't have payment keywords
    if (!hasPaymentKeyword) {
      print('[SMS Parser] ❌ REJECTED: No payment keywords found');
      return null;
    }
    if (hasCreditKeyword) {
      print('[SMS Parser] ❌ REJECTED: Contains credit keywords (ignoring credits)');
      return null;
    }

    // 2. Extract amount
    print('[SMS Parser] Extracting amount...');
    final amountMatch = _amountPattern.firstMatch(message);
    if (amountMatch == null) {
      print('[SMS Parser] ❌ REJECTED: No amount found in message');
      print('[SMS Parser] Amount pattern: Rs, ₹, PKR, USD, \$, INR followed by numbers');
      return null;
    }

    final amountStr = amountMatch.group(1)?.replaceAll(',', '') ?? '';
    print('[SMS Parser] Amount string extracted: "$amountStr"');
    final amount = double.tryParse(amountStr);
    if (amount == null) {
      print('[SMS Parser] ❌ REJECTED: Could not parse amount "$amountStr" as number');
      return null;
    }
    if (amount <= 0) {
      print('[SMS Parser] ❌ REJECTED: Amount is zero or negative: $amount');
      return null;
    }
    print('[SMS Parser] ✓ Amount extracted: $amount');

    // 3. Extract merchant/description
    print('[SMS Parser] Extracting merchant...');
    String? merchant;
    final merchantMatch = _merchantPattern.firstMatch(message) ??
        _merchantPattern2.firstMatch(message);
    if (merchantMatch != null) {
      merchant = merchantMatch.group(1)?.trim();
      // Clean up merchant name (remove extra spaces, common suffixes)
      if (merchant != null) {
        merchant = merchant
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(RegExp(r'\s+(?:LTD|LIMITED|PVT|PRIVATE)$', caseSensitive: false), '')
            .trim();
        print('[SMS Parser] ✓ Merchant extracted: $merchant');
      }
    } else {
      print('[SMS Parser] No merchant found in message');
    }

    // 4. Extract account information
    print('[SMS Parser] Extracting account...');
    String account = 'Cash';
    final accountMatch = _accountPattern.firstMatch(message);
    if (accountMatch != null) {
      final accountDigits = accountMatch.group(1);
      if (accountDigits != null && accountDigits.length >= 4) {
        // Use last 4 digits to identify account
        account = '****${accountDigits.substring(accountDigits.length - 4)}';
        print('[SMS Parser] ✓ Account extracted: $account');
      }
    } else {
      // Try to infer account from sender number or message
      account = _inferAccountFromSender(senderNumber, message);
      print('[SMS Parser] Account inferred: $account');
    }

    // 5. Map to category (smart categorization)
    final category = _categorizeExpense(message, merchant);
    print('[SMS Parser] Category assigned: $category');

    // 6. Create title
    final title = merchant ?? _generateTitleFromMessage(message, amount);
    print('[SMS Parser] Title: $title');

    print('[SMS Parser] ✓ SUCCESS: Parsed expense - $title, Rs $amount, Category: $category');
    print('[SMS Parser] ========================================');

    return ParsedExpenseModel(
      id: _uuid.v4(),
      originalMessage: message,
      senderNumber: senderNumber,
      amount: amount,
      merchant: merchant,
      title: title,
      category: category,
      date: messageDate,
      description: message, // Store full message as description
      account: account,
      status: 'pending',
      parsedAt: DateTime.now(),
    );
  }

  /// Infers account name from sender number or message content
  static String _inferAccountFromSender(String senderNumber, String message) {
    final lowerMessage = message.toLowerCase();
    final lowerSender = senderNumber.toLowerCase();

    // Check for bank names in message or sender
    if (lowerMessage.contains('meezan') || lowerSender.contains('meezan')) {
      return 'Meezan Bank';
    }
    if (lowerMessage.contains('hbl') || lowerSender.contains('hbl')) {
      return 'HBL';
    }
    if (lowerMessage.contains('ubl') || lowerSender.contains('ubl')) {
      return 'UBL';
    }
    if (lowerMessage.contains('allied') || lowerSender.contains('allied')) {
      return 'Allied Bank';
    }
    if (lowerMessage.contains('bank') || lowerSender.contains('bank')) {
      return 'Bank Account';
    }

    return 'Cash';
  }

  /// Generates a title from message if merchant is not found
  static String _generateTitleFromMessage(String message, double amount) {
    // Try to extract meaningful title
    final lines = message.split('\n');
    if (lines.isNotEmpty) {
      final firstLine = lines[0].trim();
      if (firstLine.isNotEmpty && firstLine.length < 50) {
        return firstLine;
      }
    }
    return 'Payment of ${amount.toStringAsFixed(0)}';
  }

  /// Categorizes expense based on message content and merchant
  static String _categorizeExpense(String message, String? merchant) {
    final lowerMessage = message.toLowerCase();
    final lowerMerchant = merchant?.toLowerCase() ?? '';

    // Food & Dining
    if (lowerMessage.contains('food') ||
        lowerMessage.contains('restaurant') ||
        lowerMessage.contains('cafe') ||
        lowerMessage.contains('pizza') ||
        lowerMessage.contains('burger') ||
        lowerMessage.contains('mcdonalds') ||
        lowerMessage.contains('kfc') ||
        lowerMessage.contains('subway') ||
        lowerMessage.contains('dominos') ||
        lowerMerchant.contains('restaurant') ||
        lowerMerchant.contains('cafe')) {
      return 'Food';
    }

    // Transportation
    if (lowerMessage.contains('fuel') ||
        lowerMessage.contains('petrol') ||
        lowerMessage.contains('gas') ||
        lowerMessage.contains('uber') ||
        lowerMessage.contains('careem') ||
        lowerMessage.contains('taxi') ||
        lowerMessage.contains('transport') ||
        lowerMerchant.contains('petrol') ||
        lowerMerchant.contains('fuel')) {
      return 'Transportation';
    }

    // Bills & Utilities
    if (lowerMessage.contains('bill') ||
        lowerMessage.contains('utility') ||
        lowerMessage.contains('electricity') ||
        lowerMessage.contains('water') ||
        lowerMessage.contains('gas bill') ||
        lowerMessage.contains('internet') ||
        lowerMessage.contains('phone bill') ||
        lowerMessage.contains('ptcl') ||
        lowerMessage.contains('jazz') ||
        lowerMessage.contains('ufone') ||
        lowerMessage.contains('telenor')) {
      return 'Bills';
    }

    // Shopping
    if (lowerMessage.contains('shopping') ||
        lowerMessage.contains('mall') ||
        lowerMessage.contains('store') ||
        lowerMessage.contains('market') ||
        lowerMessage.contains('amazon') ||
        lowerMessage.contains('daraz') ||
        lowerMerchant.contains('shop') ||
        lowerMerchant.contains('store')) {
      return 'Shopping';
    }

    // Healthcare
    if (lowerMessage.contains('hospital') ||
        lowerMessage.contains('clinic') ||
        lowerMessage.contains('pharmacy') ||
        lowerMessage.contains('medicine') ||
        lowerMessage.contains('doctor') ||
        lowerMerchant.contains('hospital') ||
        lowerMerchant.contains('pharmacy')) {
      return 'Healthcare';
    }

    // Entertainment
    if (lowerMessage.contains('cinema') ||
        lowerMessage.contains('movie') ||
        lowerMessage.contains('netflix') ||
        lowerMessage.contains('entertainment') ||
        lowerMessage.contains('game')) {
      return 'Entertainment';
    }

    // Travel
    if (lowerMessage.contains('travel') ||
        lowerMessage.contains('hotel') ||
        lowerMessage.contains('flight') ||
        lowerMessage.contains('airline') ||
        lowerMessage.contains('booking')) {
      return 'Travel';
    }

    // Finance (bank charges, etc.)
    if (lowerMessage.contains('charge') ||
        lowerMessage.contains('fee') ||
        lowerMessage.contains('commission') ||
        lowerMessage.contains('interest')) {
      return 'Finance';
    }

    // Default category
    return 'Other';
  }

  /// Parses multiple messages and returns list of parsed expenses
  static List<ParsedExpenseModel> parseMessages({
    required List<Map<String, dynamic>> messages,
  }) {
    print('[SMS Parser] ========================================');
    print('[SMS Parser] Starting to parse ${messages.length} messages');
    print('[SMS Parser] ========================================');
    
    final List<ParsedExpenseModel> parsedExpenses = [];
    int skippedEmpty = 0;
    int rejectedCount = 0;

    for (int i = 0; i < messages.length; i++) {
      final messageData = messages[i];
      print('[SMS Parser] --- Message ${i + 1}/${messages.length} ---');
      
      final message = messageData['body'] as String? ?? messageData['message'] as String? ?? '';
      final sender = messageData['address'] as String? ?? messageData['sender'] as String? ?? '';
      final date = messageData['date'] as DateTime? ??
          (messageData['dateSent'] != null
              ? DateTime.fromMillisecondsSinceEpoch(messageData['dateSent'] as int)
              : DateTime.now());

      if (message.isEmpty || sender.isEmpty) {
        print('[SMS Parser] ⏭️ Skipped: Empty message or sender');
        skippedEmpty++;
        continue;
      }

      final parsed = parseMessage(
        message: message,
        senderNumber: sender,
        messageDate: date,
      );

      if (parsed != null) {
        parsedExpenses.add(parsed);
        print('[SMS Parser] ✓ Added to parsed expenses list');
      } else {
        rejectedCount++;
        print('[SMS Parser] ❌ Message was rejected by parser');
      }
    }

    print('[SMS Parser] ========================================');
    print('[SMS Parser] Parsing Summary:');
    print('[SMS Parser]   - Total messages: ${messages.length}');
    print('[SMS Parser]   - Skipped (empty): $skippedEmpty');
    print('[SMS Parser]   - Rejected: $rejectedCount');
    print('[SMS Parser]   - Successfully parsed: ${parsedExpenses.length}');
    print('[SMS Parser] ========================================');

    return parsedExpenses;
  }
}

