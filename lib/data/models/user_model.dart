class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final UserSettings settings;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'settings': settings.toJson(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      settings: UserSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class UserSettings {
  final String country;
  final String currency;
  final bool budgetAlerts;
  final double monthlyBudget;

  UserSettings({
    required this.country,
    required this.currency,
    required this.budgetAlerts,
    required this.monthlyBudget,
  });

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'currency': currency,
      'budgetAlerts': budgetAlerts,
      'monthlyBudget': monthlyBudget,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      country: json['country'] as String? ?? 'Pakistan',
      currency: json['currency'] as String? ?? 'PKR',
      budgetAlerts: json['budgetAlerts'] as bool? ?? false,
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
