import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CategorySelectionModal extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelectionModal({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                    'Select Category',
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
          // Categories Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.9,
                ),
                itemCount: AppConstants.defaultCategories.length,
                itemBuilder: (context, index) {
                  final category = AppConstants.defaultCategories[index];
                  final isSelected = category == selectedCategory;
                  return _buildCategoryItem(
                    context: context,
                    category: category,
                    isSelected: isSelected,
                    onTap: () {
                      onCategorySelected(category);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected
                  ? _getCategoryColor(category).withOpacity(0.2)
                  : Colors.grey[100],
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: _getCategoryColor(category), width: 2)
                  : null,
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: isSelected
                  ? _getCategoryColor(category)
                  : Colors.grey[600],
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? _getCategoryColor(category)
                  : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'housing':
        return Icons.home;
      case 'transportation':
        return Icons.directions_car;
      case 'bills':
        return Icons.phone_android;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'healthcare':
        return Icons.local_hospital;
      case 'travel':
        return Icons.flight;
      case 'personal':
        return Icons.person;
      case 'finance':
        return Icons.account_balance_wallet;
      case 'donations':
        return Icons.volunteer_activism;
      case 'other':
        return Icons.push_pin;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'housing':
        return Colors.blue;
      case 'transportation':
        return Colors.red;
      case 'bills':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'shopping':
        return Colors.green;
      case 'healthcare':
        return Colors.red;
      case 'travel':
        return Colors.blue;
      case 'personal':
        return Colors.indigo;
      case 'finance':
        return Colors.amber;
      case 'donations':
        return Colors.teal;
      case 'other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
