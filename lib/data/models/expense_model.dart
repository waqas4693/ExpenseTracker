class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final String account;
  final String source;
  final String status;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.account = 'Cash',
    this.source = 'manual',
    this.status = 'approved',
  });

  Map<String, dynamic> toJson({bool includeId = false}) {
    final json = {
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'account': account,
      'source': source,
      'status': status,
    };
    if (includeId) {
      json['id'] = id;
    }
    return json;
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String? ?? json['_id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      account: json['account'] as String? ?? 'Cash',
      source: json['source'] as String? ?? 'manual',
      status: json['status'] as String? ?? 'approved',
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    String? account,
    String? source,
    String? status,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      account: account ?? this.account,
      source: source ?? this.source,
      status: status ?? this.status,
    );
  }
}
