class AppConstants {
  // Storage Keys
  static const String expensesKey = 'expenses';
  static const String categoriesKey = 'categories';
  static const String themeKey = 'theme_mode';
  static const String parsedExpensesKey = 'parsed_expenses'; // Temporary SMS expenses

  // Expense Categories
  static const List<String> defaultCategories = [
    'Food',
    'Housing',
    'Transportation',
    'Bills',
    'Entertainment',
    'Shopping',
    'Healthcare',
    'Travel',
    'Personal',
    'Finance',
    'Donations',
    'Other',
  ];

  // Account Types
  static const List<String> defaultAccounts = ['Cash', 'Meezan Bank'];

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
}
