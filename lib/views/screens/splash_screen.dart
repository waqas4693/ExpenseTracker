import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/config/app_config.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for splash duration
    await Future.delayed(AppConfig.splashDuration);

    // Check authentication status
    final authController = Get.find<AuthController>();

    if (!mounted) return;

    if (authController.isAuthenticated.value) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.splashBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and App Name
              const AppLogo(size: 100, spacing: 24),
            ],
          ),
        ),
      ),
    );
  }
}
