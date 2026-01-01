import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/config/app_config.dart';
import '../../routes/app_routes.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final NavigationController _navController;
  final AuthController _authController = Get.find<AuthController>();
  bool _fingerprintLogin = false;
  bool _budgetAlerts = true;
  String _country = 'Pakistan';
  String _currency = 'PKR';
  int _selectedBanks = 1;

  @override
  void initState() {
    super.initState();
    _navController = Get.find<NavigationController>();
    _navController.setNavItem(NavItem.settings);
  }

  Future<bool> _onWillPop() async {
    Get.offNamed(AppRoutes.home);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser.value;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppConfig.surfaceColor,
        appBar: AppBar(
        backgroundColor: AppConfig.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConfig.textPrimaryColor),
          onPressed: () => Get.offNamed(AppRoutes.home),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppConfig.textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppConfig.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Profile Picture
                        Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppConfig.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  (user?.name != null && user!.name.isNotEmpty)
                                      ? user.name.substring(0, 1).toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppConfig.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppConfig.backgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.email ?? 'user@example.com',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppConfig.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to profile settings
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 18,
                                      color: AppConfig.textSecondaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Profile Settings',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppConfig.textPrimaryColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppConfig.textSecondaryColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Expense Settings Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppConfig.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expense Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Automated Receipt Tracking Button
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to automated receipt tracking
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppConfig.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppConfig.textPrimaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '@',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Automated receipt tracking',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Forward receipt emails to automatically add expenses to your account.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Fingerprint Login
                        _buildSettingItem(
                          icon: Icons.fingerprint,
                          title: 'Fingerprint Login',
                          trailing: Switch(
                            value: _fingerprintLogin,
                            onChanged: (value) {
                              setState(() {
                                _fingerprintLogin = value;
                              });
                            },
                            activeColor: AppConfig.primaryColor,
                          ),
                        ),
                        const Divider(height: 32),
                        // Country
                        _buildSettingItem(
                          icon: Icons.public,
                          title: 'Country',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _country,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppConfig.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppConfig.textSecondaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () {
                            _showCountryPicker();
                          },
                        ),
                        const Divider(height: 32),
                        // Currency
                        _buildSettingItem(
                          icon: Icons.attach_money,
                          title: 'Currency',
                          trailing: Text(
                            _currency,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConfig.textPrimaryColor,
                            ),
                          ),
                        ),
                        const Divider(height: 32),
                        // Select your banks
                        _buildSettingItem(
                          icon: Icons.account_balance,
                          title: 'Select your banks',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_selectedBanks selected',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppConfig.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppConfig.textSecondaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: Navigate to bank selection
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // General Settings Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppConfig.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'General Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Country
                        _buildSettingItem(
                          icon: Icons.public,
                          title: 'Country',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _country,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppConfig.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppConfig.textSecondaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () {
                            _showCountryPicker();
                          },
                        ),
                        const Divider(height: 32),
                        // Currency
                        _buildSettingItem(
                          icon: Icons.attach_money,
                          title: 'Currency',
                          trailing: Text(
                            _currency,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConfig.textPrimaryColor,
                            ),
                          ),
                        ),
                        const Divider(height: 32),
                        // Select your banks
                        _buildSettingItem(
                          icon: Icons.account_balance,
                          title: 'Select your banks',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_selectedBanks selected',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppConfig.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppConfig.textSecondaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: Navigate to bank selection
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Support Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppConfig.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingItem(
                          icon: Icons.download,
                          title: 'Import Expenses',
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppConfig.textSecondaryColor,
                            size: 20,
                          ),
                          onTap: () {
                            // TODO: Navigate to import expenses
                          },
                        ),
                        const Divider(height: 32),
                        _buildSettingItem(
                          icon: Icons.chat_bubble_outline,
                          title: 'Support & Feedback',
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppConfig.textSecondaryColor,
                            size: 20,
                          ),
                          onTap: () {
                            // TODO: Navigate to support
                          },
                        ),
                        const Divider(height: 32),
                        _buildSettingItem(
                          icon: Icons.refresh,
                          title: 'Check for Updates',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'v1.1.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppConfig.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: AppConfig.textSecondaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: Check for updates
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Budget Settings Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppConfig.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Budget Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingItem(
                          icon: Icons.account_balance_wallet,
                          title: 'Monthly Budget',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Not set',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppConfig.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: AppConfig.textSecondaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: Navigate to set budget
                          },
                        ),
                        const Divider(height: 32),
                        _buildSettingItem(
                          icon: Icons.notifications,
                          title: 'Budget Alerts',
                          trailing: Switch(
                            value: _budgetAlerts,
                            onChanged: (value) {
                              setState(() {
                                _budgetAlerts = value;
                              });
                            },
                            activeColor: AppConfig.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Log Out Button
                  GestureDetector(
                    onTap: () {
                      _showLogoutDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConfig.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppConfig.errorColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppConfig.errorColor,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: AppConfig.errorColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar
          const CustomBottomNavBar(),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppConfig.textSecondaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppConfig.textPrimaryColor,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConfig.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Country',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConfig.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text(
                'Pakistan',
                style: TextStyle(color: AppConfig.textPrimaryColor),
              ),
              onTap: () {
                setState(() {
                  _country = 'Pakistan';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'United States',
                style: TextStyle(color: AppConfig.textPrimaryColor),
              ),
              onTap: () {
                setState(() {
                  _country = 'United States';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'United Kingdom',
                style: TextStyle(color: AppConfig.textPrimaryColor),
              ),
              onTap: () {
                setState(() {
                  _country = 'United Kingdom';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConfig.backgroundColor,
        title: const Text(
          'Log Out',
          style: TextStyle(color: AppConfig.textPrimaryColor),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppConfig.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppConfig.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _authController.signOut();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
