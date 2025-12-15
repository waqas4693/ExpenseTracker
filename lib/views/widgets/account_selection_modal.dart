import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AccountSelectionModal extends StatelessWidget {
  final String selectedAccount;
  final Function(String) onAccountSelected;

  const AccountSelectionModal({
    super.key,
    required this.selectedAccount,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Select Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),
          const Divider(height: 1),
          // Accounts List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: AppConstants.defaultAccounts.length,
              itemBuilder: (context, index) {
                final account = AppConstants.defaultAccounts[index];
                final isSelected = account == selectedAccount;
                return _buildAccountItem(
                  account: account,
                  isSelected: isSelected,
                  onTap: () {
                    onAccountSelected(account);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem({
    required String account,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getAccountIcon(account),
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                account,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A1A)),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 24),
          ],
        ),
      ),
    );
  }

  IconData _getAccountIcon(String account) {
    switch (account.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'meezan bank':
        return Icons.credit_card;
      default:
        return Icons.account_balance;
    }
  }
}
