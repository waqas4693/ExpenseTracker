import 'package:get/get.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/sign_in_screen.dart';
import '../views/screens/sign_up_screen.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/all_expenses_screen.dart';
import '../views/screens/sms_expenses_screen.dart';
import '../views/screens/settings_screen.dart';
import '../views/screens/add_expense_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/';
  static const String allExpenses = '/all-expenses';
  static const String smsExpenses = '/sms-expenses';
  static const String settings = '/settings';
  static const String addExpense = '/add-expense';

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: signIn, page: () => const SignInScreen()),
    GetPage(name: signUp, page: () => const SignUpScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: allExpenses, page: () => const AllExpensesScreen()),
    GetPage(name: smsExpenses, page: () => const SmsExpensesScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(name: addExpense, page: () => const AddExpenseScreen()),
  ];
}
