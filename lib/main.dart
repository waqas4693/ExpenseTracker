import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'controllers/sms_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/expense_controller.dart';
import 'controllers/navigation_controller.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(AuthController());
  Get.put(ExpenseController(), permanent: true);
  Get.put(SmsController(), permanent: true); // Initialize SMS controller
  Get.put(
    NavigationController(),
    permanent: true,
  ); // Initialize Navigation controller

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appDisplayName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
