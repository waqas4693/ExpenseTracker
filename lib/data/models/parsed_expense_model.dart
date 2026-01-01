class ParsedExpenseModel {
  final String id;
  final String originalMessage;
  final String senderNumber;
  final double amount;
  final String? merchant;
  final String title;
  final String category;
  final DateTime date;
  final String? description;
  final String account;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime parsedAt;

  ParsedExpenseModel({
    required this.id,
    required this.originalMessage,
    required this.senderNumber,
    required this.amount,
    this.merchant,
    required this.title,
    required this.category,
    required this.date,
    this.description,
    this.account = 'Cash',
    this.status = 'pending',
    required this.parsedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalMessage': originalMessage,
      'senderNumber': senderNumber,
      'amount': amount,
      'merchant': merchant,
      'title': title,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'account': account,
      'status': status,
      'parsedAt': parsedAt.toIso8601String(),
    };
  }

  factory ParsedExpenseModel.fromJson(Map<String, dynamic> json) {
    return ParsedExpenseModel(
      id: json['id'] as String,
      originalMessage: json['originalMessage'] as String,
      senderNumber: json['senderNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      merchant: json['merchant'] as String?,
      title: json['title'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      account: json['account'] as String? ?? 'Cash',
      status: json['status'] as String? ?? 'pending',
      parsedAt: DateTime.parse(json['parsedAt'] as String),
    );
  }

  ParsedExpenseModel copyWith({
    String? id,
    String? originalMessage,
    String? senderNumber,
    double? amount,
    String? merchant,
    String? title,
    String? category,
    DateTime? date,
    String? description,
    String? account,
    String? status,
    DateTime? parsedAt,
  }) {
    return ParsedExpenseModel(
      id: id ?? this.id,
      originalMessage: originalMessage ?? this.originalMessage,
      senderNumber: senderNumber ?? this.senderNumber,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      account: account ?? this.account,
      status: status ?? this.status,
      parsedAt: parsedAt ?? this.parsedAt,
    );
  }
}

